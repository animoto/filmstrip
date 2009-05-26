package filmstripexamples
{
	import caurina.transitions.Tweener;
	
	import com.animoto.filmstrip.PulseControl;
	
	import flash.events.Event;
	
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.core.proto.LightObject3D;
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.materials.BitmapFileMaterial;
	import org.papervision3d.materials.shadematerials.FlatShadeMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Cube;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.view.Viewport3D;
	import org.papervision3d.view.layer.BitmapEffectLayer;
	import org.papervision3d.view.layer.ViewportLayer;
	
	public class OverlappingDice extends Dice
	{
		public function OverlappingDice()
		{
			addEventListener(Event.ADDED_TO_STAGE, setupScene);
		}
		
		override protected function draw():void {
			super.draw();
			camera.zoom = 2;
			camera.rotationX = 25;
			camera.rotationY = -45;
			_cube2.x = 1000;
		}
		override protected function runAnimation():void {
			
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