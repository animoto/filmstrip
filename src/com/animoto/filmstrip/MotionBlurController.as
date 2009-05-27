package com.animoto.filmstrip
{
	import com.mosesSupposes.util.SelectiveDrawBase;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.filters.BitmapFilter;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
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
		
		protected var controller: FilmStripSceneController;
		protected var deltaMgr: DeltaManager;
		protected var drawUtil: SelectiveDrawBase;
		protected var buffer: Timer;
		protected var subframes: int;
		protected var index: int;
		protected var delay: int;
		protected var captureSubframe: Function;
		protected var primaryOnly: Boolean = false;
		protected var wholeScene: Boolean = false;
		
		public function MotionBlurController(controller:FilmStripSceneController, target:Object)
		{
			this.controller = controller;
			this.target = target;
			deltaMgr = new DeltaManager(target);
			delay = controller.filmStrip.subframeBufferMilliseconds;
			if (delay > 0) {
				buffer = new Timer(delay, 1);
				buffer.addEventListener(TimerEvent.TIMER_COMPLETE, nextSubFrame);
			}
			threshold = Math.max(1, threshold);
			subframeDuration = Math.max(1, subframeDuration);
			peakAlpha = Math.min(1, Math.max(0, peakAlpha));
			maxFrames = Math.max(1, maxFrames);
			// For now offset is limited to -1 or 1.
			offset = (offset > 0 ? 1 : -1);
				
			wholeScene = (controller.filmStrip.captureMode == FilmStripCaptureMode.WHOLE_SCENE);
			switch (controller.filmStrip.blurMode) {
				case FilmStripBlurMode.NONE:
					primaryOnly = true;
					break;
					
				case FilmStripBlurMode.SPLIT_SUBFRAMES:
					captureSubframe = captureSplit;
					break;
					
				case FilmStripBlurMode.MATTE_SUBFRAMES:
					captureSubframe = captureMatte;
					break;
			}
			
			if (!primaryOnly && wholeScene && !useFixedFrameCount && maxFrames>1) {
				FilmStrip.error("You must set MotionBlurSettings.usefixedFrameCount to true for WHOLE_SCENE captureMode.");
			}
		}
		
		public function render():void {
			index = 0;
			newContainer();
			PulseControl.freeze(); // safety
			
			// animate to previous or next frame and set up delta.
			PulseControl.setTime(controller.currentTime + (controller.filmStrip.frameDuration * offset));
			if ( !useFixedFrameCount && !primaryOnly ) {
				deltaMgr.recordStartValues();
			}
			
			// estimate how many subframes we'll need based on amount of animation and capture primary frame.
			PulseControl.setTime(controller.currentTime);
			setSubframes();
			capturePrimary();
			
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
			captureSubframe(); // Calls captureSplit or captureMatte depending on mode.
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
		
		protected function capturePrimary():void {
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
		
		protected function currentAlpha():Number {
			return Math.max(0.05, peakAlpha - (peakAlpha/subframes) * index);
		}
		
		protected function currentBoxBlur():BlurFilter {
			var boxamt:Number = (Math.min(index * boxBlurMultiplier + boxBlurRange.x, boxBlurRange.y));
			return new BlurFilter(boxamt, boxamt, 1);
		}
		
		protected function captureSplit():void {
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
		
		protected function captureMatte():void {
			controller.scene.redrawScene();
			
			var ct:ColorTransform = new ColorTransform(1, 1, 1, currentAlpha());
			var filters:Array = controller.scene.getFilters(target);
			
			var bd:BitmapData = newBitmapData();
			bd.draw(drawUtil.drawSource);
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
		
		protected function setSubframes():void {
			
			if (useFixedFrameCount) {
				subframes = fixedFrameCount;
				return;
			}
			
			var strengthMultiplier: Number = 0.02; // Allows strength to be a more intuitive value where 1 is normal.
			
			var delta:int = deltaMgr.getCompoundDelta();
			
			var frameRateMult: Number = controller.filmStrip.frameRate / 30; // adjust for current render framerate, using a constant of 30fps (approximates video standard)
			
			subframes = Math.min(maxFrames-1, (delta * frameRateMult * strength * strengthMultiplier));
			
			if (subframes<threshold)
				subframes = 0;
			
			//if (delta > 0) { trace("target:"+target,"delta:" + delta, "subframes:" + subframes); }
			
			// TODO: factor camera3D movement into compound delta..?
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
		
		/**
		 * A single drawUtil is reused to cut down on object creation.
		 */
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