package com.animoto.filmstrip
{
	import com.mosesSupposes.util.SelectiveDrawBase;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.filters.BlurFilter;
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
		public var deltaMgr: DeltaManager;
		public var subframes: int;
		
		protected var controller: FilmStripSceneController;
		protected var drawUtil: SelectiveDrawBase;
		protected var buffer: Timer;
		protected var index: int;
		protected var delay: int;
		protected var primaryOnly: Boolean = false;
		protected var wholeScene: Boolean = false;
		
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
			
			// Correct static settings.
			threshold = Math.max(1, threshold);
			subframeDuration = Math.max(1, subframeDuration);
			peakAlpha = Math.min(1, Math.max(0, peakAlpha));
			maxFrames = Math.max(1, maxFrames);
			offset = (offset > 0 ? 1 : -1); // For now.
		}
		
		public function render():void {
			// subframes are precalculated by controller.
			index = 0;
			newContainer();
			PulseControl.setTime(controller.currentTime);
			capturePrimaryFrame();
			if (primaryOnly || subframes==0) {
				complete();
			}
			else {
				nextSubFrame();
			}
		}
		
		protected function nextSubFrame(e:TimerEvent=null):void {
			if (controller==null) {
				return;
			}
			var time:int = controller.currentTime + (subframeDuration * index * offset);
			if (++index > subframes || time < 0) {
				complete();
				return;
			}
			
			// Update animation and capture subframe.
			PulseControl.setTime(controller.currentTime + (subframeDuration * index * offset));
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
			controller = null;
			target = null;
			deltaMgr = null;
			if (buffer!=null) {
				buffer.reset();
				buffer.removeEventListener(TimerEvent.TIMER_COMPLETE, nextSubFrame);
				buffer = null;
			}
			if (drawUtil!=null) {
				drawUtil.manualPostDraw(false); // safety, releases references without rerendering 3d scene
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
				drawUtil.manualPreDraw([target]); // Toggles other objects' visibility off temporarily and rerenders 3d scene. Restored in complete().
			}
			drawUtil.bitmapData.draw(drawUtil.drawSource);
			var bitmap:Bitmap = new Bitmap(drawUtil.bitmapData);
			var filters:Array = controller.scene.getFilters(target);
			if (filters!=null) {
				bitmap.filters = filters;
			}
			container.addChild(bitmap);
		}
		
		protected function captureSubframe():void {
			controller.scene.redrawScene();
			refreshDrawUtil();
			drawUtil.bitmapData.draw(drawUtil.drawSource);
			
			var bitmap:Bitmap = new Bitmap(drawUtil.bitmapData);
			bitmap.blendMode = blendMode;
			bitmap.alpha = currentAlpha();
			
			if (applyBoxBlur) {
				var boxblur:BlurFilter = currentBoxBlur();
				bitmap.filters = [ boxblur ];
				if (index==1) { // retroactively box-blur primary frame on first subframe
					(container.getChildAt(0) as Bitmap).filters = [ boxblur ];
				}
			}
			var filters:Array = controller.scene.getFilters(target);
			if (filters!=null) {
				bitmap.filters = filters.concat(bitmap.filters);
			}
			
			container.addChild(bitmap);
			drawUtil.bitmapData = null;
		}
		
		protected function complete():void {
			drawUtil.manualPostDraw(); // Passing false to avoid rerendering the scene, which isn't necessary here
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