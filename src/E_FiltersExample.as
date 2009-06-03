package {
	import com.animoto.filmstrip.FilmStrip;
	import com.animoto.filmstrip.FilmStripEvent;
	import com.animoto.filmstrip.MotionBlurSettings;
	import com.animoto.filmstrip.output.PlaybackFromRAM;
	import com.animoto.filmstrip.scenes.FilmStripScenePV3D;
	
	import filmstripexamples.OverlappingDice;
	
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;

	[SWF(backgroundColor="#FFFFFF", frameRate="30")]
	
	/**
	 * You can add bitmap filters or pixel bender effects on any object's render layer.
	 * 
	 * One thing that's nice about this is that it's pretty intuitive to associate the
	 * filter directly to the target object. Another plus (maybe) is that you can animate
	 * filter properties like 'blurX' directly, without any special syntax or filter
	 * tweening classes. Truth be told, this feature was easy to toss in and makes
	 * for a nice little extra.
	 * 
	 * @author moses gunesch
	 * 
	 */
	public class E_FiltersExample extends SplitScreenView
	{
		public function E_FiltersExample()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, setup);
		}
		
		public function setup(event:Event):void {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			example = new OverlappingDice();
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
			
			var dice:OverlappingDice = example as OverlappingDice;
			var scene:FilmStripScenePV3D = new FilmStripScenePV3D(dice.scene, dice.camera, dice.viewport, dice.renderer);
			dice.camera.zoom = 1.25;
			
			// FILTERS/EFFECTS
			
			// sorry these are so lame, you can do better. just trying to get this thing out the door!
			
			scene.addFilter(dice.cube1, dice.filter1);
			scene.addFilter(dice.cube2, dice.filter2);
			scene.addFilter(dice.cube1, dice.filter3);
			scene.addFilter(dice.cube2, dice.filter4);
			
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
