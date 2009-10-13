package com.animoto.filmstrip.managers
{
	import com.animoto.filmstrip.FilmStripBlurMode;
	import com.animoto.filmstrip.MotionBlurSettings;
	import com.animoto.filmstrip.PulseControl;
	import com.mosesSupposes.util.SelectiveDrawBase;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.filters.BitmapFilter;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * Processes and captures a primary frame and a set of subframes.
	 * 
	 * @author moses gunesch
	 */
	public class MotionBlurController extends MotionBlurSettings
	{
		public var container:Sprite;
		public var target: Object;
		public var whitelist: Array;
		public var deltaMgr: DeltaManager;
		public var subframes: int;
		
		protected var controller: FilmStripSceneController;
		protected var drawUtil: SelectiveDrawBase;
		protected var buffer: Timer;
		protected var index: int;
		protected var delay: int;
		protected var primaryOnly: Boolean = false;
		protected var wholeScene: Boolean = false;
		protected var clipMatrix: Matrix;
		protected var busy: Boolean = false;
		
		public function MotionBlurController(controller:FilmStripSceneController, target:Object, wholeScene:Boolean)
		{
			this.controller = controller;
			this.target = target;
			this.wholeScene = wholeScene;
			deltaMgr = new DeltaManager(target);
			delay = controller.filmStrip.subframeBufferMilliseconds;
			if (delay > 0) {
				buffer = new Timer(delay, 1);
				buffer.addEventListener(TimerEvent.TIMER_COMPLETE, nextSubFrame);
			}
			if (controller.filmStrip.blurMode == FilmStripBlurMode.NONE) {
				primaryOnly = true;
			}
			else if (controller.scene.blurExceptions.indexOf(target) > -1) {
				primaryOnly = true;
			}
			
			// Correct static settings.
			strength = Math.max(0, strength);
			threshold = Math.max(1, threshold);
			maxFrames = Math.max(1, maxFrames);
			subframeDuration = Math.max(0.01, subframeDuration);
			peakAlpha = Math.min(1, Math.max(0, peakAlpha));
			offset = (offset > 0 ? 1 : -1); // For now.
		}
		
		public function render():void {
			busy = true;
			// subframes are precalculated by controller.
			index = 0;
			newContainer();
			
			if (!whitelist) {
				// Target whitelisting improves performance by only animating the targets being rendered.
				// The whitelist is global, assuming there's not going to be multiple filmstrips operating at once on the same object.
				whitelist = controller.scene.getDisplayChain(target);
				if (!whitelist) { // fallback
					whitelist = [ target ];
				}
			}
			PulseControl.whitelist(whitelist);
			PulseControl.whitelist(controller.scene.getPerpectiveObject());
			
			PulseControl.setTime(controller.currentTime);
			capturePrimaryFrame();
			if (primaryOnly || subframes==0) {
				complete();
			}
			else if (delay > 0) {
				buffer.reset();
				buffer.start();
			}
			else {
				nextSubFrame();
			}
		}
		
		protected function nextSubFrame(e:TimerEvent=null):void {
			if (controller==null) {
				return;
			}
			index++;
			var time:int = controller.currentTime + (subframeDuration * index * offset);
			if (index > subframes || time < 0) {
				complete();
				return;
			}
			
			// Update animation and capture subframe.
			if (cameraBlurPercent!=1) { // otherwise, full camera blur so we leave the camera in the whitelist.
				if (cameraBlurPercent==0) { // no camera blur - unwhitelist for all subframes.
					PulseControl.unwhitelist(controller.scene.getPerpectiveObject());
				}
				else { // adjusted camera blur
					var camTime:int = Math.round(controller.currentTime + (subframeDuration * cameraBlurPercent * index * offset));
					if (camTime==time) { // adjustment ended in full camera blur for this subframe anyway
						PulseControl.whitelist(controller.scene.getPerpectiveObject());
					}
					else { // value is adjusted - animate camera separately then restore whitelist (slower)
						PulseControl.unwhitelist(whitelist);
						PulseControl.whitelist(controller.scene.getPerpectiveObject());
						PulseControl.setTime(camTime);
						PulseControl.unwhitelist(controller.scene.getPerpectiveObject());
						PulseControl.whitelist(whitelist);
					}
				}
			}
			PulseControl.setTime(time);
			captureSubframe();
			controller.subframeComplete(this, index, false);
			
			if (delay > 0) {
				buffer.reset();
				buffer.start();
			}
			else {
				nextSubFrame();
			}
		}
		
		public function destroy():void {
			if (busy && whitelist) {
				PulseControl.unwhitelist(whitelist);
			}
			busy = false;
			controller = null;
			target = null;
			whitelist = null;
			deltaMgr = null;
			if (buffer!=null) {
				buffer.reset();
				buffer.removeEventListener(TimerEvent.TIMER_COMPLETE, nextSubFrame);
				buffer = null;
			}
			if (drawUtil!=null) {
				drawUtil.manualPostDraw(false); // safety, restores scene
				drawUtil.destroy();
				drawUtil = null;
			}
		}
		
		protected function currentAlpha():Number {
			return Math.max(0.05, peakAlpha - (peakAlpha/subframes) * index);
		}
		
		protected function currentBoxBlur():BlurFilter {
			var boxamt:Number = (Math.min(index * boxBlurMultiplier + boxBlurRange.x, boxBlurRange.y));
			return new BlurFilter(boxamt, boxamt, 1);
		}
		
		protected function capturePrimaryFrame():void {
			refreshDrawUtil();
			if (wholeScene) {
				controller.scene.redrawScene();
			}
			else {
				var redrew:Boolean = drawUtil.manualPreDraw([target]); // Toggles other objects' visibility off temporarily and rerenders 3d scene. Restored in complete().
				if (!redrew)
					controller.scene.redrawScene();
			}
			if (!clipMatrix) {
				clipMatrix = new Matrix();
				clipMatrix.translate(-controller.filmStrip.left, -controller.filmStrip.top);
				var offset:Point = drawUtil.getOffset();
				if (offset) {
					clipMatrix.translate(offset.x, offset.y);
				}
				clipMatrix.scale(controller.filmStrip.scale, controller.filmStrip.scale);
			}
			drawUtil.bitmapData.draw(drawUtil.drawSource, clipMatrix);
			var bitmap:Bitmap = new Bitmap(drawUtil.bitmapData);
			var filters:Array = controller.scene.getFilters(target, false);
			if (filters!=null) {
				bitmap.filters = filters;
			}
			container.addChild(bitmap);
		}
		
		protected function captureSubframe():void {
			drawUtil.updateBeforeDraw();
			
			var ct:ColorTransform = new ColorTransform(1, 1, 1, currentAlpha());
			var filters:Array = controller.scene.getFilters(target, true);
			
			var bd:BitmapData = newBitmapData();
			bd.draw(drawUtil.drawSource, clipMatrix);
			if (filters==null) {
				filters = [];
			}
			else {
				filters = filters.slice();
			}
			if (applyBoxBlur) {
				filters.push(currentBoxBlur());
			}
			var p:Point = new Point(0,0);
			for each (var filter:BitmapFilter in filters) {
				bd.applyFilter(bd, drawUtil.bitmapData.rect, p, filter);
			}
			drawUtil.bitmapData.draw(bd, null, ct, blendMode);
		}
		
		protected function complete():void {
			if (whitelist) {
				PulseControl.unwhitelist(whitelist);
			}
			drawUtil.manualPostDraw(false); // Restores scene
			busy = false;
			controller.subframeComplete(this, index, true);
		}
		
		protected function newContainer():void {
			container = new Sprite();
			container.name = getQualifiedClassName(target).split("::")[1];
			if (target.hasOwnProperty("name")) {
				container.name += " ('"+ target.name + "')";
			}
		}
		
		protected function refreshDrawUtil():void {
			if (drawUtil==null) {
				drawUtil = controller.scene.getSelectiveDrawUtil(newBitmapData());
			}
			else {
				drawUtil.bitmapData = newBitmapData();
			}
		}
		
		protected function newBitmapData():BitmapData {
			return new BitmapData(controller.filmStrip.width, controller.filmStrip.height, true, 0x0);
		}
	}
}