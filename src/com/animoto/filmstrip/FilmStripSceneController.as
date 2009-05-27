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
		protected var motionBlurRetainer: Dictionary;
		protected var motionBlurs: Array;
		protected var motionBlurIndex: int;
		
		public function FilmStripSceneController(scene: FilmStripScene)
		{
			this.scene = scene;
		}
		
		public function init(filmStrip:FilmStrip, renderCallback:Function):void {
			this.filmStrip = filmStrip;
			this.renderCallback = renderCallback;
			filmStrip.addEventListener(FilmStripEvent.RENDER_STOPPED, filmstripRenderStopped, false, 0, true);
		}
		
		public function stopRendering():void {
			motionBlurs = null;
			for each (var blur:MotionBlurController in motionBlurRetainer) {
				blur.destroy();
			}
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
			this.motionBlurRetainer = new Dictionary(true);
			
			if (filmStrip.captureMode==FilmStripCaptureMode.WHOLE_SCENE) {
				var sceneBlur:MotionBlurController = newMotionBlur(scene);
				motionBlurs = [ sceneBlur ];
				motionBlurRetainer[ scene ] = sceneBlur;
				sceneBlur.render();
			}
			else {
				setupMotionBlur();
			}
		}
		
		protected function newMotionBlur(target:Object):MotionBlurController {
			if (filmStrip.blurMode==FilmStripBlurMode.MATTE_SUBFRAMES) {
				return new MotionBlurCtrlMatte(this, target);
			}
			return new MotionBlurController(this, target);
		}
		
		protected function setupMotionBlur():void {
			motionBlurs = new Array();
			var blur: MotionBlurController;
			var children:Array = scene.getVisibleChildren();
			for each (var child:Object in children) {
				if (motionBlurRetainer[child]==null) {
					blur = newMotionBlur(child);
					motionBlurRetainer[child] = blur;
					motionBlurs.push(blur);
				}
				else {
					motionBlurs.push(motionBlurRetainer[child]);
				}
			}
			for each (blur in motionBlurRetainer) {
				if (motionBlurs.indexOf(blur)==-1) {
					motionBlurRetainer[blur.target].destroy();
					delete motionBlurRetainer[blur.target];
				}
			}
			if (motionBlurs.length > 0) {
				motionBlurIndex = -1;
				renderNextBlur();
			}
			else {
				complete();
			}
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