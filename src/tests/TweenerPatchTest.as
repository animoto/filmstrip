package tests
{
	import caurina.transitions.Tweener;
	
	import flash.events.Event;

	[SWF(backgroundColor="#FFFFFF", frameRate="30")]
	
	public class TweenerPatchTest extends TestBase
	{
		public function TweenerPatchTest()
		{
			super();
		}
		
		override protected function onAddedToStage(event:Event):void {
			super.onAddedToStage(event);
			
			// Animation
			Tweener.addTween(target1, { x:500, time:5, delay:1, transition:"easeoutelastic" });
		}
	}
}
