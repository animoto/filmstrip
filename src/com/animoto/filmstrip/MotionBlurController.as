package com.animoto.filmstrip
{
	import com.mosesSupposes.util.SelectiveDrawBase;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	public class MotionBlurController
	{
		/**
		 * Subframes required for blur to be processed (1 or higher).
		 */
		public static var threshold:int = 1;
		
		public static var strength:Number = 1;
		
		public static var maxSubframes:int = 16;
		
		public static var millisecondsPerSubframe:int = 1;
		
		public static var subframeBlendMode: String = BlendMode.LIGHTEN;

		public static var peakSubframeAlpha: Number = 0.75;
		
		public static var applyBoxBlur: Boolean = true;
		
		public static var boxBlurRange: Point = new Point(1.5, 3);
		
		public static var boxBlurMultiplier: Number = 0.1;
		
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
		protected var captureSubframe: Function = captureSubframeSplit;
		
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
			if (controller.filmStrip.blurMode == FilmStripBlurMode.MATTE_SUBFRAMES)
				captureSubframe = captureSubframeMatte;
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
			capturePrimaryFrame();
			
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
			index++;
			var done:Boolean = (index>subframes || subframes<threshold || time<0);
			if (done) {
				complete();
				return;
			}
			
			// Set subframe time
			PulseControl.setTime(controller.currentTime + (millisecondsPerSubframe * index * offset));
			
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
			buffer.reset();
			buffer.removeEventListener(TimerEvent.TIMER_COMPLETE, nextSubFrame);
			buffer = null;
			if (drawUtil!=null) {
				drawUtil.manualPostDraw(false); // safety, releases references without rerendering 3d scene
				drawUtil = null;
			}
		}
		
		protected function capturePrimaryFrame():void {
			refreshDrawUtil();
			drawUtil.manualPreDraw([target]); // Toggles other objects' visibility off temporarily and rerenders 3d scene. Restored in complete().
			drawUtil.bitmapData.draw(drawUtil.drawSource);
			container.addChild(new Bitmap(drawUtil.bitmapData));
		}
		
		protected function currentAlpha():Number {
			var maxalpha: Number = Math.max(0.1, 1 - (1/subframes)*index);
			return (maxalpha - ((maxalpha / subframes) * (index - 1))) * peakSubframeAlpha;
		}
		
		protected function currentBoxBlur():BlurFilter {
			var boxamt:Number = (Math.min(index * boxBlurMultiplier + boxBlurRange.x, boxBlurRange.y));
			return new BlurFilter(boxamt, boxamt, 1);
		}
		
		protected function captureSubframeSplit():void {
			controller.scene.redrawScene();
			refreshDrawUtil();
			drawUtil.bitmapData.draw(drawUtil.drawSource);
			var bitmap:Bitmap = new Bitmap(drawUtil.bitmapData);
			bitmap.blendMode = subframeBlendMode;
			bitmap.alpha = currentAlpha();
			if (applyBoxBlur) {
				var boxblur:BlurFilter = currentBoxBlur();
				bitmap.filters = [ boxblur ];
				if (index==2)
					(container.getChildAt(0) as Bitmap).filters = [ boxblur ];
			}
			container.addChild(bitmap);
			drawUtil.bitmapData = null;
		}
		
		protected function captureSubframeMatte():void {
			controller.scene.redrawScene();
			var ct:ColorTransform = new ColorTransform(1, 1, 1, currentAlpha());
			if (applyBoxBlur) {
				var bd:BitmapData = newBitmapData();
				bd.draw(drawUtil.drawSource);
				bd.applyFilter(bd, drawUtil.bitmapData.rect, new Point(0,0), currentBoxBlur());
				drawUtil.bitmapData.draw(bd, null, ct, subframeBlendMode);
			}
			else {
				drawUtil.bitmapData.draw(drawUtil.drawSource, null, ct, subframeBlendMode);
			}
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
			controller.subframeComplete(this, index, true);
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