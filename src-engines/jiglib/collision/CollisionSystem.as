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

package jiglib.collision {
	import jiglib.geometry.JSegment;
	import jiglib.math.*;
	import jiglib.physics.RigidBody;
	
	public class CollisionSystem {
		
		private var detectionFunctors:Array;
		private var collBody:Array;
		
		public function CollisionSystem() {
			collBody = new Array();
			detectionFunctors = new Array();
			detectionFunctors["BOX"] = new Array();
			detectionFunctors["BOX"]["BOX"] = new CollDetectBoxBox();
			detectionFunctors["BOX"]["SPHERE"] = new CollDetectSphereBox();
			detectionFunctors["BOX"]["CAPSULE"]=new CollDetectCapsuleBox();
			detectionFunctors["BOX"]["PLANE"] = new CollDetectBoxPlane();
			detectionFunctors["SPHERE"] = new Array();
			detectionFunctors["SPHERE"]["BOX"] = new CollDetectSphereBox();
			detectionFunctors["SPHERE"]["SPHERE"] = new CollDetectSphereSphere();
			detectionFunctors["SPHERE"]["CAPSULE"]=new CollDetectSphereCapsule();
			detectionFunctors["SPHERE"]["PLANE"] = new CollDetectSpherePlane();
			detectionFunctors["PLANE"] = new Array();
			detectionFunctors["PLANE"]["BOX"] = new CollDetectBoxPlane();
			detectionFunctors["PLANE"]["SPHERE"] = new CollDetectSpherePlane();
			detectionFunctors["PLANE"]["CAPSULE"]=new CollDetectCapsulePlane();
			detectionFunctors["CAPSULE"] = new Array();
			detectionFunctors["CAPSULE"]["CAPSULE"] = new CollDetectCapsuleCapsule();
			detectionFunctors["CAPSULE"]["BOX"] = new CollDetectCapsuleBox();
			detectionFunctors["CAPSULE"]["SPHERE"] = new CollDetectSphereCapsule();
			detectionFunctors["CAPSULE"]["PLANE"] = new CollDetectCapsulePlane();
		}
		
		public function addCollisionBody(body:RigidBody):void {
			if (!findBody(body)) {
				collBody.push(body);
			}
		}
		
		public function removeCollisionBody(body:RigidBody):void {
			if (findBody(body)) {
				collBody.splice(collBody.indexOf(body), 1);
			}
		}
		
		public function removeAllCollisionBodys():void {
			collBody = [];
		}
		
		public function detectCollisions(body:RigidBody, collArr:Array):void {
			if (!body.isActive()) {
				return;
			}
			var info:CollDetectInfo;
			var fu:CollDetectFunctor;
			 
			for (var i:String in collBody) { 
				if (body != collBody[i] && checkCollidables(body, collBody[i]) && detectionFunctors[body.type][collBody[i].type] != undefined) {
					info = new CollDetectInfo();
					info.body0 = body;
					info.body1 = collBody[i];
					fu = detectionFunctors[info.body0.type][info.body1.type];
					fu.collDetect(info, collArr);
				}
			}
		}
		
		public function detectAllCollisions(bodies:Array, collArr:Array):void {
			var info:CollDetectInfo;
			var fu:CollDetectFunctor;
			for (var i:String in bodies) {
				for (var j:String in collBody) {
					if (bodies[i] == collBody[j]) {
						continue;
					}
					
					if (collBody[j].isActive() && bodies[i].id > collBody[j].id) {
						continue;
					}
					
					if (checkCollidables(bodies[i], collBody[j]) && detectionFunctors[bodies[i].type][collBody[j].type] != undefined) {
						info = new CollDetectInfo();
						info.body0 = bodies[i];
						info.body1 = collBody[j];
						fu = detectionFunctors[info.body0.type][info.body1.type];
						fu.collDetect(info, collArr);
					}
				}
			}
		}
		
		public function segmentIntersect(out:Object, seg:JSegment, ownerBody:RigidBody):Boolean {
			out.fracOut = JNumber3D.NUM_HUGE;
			out.posOut = new JNumber3D();
			out.normalOut = new JNumber3D();
			
			var obj:Object = new Object();
			for (var i:String in collBody) {
				if (collBody[i] != ownerBody && segmentBounding(seg, collBody[i])) {
					if (collBody[i].segmentIntersect(obj, seg, collBody[i].currentState)) {
						if (obj.fracOut < out.fracOut) {
							out.posOut = obj.posOut;
							out.normalOut = obj.normalOut;
							out.fracOut = obj.fracOut;
							out.bodyOut = collBody[i];
						}
					}
				}
			}
			 
			if (out.fracOut > 1) {
				return false;
			}
			if (out.fracOut < 0) {
				out.fracOut = 0;
			}
			else if (out.fracOut > 1) {
				out.fracOut = 1;
			}
			return true;
		}
		
		public function segmentBounding(seg:JSegment,obj:RigidBody):Boolean {
			var pos:JNumber3D = seg.getPoint(0.5);
			var r:Number = seg.delta.modulo / 2;
			
			if (obj.type != "PLANE") {
				var num1:Number = JNumber3D.sub(pos, obj.currentState.position).modulo;
				var num2:Number = r + obj.boundingSphere;
				if (num1 <= num2) {
					return true;
				} else {
					return false;
				}
			} else {
				return true;
			}
		}
		 
		private function findBody(body:RigidBody):Boolean {
			for (var i:String in collBody) {
				if (body == collBody[i]) {
					return true;
				}
			}
			return false;
		}
		
		private function checkCollidables(body0:RigidBody, body1:RigidBody):Boolean {
			if (body0.nonCollidables.length == 0 && body1.nonCollidables.length == 0) {
				return true;
			}
			
			for (var i:String in body0.nonCollidables) {
				if (body1 == body0.nonCollidables[i]) {
					return false;
				}
			}
			for (i in body1.nonCollidables) {
				if (body0 == body1.nonCollidables[i]) {
					return false;
				}
			}
			return true;
		}
	}
	
}
