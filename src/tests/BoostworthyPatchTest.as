package tests
{
	import com.boostworthy.animation.easing.Transitions;
	import com.boostworthy.animation.management.AnimationManager;
	
	import flash.events.Event;

	[SWF(backgroundColor="#FFFFFF", frameRate="30")]
	
	public class BoostworthyPatchTest extends TestBase
	{
		public function BoostworthyPatchTest()
		{
			super();
		}
		
		override protected function onAddedToStage(event:Event):void {
			super.onAddedToStage(event);
			
			// Animation
			var mgr:AnimationManager = new AnimationManager();
			mgr.move(target1, 500, target1.y, 6000, Transitions.ELASTIC_OUT);
		}
	}
}