package com.animoto.filmstrip
{
	import flash.display.BitmapData;
	import flash.display.Sprite;

	public class FilmStripBitmapScene extends Sprite
	{
		public var captureMode:String = FilmStripCaptureMode.WHOLE_SCENE;
		public var drawMode:String = FilmStripDrawMode.MATTE_SUBFRAMES;
		
		protected var filmStrip: FilmStrip;
		protected var frameCallback: Function;
		
		public function FilmStripBitmapScene(filmStrip:FilmStrip, frameCallback:Function)
		{
			super();
			this.filmStrip = filmStrip;
			this.frameCallback = frameCallback;
		}
		
		public function render():void {
			frameCallback(new BitmapData(100, 50, false, 0x33FFDD));
		}
	}
}