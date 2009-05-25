package com.animoto.filmstrip
{
	import com.mosesSupposes.util.SelectiveDrawBase;
	
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	
	public class MotionBlurController
	{
		/**
		 * Subframes required for blur to be processed (1 or higher).
		 */
		public static var threshold:int = 1;
		
		public static var strength:Number = 1;
		
		public static var maxSubframes:int = 20;
		
		public static var millisecondsPerSubframe:int = 20;
		
		public static var subframeBlendMode: String = BlendMode.LIGHTEN;
		
		/**
		 * Pans the blur across the primary frame, where -1 trails blur
		 * behind object's motion and 1 shoots blur in front of motion.
		 */
		public static var offset: Number = -1;
		
		public var images:Array;
		
		protected var controller: FilmStripSceneController;
		protected var target: Object;
		protected var deltaMgr: DeltaManager;
		protected var subframes: int;
		protected var index: int;
		protected var drawUtil: SelectiveDrawBase;
		
		public function MotionBlurController(controller:FilmStripSceneController, target:Object)
		{
			this.controller = controller;
			this.target = target;
			deltaMgr = new DeltaManager(target);
		}
		
		public function render():void {
			index = 0;
			images = new Array();
			PulseControl.freeze(); // safety
			
			// capture primary frame and set up delta.
			PulseControl.setTime(controller.currentTime);
			
			capture();
			deltaMgr.recordStartValues();
			
			// 
			PulseControl.setTime(controller.currentTime - controller.filmStrip.frameDuration);
			calculateSubframes();
			if (subframes < Math.max(1, threshold)) {
				subframes = 0;
			}
			complete(); // temp
		}
		
		public function destroy():void {
			controller = null;
			target = null;
			// TODO: complete this method
		}
		
		protected function capture():void {
			
			// test:
//			var bd:BitmapData = new BitmapData(controller.filmStrip.width, controller.filmStrip.height, true, 0x0);
//			bd.draw(controller.scene.viewport);
//			images.push(bd);
			
			refreshDrawUtil();
			drawUtil.manualPreDraw([target]);
			drawUtil.bitmapData.draw(drawUtil.drawSource);
			drawUtil.manualPostDraw(false);
			images.push(drawUtil.bitmapData);
			drawUtil.bitmapData = null;
		}
		
		protected function calculateSubframes():void {
			
			var strengthMultiplier: Number = 0.02; // Allows strength to be a more intuitive value where 1 is normal.
			
			var delta:int = deltaMgr.getCompoundDelta();
			
			var frameRateMult: Number = controller.filmStrip.frameRate / 30; // adjust for current render framerate, using a constant of 30fps (approximates video standard)
			
			subframes = delta * frameRateMult * strength * strengthMultiplier;
			
			if (delta > 0) { trace("target:"+target,"delta:" + delta, "subframes:" + subframes); }
			
			// TODO: factor camera3D movement into compound delta..?
		}
		
		protected function complete():void {
			controller.motionBlurComplete(this);
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