package {
	import com.animoto.filmstrip.FilmStrip;
	import com.animoto.filmstrip.FilmStripEvent;
	import com.animoto.filmstrip.MotionBlurSettings;
	import com.animoto.filmstrip.output.PlaybackFromRAM;
	import com.animoto.filmstrip.scenes.FilmStripSceneSprite;
	
	import filmstripexamples.Photos;
	
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;

	[SWF(backgroundColor="#FFFFFF", frameRate="30")]
	
	/**
	 * This example wraps a Sprite scene -- which wouldn't necessarily 
	 * need to be 2D if you're using Flash 10.
	 * 
	 * For more of a tutorial, see the 'NotatedExample' file.
	 * 
	 * @author moses gunesch
	 * 
	 */
	public class B_Example2D extends SplitScreenView
	{
		public function B_Example2D()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, setup);
		}
		
		public function setup(event:Event):void {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			example = new Photos(); // an animation of a few photos in a sprite.
			addChild(example);
			if (example.requiresWait) {
				example.addEventListener(Event.COMPLETE, setupStart);
			}
			else {
				setupStart();
			}
		}
		
		public function setupStart(event:Event=null):void {
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
			
			var scene:FilmStripSceneSprite = new FilmStripSceneSprite(example); // This scene wrapper class works with a plain Sprite.
			
			filmStrip = new FilmStrip(scene);
			filmStrip.width = example.contentWidth;
			filmStrip.height = example.contentHeight;
			filmStrip.backgroundColor = 0xf0ecaf;
			filmStrip.durationInSeconds = 3;
			filmStrip.frameRate = 20;
			filmStrip.bufferMilliseconds = 1; // Important: read the notes on this property in NotatedExample before you change this!
			
			MotionBlurSettings.offset = 1; // this animation looks a little better blurring forward instead of trailing.
			
			playbackBitmap = new PlaybackFromRAM(filmStrip);
			
			filmStrip.addEventListener(FilmStripEvent.RENDER_STOPPED, super.exitSplitScreen);
			super.enterSplitScreen();
			
			filmStrip.startRendering();
			dispatchEvent(new Event("starting")); // used by AIR frameDumper project
		}
		
	}
}
