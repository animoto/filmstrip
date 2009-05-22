/**
 * Copyright (c) 2008 ZAAZ, Inc
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

package com.zaaz.goasap.core
{
	import flash.display.DisplayObject;

	import org.goasap.items.LinearGo;	
	import org.goasap.interfaces.IManageable;
	import org.goasap.PlayStates;

	/**
	 * This is a class to tween basic x and y position of a DisplayObject
	 * 
	 * @author Jud Holliday (flashdev@zaaz.com)
	 */
	public class PositionTween extends LinearGo implements IManageable
	{
		protected var _target:DisplayObject;
		protected var _xTo:Number;
		protected var _yTo:Number;
		protected var _xStart:Number;
		protected var _yStart:Number;
		protected var _xChange:Number;
		protected var _yChange:Number;
		
		protected var _localXStart:Number;
		protected var _localYStart:Number;

		
		/**
		 * Constructor
		 * @param target		The target of the tween
		 * @param xTo			The x value to tween to		 * @param yTo			The y value to tween to
		 * @param duration		The duration of the tween
		 * @param easing		The easing equation to use
		 * @param delay			Delay before tween starts
		 * @param xStart		If this parameter is set it will override the existing x value of the target on start		 * @param yStart		If this parameter is set it will override the existing y value of the target on start
		 */
		public function PositionTween(target:DisplayObject = null, xTo:Number = NaN, yTo:Number = NaN, duration:Number = NaN, easing:Function = null, delay:Number = NaN,  xStart:Number = NaN, yStart:Number = NaN) 
		{
			super(delay, duration, easing);
			
			if (target != null) 
				this.target = target;

			if (!isNaN(xTo)) 
				this.xTo = xTo;

			if (!isNaN(yTo)) 
				this.yTo = yTo;
				
//			if (!isNaN(xStart)) 
				this.xStart = xStart;
			
//			if (!isNaN(yStart)) 
				this.yStart = yStart;
		}

		
		//Getters & Setters
		/**
		 * Target of the tween
		 */
		public function get target():DisplayObject 
		{
			return _target;
		}

		public function set target(target:DisplayObject):void 
		{
			if(super._state == PlayStates.STOPPED) 
				_target = target;
		}

		/**
		 * The x value that will be tweened to.
		 */
		public function get xTo():Number 
		{
			return _xTo;
		}

		public function set xTo(value:Number):void 
		{
			if(super._state == PlayStates.STOPPED) 
				_xTo = value;
		}

		/**
		 * The y value that will be tweened to.
		 */
		public function get yTo():Number 
		{
			return _yTo;
		}

		public function set yTo(value:Number):void 
		{
			if(super._state == PlayStates.STOPPED) 
				_yTo = value;
		}

		/**
		 * Value of x to start from. If this is not set the existing value will be used.
		 */
		public function get xStart():Number
		{
			return _xStart;	
		}

		public function set xStart(value:Number):void
		{
			if(super._state == PlayStates.STOPPED) 
				_xStart = value;	
		}

		/**
		 * Value of y to start from. If this is not set the existing value will be used.
		 */
		public function get yStart():Number
		{
			return _yStart;	
		}

		public function set yStart(value:Number):void
		{
			if(super._state == PlayStates.STOPPED) 
				_yStart = value;	
		}

		
		//Overriden Methods
		override public function start():Boolean 
		{
			if(target == null || (isNaN(xTo) && isNaN(yTo))) 
				return false;
		
			_localXStart = _xStart;
			_localYStart = _yStart;
			
			if(isNaN(_xTo) == false) 
			{
				if(isNaN(_localXStart))
					_localXStart = target.x;
				else
					target.x = _localXStart;
				
				if(super.useRelative) 
					_xChange = _xTo;
				else 
					_xChange = (_xTo - _localXStart);
			}
			
			if(isNaN(_yTo) == false) 
			{
				if(isNaN(_localYStart))
					_localYStart = target.y;
				else
					target.y = _localYStart;
					
				if(super.useRelative) 
					_yChange = _yTo;
				else 
					_yChange = (_yTo - _localYStart);
			}
			
			return super.start();
		}

		override protected function onUpdate(type:String):void 
		{
			if(isNaN(_xTo) == false) 
				target.x = super.correctValue(_localXStart + (_xChange * _position));

			if(isNaN(_yTo) == false) 
				target.y = super.correctValue(_localYStart + (_yChange * _position));
		}

		
		//IManageable implementation
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
			if(state == PlayStates.STOPPED)
                return false;
                
			return (properties.indexOf("x") > -1 || properties.indexOf("y") > -1);
		}

		public function releaseHandling(...params):void 
		{
			stop();
		}
	}
}
