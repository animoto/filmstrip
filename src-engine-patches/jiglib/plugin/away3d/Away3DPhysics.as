package jiglib.plugin.away3d {
	import away3d.containers.View3D;
	import away3d.core.base.Mesh;
	import away3d.primitives.Cube;
	import away3d.primitives.Plane;
	import away3d.primitives.Sphere;
	
	import jiglib.geometry.JBox;
	import jiglib.geometry.JPlane;
	import jiglib.geometry.JSphere;
	import jiglib.math.JMatrix3D;
	import jiglib.physics.RigidBody;
	import jiglib.plugin.AbstractPhysics;	

	/**
	 * @author bartekd
	 */
	public class Away3DPhysics extends AbstractPhysics {
		
		private var view:View3D;

		public function Away3DPhysics(view:View3D, speed:Number = 1) {
			this.view = view;
			super(speed);
		}
		
		public function getMesh(body:RigidBody):Mesh {
			return Away3dMesh(body.skin).mesh;
		}
		
		/**
		 *  InitObject - same as in the constructor of Sphere primitive.
		 *  Example of an initObject: {radius:100, segmentsW:8, segmentsH:6}
		 *  Refer to Away3D docs for more info.
		 */
		public function createSphere(initObject:Object):RigidBody {
			var r:Number = initObject["radius"];
			var sphere:Sphere = new Sphere(initObject);
			view.scene.addChild(sphere);
			var jsphere:JSphere = new JSphere(new Away3dMesh(sphere), r);
			addBody(jsphere);
			return jsphere;
		}
		
		/**
		 *  {width:100, height:100, depth:100}
		 */
		public function createCube(initObject:Object):RigidBody {
			var w:Number = initObject["width"];			var d:Number = initObject["depth"];			var h:Number = initObject["height"];
			var cube:Cube = new Cube(initObject);
			view.scene.addChild(cube);
			var jbox:JBox = new JBox(new Away3dMesh(cube), w, d, h);
			addBody(jbox);
			return jbox;
		}
		
		/**
		 * {width:100, height:100}
		 */
		public function createGround(initObject:Object, level:Number):RigidBody {
			var ground:Plane = new Plane(initObject);
			// Away3D plane
			ground.rotationX = -90;
			ground.applyRotations();
			view.scene.addChild(ground);
			var jGround:JPlane = new JPlane(new Away3dMesh(ground));
			jGround.movable = false;
			jGround.setOrientation(JMatrix3D.rotationX(Math.PI / 2));
			jGround.y = level;
			addBody(jGround);
			return jGround;
		}
	}
}
