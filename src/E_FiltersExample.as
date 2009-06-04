package {
	import com.animoto.filmstrip.FilmStrip;
	import com.animoto.filmstrip.FilmStripBlurMode;
	import com.animoto.filmstrip.FilmStripEvent;
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
	 * scene.addFilter(cube1, cubeGlow);
	 * 
	 * One thing that's nice about this is that it's pretty intuitive to associate the
	 * filter directly to the target object. Another plus (maybe) is that you can animate
	 * filter properties like 'blurX' directly, without any special syntax or filter
	 * tweening classes. It's also very easy to apply filters to papervision display objects.
	 * 
	 * On the downside if you do the dropshadow tutorial in this class, you'll see the shadow
	 * cuts off at the top when the dice is out of frame. That's because it's applying the 
	 * filter to the capture bitmap, not the actual object. (Wouldn't be impossible to
	 * get around with some changes to the MotionBlurController class, it would involve 
	 * capturing larger bitmaps than the final output frame and repositioning them.)
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
			
			// Glows
			scene.addFilter(dice.cube1, dice.filter1);
			scene.addFilter(dice.cube2, dice.filter2);
			
			// That's it for simple usage -- pretty easy!
			// Be sure to read the header comment for this class above for more of an explanation.
			
			// Advanced tutorial continues after next block...
			
			filmStrip = new FilmStrip(scene);
			filmStrip.width = example.contentWidth;
			filmStrip.height = example.contentHeight;
			filmStrip.backgroundColor = 0xf0ecaf;
			filmStrip.durationInSeconds = 3;
			filmStrip.frameRate = 20;
			filmStrip.bufferMilliseconds = 1; // Important: read the notes on this property in NotatedExample before you change this!
			
			
			
			// Apply-filter-to-subframes option
			 
			// The third parameter of addFilter is 'applyToSubframes', which if true will draw
			// filters onto each subframe as well as the primary frame. This might be useful if it started
			// looking disembodied from the blur, or if the filter physically changes the object's appearance, 
			// like maybe a pixel bender twirl filter. However, using this mode can bring up another issue
			// you should be aware of, so let's walk through it.
			
			// 1. Start by uncommenting the next 2 lines and running this file. Shadows are drawn once per frame.
			
			// Drop Shadows
//			scene.addFilter(dice.cube1, dice.filter3);
//			scene.addFilter(dice.cube2, dice.filter4);

			// (As to the shadow being cut off in the first few frames, see the note above in the class header comment.)
			
			// 2. Next, add 'true' as the final parameter of the dropshadow addFilter() calls above -- this 
			// is the flag applyToSubframes.      -- Like:  scene.addFilter(dice.cube1, dice.filter3, true);
			// When you run it now, you'll see a problem: shadows turn light gray and show visible edges. That's due to 
			// the re-drawing of of subframes into the object's bitmap -- which is the default captureMode (MATTE_SUBFRAMES). 
			
			// 3. If you do get weird edge artifacts, you try switching the capture mode to retain subframes individually. 
			// That mode runs slower and is more memory-intensive, but can result in much cleaner output.
			// (Uncomment the next line, and import com.animoto.filmstrip.FilmStripBlurMode).
			
//			filmStrip.blurMode = FilmStripBlurMode.SPLIT_SUBFRAMES;
			
			// FYI: This special mode is also a workaround for another general issue where matting subframes can result 
			// in darkening and degradation of blur edges. (A byproduct of Flash Player's use of premultiplied alpha -- 
			// alpha is factored into RGB values during draw.) So if you ever get weird edge artifacts with filters
			// or just with regular motion-blurs, give SPLIT_SUBFRAMES a try.
			
			
			
			playbackBitmap = new PlaybackFromRAM(filmStrip);
			
			filmStrip.addEventListener(FilmStripEvent.RENDER_STOPPED, super.exitSplitScreen);
			super.enterSplitScreen();
			
			filmStrip.startRendering();
			dispatchEvent(new Event("starting")); // used by AIR frameDumper project
		}
		
	}
}
