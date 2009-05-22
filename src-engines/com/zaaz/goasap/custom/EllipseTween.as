/**
 * Copyright (c) 2008 ZAAZ Inc.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
 
package com.zaaz.goasap.custom
{
	import flash.display.DisplayObject;	import flash.display.Sprite;	import flash.geom.Point;	import flash.geom.Rectangle;
	import org.goasap.interfaces.IManageable;	import org.goasap.items.LinearGo;
	import org.goasap.PlayStates;

	/**
	 * <p><b>EllipseTween: Tweens a target along the edge of an ellipse.</b></p>
	 * 
	 * <p>EllipseTween moves a target along the edge of an ellipses bounds.  
	 * At the start of the tween the current angle of the target in relation to the 
	 * ellipse is calculated automatically. You can use absolute(tween target to 90º on the ellipse) 
	 * or relative(tween target 180º from current angle on the ellipse) positioning by
	 * setting the <code>useRelative</code> property.</p>
	 * 
	 * @author Graeme Asher, Jud Holliday (flashdev@zaaz.com)
	 */
	public class EllipseTween extends LinearGo implements IManageable 
	{

		public var angleTo:Number;

		protected var _target:DisplayObject;
		protected var _bounds:Rectangle;
		protected var _radii:Point;
		protected var _center:Point;
		protected var _startAngle:Number;
		protected var _changeAngle:Number;

		//sprite used for rendering the ellipse path;
		protected var _path:Sprite;

		
		/**
		 * Constructor
		 * @param target		The target to tween.
		 * @param angleTo		The new angle to tween to on the ellipse.
		 * @param bounds		A Rectangle object representing the bounds of the ellipse.
		 * @param duration		The duration of the tween.
		 * @param easing		Any of the available easing functions in fl.motion.easing.
		 * @param delay			Delays the start of the tween.
		 * @param startAngle	Angle which tween will start from
		 */
		public function EllipseTween(target:DisplayObject = null, 
                                     angleTo:Number = NaN,
                                     bounds:Rectangle = null,
                                     duration:Number = NaN,
                                     easing:Function = null,
                                     delay:Number = NaN,
                                     startAngle:Number = NaN) 
		{
			super(delay, duration, easing);
			
			if (target != null)
				this.target = target;
				
			if (!isNaN(angleTo))
				this.angleTo = angleTo;
				
			if (bounds != null)	
				this.bounds = bounds;
				
			if (!isNaN(startAngle))
			{
				_startAngle = startAngle - 90;	
			}	
		}

		/**
		 * The target of the tween
		 */
		public function get target():DisplayObject 
		{
			return _target;
		}

		public function set target(target:DisplayObject):void 
		{
			if(_state == PlayStates.STOPPED) 
                   _target = target;
		}

		/**
		 * The bounding rectangle which defines the width and height of the ellipse.
		 * This can be updated which the tween is playing to change value on the fly.
		 */		
		public function get bounds():Rectangle 
		{
			return _bounds;
		}

		public function set bounds(value:Rectangle):void 
		{
			_bounds = value;
			calculateValues();
			drawPath();
		}

		/**
		 * Moves the bounds of the ellipse so that it is relative to the current position of the target.
		 * By calling this method the position of the ellipse will be moved to ensure that when the target
		 * starts movoing it will already be on the path of the ellipse.
		 * @param startAngle The angle on the ellipse that the target should start at.
		 */
		public function useTargetAsStartAngle(startAngle:Number = 0):void
		{
			if (target != null && bounds != null)
			{
				var radian:Number = (startAngle - 90) * Math.PI / 180;
				var ellipseX:Number = _center.x + _radii.x * Math.cos(radian);
				var ellipseY:Number = _center.y + _radii.y * Math.sin(radian);
				bounds.x -= ellipseX - target.x;				bounds.y -= ellipseY - target.y;
				calculateValues();
				drawPath();
			}
		}

		/**
		 * Calling this method will cause the ellipse to be drawn to screen,
		 * thus making it easier to see what path the target will take when it tweens.
		 */
		public function showPath():void
		{
			if (target != null && target.parent != null && bounds != null);
			{
			if (_path == null)
			{
				_path = new Sprite();
				target.parent.addChild(_path);	
				drawPath();
			}				
			}	
		}

		private function drawPath():void
		{
			if (_path != null)
			{
				_path.graphics.clear();
				_path.graphics.lineStyle(1, 0x000000, .5);
				_path.graphics.drawEllipse(bounds.x, bounds.y, bounds.width, bounds.height);
			}
		}

		private function calculateValues():void
		{
			
			_radii = new Point(bounds.width / 2, bounds.height / 2);
			_center = _radii.add(new Point(bounds.x, bounds.y));
			
			if(useRelative) 
			{
				_changeAngle = angleTo;
			}
            else 
			{ 
				_changeAngle = (angleTo - _startAngle) - 90;
			}	
		}
		
		
		//Overridden Methods
		override public function start():Boolean 
		{
			if(target == null || isNaN(angleTo) || bounds == null) 
			{
				return false;
			}
			if (isNaN(_startAngle))
			{
				_startAngle = Math.atan2((target.y - _center.y), (target.x - _center.x)) * 180 / Math.PI;
			}
			calculateValues();
			
			return super.start();
		}

		override protected function onUpdate(type:String):void 
		{
			var angle:Number = _startAngle + (_changeAngle * _position);
			var radian:Number = angle * Math.PI / 180;
			target.x = super.correctValue(_center.x + _radii.x * Math.cos(radian));
			target.y = super.correctValue(_center.y + _radii.y * Math.sin(radian));
		}


		// IManageable implementation
		public function getActiveTargets():Array 
		{
			return [_target];
		}

		public function getActiveProperties():Array 
		{
			return ["x", "y"];
		}

		public function isHandling(properties:Array):Boolean 
		{
			if (state == PlayStates.STOPPED)
                return false;
			return (properties.indexOf("x") > -1 || properties.indexOf("y") > -1);
		}

		public function releaseHandling(...params):void 
		{
			stop();
		}
	}
}