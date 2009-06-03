package filmstripexamples
{
	import caurina.transitions.Tweener;
	
	import flash.events.Event;
	import flash.filters.BitmapFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	
	public class OverlappingDice extends Dice
	{
		public var filter1:BitmapFilter;
		public var filter2:BitmapFilter;
		public var filter3:BitmapFilter;
		public var filter4:BitmapFilter;
		
		public function OverlappingDice()
		{
			addEventListener(Event.ADDED_TO_STAGE, setupScene);
		}
		
		override public function setupScene(event:Event=null):void {
			super.setupScene();
			camera.zoom = 2;
			camera.rotationX = 25;
			camera.rotationY = -45;
			cube2.x = 1100;
			cube1.rotationZ += 35;
		}
		override public function runAnimation():void {
			
//			filter2 = new BlurFilter(100, 0);
//			Tweener.addTween(filter1, {blurX:100, blurY:100, strength:20, time:1, transition:"easeoutcirc"});
//			Tweener.addTween(filter1, {blurX:0, blurY:0, strength:0, time:1, delay:1.1, transition:"easeincirc"});

			filter1 = new GlowFilter(0xFFFFFF, 0.5);
			filter2 = new GlowFilter(0xFFFFFF, 0.5);
			filter3 = new DropShadowFilter(cubeSize*2, 90, 0, 0.2);
			filter4 = new DropShadowFilter(cubeSize*2, 90, 0, 0.2);
			
			Tweener.addTween(filter1, {blurX:20, blurY:10, time:1, transition:"easeincirc"});
			Tweener.addTween(filter2, {blurX:20, blurY:10, time:1, transition:"easeincirc"});
			
			Tweener.addTween(cube1, {x:100, z:100, rotationX:360, time:1.7, transition:"easeoutcirc"});
			Tweener.addTween(cube1, {rotationY:180, rotationZ:-180, y:cubeSize/2, time:1.7, transition:"easeoutbounce"});
			Tweener.addTween(filter3, {distance:0, time:1.7, transition:"easeoutbounce"});
			
			Tweener.addTween(cube2, {z:-250, rotationX:180, time:2, transition:"easeoutquint"});
			Tweener.addTween(cube2, {rotationY:90, rotationZ:-90, y:cubeSize/2, time:2, transition:"easeoutbounce"});
			Tweener.addTween(filter4, {distance:0, time:2, transition:"easeoutbounce"});
			Tweener.addTween(cube2, {x:-650, time:.9, transition:"easeoutquad"});
			Tweener.addTween(cube2, {x:-30, time:.5, /* rotationY:180,  */delay:.6, transition:"easeoutcirc"});
			
			Tweener.addTween(camera, {x:-320, y:350, z:-800, rotationY:25, rotationX:15, zoom:1, time:2, transition:"easeinoutsine"});
		}
	}
}