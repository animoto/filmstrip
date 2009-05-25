package com.animoto.filmstrip.scenes
{
	import com.animoto.filmstrip.FilmStrip;
	import com.animoto.filmstrip.FilmStripBlurMode;
	import com.animoto.filmstrip.FilmStripCaptureMode;
	
	public class FilmStripSceneController
	{
		protected var filmStrip:FilmStrip;
		protected var scene:IFilmStripScene;
		protected var renderCallback:Function;
		
		public function FilmStripSceneController(scene:IFilmStripScene)
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
		}
		
		
		public function renderFrame(currentTime:int):void {
			
			// eventually this class could contain all the logical pathways for various render modes, while scenes will do all the manual labor.
			// gonna start with full meal deal: EACH_OBJECT + SPLIT_SUBFRAMES and build from there.
			
		}
	}
}