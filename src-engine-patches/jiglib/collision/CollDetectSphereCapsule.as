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

	import jiglib.cof.JConfig;
	import jiglib.geometry.*;
	import jiglib.math.*;
	import jiglib.physics.RigidBody;
	import jiglib.physics.MaterialProperties;
	
	public class CollDetectSphereCapsule extends CollDetectFunctor {
		
		public function CollDetectSphereCapsule() {
			name = "SphereCapsule";
			type0 = "SPHERE";
			type1 = "CAPSULE";
		}
		
		override public function collDetect(info:CollDetectInfo, collArr:Array):void {
			var tempBody:RigidBody;
			if(info.body0.type=="CAPSULE") {
				tempBody=info.body0;
				info.body0=info.body1;
				info.body1=tempBody;
			}
			
			var sphere:JSphere = info.body0 as JSphere;
			var capsule:JCapsule = info.body1 as JCapsule;
			
			if (!sphere.hitTestObject3D(capsule)) {
				return;
			}
			
			var oldSeg:JSegment = new JSegment(capsule.getBottomPos(capsule.oldState), JNumber3D.multiply(capsule.oldState.orientation.getCols()[1], capsule.length));
			var newSeg:JSegment = new JSegment(capsule.getBottomPos(capsule.currentState), JNumber3D.multiply(capsule.currentState.orientation.getCols()[1], capsule.length));
			var radSum:Number = sphere.radius + capsule.radius;
			
			var oldObj:Object = new Object();
			var oldDistSq:Number = oldSeg.pointSegmentDistanceSq(oldObj, sphere.oldState.position);
			var newObj:Object = new Object();
			var newDistSq:Number = newSeg.pointSegmentDistanceSq(newObj, sphere.currentState.position);
			
			if (Math.min(oldDistSq, newDistSq) < Math.pow(radSum + JConfig.collToll, 2)) {
				var segPos:JNumber3D = oldSeg.getPoint(oldObj.t);
				var delta:JNumber3D = JNumber3D.sub(sphere.oldState.position, segPos);
				
				var dist:Number = Math.sqrt(oldDistSq);
				var depth:Number = radSum - dist;
				
				if (dist > JNumber3D.NUM_TINY) {
					delta = JNumber3D.divide(delta, dist);
				}
				else {
					delta = JNumber3D.UP;
					JMatrix3D.multiplyVector(JMatrix3D.rotationMatrix(0, 0, 1, 360 * Math.random()), delta);
				}
				
				var worldPos:JNumber3D = JNumber3D.add(segPos, JNumber3D.multiply(delta, capsule.radius - 0.5 * depth));
				 
				var collPts:Array = [];
				var cpInfo:CollPointInfo = new CollPointInfo();
				cpInfo.r0 = JNumber3D.sub(worldPos, sphere.oldState.position);
				cpInfo.r1 = JNumber3D.sub(worldPos, capsule.oldState.position);
				cpInfo.initialPenetration = depth;
				collPts.push(cpInfo);
				 
				var collInfo:CollisionInfo=new CollisionInfo();
			    collInfo.objInfo=info;
			    collInfo.dirToBody = delta;
			    collInfo.pointInfo = collPts;
				 
				var mat:MaterialProperties = new MaterialProperties();
				mat.restitution = Math.sqrt(sphere.material.restitution * capsule.material.restitution);
				mat.friction = Math.sqrt(sphere.material.friction * capsule.material.friction);
				collInfo.mat = mat;
				collArr.push(collInfo);
				 
				info.body0.collisions.push(collInfo);
			    info.body1.collisions.push(collInfo);
			}
		}
	}
	
}
