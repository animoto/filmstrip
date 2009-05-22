/*
Copyright (c) 2007 Danny Chapman 
http://www.rowlhouse.co.uk

This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.
Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:
1. The origin of this software must not be misrepresented; you must not
claim that you wrote the original software. If you use this software
in a product, an acknowledgment in the product documentation would be
appreciated but is not required.
2. Altered source versions must be plainly marked as such, and must not be
misrepresented as being the original software.
3. This notice may not be removed or altered from any source
distribution.
 */

/**
 * @author Muzer(muzerly@gmail.com), speedok(speedok@gmail.com)
 * @link http://code.google.com/p/jiglibflash
 */


package jiglib.physics {

	import jiglib.cof.JConfig;
	import jiglib.collision.CollPointInfo;
	import jiglib.collision.CollisionInfo;
	import jiglib.collision.CollisionSystem;
	import jiglib.math.JMatrix3D;
	import jiglib.math.JNumber3D;
	import jiglib.physics.constraint.JConstraint;
	
	public class PhysicsSystem {
		
		private static var _currentPhysicsSystem:PhysicsSystem;
		
		private const _maxVelMag:Number = 0.5;
        private const _minVelForProcessing:Number = 0.001;
		
		
		private var _bodies:Array;
		private var _activeBodies:Array;
		private var _collisions:Array;
		private var _constraints:Array;
		private var _controllers:Array;
		 
		 
		private var _gravityAxis:int;
		private var _gravity:JNumber3D;
		
		private var _doingIntegration:Boolean;
		
		private var preProcessCollisionFn:Function;
		private var preProcessContactFn:Function;
		private var processCollisionFn:Function;
		private var processContactFn:Function;
		
		private var _cachedContacts:Array;
		private var _collisionSystem:CollisionSystem;
		
		
		public static function getInstance():PhysicsSystem {
	    	if (!_currentPhysicsSystem) {
				trace("version: JigLibFlash v0.32 (2009-5-14)");
			    _currentPhysicsSystem = new PhysicsSystem();
		    }
		    return _currentPhysicsSystem;
	    }
		
		public function PhysicsSystem() {
			
			setSolverType(JConfig.solverType);
			_doingIntegration = false;
			_bodies = new Array();
			_collisions = new Array();
			_activeBodies = new Array();
			_constraints = new Array();
			_controllers = new Array();
			
			_cachedContacts = new Array();
			_collisionSystem = new CollisionSystem();
			
			setGravity(JNumber3D.multiply(JNumber3D.UP, -10));
		}
		 
		private function getAllExternalForces(dt:Number):void {
			for (var i:String in _bodies) {
				_bodies[i].addExternalForces(dt);
			}
			
			for (i in _controllers) {
				_controllers[i].updateController(dt);
			}
		}
		
		public function getCollisionSystem():CollisionSystem {
			return _collisionSystem;
		}
		 
		public function setGravity(gravity:JNumber3D):void {
			_gravity = gravity;
			if (_gravity.x == _gravity.y && _gravity.y == _gravity.z) {
				_gravityAxis = -1;
			}
			_gravityAxis = 0;
			if (Math.abs(_gravity.y) > Math.abs(_gravity.z)) {
				_gravityAxis = 1;
			}
			if (Math.abs(_gravity.z) > Math.abs(_gravity.toArray()[_gravityAxis])) {
				_gravityAxis = 2;
			}
		}
		
		public function get gravity():JNumber3D {
			return _gravity;
		}
		
		public function get gravityAxis():int {
			return _gravityAxis;
		}
		
		public function get bodys():Array {
			return _bodies;
		}
		
		public function addBody(body:RigidBody):void {
			if (!findBody(body)) {
			    _bodies.push(body);
				_collisionSystem.addCollisionBody(body);
			}
		}
		
		public function removeBody(body:RigidBody):void {
			if (findBody(body)) {
			    _bodies.splice(_bodies.indexOf(body), 1);
				_collisionSystem.removeCollisionBody(body);
			}
		}
		
		public function removeAllBodys():void {
			_bodies = [];
			_collisionSystem.removeAllCollisionBodys();
		}
		
		public function addConstraint(constraint:JConstraint):void {
			if (!findConstraint(constraint)) {
			    _constraints.push(constraint);
			}
		}
		
		public function removeConstraint(constraint:JConstraint):void {
			if (findConstraint(constraint)) {
			    _constraints.splice(_constraints.indexOf(constraint), 1);
			}
		}
		
		public function removeAllConstraints():void {
			_constraints = [];
		}
		
		public function addController(controller:PhysicsController):void {
			if (!findController(controller)) {
			    _controllers.push(controller);
			}
		}
		
		public function removeController(controller:PhysicsController):void {
			if (findController(controller)) {
			    _controllers.splice(_controllers.indexOf(controller), 1);
			}
		}
		
		public function removeAllControllers():void {
			_controllers = [];
		}
		
		public function setSolverType(type:String):void {
			switch(type) {
				case "FAST":
				    preProcessCollisionFn=preProcessCollisionFast;
					preProcessContactFn=preProcessCollisionFast;
					processCollisionFn=processCollision;
					processContactFn=processCollision;
				    return;
				case "NORMAL":
				    preProcessCollisionFn=preProcessCollisionNormal;
					preProcessContactFn=preProcessCollisionNormal;
					processCollisionFn=processCollision;
					processContactFn=processCollision;
					return;
				case "ACCUMULATED":
					preProcessCollisionFn=preProcessCollisionNormal;
					preProcessContactFn=preProcessCollisionAccumulated;
					processCollisionFn=processCollision;
					processContactFn=processCollisionAccumulated;
				    return;
				default:
					preProcessCollisionFn = preProcessCollisionNormal;
					preProcessContactFn = preProcessCollisionNormal;
					processCollisionFn = processCollision;
					processContactFn = processCollision;
					return;
			}
		}
		 
		private function findBody(body:RigidBody):Boolean {
			for (var i:String in _bodies) {
				if (body == _bodies[i]) {
					return true;
				}
			}
			return false;
		}
		private function findConstraint(constraint:JConstraint):Boolean {
			for (var i:String in _constraints) {
				if (constraint == _constraints[i]) {
					return true;
				}
			}
			return false;
		}
		private function findController(controller:PhysicsController):Boolean {
			for (var i:String in _controllers) {
				if (controller == _controllers[i]) {
					return true;
				}
			}
			return false;
		}
		
		private function preProcessCollisionFast(collision:CollisionInfo, dt:Number):void {
			collision.satisfied = false;
			
			var body0:RigidBody=collision.objInfo.body0;
			var body1:RigidBody=collision.objInfo.body1;
			
			var N:JNumber3D=collision.dirToBody;
			var timescale:Number = JConfig.numPenetrationRelaxationTimesteps * dt;
			var approachScale:Number = 0;
			var ptInfo:CollPointInfo;
			var tempV:JNumber3D;
			var ptNum:int = collision.pointInfo.length;
			
			if (ptNum > 1) {
				var avR0:JNumber3D = new JNumber3D();
				var avR1:JNumber3D = new JNumber3D();
				var avDepth:Number = 0;
				
				for(var i:int=0; i<ptNum; i++) {
					ptInfo=collision.pointInfo[i];
					avR0 = JNumber3D.add(avR0, ptInfo.r0);
					avR1 = JNumber3D.add(avR1, ptInfo.r1);
					avDepth += ptInfo.initialPenetration;
				}
				avR0 = JNumber3D.divide(avR0, Number(ptNum));
				avR1 = JNumber3D.divide(avR1, Number(ptNum));
				avDepth /= ptNum;
				 
				collision.pointInfo = [];
				collision.pointInfo[0] = new CollPointInfo();
				collision.pointInfo[0].r0 = avR0;
				collision.pointInfo[0].r1 = avR1;
				collision.pointInfo[0].initialPenetration = avDepth;
			}
			 
			var len:int = collision.pointInfo.length;
			for (i = 0; i < len; i++) {
				ptInfo=collision.pointInfo[i];
				if(!body0.movable) {
					ptInfo.denominator=0;
				} else {
					tempV = JNumber3D.cross(N, ptInfo.r0);
					JMatrix3D.multiplyVector(body0.worldInvInertia, tempV);
					ptInfo.denominator = body0.invMass + JNumber3D.dot(N, JNumber3D.cross(ptInfo.r0, tempV));
				}
				if(body1.movable) {
					tempV=JNumber3D.cross(N,ptInfo.r1);
					JMatrix3D.multiplyVector(body1.worldInvInertia,tempV);
					ptInfo.denominator+=(body1.invMass+JNumber3D.dot(N,JNumber3D.cross(ptInfo.r1,tempV)));
				}
				if(ptInfo.denominator<JNumber3D.NUM_TINY) {
					ptInfo.denominator=JNumber3D.NUM_TINY;
				}
				
				if(ptInfo.initialPenetration>JConfig.allowedPenetration) {
					ptInfo.minSeparationVel=(ptInfo.initialPenetration - JConfig.allowedPenetration) / timescale;
				} else {
					approachScale = -0.1 * (ptInfo.initialPenetration - JConfig.allowedPenetration) / JConfig.allowedPenetration;
					if(approachScale<JNumber3D.NUM_TINY) {
						approachScale=JNumber3D.NUM_TINY;
					} else if (approachScale>1) {
						approachScale=1;
					}
					ptInfo.minSeparationVel = approachScale * (ptInfo.initialPenetration - JConfig.allowedPenetration) / Math.max(dt, JNumber3D.NUM_TINY);
				}
				if(ptInfo.minSeparationVel>_maxVelMag) {
					ptInfo.minSeparationVel=_maxVelMag;
				}
			}
		}
		 
		private function preProcessCollisionNormal(collision:CollisionInfo, dt:Number):void {
			collision.satisfied = false;
			 
			var body0:RigidBody=collision.objInfo.body0;
			var body1:RigidBody=collision.objInfo.body1;
			 
			var N:JNumber3D=collision.dirToBody;
			var timescale:Number = JConfig.numPenetrationRelaxationTimesteps * dt;
			var approachScale:Number = 0;
			var ptInfo:CollPointInfo;
			var tempV:JNumber3D;
			var len:int = collision.pointInfo.length;
			for (var i:int = 0; i < len; i++) {
				ptInfo=collision.pointInfo[i];
				if(!body0.movable) {
					ptInfo.denominator=0;
				} else {
					tempV = JNumber3D.cross(N, ptInfo.r0);
					JMatrix3D.multiplyVector(body0.worldInvInertia, tempV);
					ptInfo.denominator = body0.invMass + JNumber3D.dot(N, JNumber3D.cross(ptInfo.r0, tempV));
				}
				 
				if(body1.movable) {
					tempV=JNumber3D.cross(N,ptInfo.r1);
					JMatrix3D.multiplyVector(body1.worldInvInertia,tempV);
					ptInfo.denominator+=(body1.invMass+JNumber3D.dot(N,JNumber3D.cross(ptInfo.r1,tempV)));
				}
				if(ptInfo.denominator<JNumber3D.NUM_TINY) {
					ptInfo.denominator=JNumber3D.NUM_TINY;
				}
				if(ptInfo.initialPenetration>JConfig.allowedPenetration) {
					ptInfo.minSeparationVel=(ptInfo.initialPenetration - JConfig.allowedPenetration) / timescale;
				}else {
					approachScale = -0.1 * (ptInfo.initialPenetration - JConfig.allowedPenetration) / JConfig.allowedPenetration;
					if(approachScale<JNumber3D.NUM_TINY) {
						approachScale=JNumber3D.NUM_TINY;
					} else if(approachScale>1) {
						approachScale=1;
					}
					ptInfo.minSeparationVel = approachScale * (ptInfo.initialPenetration - JConfig.allowedPenetration) / Math.max(dt, JNumber3D.NUM_TINY);
				}
				if(ptInfo.minSeparationVel>_maxVelMag) {
					ptInfo.minSeparationVel=_maxVelMag;
				}
			}
			
		}
		
		private function preProcessCollisionAccumulated(collision:CollisionInfo, dt:Number):void {
			collision.satisfied = false;
			var body0:RigidBody = collision.objInfo.body0;
			var body1:RigidBody = collision.objInfo.body1;
			 
			var N:JNumber3D=collision.dirToBody;
			var timescale:Number = JConfig.numPenetrationRelaxationTimesteps * dt;
			 
			var tempV:JNumber3D;
			var ptInfo:CollPointInfo;
			var approachScale:Number = 0;
			
			var len:int = collision.pointInfo.length;
			for (var i:int = 0; i < len; i++) {
				ptInfo = collision.pointInfo[i];
				if(!body0.movable) {
					ptInfo.denominator=0;
				} else {
					tempV = JNumber3D.cross(N, ptInfo.r0);
					JMatrix3D.multiplyVector(body0.worldInvInertia, tempV);
					ptInfo.denominator = body0.invMass + JNumber3D.dot(N, JNumber3D.cross(ptInfo.r0, tempV));
				}
				 
				if(body1.movable) {
					tempV=JNumber3D.cross(N,ptInfo.r1);
					JMatrix3D.multiplyVector(body1.worldInvInertia,tempV);
					ptInfo.denominator+=(body1.invMass+JNumber3D.dot(N,JNumber3D.cross(ptInfo.r1,tempV)));
				}
				if(ptInfo.denominator<JNumber3D.NUM_TINY) {
					ptInfo.denominator = JNumber3D.NUM_TINY;
				}
				if(ptInfo.initialPenetration>JConfig.allowedPenetration) {
					ptInfo.minSeparationVel=(ptInfo.initialPenetration - JConfig.allowedPenetration) / timescale;
				} else {
					approachScale = -0.1 * (ptInfo.initialPenetration - JConfig.allowedPenetration) / JConfig.allowedPenetration;
					if(approachScale<JNumber3D.NUM_TINY) {
						approachScale = JNumber3D.NUM_TINY;
					} else if(approachScale>1) {
						approachScale = 1;
					}
					ptInfo.minSeparationVel = approachScale * (ptInfo.initialPenetration - JConfig.allowedPenetration) / Math.max(dt, JNumber3D.NUM_TINY);
				}
				 
				ptInfo.accumulatedNormalImpulse = 0;
				ptInfo.accumulatedNormalImpulseAux = 0;
				ptInfo.accumulatedFrictionImpulse = new JNumber3D();
				
				var bestDistSq:Number = 0.04;
				var bp:BodyPair = new BodyPair(body0, body1, JNumber3D.ZERO, JNumber3D.ZERO);
				
				for (var j:String in _cachedContacts) {
					if (!(bp.body0 == _cachedContacts[j].Pair.body0 && bp.body1 == _cachedContacts[j].Pair.body1)) {
						continue;
					}
					var distSq:Number = (_cachedContacts[j].Pair.body0 == body0)?
					JNumber3D.sub(_cachedContacts[j].Pair.r, ptInfo.r0).modulo2:
					JNumber3D.sub(_cachedContacts[j].Pair.r, ptInfo.r1).modulo2;
					
					if (distSq < bestDistSq) {
						bestDistSq = distSq;
						ptInfo.accumulatedNormalImpulse = _cachedContacts[j].Impulse.normalImpulse;
						ptInfo.accumulatedNormalImpulseAux = _cachedContacts[j].Impulse.normalImpulseAux;
						ptInfo.accumulatedFrictionImpulse = _cachedContacts[j].Impulse.frictionImpulse;
						if (_cachedContacts[j].Pair.body0 != body0) {
							ptInfo.accumulatedFrictionImpulse = JNumber3D.multiply(ptInfo.accumulatedFrictionImpulse, -1);
						}
					}
				}
				
				if (ptInfo.accumulatedNormalImpulse != 0) {
					var impulse:JNumber3D = JNumber3D.multiply(N, ptInfo.accumulatedNormalImpulse);
					impulse = JNumber3D.add(impulse, ptInfo.accumulatedFrictionImpulse);
					body0.applyBodyWorldImpulse(impulse, ptInfo.r0);
				    body1.applyBodyWorldImpulse(JNumber3D.multiply(impulse, -1), ptInfo.r1);
				}
				if (ptInfo.accumulatedNormalImpulseAux != 0) {
					impulse = JNumber3D.multiply(N, ptInfo.accumulatedNormalImpulseAux);
					body0.applyBodyWorldImpulseAux(impulse, ptInfo.r0);
				    body1.applyBodyWorldImpulseAux(JNumber3D.multiply(impulse, -1), ptInfo.r1);
				}
			}
		}
		
		private function processCollision(collision:CollisionInfo, dt:Number):Boolean {
			collision.satisfied = true;
			
			var body0:RigidBody=collision.objInfo.body0;
			var body1:RigidBody=collision.objInfo.body1;
			 
			var gotOne:Boolean = false;
			var N:JNumber3D = collision.dirToBody;
			 
			var deltaVel:Number = 0;
			var normalVel:Number = 0;
			var finalNormalVel:Number = 0;
			var normalImpulse:Number = 0;
			var impulse:JNumber3D;
			var Vr0:JNumber3D;
			var Vr1:JNumber3D;
			var ptInfo:CollPointInfo;
			
			var len:int = collision.pointInfo.length;
			for (var i:int = 0; i < len; i++) {
				ptInfo = collision.pointInfo[i];
				
				Vr0 = body0.getVelocity(ptInfo.r0);
				Vr1 = body1.getVelocity(ptInfo.r1);
				normalVel = JNumber3D.dot(JNumber3D.sub(Vr0, Vr1), N);
				if (normalVel > ptInfo.minSeparationVel) {
					continue;
				}
				finalNormalVel = -1 * collision.mat.restitution * normalVel;
				if (finalNormalVel < _minVelForProcessing) {
					finalNormalVel = ptInfo.minSeparationVel;
				}
				deltaVel = finalNormalVel - normalVel;
				if (deltaVel <= _minVelForProcessing) {
				    continue;
				}
				normalImpulse = deltaVel / ptInfo.denominator;
				
				gotOne = true;
				impulse = JNumber3D.multiply(N, normalImpulse);
				
				body0.applyBodyWorldImpulse(impulse, ptInfo.r0);
				body1.applyBodyWorldImpulse(JNumber3D.multiply(impulse, -1), ptInfo.r1);
				
				var tempV:JNumber3D;
				var VR:JNumber3D=JNumber3D.sub(Vr0,Vr1);
				var tangent_vel:JNumber3D=JNumber3D.sub(VR,JNumber3D.multiply(N,JNumber3D.dot(VR,N)));
				var tangent_speed:Number = tangent_vel.modulo;
				
				if(tangent_speed>_minVelForProcessing) {
					var T:JNumber3D = JNumber3D.multiply(JNumber3D.divide(tangent_vel, tangent_speed), -1);
					var denominator:Number = 0;
					
					if(body0.movable) {
						tempV=JNumber3D.cross(T,ptInfo.r0);
						JMatrix3D.multiplyVector(body0.worldInvInertia,tempV);
						denominator = body0.invMass + JNumber3D.dot(T, JNumber3D.cross(ptInfo.r0, tempV));
					}
					
					if(body1.movable) {
						tempV=JNumber3D.cross(T,ptInfo.r1);
						JMatrix3D.multiplyVector(body1.worldInvInertia,tempV);
						denominator += (body1.invMass + JNumber3D.dot(T, JNumber3D.cross(ptInfo.r1, tempV)));
					}
					 
					if (denominator > JNumber3D.NUM_TINY) {
						var impulseToReverse:Number = Math.pow(collision.mat.friction, 3) * tangent_speed / denominator;
						
						T = JNumber3D.multiply(T, impulseToReverse);
						body0.applyBodyWorldImpulse(T, ptInfo.r0);
						body1.applyBodyWorldImpulse(JNumber3D.multiply(T, -1), ptInfo.r1);
					}
				}
			}
			 
			if (gotOne) {
				body0.setConstraintsAndCollisionsUnsatisfied();
				body1.setConstraintsAndCollisionsUnsatisfied();
			}
			return gotOne;
		}
		
		private function processCollisionAccumulated(collision:CollisionInfo, dt:Number):Boolean {
			collision.satisfied = true;
			var gotOne:Boolean = false;
			var N:JNumber3D=collision.dirToBody;
			var body0:RigidBody=collision.objInfo.body0;
			var body1:RigidBody=collision.objInfo.body1;
			 
			var deltaVel:Number = 0;
			var normalVel:Number = 0;
			var normalImpulse:Number = 0;
			var impulse:JNumber3D;
			var Vr0:JNumber3D;
			var Vr1:JNumber3D;
			var ptInfo:CollPointInfo;
			
			var len:int = collision.pointInfo.length;
			for (var i:int = 0; i < len; i++) {
				ptInfo = collision.pointInfo[i];
				 
				Vr0 = body0.getVelocity(ptInfo.r0);
				Vr1 = body1.getVelocity(ptInfo.r1);
				normalVel = JNumber3D.dot(JNumber3D.sub(Vr0, Vr1), N);
				 
				deltaVel = -normalVel;
				if (ptInfo.minSeparationVel < 0) {
					deltaVel += ptInfo.minSeparationVel;
				}
				 
				if (Math.abs(deltaVel) > _minVelForProcessing) {
					normalImpulse = deltaVel / ptInfo.denominator;
					var origAccumulatedNormalImpulse:Number = ptInfo.accumulatedNormalImpulse;
					ptInfo.accumulatedNormalImpulse = Math.max(ptInfo.accumulatedNormalImpulse + normalImpulse, 0);
					var actualImpulse:Number = ptInfo.accumulatedNormalImpulse - origAccumulatedNormalImpulse;
					
					impulse = JNumber3D.multiply(N, actualImpulse);
					body0.applyBodyWorldImpulse(impulse, ptInfo.r0);
				    body1.applyBodyWorldImpulse(JNumber3D.multiply(impulse, -1), ptInfo.r1);
					
					gotOne = true;
				}
				
				Vr0 = body0.getVelocityAux(ptInfo.r0);
				Vr1 = body1.getVelocityAux(ptInfo.r1);
				normalVel = JNumber3D.dot(JNumber3D.sub(Vr0, Vr1), N);
				 
				deltaVel = -normalVel;
				if (ptInfo.minSeparationVel > 0) {
					deltaVel += ptInfo.minSeparationVel;
				}
				if (Math.abs(deltaVel) > _minVelForProcessing) {
					normalImpulse = deltaVel / ptInfo.denominator;
					origAccumulatedNormalImpulse = ptInfo.accumulatedNormalImpulseAux;
					ptInfo.accumulatedNormalImpulseAux = Math.max(ptInfo.accumulatedNormalImpulseAux + normalImpulse, 0);
					actualImpulse = ptInfo.accumulatedNormalImpulseAux - origAccumulatedNormalImpulse;
					
					impulse = JNumber3D.multiply(N, actualImpulse);
					body0.applyBodyWorldImpulseAux(impulse, ptInfo.r0);
				    body1.applyBodyWorldImpulseAux(JNumber3D.multiply(impulse, -1), ptInfo.r1);
					
					gotOne = true;
				}
				 
				 
				if(ptInfo.accumulatedNormalImpulse > 0) {
					Vr0 = body0.getVelocity(ptInfo.r0);
				    Vr1 = body1.getVelocity(ptInfo.r1);
					var tempV:JNumber3D;
				    var VR:JNumber3D = JNumber3D.sub(Vr0, Vr1);
				    var tangent_vel:JNumber3D = JNumber3D.sub(VR, JNumber3D.multiply(N, JNumber3D.dot(VR, N)));
				    var tangent_speed:Number = tangent_vel.modulo;
					if (tangent_speed > _minVelForProcessing) {
						
						var T:JNumber3D = JNumber3D.multiply(JNumber3D.divide(tangent_vel, tangent_speed), -1);
						var denominator:Number = 0;
						if(body0.movable) {
							tempV = JNumber3D.cross(T, ptInfo.r0);
							JMatrix3D.multiplyVector(body0.worldInvInertia, tempV);
							denominator = body0.invMass + JNumber3D.dot(T, JNumber3D.cross(ptInfo.r0, tempV));
						}
						if(body1.movable) {
							tempV = JNumber3D.cross(T, ptInfo.r1);
							JMatrix3D.multiplyVector(body1.worldInvInertia, tempV);
							denominator += (body1.invMass + JNumber3D.dot(T, JNumber3D.cross(ptInfo.r1, tempV)));
						}
						if (denominator > JNumber3D.NUM_TINY) {
							var impulseToReverse:Number = tangent_speed / denominator;
							var frictionImpulseVec:JNumber3D = JNumber3D.multiply(T, impulseToReverse);
							 
							var origAccumulatedFrictionImpulse:JNumber3D = ptInfo.accumulatedFrictionImpulse.clone();
							ptInfo.accumulatedFrictionImpulse = JNumber3D.add(ptInfo.accumulatedFrictionImpulse, frictionImpulseVec);
							 
							var AFIMag:Number = ptInfo.accumulatedFrictionImpulse.modulo;
							var maxAllowedAFIMag:Number = collision.mat.friction * ptInfo.accumulatedNormalImpulse;
							 
							if (AFIMag > JNumber3D.NUM_TINY && AFIMag > maxAllowedAFIMag)
							{
								ptInfo.accumulatedFrictionImpulse = JNumber3D.multiply(ptInfo.accumulatedFrictionImpulse, maxAllowedAFIMag / AFIMag);
							}
							 
							var actualFrictionImpulse:JNumber3D = JNumber3D.sub(ptInfo.accumulatedFrictionImpulse, origAccumulatedFrictionImpulse);
							 
							body0.applyBodyWorldImpulse(actualFrictionImpulse, ptInfo.r0);
							body1.applyBodyWorldImpulse(JNumber3D.multiply(actualFrictionImpulse, -1), ptInfo.r1);
						}
				    }
				}
			}
			if (gotOne) {
				body0.setConstraintsAndCollisionsUnsatisfied();
				body1.setConstraintsAndCollisionsUnsatisfied();
			}
			return gotOne;
		}
		
		private function updateContactCache():void {
			_cachedContacts = [];
			var collInfo:CollisionInfo;
			var ptInfo:CollPointInfo;
			var fricImpulse:JNumber3D;
			var contact:Object;
			for (var i:String in _collisions) {
				collInfo = _collisions[i];
				for (var j:String in collInfo.pointInfo) {
					ptInfo = collInfo.pointInfo[j];
					fricImpulse = (collInfo.objInfo.body0.id > collInfo.objInfo.body1.id)?
					ptInfo.accumulatedFrictionImpulse:JNumber3D.multiply(ptInfo.accumulatedFrictionImpulse, -1);
					 
					contact = new Object();
					contact.Pair = new BodyPair(collInfo.objInfo.body0, collInfo.objInfo.body1, ptInfo.r0, ptInfo.r1);
					contact.Impulse = new CachedImpulse(ptInfo.accumulatedNormalImpulse, ptInfo.accumulatedNormalImpulseAux, ptInfo.accumulatedFrictionImpulse);
					
					_cachedContacts.push(contact);
				}
			}
		}
		
		private function handleAllConstraints(dt:Number, iter:int, forceInelastic:Boolean):void {
			var origNumCollisions:int = _collisions.length;
			
			for (var k:String in _constraints) {
				_constraints[k].preApply(dt);
			}
			
			if(forceInelastic) {
				for(var i:String in _collisions) {
					preProcessContactFn(_collisions[i], dt);
					_collisions[i].mat.restitution = 0;
					_collisions[i].satisfied = false;
				}
			} else {
				for(i in _collisions) {
					preProcessCollisionFn(_collisions[i],dt);
				}
			}
			
			var flag:Boolean;
			var gotOne:Boolean;
			var len:int;
			for (var step:uint = 0; step < iter; step++) {
				gotOne = false;
				for(i in _collisions) {
					if (!_collisions[i].satisfied) {
						if(forceInelastic) {
							flag = processContactFn(_collisions[i], dt);
							gotOne = gotOne || flag;
						} else {
							flag = processCollisionFn(_collisions[i], dt);
							gotOne = gotOne || flag;
						}
					}
				}
				for (k in _constraints) {
					if (!_constraints[k].satisfied) {
						flag = _constraints[k].apply(dt);
						gotOne = gotOne || flag;
					}
				}
				tryToActivateAllFrozenObjects();
				
				if (forceInelastic) {
					len = _collisions.length;
			    	for (var j:int = origNumCollisions; j < len; j++) {
						_collisions[j].mat.restitution = 0;
					    _collisions[j].satisfied = false;
			    		preProcessContactFn(_collisions[j], dt);
			    	}
			    } else {
					len = _collisions.length;
			    	for (j = origNumCollisions; j < len; j++) {
			    		preProcessCollisionFn(_collisions[j], dt);
			    	}
			    }
			    origNumCollisions = _collisions.length;
				if (!gotOne) {
					break;
				}
			}
		}
		 
		public function activateObject(body:RigidBody):void {
			if (!body.movable || body.isActive()) {
				return;
			}
			body.setActive();
			_activeBodies.push(body);
			var orig_num:int = _collisions.length;
			_collisionSystem.detectCollisions(body, _collisions);
			var other_body:RigidBody;
			var thisBody_normal:JNumber3D;
			var len:int = _collisions.length;
			for (var i:int = orig_num; i < len; i++) {
				other_body=_collisions[i].objInfo.body0;
				thisBody_normal=_collisions[i].dirToBody;
				if (other_body == body) {
					other_body=_collisions[i].objInfo.body1;
					thisBody_normal=JNumber3D.multiply(_collisions[i].dirToBody,-1);
				}
				if (!other_body.isActive() && JNumber3D.dot(other_body.force, thisBody_normal) < -JNumber3D.NUM_TINY) {
					activateObject(other_body);
				}
			}
		}
		 
		private function dampAllActiveBodies():void {
			for (var i:String in _activeBodies) {
				_activeBodies[i].dampForDeactivation();
			}
		}
		 
		private function tryToActivateAllFrozenObjects():void {
			for (var i:String in _bodies) {
				if (!_bodies[i].isActive()) {
					if (_bodies[i].getShouldBeActive()) {
						activateObject(_bodies[i]);
					} else {
						if (_bodies[i].getVelChanged()) {
							_bodies[i].setVelocity(JNumber3D.ZERO);
							_bodies[i].setAngVel(JNumber3D.ZERO);
							_bodies[i].clearVelChanged();
						}
					}
				}
			}
		}
		
		private function activateAllFrozenObjectsLeftHanging():void {
			var other_body:RigidBody;
			for(var i:String in _bodies) {
				if(_bodies[i].isActive()) {
					_bodies[i].doMovementActivations();
					if (_bodies[i].collisions.length > 0) {
						for(var j:String in _bodies[i].collisions) {
							other_body=_bodies[i].collisions[j].objInfo.body0;
							if(other_body==_bodies[i]) {
								other_body=_bodies[i].collisions[j].objInfo.body1;
							}
							
							if(!other_body.isActive()) {
								_bodies[i].addMovementActivation(_bodies[i].currentState.position,other_body);
							}
						}
					}
				}
			}
		}
		
		private function updateAllVelocities(dt:Number):void {
			for (var i:String in _activeBodies) {
				_activeBodies[i].updateVelocity(dt);
			}
		}
		
		private function updateAllPositions(dt:Number):void {
			for (var i:String in _activeBodies) {
				_activeBodies[i].updatePositionWithAux(dt);
			}
		}
		
		private function notifyAllPostPhysics(dt:Number):void {
			for (var i:String in _bodies) {
				_bodies[i].postPhysics(dt);
			}
		}
		
		private function updateAllObject3D():void {
			for (var i:String in _bodies) {
				_bodies[i].updateObject3D();
			}
		}
		
		private function limitAllVelocities():void {
			for (var i:String in _activeBodies) {
				_activeBodies[i].limitVel();
				_activeBodies[i].limitAngVel();
			}
		}
		 
		private function tryToFreezeAllObjects(dt:Number):void {
			for (var i:String in _activeBodies) {
				_activeBodies[i].tryToFreeze(dt);
			}
		}
		
		private function detectAllCollisions(dt:Number):void {
			for(var i:String in _activeBodies) {
				_activeBodies[i].storeState();
			}
			updateAllVelocities(dt);
			updateAllPositions(dt);
			
			for(i in _bodies) {
				_bodies[i].collisions = [];
			}
			_collisions = [];
			_collisionSystem.detectAllCollisions(_activeBodies, _collisions);
			
			for(i in _activeBodies) {
				_activeBodies[i].restoreState();
			}
		}
		
		private function copyAllCurrentStatesToOld():void {
			for (var i:String in _bodies) {
				if (_bodies[i].isActive() || _bodies[i].getVelChanged()) {
					_bodies[i].copyCurrentStateToOld();
				}
			}
		}
		 
		private function findAllActiveBodies():void {
			_activeBodies = [];
			for (var i:String in _bodies) {
				if (_bodies[i].isActive()) {
					_activeBodies.push(_bodies[i]);
				}
			}
		}
		
		public function integrate(dt:Number):void {
			_doingIntegration = true;
			
			findAllActiveBodies();
			copyAllCurrentStatesToOld();
			 
			getAllExternalForces(dt);
			detectAllCollisions(dt);
			handleAllConstraints(dt, JConfig.numCollisionIterations, false);
			updateAllVelocities(dt);
			handleAllConstraints(dt, JConfig.numContactIterations, true);
			 
			dampAllActiveBodies();
			tryToFreezeAllObjects(dt);
			activateAllFrozenObjectsLeftHanging();
			 
			limitAllVelocities();
			 
			updateAllPositions(dt);
			notifyAllPostPhysics(dt);
			 
			updateAllObject3D();
			if (JConfig.solverType == "ACCUMULATED") {
				updateContactCache();
			}
			for (var i:String in _bodies) {
				_bodies[i].clearForces();
			}
			 
			_doingIntegration = false;
		}
	}
}
