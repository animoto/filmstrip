package filmstripexamples
{
	import caurina.transitions.Tweener;
	
	import flash.events.Event;
	
	import org.papervision3d.materials.MovieMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	
	public class PhotoDice extends Dice
	{
		
		[Embed(source="150sq.jpg")]
		public var photo:Class;
		
		public function PhotoDice() {
			super();
			requiresLoad = false;
		}
		
		override public function getDiceMatList():MaterialsList
		{
			return new MaterialsList({ all : new MovieMaterial(new photo()) });
		}
		
		override public function setupScene(event:Event=null):void {
			super.setupScene();
			super.begin();
		}
		
		override public function runAnimation():void {
			_cube1.x = -200;
			_cube1.z = -300;
			_cube1.y = 200;
			_cube2.x = 350;
			_cube2.y = 400;
			_cube2.z = -800;
			_cube1.scale = 1;
			_cube2.scale = 1.5;
			
			//Tweener.addTween(_cube1, {scale:1.5, x:20, rotationX:20, time:1, transition:"linear"});
			
			Tweener.addTween(_cube2, {z:-250, x:400, y:650, rotationY:20, time:1, transition:"linear"});
		}
	}
}