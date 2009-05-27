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
	
	import org.goasap.PlayStates;
	import org.goasap.interfaces.IManageable;
	import org.goasap.items.LinearGo;	
	/**
	 * A class to tween the width and height of a DisplayObject
	 * 
	 * @author Graeme Asher (flashdev@zaaz.com)
	 */
	public class ScaleTween extends LinearGo implements IManageable
	{
		protected var _target:DisplayObject;
		protected var _scaleXTo:Number;
		protected var _scaleXStart:Number;
		protected var _scaleXChange:Number;
		protected var _scaleYTo:Number;
		protected var _scaleYStart:Number;
		protected var _scaleYChange:Number;
		
		protected var _localXStart:Number;
		protected var _localYStart:Number;
				/**
		 * Constructor
		 * @param target		A DisplayObject to scale.
		 * @param scaleXTo		The percentage to scaleX to. 1 = 100%
		 * @param scaleYTo		The percentage to scaleY to. 1 = 100%
		 * @param duration		The amount of time to tween.
		 * @param delay			The amount of time to delay the start of the tween.
		 * @param easing		The easing equation for the tween.
		 * @param scaleXStart	Sets the target to a starting scaleX and begins tween from that point.
		 * @param scaleYStart	Sets the target to a starting scaleY and begins tween from that point.
		 */
		public function ScaleTween(target:DisplayObject = null, scaleXTo:Number = NaN, scaleYTo:Number = NaN, duration:Number = NaN, easing:Function = null, delay:Number = NaN, scaleXStart:Number = NaN, scaleYStart:Number = NaN) 
		{
			super(delay, duration, easing);
			
			if(target != null) 
				this.target = target;

			if(!isNaN(scaleXTo)) 
				this.scaleXTo = scaleXTo;

			if(!isNaN(scaleYTo)) 
				this.scaleYTo = scaleYTo;

//			if(!isNaN(scaleXStart))
				_scaleXStart = scaleXStart;

//			if(!isNaN(scaleYStart))
				_scaleYStart = scaleYStart;
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
		 * The scaleX value that will be tweened to.
		 */
		public function get scaleXTo():Number 
		{
			return _scaleXTo;
		}
		public function set scaleXTo(value:Number):void 
		{
			if(super._state == PlayStates.STOPPED) 
				_scaleXTo = value;
		}
		/**
		 * The scaleY value that will be tweened to.
		 */
		public function get scaleYTo():Number 
		{
			return _scaleYTo;
		}
		public function set scaleYTo(value:Number):void 
		{
			if(super._state == PlayStates.STOPPED) 
				_scaleYTo = value;
		}
		/**
		 * Value of scaleX to start from. If this is not set the existing value will be used.
		 */
		public function get scaleXStart():Number
		{
			return _scaleXStart;	
		}
		public function set scaleXStart(value:Number):void
		{
			if(super._state == PlayStates.STOPPED) 
				_scaleXStart = value;	
		}
		/**
		 * Value of scaleY to start from. If this is not set the existing value will be used.
		 */
		public function get scaleYStart():Number
		{
			return _scaleYStart;	
		}
		public function set scaleYStart(value:Number):void
		{
			if(super._state == PlayStates.STOPPED) 
				_scaleYStart = value;	
		}

		//Overiden Methods
		override public function start():Boolean 
		{
			if(target == null || (isNaN(scaleXTo) && (isNaN(scaleYTo)))) 
				return false;
			
			_localXStart = _scaleXStart;
			_localYStart = _scaleYStart;
			
			if(isNaN(_localXStart))
				_localXStart = target.scaleX;
			else
				target.scaleX = _localXStart;
			
			if(isNaN(_localYStart))
				_localYStart = target.scaleY;
			else
				target.scaleY = _localYStart;
			
			if(super.useRelative)
			{
				_scaleXChange = _scaleXTo;
				_scaleYChange = _scaleYTo;
			}
			else 
			{
				_scaleXChange = (_scaleXTo - _localXStart);
				_scaleYChange = (_scaleYTo - _localYStart);
			}
			
			return super.start();
		}
		override protected function onUpdate(type:String):void 
		{
			if(!isNaN(scaleXTo))
				target.scaleX = super.correctValue(_localXStart + (_scaleXChange * _position)); 
			if(!isNaN(scaleYTo))
				target.scaleY = super.correctValue(_localYStart + (_scaleYChange * _position));
		}
				// IManageable implementation
		public function getActiveTargets():Array 
		{
			return [_target];
		}
		public function getActiveProperties():Array 
		{
			return ["scaleX", "scaleY"];
		}
		public function isHandling(properties:Array):Boolean 
		{
			if (state == PlayStates.STOPPED)
                return false;
			return (properties.indexOf("scaleX") > -1 || properties.indexOf("scaleY") > -1);
		}
		public function releaseHandling(...params):void 
		{
			stop();
		}
	}
}