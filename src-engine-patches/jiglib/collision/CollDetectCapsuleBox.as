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
	
	public class CollDetectCapsuleBox extends CollDetectFunctor {
		
		public function CollDetectCapsuleBox() {
			name = "CapsuleBox";
			type0 = "CAPSULE";
			type1 = "BOX";
		}
		
		override public function collDetect(info:CollDetectInfo, collArr:Array):void {
			var tempBody:RigidBody;
			if(info.body0.type=="BOX") {
				tempBody=info.body0;
				info.body0=info.body1;
				info.body1=tempBody;
			}
			
			var capsule:JCapsule = info.body0 as JCapsule;
			var box:JBox = info.body1 as JBox;
			
			if (!capsule.hitTestObject3D(box)) {
				return;
			}
			
			var collPts:Array = [];
			var cpInfo:CollPointInfo;
			
			var oldSeg:JSegment = new JSegment(capsule.getBottomPos(capsule.oldState), JNumber3D.multiply(capsule.oldState.orientation.getCols()[1], capsule.length));
			var newSeg:JSegment = new JSegment(capsule.getBottomPos(capsule.currentState), JNumber3D.multiply(capsule.currentState.orientation.getCols()[1], capsule.length));
			var radius:Number = capsule.radius;
			
			var oldObj:Object = new Object();
			var oldDistSq:Number = oldSeg.segmentBoxDistanceSq(oldObj, box, box.oldState);
			var newObj:Object = new Object();
			var newDistSq:Number = newSeg.segmentBoxDistanceSq(newObj, box, box.currentState);
			var arr:Array = box.oldState.orientation.getCols();
			
			if (Math.min(oldDistSq, newDistSq) < Math.pow(radius + JConfig.collToll, 2)) {
				var segPos:JNumber3D = oldSeg.getPoint(Number(oldObj.pfLParam));
				var boxPos:JNumber3D = box.oldState.position.clone();
				boxPos = JNumber3D.add(boxPos, JNumber3D.multiply(arr[0], oldObj.pfLParam0));
				boxPos = JNumber3D.add(boxPos, JNumber3D.multiply(arr[1], oldObj.pfLParam1));
				boxPos = JNumber3D.add(boxPos, JNumber3D.multiply(arr[2], oldObj.pfLParam2));
				
				var dist:Number = Math.sqrt(oldDistSq);
				var depth:Number = radius - dist;
				
				var dir:JNumber3D;
				if (dist > JNumber3D.NUM_TINY) {
					dir = JNumber3D.sub(segPos, boxPos);
					dir.normalize();
				}
				else if (JNumber3D.sub(segPos, box.oldState.position).modulo > JNumber3D.NUM_TINY) {
					dir = JNumber3D.sub(segPos, box.oldState.position);
					dir.normalize();
				}
				else {
					dir = JNumber3D.UP;
					JMatrix3D.multiplyVector(JMatrix3D.rotationMatrix(0, 0, 1, 360 * Math.random()), dir);
				}
				 
				cpInfo = new CollPointInfo();
				cpInfo.r0 = JNumber3D.sub(boxPos, capsule.oldState.position);
				cpInfo.r1 = JNumber3D.sub(boxPos, box.oldState.position);
				cpInfo.initialPenetration = depth;
				collPts.push(cpInfo);
			}
			
			
			oldSeg = new JSegment(capsule.getEndPos(capsule.oldState), JNumber3D.multiply(capsule.oldState.orientation.getCols()[1], capsule.length));
			newSeg = new JSegment(capsule.getEndPos(capsule.currentState), JNumber3D.multiply(capsule.currentState.orientation.getCols()[1], capsule.length));
			 
			oldObj = new Object();
			oldDistSq = oldSeg.segmentBoxDistanceSq(oldObj, box, box.oldState);
			newObj = new Object();
			newDistSq = newSeg.segmentBoxDistanceSq(newObj, box, box.currentState);
			
			if (Math.min(oldDistSq, newDistSq) < Math.pow(radius + JConfig.collToll, 2)) {
				segPos = oldSeg.getPoint(Number(oldObj.pfLParam));
				boxPos = box.oldState.position.clone();
				boxPos = JNumber3D.add(boxPos, JNumber3D.multiply(arr[0], oldObj.pfLParam0));
				boxPos = JNumber3D.add(boxPos, JNumber3D.multiply(arr[1], oldObj.pfLParam1));
				boxPos = JNumber3D.add(boxPos, JNumber3D.multiply(arr[2], oldObj.pfLParam2));
				
				dist = Math.sqrt(oldDistSq);
				depth = radius - dist;
				
				if (dist > JNumber3D.NUM_TINY) {
					dir = JNumber3D.sub(segPos, boxPos);
					dir.normalize();
				}
				else if (JNumber3D.sub(segPos, box.oldState.position).modulo > JNumber3D.NUM_TINY) {
					dir = JNumber3D.sub(segPos, box.oldState.position);
					dir.normalize();
				}
				else {
					dir = JNumber3D.UP;
					JMatrix3D.multiplyVector(JMatrix3D.rotationMatrix(0, 0, 1, 360 * Math.random()), dir);
				}
				 
				cpInfo = new CollPointInfo();
				cpInfo.r0 = JNumber3D.sub(boxPos, capsule.oldState.position);
				cpInfo.r1 = JNumber3D.sub(boxPos, box.oldState.position);
				cpInfo.initialPenetration = depth;
				collPts.push(cpInfo);
			}
			
			if (collPts.length > 0) {
				var collInfo:CollisionInfo=new CollisionInfo();
			    collInfo.objInfo=info;
			    collInfo.dirToBody = dir;
			    collInfo.pointInfo = collPts;
				
				var mat:MaterialProperties = new MaterialProperties();
				mat.restitution = Math.sqrt(capsule.material.restitution * box.material.restitution);
				mat.friction = Math.sqrt(capsule.material.friction * box.material.friction);
				collInfo.mat = mat;
				collArr.push(collInfo);
				
				info.body0.collisions.push(collInfo);
			    info.body1.collisions.push(collInfo);
			}
		}
	}
	
}
