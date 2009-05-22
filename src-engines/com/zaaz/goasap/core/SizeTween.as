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
	public class SizeTween extends LinearGo implements IManageable
	{
		protected var _target:DisplayObject;
		protected var _widthTo:Number;
		protected var _widthStart:Number;
		protected var _widthChange:Number;
		protected var _heightTo:Number;
		protected var _heightStart:Number;
		protected var _heightChange:Number;
		
		protected var _localWidthStart:Number;
		protected var _localHeightStart:Number;
		
		
		/**
		 * Constructor
		 * @param target		A DisplayObject to tween size (width/height).
		 * @param widthTo		The value to adjust width to.
		 * @param heightTo		The value to adjust height to.
		 * @param duration		The amount of time to tween.
		 * @param delay			The amount of time to delay the start of the tween.
		 * @param easing		The easing equation for the tween.
		 * @param widthStart	Sets the target to a starting size and begins tween from that point.
		 * @param heightStart	Sets the target to a starting size and begins tween from that point.
		 */
		public function SizeTween(target:DisplayObject = null, widthTo:Number = NaN, heightTo:Number = NaN, duration:Number = NaN, easing:Function = null, delay:Number = NaN, widthStart:Number = NaN, heightStart:Number = NaN) 
		{
			super(delay, duration, easing);
			
			if(target != null) 
				this.target = target;

			if(!isNaN(widthTo)) 
				this.widthTo = widthTo;

			if(!isNaN(heightTo)) 
				this.heightTo = heightTo;
				
//			if(!isNaN(widthStart))
				_widthStart = widthStart;

//			if(!isNaN(heightStart))
				_heightStart = heightStart;
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
		 * The width value that will be tweened to.
		 */
		public function get widthTo():Number 
		{
			return _widthTo;
		}

		public function set widthTo(value:Number):void 
		{
			if(super._state == PlayStates.STOPPED) 
				_widthTo = value;
		}

		/**
		 * The height value that will be tweened to.
		 */
		public function get heightTo():Number 
		{
			return _heightTo;
		}

		public function set heightTo(value:Number):void 
		{
			if(super._state == PlayStates.STOPPED) 
				_heightTo = value;
		}

		/**
		 * Value of width to start from. If this is not set the existing value will be used.
		 */
		public function get widthStart():Number
		{
			return _widthStart;	
		}

		public function set widthStart(value:Number):void
		{
			if(super._state == PlayStates.STOPPED) 
				_widthStart = value;	
		}

		/**
		 * Value of height to start from. If this is not set the existing value will be used.
		 */
		public function get heightStart():Number
		{
			return _heightStart;	
		}

		public function set heightStart(value:Number):void
		{
			if(super._state == PlayStates.STOPPED) 
				_heightStart = value;	
		}


		//Overiden Methods
		override public function start():Boolean 
		{
			if(target == null || (isNaN(widthTo) && (isNaN(heightTo))) ) 
				return false;
			
			_localWidthStart = _widthStart;
			_localHeightStart = _heightStart;
			
			if(isNaN(_localWidthStart))
				_localWidthStart = target.width;
			else
				target.width = _localWidthStart;
			
			if(isNaN(_localHeightStart))
				_localHeightStart = target.height;
			else
				target.height = _localHeightStart;
			
			if(super.useRelative)
			{
				_widthChange = _widthTo;
				_heightChange = _heightTo;
			}
			else 
			{
				_widthChange = (_widthTo - _localWidthStart);
				_heightChange = (_heightTo - _localHeightStart);
			}
			
			return super.start();
		}

		override protected function onUpdate(type:String):void 
		{
			if(!isNaN(_widthTo)) 
			{
				target.width = super.correctValue(_localWidthStart + (_widthChange * _position));
			}
			if(!isNaN(_heightTo)) 
			{
				target.height = super.correctValue(_localHeightStart + (_heightChange * _position));
			}
		}


		// IManageable implementation
		public function getActiveTargets():Array 
		{
			return [_target];
		}

		public function getActiveProperties():Array 
		{
			return ["width", "height"];
		}

		public function isHandling(properties:Array):Boolean 
		{
			if (state == PlayStates.STOPPED)
                return false;
			return (properties.indexOf("width") > -1 || properties.indexOf("height") > -1);
		}

		public function releaseHandling(...params):void 
		{
			stop();
		}
	}
}