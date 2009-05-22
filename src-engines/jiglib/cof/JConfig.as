package jiglib.cof {

	public class JConfig {
		public static var solverType:String = "ACCUMULATED"; //allowable value: FAST,NORMAL,ACCUMULATED
		public static var boxCollisionsType:String = "EDGEBASE"; //allowable value: EDGEBASE or SORTBASE
		public static var rotationType:String = "DEGREES"; // can be either RADIANS or DEGREES;
		public static var limitLinVelocities:Number = 500; // limit the max value of body's line velocity;
		public static var limitAngVelocities:Number = 10; // limit the max value of body's angle velocity;
		public static var allowedPenetration:Number = 0.0001; // How much penetration to allow
		public static var collToll:Number = 0.005; // the tolerance for collision detection 
		public static var damping:Number = 0.995;
		public static var velThreshold:Number = 0.5;
		public static var angVelThreshold:Number = 10;
		public static var posThreshold:Number = 0.1; // change for detecting position changes during deactivation
		public static var orientThreshold:Number = 0.2; // change for detecting orientation changes during deactivation.
		public static var deactivationTime:Number = 1; // how long it takes to go from active to frozen when stationary.
		public static var numPenetrationRelaxationTimesteps:Number = 10; // number of timesteps to resolve penetration over
		public static var numCollisionIterations:Number = 4; // number of collision iterations
		public static var numContactIterations:Number = 4; // number of contact iteratrions
	}
}