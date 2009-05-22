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

	import jiglib.physics.PhysicsState;
	import jiglib.plugin.ISkin3D;
	import jiglib.math.*;
	import jiglib.physics.RigidBody;
	
	public class JBox extends RigidBody {
		
		private var _sideLengths:JNumber3D;
		private var _points:Array;
		private var _edges:Array = [ { ind0:0, ind1:1 }, { ind0:3, ind1:1 }, { ind0:2, ind1:3 },
			                         { ind0:2, ind1:0 }, { ind0:4, ind1:5 }, { ind0:5, ind1:7 },
							         { ind0:6, ind1:7 }, { ind0:4, ind1:6 }, { ind0:7, ind1:1 },
							         { ind0:5, ind1:3 }, { ind0:4, ind1:2 }, { ind0:6, ind1:0 } ];
										 
		private var _face:Array = [[6, 7, 1, 0], [5, 4, 2, 3], 
								   [3, 1, 7, 5], [4, 6, 0, 2], 
								   [1, 3, 2, 0], [7, 6, 4, 5]];
		 
		public function JBox(skin:ISkin3D, width:Number, depth:Number, height:Number) {
			
			super(skin);
			_type = "BOX";
			
			_sideLengths = new JNumber3D(width, height, depth);
			_boundingSphere = 0.5 * _sideLengths.modulo;
			initPoint();
			mass = 1;
		}
		
		private function initPoint():void {
			var halfSide:JNumber3D = getHalfSideLengths();
			_points = [];
			_points[0] = new JNumber3D(halfSide.x, -halfSide.y, halfSide.z);
			_points[1] = new JNumber3D(halfSide.x, halfSide.y, halfSide.z);
			_points[2] = new JNumber3D(-halfSide.x, -halfSide.y, halfSide.z);
			_points[3] = new JNumber3D(-halfSide.x, halfSide.y, halfSide.z);
			_points[4] = new JNumber3D(-halfSide.x, -halfSide.y, -halfSide.z);
			_points[5] = new JNumber3D(-halfSide.x, halfSide.y, -halfSide.z);
			_points[6] = new JNumber3D(halfSide.x, -halfSide.y, -halfSide.z);
			_points[7] = new JNumber3D(halfSide.x, halfSide.y, -halfSide.z);
		}
		 
		public function set sideLengths(size:JNumber3D):void {
			_sideLengths = size.clone();
			_boundingSphere = 0.5 * _sideLengths.modulo;
			initPoint();
			setInertia(getInertiaProperties(mass));
			setActive();
		}
		 
		public function get sideLengths():JNumber3D {
			return _sideLengths;
		}
		
		public function get edges():Array {
			return _edges;
		}
		 
		public function getVolume():Number {
			return (_sideLengths.x * _sideLengths.y * _sideLengths.z);
		}
		
		public function getSurfaceArea():Number {
			return 2 * (_sideLengths.x * _sideLengths.y + _sideLengths.x * _sideLengths.z + _sideLengths.y * _sideLengths.z);
		}
		
		public function getHalfSideLengths():JNumber3D {
			return JNumber3D.multiply(_sideLengths, 0.5);
		}
		
		public function getSpan(axis:JNumber3D):Object {
			var obj:Object = new Object();
			var s:Number = Math.abs(JNumber3D.dot(axis, currentState.orientation.getCols()[0])) * (0.5 * _sideLengths.x);
			var u:Number = Math.abs(JNumber3D.dot(axis, currentState.orientation.getCols()[1])) * (0.5 * _sideLengths.y);
			var d:Number = Math.abs(JNumber3D.dot(axis, currentState.orientation.getCols()[2])) * (0.5 * _sideLengths.z);
			var r:Number = s + u + d;
			var p:Number = JNumber3D.dot(currentState.position, axis);
			obj.min = p - r;
			obj.max = p + r;
			 
			return obj;
		}
		
		public function getCornerPoints(state:PhysicsState):Array {
			var vertex:JNumber3D;
			var arr:Array = [];
			var transform:JMatrix3D=JMatrix3D.multiply(JMatrix3D.translationMatrix(state.position.x, state.position.y, state.position.z), state.orientation);
			for (var i:String in _points) {
				vertex = new JNumber3D(_points[i].x, _points[i].y, _points[i].z);
				JMatrix3D.multiplyVector(transform, vertex);
				arr.push(vertex);
			}
			 
			return arr;
		}
		 
		public function getSqDistanceToPoint(state:PhysicsState, closestBoxPoint:Object, point:JNumber3D):Number {
			closestBoxPoint.pos = JNumber3D.sub(point, state.position);
			JMatrix3D.multiplyVector(JMatrix3D.transpose(state.orientation), closestBoxPoint.pos);
			
			var delta:Number = 0;
			var sqDistance:Number = 0;
			var halfSideLengths:JNumber3D = getHalfSideLengths();
			
			if ( closestBoxPoint.pos.x < -halfSideLengths.x ) {
				delta = closestBoxPoint.pos.x + halfSideLengths.x;
                sqDistance += (delta * delta);
                closestBoxPoint.pos.x = -halfSideLengths.x;
            } else if ( closestBoxPoint.pos.x > halfSideLengths.x ) {
                delta = closestBoxPoint.pos.x - halfSideLengths.x;
                sqDistance += (delta * delta);
                closestBoxPoint.pos.x = halfSideLengths.x;
            }
			 
            if ( closestBoxPoint.pos.y < -halfSideLengths.y ) {
                delta = closestBoxPoint.pos.y + halfSideLengths.y;
                sqDistance += (delta * delta);
                closestBoxPoint.pos.y = -halfSideLengths.y;
            } else if ( closestBoxPoint.pos.y > halfSideLengths.y ) {
                delta = closestBoxPoint.pos.y - halfSideLengths.y;
                sqDistance += (delta * delta);
                closestBoxPoint.pos.y = halfSideLengths.y;
            }
             
            if ( closestBoxPoint.pos.z < -halfSideLengths.z ) {
                delta = closestBoxPoint.pos.z + halfSideLengths.z;
                sqDistance += (delta * delta);
                closestBoxPoint.pos.z = -halfSideLengths.z;
            } else if ( closestBoxPoint.pos.z > halfSideLengths.z ) {
                delta = (closestBoxPoint.pos.z - halfSideLengths.z);
                sqDistance += (delta * delta);
                closestBoxPoint.pos.z = halfSideLengths.z;
            }
			JMatrix3D.multiplyVector(state.orientation, closestBoxPoint.pos);
			closestBoxPoint.pos = JNumber3D.add(state.position, closestBoxPoint.pos);
            return sqDistance;
		}
		
		public function getDistanceToPoint(state:PhysicsState, closestBoxPoint:Object, point:JNumber3D):Number {
			return Math.sqrt(getSqDistanceToPoint(state, closestBoxPoint, point));
		}
		
		public function pointIntersect(pos:JNumber3D):Boolean {
			var p:JNumber3D=JNumber3D.sub(pos,currentState.position);
			var h:JNumber3D = JNumber3D.multiply(_sideLengths, 0.5);
			var dirVec:JNumber3D;
			for(var dir:int;dir<3;dir++) {
				dirVec = currentState.orientation.getCols()[dir].clone();
				dirVec.normalize();
				if(Math.abs(JNumber3D.dot(dirVec,p))>h.toArray()[dir]+JNumber3D.NUM_TINY) {
					return false;
				}
			}
			return true;
		}
		
		public function getSupportVertices(axis:JNumber3D):Array {
			var vertices:Array = [];
			var d:Array = new Array(3);
			var H:JNumber3D;
			var temp:Array = currentState.orientation.getCols();
			temp[0].normalize();
			temp[1].normalize();
			temp[2].normalize();
			for (var i:uint = 0; i < 3; i++ ) {
				d[i] = JNumber3D.dot(axis, temp[i]);
				if (Math.abs(d[i]) > 1 - 0.001) {
					var f:int = (d[i] < 0)?(i * 2) : (i * 2) + 1;
					for (var j:int = 0; j < 4; j++ ) {
						H = _points[_face[f][j]];
						vertices[j] = currentState.position.clone();
						vertices[j] = JNumber3D.add(vertices[j], JNumber3D.multiply(temp[0], H.x));
						vertices[j] = JNumber3D.add(vertices[j], JNumber3D.multiply(temp[1], H.y));
						vertices[j] = JNumber3D.add(vertices[j], JNumber3D.multiply(temp[2], H.z));
					}
					return vertices;
				}
			}
			
			for (i = 0; i < 3; i++ ) {
				if (Math.abs(d[i]) < 0.005) {
					var k:int;
					var m:int = (i + 1) % 3;
					var n:int = (i + 2) % 3;
					
					H = currentState.position.clone();
					k = (d[m] > 0)?-1: 1;
					H = JNumber3D.add(H, JNumber3D.multiply(temp[m], k * _sideLengths.toArray()[m] / 2));
					k = (d[n] > 0)?-1: 1;
					H = JNumber3D.add(H, JNumber3D.multiply(temp[n], k * _sideLengths.toArray()[n] / 2));
					
					vertices[0] = JNumber3D.add(H, JNumber3D.multiply(temp[i], _sideLengths.toArray()[i] / 2));
					vertices[1] = JNumber3D.add(H, JNumber3D.multiply(temp[i], -_sideLengths.toArray()[i] / 2));
					return vertices;
				}
			}
			
			vertices[0] = currentState.position.clone();
			k = (d[0] > 0)?-1: 1;
			vertices[0] = JNumber3D.add(vertices[0], JNumber3D.multiply(temp[0], k * _sideLengths.x / 2));
			k = (d[1] > 0)?-1: 1;
			vertices[0] = JNumber3D.add(vertices[0], JNumber3D.multiply(temp[1], k * _sideLengths.y / 2));
			k = (d[2] > 0)?-1: 1;
			vertices[0] = JNumber3D.add(vertices[0], JNumber3D.multiply(temp[2], k * _sideLengths.z / 2));
			return vertices;
		}
		 
		override public function segmentIntersect(out:Object, seg:JSegment, state:PhysicsState):Boolean {
			out.fracOut = 0;
			out.posOut = new JNumber3D();
			out.normalOut = new JNumber3D();
			
			var frac:Number = JNumber3D.NUM_HUGE;
			var min:Number = -JNumber3D.NUM_HUGE;
			var max:Number = JNumber3D.NUM_HUGE;
			var dirMin:Number = 0;
			var dirMax:Number = 0;
			var dir:Number = 0;
			var p:JNumber3D = JNumber3D.sub(state.position, seg.origin);
			var h:JNumber3D = JNumber3D.multiply(_sideLengths, 0.5);
			
			var tempV:JNumber3D;
			var e:Number;
			var f:Number;
			var t:Number;
			var t1:Number;
			var t2:Number;
			for (dir = 0; dir < 3; dir++) {
				e = JNumber3D.dot(state.orientation.getCols()[dir], p);
				f = JNumber3D.dot(state.orientation.getCols()[dir], seg.delta);
				if (Math.abs(f) > JNumber3D.NUM_TINY) {
					t1 = (e + h.toArray()[dir]) / f;
					t2 = (e - h.toArray()[dir]) / f;
					if (t1 > t2) {
						t = t1;
						t1 = t2;
						t2 = t;
					}
					if (t1 > min) {
						min = t1;
                        dirMin = dir;
					}
					if (t2 < max) {
                        max = t2;
                        dirMax = dir;
                    }
					if (min > max) return false;
                    if (max < 0) return false;
				} else if ( -e - h.toArray()[dir] > 0 || -e + h.toArray()[dir] < 0) {
					return false;
				}
			}
			
			if (min > 0) {
                dir = dirMin;
                frac = min;
            } else {
				dir = dirMax;
                frac = max;
			}
			if (frac < 0) frac = 0;
			if (frac > 1) frac = 1;
			if (frac > 1 - JNumber3D.NUM_TINY) {
				return false;
			}
			out.fracOut = frac;
			out.posOut = seg.getPoint(frac);
			if (JNumber3D.dot(state.orientation.getCols()[dir], seg.delta) < 0) {
				out.normalOut = JNumber3D.multiply(state.orientation.getCols()[dir], -1);
			} else {
				out.normalOut = state.orientation.getCols()[dir];
			}
			out.normalOut.normalize();
			return true;
		}
		
		override public function getInertiaProperties(m:Number):JMatrix3D {
			var inertiaTensor:JMatrix3D = new JMatrix3D();
			inertiaTensor.n11 = (m / 12) * (_sideLengths.y * _sideLengths.y + _sideLengths.z * _sideLengths.z);
			inertiaTensor.n22 = (m / 12) * (_sideLengths.x * _sideLengths.x + _sideLengths.z * _sideLengths.z);
			inertiaTensor.n33 = (m / 12) * (_sideLengths.x * _sideLengths.x + _sideLengths.y * _sideLengths.y);
			return inertiaTensor;
		}
	}
}
