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

	public class CollDetectSphereBox extends CollDetectFunctor {
		
		public function CollDetectSphereBox() {
			name = "SphereBox";
			type0 = "SPHERE";
			type1 = "BOX";
		}
		
		override public function collDetect(info:CollDetectInfo, collArr:Array):void {
			var tempBody:RigidBody;
			if(info.body0.type=="BOX") {
				tempBody=info.body0;
				info.body0=info.body1;
				info.body1=tempBody;
			}
			
			var sphere:JSphere = info.body0 as JSphere;
			var box:JBox = info.body1 as JBox;
			
			if (!sphere.hitTestObject3D(box)) {
				return;
			}
			var spherePos:JNumber3D = sphere.oldState.position;
			var boxPos:JNumber3D = box.oldState.position;
			
			var oldBoxPoint:Object=new Object();
			var newBoxPoint:Object=new Object();
			
			var oldDist:Number = box.getDistanceToPoint(box.oldState, oldBoxPoint, sphere.oldState.position);
			var newDist:Number = box.getDistanceToPoint(box.currentState, newBoxPoint, sphere.currentState.position);
			
			var oldDepth:Number = sphere.radius - oldDist;
			var newDepth:Number = sphere.radius - newDist;
			if (Math.max(oldDepth, newDepth) > -JConfig.collToll) {
				var dir:JNumber3D;
				var collPts:Array = [];
				if (oldDist < -JNumber3D.NUM_TINY) {
					dir = JNumber3D.sub(JNumber3D.sub(oldBoxPoint.pos, sphere.oldState.position), oldBoxPoint.pos);
					dir.normalize();
				}
				else if (oldDist > JNumber3D.NUM_TINY) {
					dir = JNumber3D.sub(sphere.oldState.position, oldBoxPoint.pos);
					dir.normalize();
				}
				else {
					dir = JNumber3D.sub(sphere.oldState.position, box.oldState.position);
					dir.normalize();
				}
				
				var cpInfo:CollPointInfo = new CollPointInfo();
				cpInfo.r0 = JNumber3D.sub(oldBoxPoint.pos, sphere.oldState.position);
				cpInfo.r1 = JNumber3D.sub(oldBoxPoint.pos, box.oldState.position);
				cpInfo.initialPenetration = oldDepth;
				collPts.push(cpInfo);
				
				var collInfo:CollisionInfo=new CollisionInfo();
			    collInfo.objInfo=info;
			    collInfo.dirToBody = dir;
			    collInfo.pointInfo = collPts;
				
				var mat:MaterialProperties = new MaterialProperties();
				mat.restitution = Math.sqrt(sphere.material.restitution * box.material.restitution);
				mat.friction = Math.sqrt(sphere.material.friction * box.material.friction);
				collInfo.mat = mat;
				collArr.push(collInfo);
				
				info.body0.collisions.push(collInfo);
			    info.body1.collisions.push(collInfo);
			}
		}
	}
	
}
