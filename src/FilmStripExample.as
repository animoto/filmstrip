package {
	import com.animoto.filmstrip.FilmStrip;
	import com.animoto.filmstrip.FilmStripEvent;
	import com.animoto.filmstrip.scenes.FilmStripScenePV3D;
	
	import filmstripexamples.Dice;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.filters.DropShadowFilter;

	[SWF(backgroundColor="#DDDDDD", frameRate="30")]
	
	public class FilmStripExample extends Sprite
	{
		private var bitmap:Bitmap;
		
		public function FilmStripExample()
		{
			super();
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			var dice:Dice = new Dice();
			addChild(dice);
			
			bitmap = new Bitmap();
			bitmap.scaleX = bitmap.scaleY = 0.33;
			bitmap.filters = [new DropShadowFilter(4,45,0,0.25,5,5)];
			addChild(bitmap);
			
			var f:FilmStrip = new FilmStrip(new FilmStripScenePV3D(dice.scene, dice.camera, dice.viewport, dice.renderer));
			f.addEventListener(FilmStripEvent.FRAME_RENDERED, frameRendered);
			f.backgroundColor = 0x330000;
			f.bufferMilliseconds = 100;
			f.durationInSeconds = 1;
			f.startRendering();
		}
		
		private function frameRendered(event:FilmStripEvent):void {
			bitmap.bitmapData = event.data;
			bitmap.smoothing = true;
		}
	}
}
