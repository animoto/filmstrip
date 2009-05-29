package com.animoto.filmstrip
{
	import com.animoto.filmstrip.scenes.FilmStripScene;
	
	import flash.utils.Dictionary;
	
	/**
	 * Requests a list of visible children from the scene, then generates
	 * a MotionBlurController for each child object and sequences render.
	 * 
	 * @author moses gunesch
	 */
	public class FilmStripSceneController
	{
		public var filmStrip:FilmStrip;
		public var scene:FilmStripScene;
		public var currentTime:int;
		
		protected var renderCallback:Function;
		protected var motionBlurRetainer: Dictionary = new Dictionary(true);
		protected var deltas: Dictionary = new Dictionary(false);
		protected var motionBlurs: Array;
		protected var motionBlurIndex: int;
		protected var sceneBlur: MotionBlurController;
		
		public function FilmStripSceneController(scene: FilmStripScene)
		{
			this.scene = scene;
		}
		
		public function init(filmStrip:FilmStrip, renderCallback:Function):void {
			this.filmStrip = filmStrip;
			this.renderCallback = renderCallback;
			filmStrip.addEventListener(FilmStripEvent.RENDER_STOPPED, filmstripRenderStopped, false, 0, true);
			this.sceneBlur = newMotionBlur(scene, true);
		}
		
		public function stopRendering():void {
			motionBlurs = null;
			for each (var blur:MotionBlurController in motionBlurRetainer) {
				blur.destroy();
			}
			sceneBlur.destroy();
			motionBlurRetainer = null;
		}
		
		public function destroy():void {
			stopRendering();
			filmStrip = null;
			renderCallback = null;
			scene = null;
		}
		
		public function renderFrame(currentTime:int):void {
			//trace("renderFrame");
			this.currentTime = currentTime;
			
			// MotionBlurControllers are used for capture even when there are no subframes.
			if (filmStrip.captureMode==FilmStripCaptureMode.WHOLE_SCENE) {
				if (!MotionBlurSettings.useFixedFrameCount && MotionBlurSettings.maxFrames > 1) {
					FilmStrip.error("You must set MotionBlurSettings.usefixedFrameCount to true for WHOLE_SCENE captureMode.");
				}
				singleCapture();
			}
			else {
				setupMultiCapture();
			}
		}
		
		protected function singleCapture():void {
			motionBlurs = [ sceneBlur ];
			scene.redrawScene();
			sceneBlur.render();
		}
		
		protected function newMotionBlur(target:Object, wholeScene:Boolean):MotionBlurController {
			if (filmStrip.blurMode==FilmStripBlurMode.MATTE_SUBFRAMES) {
				return new MotionBlurCtrlMatte(this, target, wholeScene);
			}
			return new MotionBlurController(this, target, wholeScene);
		}
		
		protected function setupMultiCapture():void {
			
			// In many cases this step is really only needed once, but it keeps us synced as objects enter and leave the scene.
			makeBlurControllers();
			
			if (motionBlurs.length == 0) {
				trace("scene empty in this frame.");
				complete();
				return;
			}
			if ( MotionBlurSettings.useFixedFrameCount == false ) {
				var totalSubframes:int = precalcSubframes();
				if (totalSubframes == 0) {
					trace("Reverted to single capture - no blur in this frame.");
					singleCapture();
					return;
				}
			}
			motionBlurIndex = -1;
			renderNextBlur();
		}
		
		protected function makeBlurControllers():void {
			motionBlurs = new Array();
			var blur: MotionBlurController;
			var children:Array = scene.getVisibleChildren();
			
			for each (var child:Object in children) {
				if (child.visible && motionBlurRetainer[child]==null) {
					blur = newMotionBlur(child, false);
					motionBlurRetainer[child] = blur;
					motionBlurs.push(blur);
				}
				else {
					motionBlurs.push(motionBlurRetainer[child]);
				}
			}
			
			// Clean up retainer
			for each (blur in motionBlurRetainer) {
				if (motionBlurs.indexOf(blur)==-1) {
					motionBlurRetainer[blur.target].destroy();
					delete motionBlurRetainer[blur.target];
				}
			}
		}
		
		protected function precalcSubframes():int {
			var blur: MotionBlurController;
			var totalSubframes:int = 0;
			var frameRate:int = filmStrip.frameRate;
			
			// animate to previous or next frame time then back to currentTime to get deltas.
			// doing this centrally lets us check whether it's necessary to capture objects separately.
			PulseControl.setTime( Math.max(0, currentTime + (filmStrip.frameDuration * MotionBlurSettings.offset)) );
			for each (blur in motionBlurs) {
				blur.deltaMgr.recordStartValues();
			}
			PulseControl.setTime(currentTime);
			var delta:Number;
			for each (blur in motionBlurs) {
				delta = blur.deltaMgr.getCompoundDelta();
				blur.subframes = MotionBlurSettings.getSubframeCount(frameRate, delta);
				totalSubframes += blur.subframes;
			}
			return totalSubframes;
		}
		
		public function subframeComplete(blur:MotionBlurController, index:int, done:Boolean):void {
			
			if (filmStrip.bitmapScene.contains(blur.container)==false) {
				filmStrip.bitmapScene.addChild(blur.container);
			}
			
			if (done) {
				renderNextBlur();
			}
		}
		
		protected function renderNextBlur():void {
			if (++motionBlurIndex >= motionBlurs.length) {
				complete();
			}
			else {
				(motionBlurs[motionBlurIndex] as MotionBlurController).render();
			}
		}
		
		protected function complete():void {
			renderCallback();
		}
		
		protected function filmstripRenderStopped(event:FilmStripEvent):void {
			for each (var blur:MotionBlurController in motionBlurRetainer) {
				blur.destroy();
				delete motionBlurRetainer[blur.target];
			}
		}
	}
}