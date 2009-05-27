package jiglib.plugin {
	import flash.utils.getTimer;
	
	import jiglib.physics.PhysicsSystem;
	import jiglib.physics.RigidBody;
	import jiglib.physics.constraint.JConstraint;
	import jiglib.physics.constraint.JConstraintPoint;	

	/**
	 * @author bartekd
	 */
	public class AbstractPhysics {
		
		private var initTime:int;
		private var stepTime:int;
		private var speed:Number;
		private var deltaTime:Number = 0;
		
		public function AbstractPhysics(speed:Number = 5) {
			this.speed = speed;
			initTime = getTimer();
		}
		
		public function addBody(body:RigidBody):void {
			PhysicsSystem.getInstance().addBody(body as RigidBody);
		}
		
		public function removeBody(body:RigidBody):void {
			PhysicsSystem.getInstance().removeBody(body as RigidBody);
		}
		
		public function get engine():PhysicsSystem {
			return PhysicsSystem.getInstance();
		}
		
		public function step():void {
			stepTime = getTimer();
	        deltaTime = ((stepTime - initTime) / 1000) * speed;
	        initTime = stepTime;
	        PhysicsSystem.getInstance().integrate(deltaTime);
		}
	}
}
