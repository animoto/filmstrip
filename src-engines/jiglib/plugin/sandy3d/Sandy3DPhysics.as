package jiglib.plugin.sandy3d
{
	import jiglib.geometry.JBox;
	import jiglib.geometry.JPlane;
	import jiglib.geometry.JSphere;
	import jiglib.math.JMatrix3D;
	import jiglib.physics.RigidBody;
	import jiglib.plugin.AbstractPhysics;
	
	import sandy.core.Scene3D;
	import sandy.core.scenegraph.Shape3D;
	import sandy.materials.Appearance;
	import sandy.primitive.Box;
	import sandy.primitive.Plane3D;
	import sandy.primitive.Sphere;
	

	/**
	 * @author bartekd
	 */
	public class Sandy3DPhysics extends AbstractPhysics
	{
		private var scene:Scene3D;

		public function Sandy3DPhysics(scene:Scene3D, speed:Number = 1) 
		{
			super(speed);
			this.scene = scene;
		}
		
		public function getMesh(body:RigidBody):Shape3D 
		{
			return Sandy3DMesh(body.skin).mesh;
		}

		public function createSphere( name:String, appearance:Appearance, radius:Number=100, segmentsW:int=8, segmentsH:int = 6):RigidBody 
		{
			var sphere:Sphere = new Sphere(name, radius, segmentsW, segmentsH);
			if (appearance) sphere.appearance = appearance;
			scene.root.addChild( sphere );
			var jsphere:JSphere = new JSphere(new Sandy3DMesh(sphere), radius);
			addBody(jsphere);
			return jsphere;
		}
		
		public function createCube( name:String, appearance:Appearance, width:Number=500, depth:Number=500, height:Number=500, segments:int=1):RigidBody 
		{
			var cube:Box = new Box( name, width, height, depth, "tri", segments );
			if( appearance ) cube.appearance = appearance;
			scene.root.addChild(cube);
			var jbox:JBox = new JBox(new Sandy3DMesh(cube), width, depth, height);
			addBody(jbox);
			return jbox;
		}
		
		public function createGround(name:String, appearance:Appearance, size:Number, level:Number, p_nQuality:uint = 1):RigidBody 
		{
			var ground:Plane3D = new Plane3D( name, size, size, p_nQuality, p_nQuality);//, Plane3D.ZX_ALIGNED);
			ground.y = level;
			if( appearance ) ground.appearance = appearance;
			scene.root.addChild(ground);
			var jGround:JPlane = new JPlane(new Sandy3DMesh(ground));
			jGround.movable = false;
			jGround.setOrientation(JMatrix3D.rotationX(Math.PI / 2));
			jGround.y = level;
			addBody(jGround);
			return jGround;
		}
	}
}
