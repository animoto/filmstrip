package com.animoto.filmstrip
{
	import com.animoto.filmstrip.scenes.FilmStripScenePV3D;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	
	public class FilmStripSceneController
	{
		public var filmStrip:FilmStrip;
		public var scene:FilmStripScenePV3D; // TODO: retype to IFilmStripScene!!!
		public var currentTime:int;
		
		protected var renderCallback:Function;
		protected var motionBlurRetainer: Dictionary = new Dictionary(true);
		protected var motionBlurs: Array;
		protected var motionBlurIndex: int;
		
		public function FilmStripSceneController(scene: *) // TODO: retype to IFilmStripScene!!!
		{
			this.scene = scene;
		}
		
		public function init(filmStrip:FilmStrip, renderCallback:Function):void {
			this.filmStrip = filmStrip;
			this.renderCallback = renderCallback;
			filmStrip.addEventListener(FilmStripEvent.RENDER_STOPPED, filmstripRenderStopped, false, 0, true);
		}
		
		public function stopRendering():void {
			renderCallback = null;
			filmStrip = null;
			motionBlurs = null;
			// TODO: kill active processes
		}
		
		public function renderFrame(currentTime:int):void {
			trace("renderFrame");
			this.currentTime = currentTime;
			
			// eventually this class could contain all the logical pathways for various render modes, while scenes will do all the manual labor.
			// gonna start with full meal deal: EACH_OBJECT + SPLIT_SUBFRAMES and build from there.
			if (filmStrip.blurMode!=FilmStripBlurMode.NONE) {
				setupMotionBlur();
			}
		}
		
		protected function setupMotionBlur():void {
			scene.inventoryObjects();
			motionBlurs = new Array();
			var blur: MotionBlurController;
			for each (var child:Object in scene.visibleChildren) {
				if (motionBlurRetainer[child]==null) {
					blur = new MotionBlurController(this, child);
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
		
		public function firstSubframeComplete(container:Sprite):void {
			filmStrip.bitmapScene.addChild(container);
		}
		
		public function motionBlurComplete(container:Sprite):void {
			if (filmStrip.bitmapScene.contains(container)==false) {
				filmStrip.bitmapScene.addChild(container);
			}
//			if (singleImage!=null) {
//				filmStrip.bitmapScene.addChild(singleImage);
//			}
			
			renderNextBlur();
		}
		
		protected function renderNextBlur():void {
			if (++motionBlurIndex == motionBlurs.length) {
				complete();
			}
			else {
				(motionBlurs[motionBlurIndex] as MotionBlurController).render();
			}
		}
		
		protected function complete():void {
			renderCallback();
			stopRendering(); // performs cleanup
		}
		
		protected function filmstripRenderStopped(event:FilmStripEvent):void {
			for each (var blur:MotionBlurController in motionBlurRetainer) {
				blur.destroy();
				delete motionBlurRetainer[blur.target];
			}
		}
	}
}