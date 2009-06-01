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

		public static var throwErrors: Boolean = true;
		public static function error(message:String):void {
			if (throwErrors)
				throw new Error(message);
			else
				trace ("* FilmStrip Error: " + message + " *");
		}
		
		public var scenes: Array = new Array();
		public var bitmapScene: FilmStripBitmapScene;
		public var width: Number = NaN;
		public var height: Number = NaN;
		public var frameRate: int = 15;
		public var durationInSeconds: Number = NaN;
		public var captureMode:String = FilmStripCaptureMode.EACH_OBJECT;
		public var blurMode:String = FilmStripBlurMode.MATTE_SUBFRAMES;
		public var transparent: Boolean = false;
		public var backgroundColor: Number = 0xFFFFFF;
		public var bufferMilliseconds: int = 0;
		public var subframeBufferMilliseconds: int = 0;
		
		public function get rendering(): Boolean {
			return _busy;
		}
		
		public function get frameDuration(): int {
			return int(1000 / frameRate);
		}
		
		protected var _busy: Boolean = false;
		protected var _startTime:Number;
		protected var _currentTime:Number;
		protected var _index: int;
		protected var _buffer:Timer = new Timer(1, 1);
		protected var _clock: StopWatch = new StopWatch();
		protected var _frameCount: int;
		
		public function FilmStrip(scene:FilmStripScene)
		{
			super();
			addScene( scene );
			bitmapScene = new FilmStripBitmapScene();
			_buffer.addEventListener(TimerEvent.TIMER_COMPLETE, doRenderNext);
		}
		
		public function addScene(scene:FilmStripScene):void {
			scenes.push( scene );
		}
		
		public function getSceneAt(index:int):FilmStripScene {
			return scenes[index] as FilmStripScene;
		}
		
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
		
		public function stopRendering():void {
			if (_busy) {
				_clock.pause();
				var stats: String = "Time elapsed: "+_clock.seconds+" seconds "+
									 "for "+(_frameCount * frameRate / 1000).toFixed(1)+" seconds of video. " +
									"("+_frameCount+" frames @ " + (_clock.seconds/_frameCount).toFixed(1)+" seconds/frame)";
				trace(stats);
				dispatchEvent( new FilmStripEvent(FilmStripEvent.RENDER_STOPPED, null, stats) );
				PulseControl.resume(); // unfreezes time for animation engines
			}
			bitmapScene.clearDisplay();
			_buffer.reset();
			if (_busy) {
				try { (scenes[_index] as FilmStripScene).controller.stopRendering(); }
				catch (e:Error) { }
			}
			_index = 0;
			_busy = false;
		}
		
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
			scene.controller.renderFrame(_currentTime);
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
			// TODO: bitmap scene may need to be attached to stage to fully render correctly
			
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