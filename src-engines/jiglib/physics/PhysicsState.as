
package jiglib.physics {

	import jiglib.math.*;
	
	public class PhysicsState {
		
		public var position:JNumber3D=new JNumber3D();
		public var orientation:JMatrix3D=new JMatrix3D();
		public var linVelocity:JNumber3D=new JNumber3D();
		public var rotVelocity:JNumber3D=new JNumber3D();
	}
	
}
