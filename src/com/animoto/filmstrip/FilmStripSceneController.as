package com.animoto.filmstrip
{
	import com.animoto.filmstrip.scenes.FilmStripScenePV3D;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	public class FilmStripSceneController
	{
		public var filmStrip:FilmStrip;
		public var scene:FilmStripScenePV3D; // TODO: retype to IFilmStripScene!!!
		public var currentTime:int;
		
		protected var renderCallback:Function;
		protected var motionBlurs: Array;
		protected var motionBlurIndex: int;
		
		public function FilmStripSceneController(scene: *) // TODO: retype to IFilmStripScene!!!
		{
			this.scene = scene;
		}
		
		public function init(filmStrip:FilmStrip, renderCallback:Function):void {
			this.filmStrip = filmStrip;
			this.renderCallback = renderCallback;
		}
		
		public function stopRendering():void {
			renderCallback = null;
			filmStrip = null;
			if (motionBlurs!=null) {
				for each (var blur:MotionBlurController in motionBlurs) {
					blur.destroy();
				}
			}
			motionBlurs = null;
			// TODO: kill active processes
		}
		
		public function renderFrame(currentTime:int):void {
			
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
			for each (var child:Object in scene.visibleChildren) {
				motionBlurs.push( new MotionBlurController(this, child) );
			}
			if (motionBlurs.length > 0) {
				motionBlurIndex = 0;
				(motionBlurs[0] as MotionBlurController).render();
			}
			else {
				complete();
			}
		}
		
		public function motionBlurComplete(motionBlur:MotionBlurController):void {
			filmStrip.bitmapScene.addChild(new Bitmap(motionBlur.images[0] as BitmapData));
			
			// TEMP!
			PulseControl.setTime(currentTime);
			scene.redrawScene();
			
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
	}
}