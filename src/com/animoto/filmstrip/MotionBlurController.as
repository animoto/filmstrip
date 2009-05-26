package com.animoto.filmstrip
{
	import com.mosesSupposes.util.SelectiveDrawBase;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.filters.BlurFilter;
	import flash.utils.Timer;
	
	public class MotionBlurController
	{
		/**
		 * Subframes required for blur to be processed (1 or higher).
		 */
		public static var threshold:int = 1;
		
		public static var strength:Number = 1;
		
		public static var maxSubframes:int = 16;
		
		public static var millisecondsPerSubframe:int = 2;
		
		public static var subframeBlendMode: String = BlendMode.NORMAL;

		public static var peakSubframeAlpha: Number = 0.5;
		
		/**
		 * For now set to -1 (trailing blur) or 1 (blur in front of motion).
		 * 
		 * In future this could be improved to include values in between,
		 * to pan the blur across the primary frame, causing it to go both ways.
		 */
		public static var offset: Number = -1;
		
		public var container:Sprite;
		public var target: Object;
		
		protected var controller: FilmStripSceneController;
		protected var deltaMgr: DeltaManager;
		protected var drawUtil: SelectiveDrawBase;
		protected var buffer: Timer;
		protected var subframes: int;
		protected var index: int;
		protected var delay: int;
		
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
			peakSubframeAlpha = Math.max(1, peakSubframeAlpha);
			// For now offset is limited to -1 or 1.
			offset = (offset > 0 ? 1 : -1);
		}
		
		public function render():void {
			index = 0;
			container = new Sprite();
			PulseControl.freeze(); // safety
			
			// animate to previous or next frame and set up delta.
			PulseControl.setTime(controller.currentTime + (controller.filmStrip.frameDuration * offset));
			deltaMgr.recordStartValues();
			
			// estimate how many subframes we'll need based on amount of animation and capture primary frame.
			PulseControl.setTime(controller.currentTime);
			calculateSubframes();
			capture();
			
			if (delay > 0) {
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
			var time:int = controller.currentTime + (millisecondsPerSubframe * index * offset);
			if (++index>subframes || subframes<threshold || time<0) {
				complete();
				return;
			}
			
			PulseControl.setTime(controller.currentTime + (millisecondsPerSubframe * index * offset));
			var bitmap:Bitmap = capture();
			bitmap.blendMode = subframeBlendMode;
			var maxAlpha: Number = Math.max(0.1, 1 - (1/subframes)*index);
			bitmap.alpha = (maxAlpha - ((maxAlpha / subframes) * (index - 1))) * peakSubframeAlpha;
			var box:Number = (Math.min(index*0.1 + 1.5, 3));
			bitmap.filters = [ new BlurFilter(box, box, 1) ];

			if (index==2) {
				(container.getChildAt(0) as Bitmap).filters = [ new BlurFilter(box, box, 1) ];
				controller.firstSubframeComplete(container);
			}
			
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
			buffer.reset();
			buffer.removeEventListener(TimerEvent.TIMER_COMPLETE, nextSubFrame);
			buffer = null;
			drawUtil.manualPostDraw(false); // safety, releases references without rerendering 3d scene
			drawUtil = null;
		}
		
		protected function capture():Bitmap {
			refreshDrawUtil();
			if (index==0) {
				drawUtil.manualPreDraw([target]); // Toggles other objects' visibility off temporarily and rerenders 3d scene. Restored in complete().
			}
			else {
				controller.scene.redrawScene();
			}
			drawUtil.bitmapData.draw(drawUtil.drawSource);
			var b:Bitmap = new Bitmap(drawUtil.bitmapData);
			drawUtil.bitmapData = null;
			container.addChild(b);
			return b;
		}
		
		protected function calculateSubframes():void {
			
			var strengthMultiplier: Number = 0.02; // Allows strength to be a more intuitive value where 1 is normal.
			
			var delta:int = deltaMgr.getCompoundDelta();
			
			var frameRateMult: Number = controller.filmStrip.frameRate / 30; // adjust for current render framerate, using a constant of 30fps (approximates video standard)
			
			subframes = Math.min(maxSubframes, (delta * frameRateMult * strength * strengthMultiplier));
			
			//if (delta > 0) { trace("target:"+target,"delta:" + delta, "subframes:" + subframes); }
			
			// TODO: factor camera3D movement into compound delta..?
		}
		
		protected function complete():void {
			drawUtil.manualPostDraw(); // Passing false to avoid rerendering the scene, which isn't necessary here
			controller.motionBlurComplete(container);
		}

		
		/**
		 * A single drawUtil is reused to cut down on object creation.
		 */
		protected function refreshDrawUtil():void {
			var bd:BitmapData = new BitmapData(controller.filmStrip.width, controller.filmStrip.height, true, 0x0);
			if (drawUtil==null) {
				drawUtil = controller.scene.getSelectiveDrawUtil(bd);
			}
			else {
				drawUtil.bitmapData = bd;
			}
		}
	}
}