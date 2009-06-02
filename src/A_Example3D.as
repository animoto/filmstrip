package {
	import com.animoto.filmstrip.FilmStrip;
	import com.animoto.filmstrip.FilmStripEvent;
	import com.animoto.filmstrip.output.PlaybackFromRAM;
	import com.animoto.filmstrip.scenes.FilmStripScenePV3D;
	
	import filmstripexamples.Dice;
	import filmstripexamples.ExampleScene;
	
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;

	[SWF(backgroundColor="#FFFFFF", frameRate="30")]
	
	/**
	 * FilmStrip is written to be extensible to various types of scenes.
	 * This one wraps a simple Papervision3D scene.
	 * 
	 * For more of a tutorial, see the file NotatedExample.
	 * 
	 * @author moses gunesch
	 * 
	 */
	public class A_Example3D extends SplitScreenView
	{
		public function A_Example3D()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, setup);
		}
		
		public function setup(event:Event):void {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			example = new Dice();
			addChild(example);
			if (example.requiresLoad) {
				example.addEventListener(Event.COMPLETE, startAnimation);
			}
			else {
				startAnimation();
			}
		}
		
		public function startAnimation(event:Event=null):void {
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
			
			var dice:Dice = example as Dice;
			var scene:FilmStripScenePV3D = new FilmStripScenePV3D(dice.scene, dice.camera, dice.viewport, dice.renderer);
			
			filmStrip = new FilmStrip(scene);
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
