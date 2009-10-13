package
{
	import flash.display.Sprite;
	
	import tests.*;

	[SWF(backgroundColor="#FFFFFF", frameRate="30")]
	
	/**
	 * Makes it easier to boot up a test file in Flex / Flash Builder.
	 */
	public class RunTest extends Sprite
	{
		public function RunTest()
		{
			super();
			
			addChild( new TweenLitePatchTest() );
			
//			addChild( new TweenerPatchTest() );

//			addChild( new GTweenPatchTest() );

//			addChild( new KitchenSyncPatchTest() );

//			addChild( new BoostworthyPatchTest() );
			
//			addChild( new GoPatchTest() );
		}
	}
}