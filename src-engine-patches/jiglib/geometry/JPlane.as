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

package jiglib.geometry {
	import jiglib.math.*;
	import jiglib.physics.PhysicsState;
	import jiglib.physics.RigidBody;
	import jiglib.plugin.ISkin3D;
	
	public class JPlane extends RigidBody {
		
		private var _normal:JNumber3D;
		private var _distance:Number;
		
		public function JPlane(skin:ISkin3D) {
			
			super(skin);
			_type = "PLANE";
			_normal = new JNumber3D(0, 0, -1);
			_distance = 0;
			this.movable = false;
		}
		
		public function get normal():JNumber3D {
			return _normal;
		}
		
		public function get distance():Number {
			return _distance;
		}
		 
		public function pointPlaneDistance(pt:JNumber3D):Number {
			return JNumber3D.dot(_normal, pt) - _distance;
		}
		
		override public function segmentIntersect(out:Object, seg:JSegment,state:PhysicsState):Boolean {
			out.fracOut = 0;
			out.posOut = new JNumber3D();
			out.normalOut = new JNumber3D();
			
			var frac:Number = 0;
			
			var t:Number;
			
			var denom:Number = JNumber3D.dot(_normal, seg.delta);
			if (Math.abs(denom) > JNumber3D.NUM_TINY) {
				t = -1 * (JNumber3D.dot(_normal, seg.origin) - _distance) / denom;
				
				if (t < 0 || t > 1) {
					return false;
				} else {
					frac = t;
					out.fracOut = frac;
					out.posOut = seg.getPoint(frac);
					out.normalOut = _normal.clone();
					out.normalOut.normalize();
					return true;
				}
			} else {
				return false;
			}
		}
		
		override protected function updateState():void {	
			super.updateState();
			_normal = new JNumber3D(0, 0, -1);
			JMatrix3D.multiplyVector(_currState.orientation, _normal);
			_distance = JNumber3D.dot(_currState.position, _normal);
		}
	}
}
