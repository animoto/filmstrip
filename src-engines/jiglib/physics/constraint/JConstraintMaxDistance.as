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
 * @author Muzer(muzerly@gmail.com)
 * @link http://code.google.com/p/jiglibflash
 */

 
package jiglib.physics.constraint {
	
	import jiglib.math.*;
	import jiglib.physics.RigidBody;
	
	public class JConstraintMaxDistance extends JConstraint {
		
		private const _maxVelMag:Number = 20;
        private const _minVelForProcessing:Number = 0.01;
		 
		private var _body0:RigidBody;
		private var _body1:RigidBody;
		private var _body0Pos:JNumber3D;
		private var _body1Pos:JNumber3D;
		private var _maxDistance:Number;
		 
		private var r0:JNumber3D;
		private var r1:JNumber3D;
		private var _worldPos:JNumber3D;
		private var _currentRelPos0:JNumber3D;
		 
		public function JConstraintMaxDistance(body0:RigidBody, body0Pos:JNumber3D, body1:RigidBody, body1Pos:JNumber3D, maxDistance:Number = 1) {
			super();
			_body0 = body0;
			_body0Pos = body0Pos;
			_body1 = body1;
			_body1Pos = body1Pos;
			_maxDistance = maxDistance;
			body0.addConstraint(this);
			body1.addConstraint(this);
		}
		 
		override public function preApply(dt:Number):void {
			this.satisfied = false;
			 
			r0 = _body0Pos.clone();
			JMatrix3D.multiplyVector(_body0.currentState.orientation, r0);
			r1 = _body1Pos.clone();
			JMatrix3D.multiplyVector(_body1.currentState.orientation, r1);
			 
			var worldPos0:JNumber3D = JNumber3D.add(_body0.currentState.position, r0);
			var worldPos1:JNumber3D = JNumber3D.add(_body1.currentState.position, r1);
			_worldPos = JNumber3D.multiply(JNumber3D.add(worldPos0, worldPos1), 0.5);
			 
			_currentRelPos0 = JNumber3D.sub(worldPos0, worldPos1);
		}
		 
		override public function apply(dt:Number):Boolean {
			this.satisfied = true;
			
			if (!_body0.isActive() && !_body1.isActive()) {
				return false;
			}
			 
			var currentVel0:JNumber3D = _body0.getVelocity(r0);
			var currentVel1:JNumber3D = _body1.getVelocity(r1);
			 
			var predRelPos0:JNumber3D = JNumber3D.add(_currentRelPos0, JNumber3D.multiply(JNumber3D.sub(currentVel0, currentVel1), dt));
			var clampedRelPos0:JNumber3D = predRelPos0.clone();
			var clampedRelPos0Mag:Number = clampedRelPos0.modulo;
			if (clampedRelPos0Mag <= JNumber3D.NUM_TINY) {
				return false;
			}
			if (clampedRelPos0Mag > _maxDistance) {
				clampedRelPos0 = JNumber3D.multiply(clampedRelPos0, _maxDistance / clampedRelPos0Mag);
			}
			 
			var desiredRelVel0:JNumber3D = JNumber3D.divide(JNumber3D.sub(clampedRelPos0, _currentRelPos0), dt);
			var Vr:JNumber3D = JNumber3D.sub(JNumber3D.sub(currentVel0, currentVel1), desiredRelVel0);
			 
			var normalVel:Number = Vr.modulo;
			if (normalVel > _maxVelMag) {
				Vr = JNumber3D.multiply(Vr, _maxVelMag / normalVel);
				normalVel = _maxVelMag;
			} else if (normalVel < _minVelForProcessing) {
				return false;
			}
			 
			var N:JNumber3D = JNumber3D.divide(Vr, normalVel);
			var tempVec1:JNumber3D = JNumber3D.cross(N, r0);
			JMatrix3D.multiplyVector(_body0.worldInvInertia, tempVec1);
			var tempVec2:JNumber3D = JNumber3D.cross(N, r1);
			JMatrix3D.multiplyVector(_body1.worldInvInertia, tempVec2);
			var denominator:Number = _body0.invMass + _body1.invMass + JNumber3D.dot(N, JNumber3D.cross(r0, tempVec1)) + JNumber3D.dot(N, JNumber3D.cross(r1, tempVec2));
			if (denominator < JNumber3D.NUM_TINY) {
				return false;
			}
			 
			var normalImpulse:JNumber3D = JNumber3D.multiply(N, -normalVel / denominator);
			_body0.applyWorldImpulse(normalImpulse, _worldPos);
			_body1.applyWorldImpulse(JNumber3D.multiply(normalImpulse, -1), _worldPos);
			 
			_body0.setConstraintsAndCollisionsUnsatisfied();
			_body1.setConstraintsAndCollisionsUnsatisfied();
			this.satisfied = true;
			return true;
		}
	}
	
}