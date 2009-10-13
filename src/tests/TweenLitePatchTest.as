package tests
{
	import flash.events.Event;
	
	import gs.TweenLite;
	import gs.easing.Elastic;

	public class TweenLitePatchTest extends TestBase
	{
		public function TweenLitePatchTest()
		{
			super();
		}
		
		override protected function onAddedToStage(event:Event):void {
			super.onAddedToStage(event);
			
			// Animation
			TweenLite.to(target1, 5, { x:500, delay:1, ease:Elastic.easeOut });
		}
	}
}
