package
{
	import com.animoto.filmstrip.FilmStrip;
	import com.animoto.filmstrip.FilmStripEvent;
	import com.animoto.filmstrip.output.PlaybackFromRAM;
	
	import filmstripexamples.ExampleScene;
	
	import flash.display.Sprite;

	/**
	 * Base class for examples that draws a splitscreen view.
	 * 
	 * @author moses gunesch
	 */
	public class SplitScreenView extends Sprite
	{
		public var example:ExampleScene;
		public var filmStrip:FilmStrip;
		public var playbackBitmap:PlaybackFromRAM;
		public var outputDisplay:Sprite;
		
		public function SplitScreenView()
		{
			super();
		}
		
		// Split screen view: top right is the real scene, bottom left is the FilmStrip's
		// bitmapView, and top left is the final frame capture.
		public function enterSplitScreen():void {	
			outputDisplay = new Sprite();
			outputDisplay.graphics.drawRect(0, 0, example.contentWidth, example.contentHeight);
			playbackBitmap.x = playbackBitmap.y = 5;
			outputDisplay.addChild(playbackBitmap);
			
			filmStrip.bitmapScene.graphics.lineStyle(1, filmStrip.backgroundColor, 1);
			filmStrip.bitmapScene.graphics.drawRect(0, 0, example.contentWidth, example.contentHeight);
			filmStrip.bitmapScene.x = 5;
			filmStrip.bitmapScene.y = example.contentHeight + 10;
			outputDisplay.addChild(filmStrip.bitmapScene);
			
			example.scaleX = example.scaleY = 0.5;
			outputDisplay.scaleX = outputDisplay.scaleY = 0.5;
			example.x = outputDisplay.getBounds(this).right + 5;
			addChild(outputDisplay);
		}
		
		public function exitSplitScreen(event:FilmStripEvent):void {
			removeChild(example);
			outputDisplay.removeChild(filmStrip.bitmapScene);
			outputDisplay.scaleX = outputDisplay.scaleY = 1;
		}		
	}
}