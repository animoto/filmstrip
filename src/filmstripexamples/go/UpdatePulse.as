package filmstripexamples.go
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import org.goasap.interfaces.ILiveManager;
	import org.goasap.interfaces.IManageable;

	public class UpdatePulse extends EventDispatcher implements ILiveManager
	{
		public static const PULSE: String = "pulse";
		
		public function UpdatePulse(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function onUpdate(pulseInterval:int, handlers:Array, currentTime:Number):void
		{
			dispatchEvent(new Event(PULSE));
		}
		
		public function reserve(handler:IManageable):void
		{
		}
		
		public function release(handler:IManageable):void
		{
		}
		
	}
}