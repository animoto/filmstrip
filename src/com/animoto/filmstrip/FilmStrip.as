package com.animoto.filmstrip
{
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class FilmStrip extends EventDispatcher
	{
		public var scenes: Array = new Array();
		public var bitmapScene: FilmStripBitmapScene;
		public var frameRate: int = 15;
		public var duration: Number;
		public var bufferMilliseconds: int = 1;
		
		public function get rendering(): Boolean {
			return _rendering;
		}
		
		protected var _start:Number;
		protected var _rendering:Boolean;
		protected var _buffer:Timer = new Timer(1, 1);
		
		public function FilmStrip(scene:FilmStripScene)
		{
			super();
			addScene( scene );
			bitmapScene = new FilmStripBitmapScene(this, frameComplete);
			_buffer.addEventListener(TimerEvent.TIMER_COMPLETE, renderNextFrame, false, 0, true);
		}
		
		public function addScene(scene:FilmStripScene):void {
			scenes.push( scene );
		}
		
		public function startRendering(durationInSeconds:Number=NaN):void {
			if (scenes!=null) {
				_rendering = true;
				duration = durationInSeconds;
				PulseControl.freeze();
				_start = PulseControl.getCurrentTime();
				renderNextFrame();
			}
		}
		
		public function stopRendering():void {
			if (_rendering) {
				_rendering = false;
				PulseControl.resume();
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
			if (isNaN(duration)) {
				return false;
			}
			var next:Number = PulseControl.getCurrentTime() + (1000/frameRate);
			var end:Number = _start + duration*1000;
			return (next > end);
		}
	}
}