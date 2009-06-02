package {
	import com.animoto.filmstrip.FilmStrip;
	import com.animoto.filmstrip.FilmStripEvent;
	import com.animoto.filmstrip.output.PlaybackFromRAM;
	import com.animoto.filmstrip.scenes.FilmStripScenePV3D;
	import com.animoto.filmstrip.scenes.FilmStripSceneSprite;
	
	import filmstripexamples.Dice;
	import filmstripexamples.Photos;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;

	[SWF(backgroundColor="#FFFFFF", frameRate="30")]
	
	/**
	 * FilmStrips can render a stack of scenes at once -- this example
	 * stacks our 3D and 2D examples.
	 * 
	 * @author moses gunesch
	 */
	public class D_CompositeExample extends SplitScreenView
	{
		private var photos:Photos;
		private var loads:int=0;
		
		public function D_CompositeExample()
		{
			super();
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			example = new Dice();
			addChild(example);
			photos = new Photos();
			addChild(photos);
			
			stage.addEventListener(MouseEvent.CLICK, start);
			start(); // Comment out to start on click instead.
		}
		
		public function start(event:Event=null): void {
			if (filmStrip!=null) {
				if (filmStrip.rendering) {
					filmStrip.stopRendering();
				}
				return;
			}
			
			var scene1:FilmStripSceneSprite = new FilmStripSceneSprite(photos);
			
			var dice:Dice = example as Dice;
			var scene2:FilmStripScenePV3D = new FilmStripScenePV3D(dice.scene, dice.camera, dice.viewport, dice.renderer);
			
			filmStrip = new FilmStrip(scene1);
			filmStrip.addScene(scene2);
			filmStrip.width = example.contentWidth;
			filmStrip.height = example.contentHeight;
			filmStrip.backgroundColor = 0xf0ecaf;
			filmStrip.durationInSeconds = 3;
			filmStrip.frameRate = 20;
			filmStrip.bufferMilliseconds = 1; // Important: read the notes on this property in NotatedExample before you change this!
			
			playbackBitmap = new PlaybackFromRAM(filmStrip);
			
			filmStrip.addEventListener(FilmStripEvent.RENDER_STOPPED, super.exitSplitScreen);
			super.enterSplitScreen();
			
			filmStrip.startRendering();
			dispatchEvent(new Event("starting")); // used by AIR frameDumper project
		}
	}
}
