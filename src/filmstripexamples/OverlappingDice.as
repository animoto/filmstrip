package filmstripexamples
{
	import caurina.transitions.Tweener;
	
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	
	public class OverlappingDice extends Dice
	{
		public function OverlappingDice()
		{
			addEventListener(Event.ADDED_TO_STAGE, setupScene);
		}
		
		override public function draw():void {
			super.draw();
			camera.zoom = 2;
			camera.rotationX = 25;
			camera.rotationY = -45;
			_cube2.x = 1000;
		}
		override public function runAnimation():void {
			
			filter1 = new GlowFilter(0xFFFFFF, 0.85, 20, 20, 5);
			filter2 = new BlurFilter(100, 0);
			
			Tweener.addTween(filter1, {blurX:100, blurY:100, strength:20, time:1, transition:"easeoutcirc"});
			Tweener.addTween(filter1, {blurX:0, blurY:0, strength:0, time:1, delay:1.1, transition:"easeincirc"});

			Tweener.addTween(filter2, {blurX:0, time:1, transition:"easeincirc"});
			
			Tweener.addTween(_cube1, {x:100, z:100, rotationX:360, time:1.7, transition:"easeoutcirc"});
			Tweener.addTween(_cube1, {rotationY:180, rotationZ:-180, y:cubeSize/2, time:1.7, transition:"easeoutbounce"});
			
			Tweener.addTween(_cube2, {z:-250, rotationX:180, time:2, transition:"easeoutquint"});
			Tweener.addTween(_cube2, {rotationY:90, rotationZ:-90, y:cubeSize/2, time:2, transition:"easeoutbounce"});
			Tweener.addTween(_cube2, {x:-650, time:.9, transition:"easeoutquad"});
			Tweener.addTween(_cube2, {x:-30, time:.5, /* rotationY:180,  */delay:.6, transition:"easeoutcirc"});
			
			Tweener.addTween(camera, {x:-320, y:350, z:-800, rotationY:25, rotationX:15, zoom:1, time:2, transition:"easeinoutsine"});
		}
	}
}