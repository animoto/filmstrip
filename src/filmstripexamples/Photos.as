package filmstripexamples
{
	import caurina.transitions.Tweener;
	import caurina.transitions.properties.FilterShortcuts;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	
	public class Photos extends ExampleScene
	{
		public var image1:Bitmap;
		public var image2:Bitmap;
		public var image3:Bitmap;
		
		[Embed(source="../../embed/img1.jpg")]
		public var img1:Class;
		
		[Embed(source="../../embed/img2.jpg")]
		public var img2:Class;
		
		[Embed(source="../../embed/img3.jpg")]
		public var img3:Class;
		
		public function Photos()
		{
			super();
			image1 = new img1() as Bitmap;
			image2 = new img2() as Bitmap;
			image3 = new img3() as Bitmap;
			image1.smoothing = true;
			image2.smoothing = true;
			image3.smoothing = true;
			draw();
			dispatchEvent(new Event(Event.COMPLETE));
			runAnimation();
		}
		
		public function draw():void {
			
			image1.x = -1000;
			image1.y = 50;
			image1.scaleX = image1.scaleY = 1.2;
			image1.rotation = Math.random()*360;
			addChild(image1);
			
			image2.x = 1000;
			image2.y = -350;
			image2.scaleX = image2.scaleY = 1.2;
			image2.rotation = Math.random()*360;
			addChild(image2);
			
			image3.x = 500;
			image3.y = 1000;
			image3.scaleX = image3.scaleY = 1.2;
			image3.rotation = Math.random()*360;
			addChild(image3);
			
			image1.filters = [new DropShadowFilter(150, 90, 0, 0.25, 8, 8)];
			image2.filters = [new DropShadowFilter(150, 90, 0, 0.25, 8, 8)];
			image3.filters = [new DropShadowFilter(150, 90, 0, 0.25, 8, 8)];
		}
		
		public function runAnimation():void {
			FilterShortcuts.init();
			Tweener.addTween(image1, { x:400, y:200, rotation:-5, time:1.75, transition:"easeOutQuint" });
			Tweener.addTween(image1, { _DropShadow_distance:4, scaleX:1, scaleY:1, time:.75, transition:"easeOutBounce" });
			Tweener.addTween(image2, { x:100, y:20, rotation:15, time:1.75, delay:.5, transition:"easeOutQuint" });
			Tweener.addTween(image2, { _DropShadow_distance:4, scaleX:1, scaleY:1, time:.75, delay:.5, transition:"easeOutBounce" });
			Tweener.addTween(image3, { x:260, y:100, rotation:5, time:1.75, delay:1, transition:"easeOutQuint" });
			Tweener.addTween(image3, { _DropShadow_distance:4, scaleX:1, scaleY:1, time:.75, delay:1, transition:"easeOutBounce" });
		}
	}
}