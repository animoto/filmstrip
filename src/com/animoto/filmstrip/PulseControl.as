package com.animoto.filmstrip
{
	import com.animoto.util.StopWatch;
	
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/**
	 * External time controller that can be easily patched into 
	 * animation engines and other pulse-based code.
	 * 
	 * To enable it: 
	 * 
	 * 1) Replace obj.addEventListener(Event.ENTER_FRAME, handler) 
	 * with PulseControl.addEngineListener(handler) in tween engines, 
	 * and PulseControl.addEnterFrameListener(handler) in your project
	 * code. Similarly replace remove calls.
	 * 
	 * 2) Replace all getTimer() or new Date().getTime() calls 
	 * with PulseControl.getCurrentTime() in both tween engines and
	 * project code.
	 * 
	 * @author moses gunesch
	 */
	public class PulseControl
	{
		// Replace all getTimer() (or new Date.getTime()) calls in active code with calls to this method.
		public static function getCurrentTime():int {
			return timer.milliseconds;
		}
		
		// You can use this to find out whether any FilmStrips are currently rendering.
		public static function isFrozen():Boolean {
			return frozen;
		}
		
		// Replace enterframe listeners in your active code with this call. (Not dispatched when PulseControl is frozen for FilmStrip render.)
		public static function addEnterFrameListener(listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			liveDispatcher.addEventListener(Event.ENTER_FRAME, listener, useCapture, priority, useWeakReference);
			onAdd();
		}
		
		// Replace enterframe listener removal in your active code with this call.
		public static function removeEnterFrameListener(listener:Function, useCapture:Boolean=false):void
		{
			liveDispatcher.removeEventListener(Event.ENTER_FRAME, listener, useCapture);
			onRemove();
		}
		
		// Engine patches should use this method instead to listen for enterframe.
		// (Dispatched when frozen. If using outside of an animation engine be forewarned that a rapid series of events are fired for each motion-blur cycle.)
		public static function addEngineListener(listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			engineDispatcher.addEventListener(Event.ENTER_FRAME, listener, useCapture, priority, useWeakReference);
			onAdd();
		}
		
		// Engine patches should use this method to remove enterframe listeners.
		public static function removeEngineListener(listener:Function, useCapture:Boolean=false):void
		{
			engineDispatcher.removeEventListener(Event.ENTER_FRAME, listener, useCapture);
			onRemove();
		}
		
		// -== Time control methods used by FilmStrip ==-
		
		public static function freeze():void {
			pulseShape.removeEventListener(Event.ENTER_FRAME, dispatchEnterFrame);
			timer.pause();
			frozen = true;
		}
		
		public static function advanceTime(milliseconds:int):void {
			setTime(timer.milliseconds + milliseconds);
		}
		
		public static function setTime(milliseconds:int):void {
			if (listening && frozen) {
				timer.milliseconds = milliseconds;
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
		
		// -== Private ==-
		
		private static var timer: StopWatch = new StopWatch();
		private static var pulseShape: Shape = new Shape();
		private static var listening: Boolean = false;
		private static var frozen: Boolean = false;
		private static var engineDispatcher: EventDispatcher = new EventDispatcher();
		private static var liveDispatcher: EventDispatcher = new EventDispatcher();
		
		private static function onAdd():void {
			listening = true;
			if (!frozen) {
				timer.start();
				pulseShape.addEventListener(Event.ENTER_FRAME, dispatchEnterFrame);
			}
		}
		
		private static function onRemove():void {
			if (liveDispatcher.hasEventListener(Event.ENTER_FRAME)==false && engineDispatcher.hasEventListener(Event.ENTER_FRAME)==false) {
				listening = false;
				pulseShape.removeEventListener(Event.ENTER_FRAME, dispatchEnterFrame);
			}
			if (frozen)
				timer.pause();
		}
		
		private static function dispatchEnterFrame(e:Event=null):void {
			// This event order should work in 99.9% of cases.
			engineDispatcher.dispatchEvent(new Event(Event.ENTER_FRAME));
			if (!frozen)
				liveDispatcher.dispatchEvent(new Event(Event.ENTER_FRAME));
		}
	}
}

