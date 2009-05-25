package com.animoto.filmstrip
{
	import com.animoto.filmstrip.scenes.AbstractFilmStripScene;
	import com.animoto.filmstrip.scenes.IFilmStripScene;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

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
		public var captureMode:String = FilmStripCaptureMode.WHOLE_SCENE;
		public var blurMode:String = FilmStripBlurMode.NONE;
		public var transparent: Boolean = false;
		public var backgroundColor: Number = 0xFFFFFF;
		public var bufferMilliseconds: int = 0;
		
		public function get rendering(): Boolean {
			return _busy;
		}
		
		protected var _busy: Boolean = false;
		protected var _startTime:Number;
		protected var _currentTime:Number;
		protected var _index: int;
		protected var _buffer:Timer = new Timer(1, 1);
		
		public function FilmStrip(scene:IFilmStripScene)
		{
			super();
			addScene( scene );
			bitmapScene = new FilmStripBitmapScene();
			_buffer.addEventListener(TimerEvent.TIMER_COMPLETE, buffered_renderNext);
		}
		
		public function addScene(scene:IFilmStripScene):void {
			scenes.push( scene );
		}
		
		public function getSceneAt(index:int):IFilmStripScene {
			return scenes[index] as IFilmStripScene;
		}
		
		public function startRendering(width:Number=NaN, height:Number=NaN, frameRate:Number=NaN, durationInSeconds:Number=NaN, blurMode:String=null, captureMode:String=null, transparent:*=null, backgroundColor:Number=NaN, bufferMilliseconds:Number=NaN):void {
			if (_busy) {
				stopRendering();
			}
			
			if (!isNaN(width))					{ this.width = int(width); }
			if (!isNaN(height))					{ this.height = int(height); }
			if (!isNaN(frameRate))				{ this.frameRate = int(frameRate); }
			if (!isNaN(durationInSeconds))		{ this.durationInSeconds = durationInSeconds; }
			if (blurMode!=null)					{ this.blurMode = blurMode; }
			if (captureMode!=null)				{ this.captureMode = captureMode; }
			if (transparent!=null)				{ this.transparent = Boolean(transparent); }
			if (!isNaN(backgroundColor))		{ this.backgroundColor = backgroundColor; }
			if (!isNaN(bufferMilliseconds))		{ this.bufferMilliseconds = int(bufferMilliseconds); }
			
			if (scenes==null || (scenes!=null && scenes.length==0)) {
				error("Scene missing.");
				return;
			}
				
			// If no size was defined, default to size of first scene.
			if (isNaN(this.width))			{ this.width = getSceneAt(0).actualContentWidth; }
			if (isNaN(this.height))			{ this.height = getSceneAt(0).actualContentWidth; }
			
			PulseControl.freeze();
			_startTime = _currentTime = PulseControl.getCurrentTime();
			_index = 0;
			_busy = true;
			renderNextScene();
		}
		
		public function stopRendering():void {
			if (_busy) {
				dispatchEvent( new FilmStripEvent(FilmStripEvent.RENDER_STOPPED) );
				PulseControl.resume(); // unfreezes time for animation engines
			}
			bitmapScene.clearDisplay();
			_buffer.reset();
			if (_busy) {
				try { (scenes[_index] as AbstractFilmStripScene).controller.stopRendering(); }
				catch (e:Error) { }
			}
			_index = 0;
			_busy = false;
		}
		
		public function destroy():void {
			stopRendering();
			scenes = null;
			bitmapScene = null;
			_buffer.removeEventListener(TimerEvent.TIMER_COMPLETE, renderNextScene);
			_buffer = null;
		}
		
		// -== Private Methods ==-
		
		protected function renderNextScene():void {
			if (bufferMilliseconds==0) {
				buffered_renderNext();
			}
			else {
				_buffer.delay = bufferMilliseconds;
				_buffer.start();
			}
		}
		
		protected function buffered_renderNext(event:TimerEvent=null):void {
			var scene:AbstractFilmStripScene = (scenes[_index] as AbstractFilmStripScene);
			if (scene==null || !(scene is IFilmStripScene)) {
				error("Scene not valid.");
				if (!throwErrors) {
					sceneCompleteCallback();
				}
				return;
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
			var data:BitmapData;
			if (bitmapScene.numChildren==1 && bitmapScene.getChildAt(0) is Bitmap) {
				data = (bitmapScene.getChildAt(0) as Bitmap).bitmapData;
			}
			else {
				data = new BitmapData(width, height, transparent, backgroundColor);
				data.draw(bitmapScene);
			}
			dispatchEvent( new FilmStripEvent(FilmStripEvent.FRAME_RENDERED, data) );
			
			if (done()) { // TODO: be sure time is not left backed up on subframe
				stopRendering();
			}
			else {
				_currentTime += int(1000 / frameRate);
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