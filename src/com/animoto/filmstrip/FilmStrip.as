package com.animoto.filmstrip
{
	import com.animoto.filmstrip.managers.FilmStripBitmapScene;
	import com.animoto.filmstrip.scenes.FilmStripScene;
	import com.animoto.util.StopWatch;
	
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * Renders a 2D or 3D scene to frames of simulated video, with options
	 * for adding motion blur and bitmap effects.
	 * 
	 * Important! You need to apply the PulseControl patch to your animation 
	 * system for the FilmStrip rendering system to work. 
	 * 
	 * @author moses gunesch
	 */
	public class FilmStrip extends EventDispatcher
	{
		// -== Global ==-

		/**
		 * When set false, known errors are traced instead of thrown,
		 * allowing render processes to continue.
		 */
		public static var throwErrors: Boolean = true;
		
		/**
		 * Global error function that traces or throws errors based on
		 * the value of <code>throwErrors</code>.
		 * 
		 * @param message Error message.
		 */
		public static function error(message:String):void {
			if (throwErrors)
				throw new Error(message);
			else
				trace ("* FilmStrip Error: " + message + " *");
		}
		
		// -== Public Properties ==-
		
		/**
		 * Stack of scenes to render each frame.
		 */
		public var scenes: Array = new Array();
		
		/**
		 * Cache for the stack of bitmaps that is captured once to
		 * generate a final frame image. 
		 * 
		 * Note: if you get weird artifacts, try adding this sprite 
		 * to the displaylist during render.
		 */
		public var bitmapScene: FilmStripBitmapScene;
		
		/**
		 * Frame output width (if unset the value of the first 
		 * scene's actualContentWidth is looked up).
		 */
		public var width: Number = NaN;
		
		/**
		 * Frame output height (if unset the value of the first 
		 * scene's actualContentHeight is looked up).
		 */
		public var height: Number = NaN;
		
		/**
		 * Sets the top edge of the capture area in the scene.
		 */
		public var top: Number = 0;
		
		/**
		 * Sets the left edge of the capture area in the scene.
		 */
		public var left: Number = 0;
		
		/**
		 * Scales the frame image as it is captured.
		 */
		public var scale: Number = 1;
		
		/**
		 * Determines the framerate of the final video.
		 */
		public var frameRate: int = 15;
		
		/**
		 * When set, the render stops when this many seconds of
		 * video have been generated -- or leave unset if you plan
		 * to stop the render manually.
		 */
		public var durationInSeconds: Number = NaN;
		
		/**
		 * Determines capture mode, which signficantly impacts what
		 * processes take place during the render.
		 * 
		 * If you are just doing a simple frame-capture without motion-blur
		 * or effects, be sure to set this to WHOLE_SCENE.
		 */
		public var captureMode:String = FilmStripCaptureMode.EACH_OBJECT;
		
		/**
		 * Determines the motion-blur mode, which signficantly impacts what
		 * processes take place during the render.
		 * 
		 * If you are just doing a simple frame-capture without motion-blur,
		 * be sure to set this to NONE.
		 */
		public var blurMode:String = FilmStripBlurMode.MATTE_SUBFRAMES;
		
		/**
		 * Whether frame bitmaps are transparent.
		 */
		public var transparent: Boolean = false;
		
		/**
		 * If frame bitmaps are not transparent, determines background color.
		 */
		public var backgroundColor: Number = 0xFFFFFF;
		
		/**
		 * Milliseconds of "breathing room" between each frame cycle.
		 * 
		 * Using 1 results is fast and usually allows the player to update visually.
		 * Using 0 can at times be faster but will generally 'lock' the player and
		 * can crash it. Set to higher values for slower but safer results or to 
		 * run a render in the background of an otherwise active program. (FilmStrip
		 * is NOT recommended for use in live apps as it is very processor-intensive.)
		 */
		public var bufferMilliseconds: int = 1;
		
		/**
		 * Milliseconds of "breathing room" between each motion-blur subframe cycle.
		 * 
		 * Setting this to 1 or higher will lengthen renders but can signficantly 
		 * lighten processor load. This setting also lets you watch the step-by-step
		 * process of each blur as it is being created.
		 */
		public var subframeBufferMilliseconds: int = 0;
		
		/**
		 * Whether this instance is actively processing a render.
		 */
		public function get rendering(): Boolean {
			return _busy;
		}
		
		/**
		 * Time value of a frame based on frameRate, in milliseconds.
		 */
		public function get frameDuration(): int {
			return int(1000 / frameRate);
		}
		
		/**
		 * Number of frames rendered since startRendering() was last called.
		 */
		public function get framesRendered(): int {
			return _frameCount;
		}
		
		// -== Private Properties ==-
		
		protected var _busy: Boolean = false;
		protected var _startTime:Number;
		protected var _currentTime:Number;
		protected var _index: int;
		protected var _buffer:Timer = new Timer(1, 1);
		protected var _clock: StopWatch = new StopWatch();
		protected var _frameCount: int = 0;
		
		// -== Public Properties ==-
		
		/**
		 * Constructor accepts the primary scene to render, you can add more afterwards using addScene.
		 * 
		 * @param scene An instance of a subclass of FilmStripScene such as FilmStripScenePV3D or FilmStripSceneSprite.
		 */
		public function FilmStrip(scene:FilmStripScene)
		{
			super();
			addScene( scene );
			bitmapScene = new FilmStripBitmapScene();
			_buffer.addEventListener(TimerEvent.TIMER_COMPLETE, doRenderNext);
		}
		
		/**
		 * A single filmstrip can render a stack of scenes.
		 * 
		 * @param scene An instance of a subclass of FilmStripScene such as FilmStripScenePV3D or FilmStripSceneSprite.
		 */
		public function addScene(scene:FilmStripScene):void {
			scenes.push( scene );
		}
		
		/**
		 * Gets a typed scene instance from the public scenes array.
		 * 
		 * @param index		Index in scenes array
		 * @return 			An instance of a subclass of FilmStripScene such as FilmStripScenePV3D or FilmStripSceneSprite.
		 */
		public function getSceneAt(index:int):FilmStripScene {
			return scenes[index] as FilmStripScene;
		}
		
		/**
		 * Begin rendering the FilmStrip.
		 * 
		 * @param width				Capture width, which defaults to the first scene's actualContentWidth if not specified.
		 * @param height			Capture height, which defaults to the first scene's actualContentHeight if not specified.
		 * @param frameRate			Capture frames per second, which may differ from your project SWF's frameRate.
		 * @param durationInSeconds	Capture duration in seconds; number of frames captured will vary based on frameRate.
		 * @param transparent		Whether frames captured are transparent or opaque.
		 * @param backgroundColor	If transparent is false, the background matte color.
		 */
		public function startRendering(width:Number=NaN, height:Number=NaN, frameRate:Number=NaN, durationInSeconds:Number=NaN, transparent:*=null, backgroundColor:Number=NaN):void {
			if (_busy) {
				stopRendering();
			}
			
			if (!isNaN(width))					{ this.width = int(width); }
			if (!isNaN(height))					{ this.height = int(height); }
			if (!isNaN(frameRate))				{ this.frameRate = int(frameRate); }
			if (!isNaN(durationInSeconds))		{ this.durationInSeconds = durationInSeconds; }
			if (transparent!=null)				{ this.transparent = Boolean(transparent); }
			if (!isNaN(backgroundColor))		{ this.backgroundColor = backgroundColor; }
			
			if (scenes==null || (scenes!=null && scenes.length==0)) {
				error("Scene missing.");
				return;
			}
			
			// If no size was defined, default to size of first scene.
			if (isNaN(this.width))			{ this.width = getSceneAt(0).actualContentWidth; }
			if (isNaN(this.height))			{ this.height = getSceneAt(0).actualContentHeight; }
			
			PulseControl.freeze();
			_startTime = _currentTime = PulseControl.getCurrentTime();
			if (blurMode!=FilmStripBlurMode.NONE) {
				_currentTime += frameDuration; // Shave a frame, to ensure blur has change to work with in case animations are at beginning.
			}
			_index = 0;
			_frameCount = 0;
			_clock.reset();
			_clock.start();
			_busy = true;
			dispatchEvent( new FilmStripEvent(FilmStripEvent.RENDER_STARTED) );
			doRenderNext();
		}
		
		/**
		 * Stops a render in progress.
		 * 
		 * (Note: needs improvement, to exit all processes in scene 
		 * and blur controllers or wait for them to finish their cycle.)
		 */
		public function stopRendering():void {
			if (!_busy) {
				return;
			}
			_busy = false;
			try { _buffer.stop(); } catch (e:Error){}
			try { bitmapScene.clearDisplay(); } catch (e:Error){}
			_clock.pause();
			try { (scenes[_index] as FilmStripScene).controller.stopRendering(); } catch (e:Error){}
			_index = 0;
			var stats: String = "Time elapsed: "+_clock.seconds.toFixed(1)+" seconds "+
								 "for "+(_frameCount * frameRate / 1000).toFixed(1)+" seconds of " + frameRate + "fps video. " +
								"("+_frameCount+" frames @ " + (_clock.seconds/_frameCount).toFixed(1)+" seconds/frame)";
			trace(stats);
			dispatchEvent( new FilmStripEvent(FilmStripEvent.RENDER_STOPPED, null, stats) );
			PulseControl.resume(); // unfreezes time for animation engines
		}
		
		/**
		 * Clears memory pointers so this instance can be deleted.
		 * 
		 * @param destroyScenes		Pass true to also destroy this instance's scenes.
		 */
		public function destroy(destroyScenes:Boolean=false):void {
			stopRendering();
			if (destroyScenes) {
				for each (var scene:FilmStripScene in scenes) {
					scene.destroy();
				}
			}
			scenes = null;
			bitmapScene = null;
			_buffer.removeEventListener(TimerEvent.TIMER_COMPLETE, renderNextScene);
			_buffer = null;
		}
		
		// -== Private Methods ==-
		
		protected function renderNextScene():void {
			// even when buffer is 0, this helps decouple processes a little and prevent player lock-up.
			_buffer.delay = bufferMilliseconds;
			_buffer.start();
		}
		
		protected function doRenderNext(event:TimerEvent=null):void {
			if (!_busy) {
				return;
			}
			var scene:FilmStripScene = (scenes[_index] as FilmStripScene);
			if (scene==null) {
				error("Scene not valid.");
				if (!throwErrors) {
					sceneCompleteCallback();
				}
				return;
			}
			if (_index==0) {
				bitmapScene.clearDisplay();
			}
			scene.controller.init(this, sceneCompleteCallback);
			if (_busy) {
				scene.controller.renderFrame(_currentTime);
			}
		}
		
		protected function sceneCompleteCallback():void {
			if (!_busy) {
				return;
			}
			if (++_index < scenes.length) {
				renderNextScene();
			}
			else {
				frameComplete();
			}
		}

		protected function frameComplete():void {
			// Render frame
			var data:BitmapData;
			data = new BitmapData(width, height, transparent, backgroundColor);
			data.draw(bitmapScene);
			
			bitmapScene.dump();
			
			dispatchEvent( new FilmStripEvent(FilmStripEvent.FRAME_RENDERED, data) );
			
			_frameCount++;
			if (done()) { // TODO: be sure time is not left backed up on subframe
				stopRendering();
			}
			else {
				_currentTime += frameDuration;
				_index = 0;
				renderNextScene();
			}
		}
		
		protected function done():Boolean {
			if (isNaN(durationInSeconds)) {
				return false;
			}
			var next:Number = _currentTime + (1000/frameRate);
			var end:Number = _startTime + durationInSeconds*1000;
			return (next > end);
		}
	}
}