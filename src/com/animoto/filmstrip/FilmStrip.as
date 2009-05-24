package com.animoto.filmstrip
{
	import com.animoto.filmstrip.scenes.IFilmStripScene;
	
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
		public var transparent: Boolean = false;
		public var backgroundColor: Number = 0xFFFFFF;
		public var bufferMilliseconds: int = 0;
		
		public function get rendering(): Boolean {
			return _rendering;
		}
		
		protected var _start:Number;
		protected var _rendering:Boolean;
		protected var _buffer:Timer = new Timer(0, 1);
		
		public function FilmStrip(scene:IFilmStripScene)
		{
			super();
			addScene( scene );
			bitmapScene = new FilmStripBitmapScene(this, frameComplete);
			_buffer.addEventListener(TimerEvent.TIMER_COMPLETE, renderNextFrame, false, 0, true);
		}
		
		public function addScene(scene:IFilmStripScene):void {
			scenes.push( scene );
		}
		
		public function getSceneAt(index:int):IFilmStripScene {
			return scenes[index] as IFilmStripScene;
		}
		
		public function startRendering(width:Number=NaN, height:Number=NaN, frameRate:Number=NaN, durationInSeconds:Number=NaN, transparent:*=null, backgroundColor:Number=NaN, bufferMilliseconds:Number=NaN):void {
			
			if (!isNaN(width))					{ this.width = int(width); }
			if (!isNaN(height))					{ this.height = int(height); }
			if (!isNaN(frameRate))				{ this.frameRate = int(frameRate); }
			if (!isNaN(durationInSeconds))		{ this.durationInSeconds = durationInSeconds; }
			if (transparent!=null)				{ this.transparent = Boolean(transparent); }
			if (!isNaN(backgroundColor))		{ this.backgroundColor = backgroundColor; }
			if (!isNaN(bufferMilliseconds))		{ this.bufferMilliseconds = int(bufferMilliseconds); }
			
			if (scenes!=null && scenes.length>0) {
				// If no size was defined, default to size of first scene.
				if (isNaN(this.width))			{ this.width = getSceneAt(0).contentWidth; }
				if (isNaN(this.height))			{ this.height = getSceneAt(0).contentWidth; }
				_rendering = true;
				durationInSeconds = durationInSeconds;
				PulseControl.freeze();
				_start = PulseControl.getCurrentTime();
				renderNextFrame();
			}
		}
		
		public function stopRendering():void {
			if (_rendering) {
				_rendering = false;
				_buffer.reset();
				bitmapScene.release();
				PulseControl.resume(); // unfreezes time for animation engines
				dispatchEvent( new FilmStripEvent(FilmStripEvent.RENDER_STOPPED) );
			}
		}
		
		public function destroy():void {
			scenes = null;
			_buffer.removeEventListener(TimerEvent.TIMER_COMPLETE, renderNextFrame);
			_buffer = null;
			bitmapScene.destroy();
			bitmapScene = null;
		}
		
		// -== Private Methods ==-
		
		protected function frameComplete(data:BitmapData):void {
			dispatchEvent( new FilmStripEvent(FilmStripEvent.FRAME_RENDERED, data) );
			if (done()) {
				stopRendering();
			}
			else if (bufferMilliseconds==0) {
				renderNextFrame();
			}
			else {
				_buffer.delay = bufferMilliseconds;
				_buffer.start();
			}
		}
		
		protected function renderNextFrame(event:TimerEvent=null):void {
			PulseControl.advanceTime( 1000 / frameRate );
			bitmapScene.render();
		}
		
		protected function done():Boolean {
			if (isNaN(durationInSeconds)) {
				return false;
			}
			var next:Number = PulseControl.getCurrentTime() + (1000/frameRate);
			var end:Number = _start + durationInSeconds*1000;
			return (next > end);
		}
	}
}