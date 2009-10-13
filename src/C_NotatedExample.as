package {
	import com.animoto.filmstrip.FilmStrip;
	import com.animoto.filmstrip.FilmStripEvent;
	import com.animoto.filmstrip.output.PlaybackFromRAM;
	import com.animoto.filmstrip.scenes.FilmStripScenePV3D;
	
	import filmstripexamples.Dice;
	import filmstripexamples.OverlappingDice;
	
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;

	[SWF(backgroundColor="#FFFFFF", frameRate="30")]
	
	/**
	 * Example with tutorial notes. This example uses Tweener
	 * but should be easy for you to switch to your preferred engine's 
	 * syntax -- see filmstripexamples.OverlappingDice.
	 * 
	 * @author moses gunesch
	 */
	public class C_NotatedExample extends SplitScreenView
	{
		public function C_NotatedExample()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, setup);
		}
		
		public function setup(event:Event):void {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			// Uncomment one of these example scenes, then set up the filmstrip in step 2 of start() below.
			
			example = new OverlappingDice();
			/*(example as OverlappingDice).doFastCameraMove = true; // this part not ready yet*/
			
//			example = new Dice();
//			example = new Photos();
			
			addChild(example);
			if (example.requiresWait) {
				example.addEventListener(Event.COMPLETE, setupStart);
			}
			else {
				setupStart();
			}
		}
		
		public function setupStart(event:Event=null):void {
			stage.addEventListener(MouseEvent.CLICK, start); // click-to-start if line below is commented. 
															 // also acts as click-to-stop during render.
			
			// Comment out to start on click instead.
			start();
		}
		
		public function start(event:Event=null): void {
			
			if (filmStrip!=null) {
				if (filmStrip.rendering) {
					filmStrip.stopRendering();
				}
				return;
			}
			
			// Filmstrip Tutorial:
			
			// 1. Patch your animation library to use PulseControl
			//    (more info on this in the pulse_patch README file.)
			
			// 2. Wrap the scene to render in a new FilmStripScene. Use this one with Dice or OverlappingDice above...
			var dice:Dice = example as Dice;
			var scene:FilmStripScenePV3D = new FilmStripScenePV3D(dice.scene, dice.camera, dice.viewport, dice.renderer);
			
			// (2...)		-== Or, Sprite scene (uncomment Photos example above) ==-
//			var scene:FilmStripSceneSprite = new FilmStripSceneSprite(example);
			
			
			// 3. Make a FilmStrip with one or more scenes.
			filmStrip = new FilmStrip(scene);
			filmStrip.width = example.contentWidth;
			filmStrip.height = example.contentHeight;
			filmStrip.backgroundColor = 0xf0ecaf;
			filmStrip.durationInSeconds = 3;
			filmStrip.frameRate = 30; // 15 or 20 are also good choices.
			
			
			// Records and plays back frames from memory
			playbackBitmap = new PlaybackFromRAM(filmStrip);

			
			// --== More ==--
			
			
			// besides width and height, you can also set the top and left of the capture rectangle.
			
//			filmStrip.width = example.contentWidth-200;
//			filmStrip.height = example.contentHeight-200;
//			filmStrip.top = 100;
//			filmStrip.left = 100;
			
			
			// Advanced settings to explore.
			
			filmStrip.bufferMilliseconds = 1; // KNOW THIS!! FilmStrip is extremely processor intensive and can easily lock up your computer! 
										// The default setting of 1 gives some breathing room between frames, and allows the split-screen
										// view in this example to update once per frame.  
										//
										// If your computer does okay with the default setting of 1, you can try 0 cautiously, but expect
										// it to lock the player fully during render even if it processes a little faster in the end.
										//
										// You can also try setting this to a higher number to lighten processor load.
										//
										// In theory by tweaking these buffer settings it could be made safe for client-side usage, but
										// for the most part FilmStrip is for rendering video on your local system, not for live apps!
										// (That is, even if it runs on your computer you can't assume that other people's computers 
										// will be able to handle it without crashing.)
										
			filmStrip.subframeBufferMilliseconds = 0; // Adds time between each blur subframe, for a slower but less processor-intensive run. 
										// Try setting this value to 10 or 33 here to watch the blur process in full split-screen action!
			
//			filmStrip.blurMode = FilmStripBlurMode.NONE; // Simple frame sequence w/out blur.
										// Be sure to import com.animoto.filmstrip.FilmStripBlurMode.
										// If you're not adding filters, use this + WHOLE_SCENE captureMode (below) for fastest capture.

//			MotionBlurSettings.blendMode = BlendMode.LIGHTEN; // try this with the 2D Photos example.
										// Be sure to import com.animoto.filmstrip.MotionBlurSettings.
										// This setting makes more painterly-looking blurs, which sometimes look cleaner.
										// Standard blurs can sometimes darken up the object which this mode can help with.
			
			
			
			// Some more motion blur settings -- a longer blur. Look in the class to see all settings.
			
//			MotionBlurSettings.subframeDuration = 1;
//			MotionBlurSettings.strength *= 2;
//			MotionBlurSettings.maxFrames = 32;
//			MotionBlurSettings.peakAlpha = 0.2;
			
			
			
			// offset: Blur forward (1) instead of the default trailing blur (-1).
			// A future version could support panning between these values so blur goes both directions. 
			
//			MotionBlurSettings.offset = 1;
			
			
			
			// WHOLE_SCENE capture mode option
			
			// This is faster and often looks just fine, and you'll almost always want to use it
			// if motion blur is turned off. When the mode is used with blur, you'll see a visual problem
			// when objects overlap -- they can appear smashed together. To see this issue in action,
			// change to the OverlappingDice example scene above and uncomment all the additional settings
			// in the block below which exaggerate the blur. the blur and use the arrow keys during playback
			// to step to the frames where the dice move past each other. Sometimes it isn't very noticeable
			// during video playback though, so give it a try if render time is a concern.
			
//			filmStrip.captureMode = FilmStripCaptureMode.WHOLE_SCENE;
//			MotionBlurSettings.subframeDuration = 2;
//			MotionBlurSettings.maxFrames = 32;
//			MotionBlurSettings.strength = 3;
//			MotionBlurSettings.peakAlpha = .5;
//			MotionBlurSettings.useFixedFrameCount = true;
			
			
			
			
			filmStrip.addEventListener(FilmStripEvent.RENDER_STOPPED, super.exitSplitScreen);
			super.enterSplitScreen();
			
			filmStrip.startRendering();
			dispatchEvent(new Event("starting")); // used by AIR frameDumper project
		}
	}
}
