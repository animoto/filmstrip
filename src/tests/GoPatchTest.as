package tests
{
	import com.zaaz.goasap.core.PositionTween;
	
	import flash.text.TextField;
	
	import gs.easing.Elastic;
	
	public class GoPatchTest extends TestBase
	{
		public function GoPatchTest()
		{
			super();
		}
		
		override protected function onAddedToStage(event:Event):void {
			super.onAddedToStage(event);
			
			// Add a second target. Go is able to run different pulses at once which makes it possible
			// to play live animations and PulseControlled animations simultaneously.			
			var target2:Sprite = box(100, 80);
			setupWhitelistingTest( target1 );
			
			// Animations
			var tween1: PositionTween = new PositionTween(target1, 500, NaN, 5, Elastic.easeOut, 1);
			tween1.start();
			
			var tween2: PositionTween = new PositionTween(target2, 500, NaN, 5, Elastic.easeOut, 1);
			tween2.pulseInterval = 33;
			tween2.start();
		}
	}
}
