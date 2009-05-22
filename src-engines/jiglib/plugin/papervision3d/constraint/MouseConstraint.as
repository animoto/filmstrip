package jiglib.plugin.papervision3d.constraint
{
	import flash.events.MouseEvent;
	
	import jiglib.math.JNumber3D;
	import jiglib.physics.PhysicsSystem;
	import jiglib.physics.RigidBody;
	import jiglib.physics.constraint.JConstraintWorldPoint;
	
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.core.math.Plane3D;
	import org.papervision3d.core.proto.CameraObject3D;
	import org.papervision3d.core.utils.Mouse3D;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.view.Viewport3D;
	
	/**
	 * Facilitates dragging physics enabled objects in 3D space
	 * @author Reynaldo Columna aka reyco1
	 * 
	 */	
	public class MouseConstraint
	{
		private var body:RigidBody;
		private var camera:CameraObject3D;
		private var viewport:Viewport3D;		
		private var mouse3D:Mouse3D;
		private var physics:PhysicsSystem;
		private var initialMousePosition:JNumber3D;
		private var dragNormal:Number3D;
		private var planeToDragOn:Plane3D;
		private var dragConstraint:JConstraintWorldPoint;
		
		/**
		 * Adds mouse drag functionality to a 3d Object 
		 * @param mesh the DisplayObject3D to drag
		 * @param dragNormal the normal of the plane to drag the object on
		 * @param camera a reference to the camera object
		 * @param viewPort a reference to the viewport
		 * 
		 */		
		public function MouseConstraint(mesh:DisplayObject3D, dragNormal:Number3D, camera:CameraObject3D, viewPort:Viewport3D)
		{
			physics = PhysicsSystem.getInstance();
			
			this.body = physics.bodys[getBodyBasedOnSkin(mesh)];
			this.dragNormal = dragNormal;
			this.camera = camera;
			this.viewport = viewPort;
			
			Mouse3D.enabled = true;
			mouse3D = viewport.interactiveSceneManager.mouse3D;
			
			initialize();
		}
		
		private function initialize():void
		{
			initialMousePosition = new JNumber3D(mouse3D.x, mouse3D.y, mouse3D.z);
			planeToDragOn = new Plane3D(dragNormal, new Number3D(0, 0, 0)); //-initialMousePosition.z
			var bodyPoint:JNumber3D = JNumber3D.sub(initialMousePosition, body.currentState.position);
			dragConstraint = new JConstraintWorldPoint(body, bodyPoint, initialMousePosition);
			viewport.containerSprite.stage.addEventListener(MouseEvent.MOUSE_MOVE, startDrag);
		}
		
		private function startDrag(e:MouseEvent):void
		{
			var ray:Number3D = camera.unproject(viewport.containerSprite.mouseX, viewport.containerSprite.mouseY);
			ray = Number3D.add(ray, new Number3D(camera.x, camera.y, camera.z));			
			var cameraVertex3D:Vertex3D = new Vertex3D(camera.x, camera.y, camera.z);
			var rayVertex3D:Vertex3D = new Vertex3D(ray.x, ray.y, ray.z);
			var intersectPoint:Vertex3D = planeToDragOn.getIntersectionLine(cameraVertex3D, rayVertex3D);			
			dragConstraint.worldPosition = new JNumber3D(intersectPoint.x, intersectPoint.y, intersectPoint.z);
		}
		
		private function getBodyBasedOnSkin(skin:DisplayObject3D):int
		{
			for (var i:String in physics.bodys)
			{
				if (skin == physics.bodys[i].skin.mesh)
				{
					return int(i);
				}
			}
			return -1;
		}
		
		/**
		 * Destryss the mouse constraint 
		 * 
		 */		
		public function destroy():void
		{
			viewport.containerSprite.stage.removeEventListener(MouseEvent.MOUSE_MOVE, startDrag);
			dragConstraint.disableConstraint();
			body.setActive();
			
			body = null;
			camera = null;
			viewport = null;		
			mouse3D = null;
			initialMousePosition = null;
			dragNormal = null;
			planeToDragOn = null;
			dragConstraint = null;
		}

	}
}