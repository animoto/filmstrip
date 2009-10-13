package tests
{
	import com.gskinner.motion.GTween;
	
	import flash.events.Event;
	
	import gs.easing.Elastic;

	[SWF(backgroundColor="#FFFFFF", frameRate="30")]
	
	public class GTweenPatchTest extends TestBase
	{
		public function GTweenPatchTest()
		{
			super();
		}
		
		override protected function onAddedToStage(event:Event):void {
			super.onAddedToStage(event);
			
			// Animation
			new GTween(target1, 5, { x:500 }, { ease:Elastic.easeOut }).delay = 1;
			
			// PulseControl also works in FRAME timingMode, but does not work in TIME mode.
			
			// To run this test, uncomment the next two lines and comment out the new GTween line above.
			
//			GTween.timingMode = GTween.FRAME;
//			new GTween(target1, 150, { x:500 }, { ease:Elastic.easeOut }).delay = 30;
		}
	}
}
