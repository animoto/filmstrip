package tests
{
	import flash.events.Event;
	
	import org.as3lib.kitchensync.KitchenSync;
	import org.as3lib.kitchensync.action.KSTween;
	import org.as3lib.kitchensync.easing.Elastic;

	[SWF(backgroundColor="#FFFFFF", frameRate="30")]
	
	public class KitchenSyncPatchTest extends TestBase
	{
		public function KitchenSyncPatchTest()
		{
			super();
		}
		
		override protected function onAddedToStage(event:Event):void {
			super.onAddedToStage(event);
			
			// Animation
			KitchenSync.initialize(this);
			var tween:KSTween = new KSTween(target1, "x", NaN, 500, "5sec", "1sec", Elastic.easeOut);
			tween.start();
		}
	}
}