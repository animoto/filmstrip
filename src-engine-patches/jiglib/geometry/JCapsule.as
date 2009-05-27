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

package jiglib.geometry{

	import jiglib.math.*;
	import jiglib.plugin.ISkin3D;
	import jiglib.geometry.JSegment;
	import jiglib.physics.RigidBody;
	import jiglib.physics.PhysicsState;
	
	public class JCapsule extends RigidBody {
		
		private var _length:Number;
		private var _radius:Number;
		
		public function JCapsule(skin:ISkin3D, r:Number, l:Number) {
			super(skin);
			_type = "CAPSULE";
			_radius = r;
			_length = l;
			_boundingSphere = getBoundingSphere(r, l);
			mass = 1;
		}
		 
		public function set radius(r:Number):void {
			_radius = r;
			_boundingSphere = getBoundingSphere(_radius, _length);
			setInertia(getInertiaProperties(mass));
			setActive();
		}
		public function get radius():Number {
			return _radius;
		}
		 
		public function set length(l:Number):void {
			_length = l;
			_boundingSphere = getBoundingSphere(_radius, _length);
			setInertia(getInertiaProperties(mass));
			setActive();
		}
		public function get length():Number {
			return _length;
		}
		 
		public function getBottomPos(state:PhysicsState):JNumber3D {
			var temp:JNumber3D = state.orientation.getCols()[1];
			temp.normalize();
			return JNumber3D.add(state.position, JNumber3D.multiply(temp, -_length / 2));
		}
		 
		public function getEndPos(state:PhysicsState):JNumber3D {
			var temp:JNumber3D = state.orientation.getCols()[1];
			temp.normalize();
			return JNumber3D.add(state.position, JNumber3D.multiply(temp, _length / 2));
		}
		 
		override public function segmentIntersect(out:Object, seg:JSegment, state:PhysicsState):Boolean {
			out.fracOut = 0;
			out.posOut = new JNumber3D();
			out.normalOut = new JNumber3D();
			
			var Ks:JNumber3D = seg.delta;
			var kss:Number = JNumber3D.dot(Ks, Ks);
			var radiusSq:Number = _radius * _radius;
			
			var cylinderAxis:JSegment = new JSegment(getBottomPos(state), state.orientation.getCols()[1]);
			var Ke:JNumber3D = cylinderAxis.delta;
			var Kg:JNumber3D = JNumber3D.sub(cylinderAxis.origin, seg.origin);
			var kee:Number = JNumber3D.dot(Ke, Ke);
			if (Math.abs(kee) < JNumber3D.NUM_TINY) {
				return false;
			}
			
			var kes:Number = JNumber3D.dot(Ke, Ks);
			var kgs:Number = JNumber3D.dot(Kg, Ks);
			var keg:Number = JNumber3D.dot(Ke, Kg);
			var kgg:Number = JNumber3D.dot(Kg, Kg);
			
			var distSq:Number = JNumber3D.sub(Kg, JNumber3D.divide(JNumber3D.multiply(Ke, keg), kee)).modulo2;
			if (distSq < radiusSq) {
				out.fracOut = 0;
				out.posOut = seg.origin.clone();
				out.normalOut = JNumber3D.sub(out.posOut, getBottomPos(state));
				out.normalOut = JNumber3D.sub(out.normalOut, JNumber3D.multiply(state.orientation.getCols()[1], JNumber3D.dot(out.normalOut, state.orientation.getCols()[1])));
				out.normalOut.normalize();
				return true;
			}
			
			var a:Number = kee * kss - (kes * kes);
			if (Math.abs(a) < JNumber3D.NUM_TINY) {
				return false;
			}
			var b:Number = 2 * (keg * kes - kee * kgs);
			var c:Number = kee * (kgg - radiusSq) - (keg * keg);
			var blah:Number = (b * b) - 4 * a * c;
			if (blah < 0) {
				return false;
			}
			var t:Number = ( -b - Math.sqrt(blah)) / (2 * a);
			if (t < 0 || t > 1) {
				return false;
			}
			out.fracOut = t;
			out.posOut = seg.getPoint(t);
			out.normalOut = JNumber3D.sub(out.posOut, getBottomPos(state));
			out.normalOut = JNumber3D.sub(out.normalOut, JNumber3D.multiply(state.orientation.getCols()[1], JNumber3D.dot(out.normalOut, state.orientation.getCols()[1])));
			out.normalOut.normalize();
			return true;
		}
		 
		override public function getInertiaProperties(m:Number):JMatrix3D {
			var cylinderMass:Number = m * Math.PI * _radius * _radius * _length / getVolume();
			var Ixx:Number = 0.25 * cylinderMass * _radius * _radius + (1 / 12) * cylinderMass * _length * _length;
			var Iyy:Number = 0.5 * cylinderMass * _radius * _radius;
			var Izz:Number = Ixx;
			 
			var endMass:Number = m - cylinderMass;
			Ixx += (0.4 * endMass * _radius * _radius + endMass * Math.pow(0.5 * _length, 2));
			Iyy += (0.2 * endMass * _radius * _radius);
			Izz += (0.4 * endMass * _radius * _radius + endMass * Math.pow(0.5 * _length, 2));
			 
			var inertiaTensor:JMatrix3D = new JMatrix3D();
			inertiaTensor.n11 = Ixx;
			inertiaTensor.n22 = Iyy;
			inertiaTensor.n33 = Izz;
			 
			return inertiaTensor;
		}
		
		private function getBoundingSphere(r:Number, l:Number):Number {
			return Math.sqrt(Math.pow(l / 2, 2) + r * r) + r;
		}
		
		private function getVolume():Number {
			return (4 / 3) * Math.PI * _radius * _radius * _radius + _length * Math.PI * _radius * _radius;
		}
	}
	
}
