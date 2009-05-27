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
	
	public class CollDetectCapsulePlane extends CollDetectFunctor {
		
		public function CollDetectCapsulePlane() {
			name = "CapsulePlane";
			type0 = "CAPSULE";
			type1 = "PLANE";
		}
		
		override public function collDetect(info:CollDetectInfo, collArr:Array):void {
			var tempBody:RigidBody;
			if (info.body0.type == "PLANE") {
				tempBody = info.body0;
				info.body0 = info.body1;
				info.body1 = tempBody;
			}
			
			var capsule:JCapsule = info.body0 as JCapsule;
			var plane:JPlane = info.body1 as JPlane;
			
			var collPts:Array = [];
			var cpInfo:CollPointInfo;
			
			var oldPos:JNumber3D = capsule.getBottomPos(capsule.oldState);
			var oldDist:Number = plane.pointPlaneDistance(oldPos);
			var newPos:JNumber3D = capsule.getBottomPos(capsule.currentState);
			var newDist:Number = plane.pointPlaneDistance(newPos);
			
			if (Math.min(oldDist, newDist) < capsule.radius + JConfig.collToll) {
				var oldDepth:Number = capsule.radius - oldDist;
				var worldPos:JNumber3D = JNumber3D.sub(oldPos, JNumber3D.multiply(plane.normal, capsule.radius));
				
				cpInfo=new CollPointInfo();
				cpInfo.r0 = JNumber3D.sub(worldPos, capsule.oldState.position);
				cpInfo.r1 = JNumber3D.sub(worldPos, plane.oldState.position);
				cpInfo.initialPenetration = oldDepth;
				collPts.push(cpInfo);
			}
			
			oldPos = capsule.getEndPos(capsule.oldState);
			newPos = capsule.getEndPos(capsule.currentState);
			oldDist = plane.pointPlaneDistance(oldPos);
			newDist = plane.pointPlaneDistance(newPos);
			if (Math.min(oldDist, newDist) < capsule.radius + JConfig.collToll) {
				oldDepth = capsule.radius - oldDist;
				worldPos = JNumber3D.sub(oldPos, JNumber3D.multiply(plane.normal, capsule.radius));
				
				cpInfo=new CollPointInfo();
				cpInfo.r0 = JNumber3D.sub(worldPos, capsule.oldState.position);
				cpInfo.r1 = JNumber3D.sub(worldPos, plane.oldState.position);
				cpInfo.initialPenetration = oldDepth;
				collPts.push(cpInfo);
			}
			
			if (collPts.length > 0) {
				var collInfo:CollisionInfo=new CollisionInfo();
			    collInfo.objInfo=info;
			    collInfo.dirToBody = plane.normal;
			    collInfo.pointInfo = collPts;
				
				var mat:MaterialProperties = new MaterialProperties();
				mat.restitution = Math.sqrt(capsule.material.restitution * plane.material.restitution);
				mat.friction = Math.sqrt(capsule.material.friction * plane.material.friction);
				collInfo.mat = mat;
				collArr.push(collInfo);
				
				info.body0.collisions.push(collInfo);
			    info.body1.collisions.push(collInfo);
			}
		}
	}
	
}
