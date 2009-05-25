package {
	import com.animoto.filmstrip.FilmStrip;
	import com.animoto.filmstrip.FilmStripEvent;
	import com.animoto.filmstrip.scenes.FilmStripScenePV3D;
	
	import filmstripexamples.Dice;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;

	[SWF(backgroundColor="#DDDDDD", frameRate="30")]
	
	public class FilmStripExample extends Sprite
	{
		private var bitmap:Bitmap;
		private var dice:Dice;
		
		public function FilmStripExample()
		{
			super();
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			dice = new Dice();
			addChild(dice);
			//start();
			stage.addEventListener(MouseEvent.CLICK, start);
		}
		
		private function start(event:Event=null): void {
			
			bitmap = new Bitmap();
			bitmap.scaleX = bitmap.scaleY = 0.25;
			bitmap.x = bitmap.y = 5;
			bitmap.filters = [new DropShadowFilter(4,45,0,0.25,5,5)];
			addChild(bitmap);
			
			var f:FilmStrip = new FilmStrip(new FilmStripScenePV3D(dice.scene, dice.camera, dice.viewport, dice.renderer));
			f.addEventListener(FilmStripEvent.FRAME_RENDERED, frameRendered);
			f.backgroundColor = 0x330000;
			f.bufferMilliseconds = 1;
			f.durationInSeconds = .5;
			f.frameRate = 30;
			
			f.bitmapScene.graphics.lineStyle(1, f.backgroundColor, 1);
			f.bitmapScene.graphics.drawRect(0, 0, dice.viewport.width, dice.viewport.height);
			f.bitmapScene.scaleX = f.bitmapScene.scaleY = 0.25;
			f.bitmapScene.x = 5;
			f.bitmapScene.y = 250;
			addChild(f.bitmapScene);
			
			f.startRendering();
		}
		
		private function frameRendered(event:FilmStripEvent):void {
			bitmap.bitmapData = event.data;
			bitmap.smoothing = true;
		}
	}
}
