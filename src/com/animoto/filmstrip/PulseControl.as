package com.animoto.filmstrip
{
	import com.animoto.StopWatch;
	
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class PulseControl
	{
		private static var timer: StopWatch = new StopWatch();
		private static var pulseShape: Shape = new Shape();
		private static var listening: Boolean = false;
		private static var frozen: Boolean = false;
		private static var frameDuration: Number;
		private static var dispatcher: EventDispatcher = new EventDispatcher();
		
		public function PulseControl()
		{
		}
		
		public static function freeze(frameRate:int=15):void {
			pulseShape.removeEventListener(Event.ENTER_FRAME, dispatchEnterFrame);
			frameDuration = (1000/frameRate);
			timer.pause();
			frozen = true;
		}
		
		public static function getCurrentTime():Number {
			return timer.milliseconds;
		}
		
		public static function advance():void {
			if (listening && frozen) {
				timer.milliseconds += frameDuration;
				dispatchEnterFrame();
			}
		}

		public static function resume():void {
			frozen = false;
			if (listening) {
				timer.start();
				pulseShape.addEventListener(Event.ENTER_FRAME, dispatchEnterFrame);
			}
		}

		public static function addEnterFrameListener(listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			dispatcher.addEventListener(Event.ENTER_FRAME, listener, useCapture, priority, useWeakReference);
			listening = true;
			pulseShape.addEventListener(Event.ENTER_FRAME, dispatchEnterFrame);
			if (!frozen)
				timer.start();
		}
		
		public static function removeEnterFrameListener(listener:Function, useCapture:Boolean=false):void
		{
			dispatcher.removeEventListener(Event.ENTER_FRAME, listener, useCapture);
			if (dispatcher.hasEventListener(Event.ENTER_FRAME)==false) {
				listening = false;
				pulseShape.addEventListener(Event.ENTER_FRAME, dispatchEnterFrame);
			}
			if (frozen)
				timer.pause();
		}
		
		private static function dispatchEnterFrame(e:Event=null):void {
			dispatcher.dispatchEvent(new Event(Event.ENTER_FRAME));
		}
	}
}

