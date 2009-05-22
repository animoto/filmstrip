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
	 * This is a class to tween the alpha of a DisplayObject
	 * 
	 * @author Jud Holliday (flashdev@zaaz.com)
	 */
	public class AlphaTween extends LinearGo implements IManageable
	{
		protected var _target:DisplayObject;
		protected var _alphaTo:Number;
		protected var _alphaStart:Number;
		protected var _alphaChange:Number;

		protected var _localAlphaStart:Number;
		
		/**
		 * Constructor
		 * @param target		The target of the tween
		 * @param alphaTo		The alpha value to tween to
		 * @param duration		The duration of the tween
		 * @param easing		The easing equation to use
		 * @param delay			Delay before tween starts
		 * @param alphaStart	Alpha value which, if set, will override the existing alpha value of the target on start
		 */
		public function AlphaTween(target:DisplayObject = null, alphaTo:Number = NaN, duration:Number = NaN, easing:Function = null, delay:Number = NaN, alphaStart:Number = NaN) 
		{
			super(delay, duration, easing);
			
			if(target != null) 
				this.target = target;
				
			if(!isNaN(alphaTo)) 
				this.alphaTo = alphaTo;

			// if(!isNaN(alphaStart))
				_alphaStart = alphaStart;
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
		 * The alpha value that will be tweened to.
		 */
		public function get alphaTo():Number 
		{
			return _alphaTo;
		}
		public function set alphaTo(value:Number):void 
		{
			if(super._state == PlayStates.STOPPED) 
				_alphaTo = value;
		}

		/**
		 * Value of alpha to start from. If this is not set the existing value will be used.
		 */
		public function get alphaStart():Number
		{
			return _alphaStart;	
		}
		public function set alphaStart(value:Number):void
		{
			if(super._state == PlayStates.STOPPED) 
				_alphaStart = value;	
		}


		//Overridden methods
		override public function start():Boolean 
		{
			if(target == null || (isNaN(alphaTo))) 
				return false;
			
			_localAlphaStart = _alphaStart;
			if(isNaN(_localAlphaStart))
				_localAlphaStart = target.alpha;
			else
				target.alpha = _localAlphaStart;
			
			if(super.useRelative) 
				_alphaChange = _alphaTo;
			else 
				_alphaChange = (_alphaTo - _localAlphaStart);
			
			return super.start();
		}

		override protected function onUpdate(type:String):void 
		{
			if(!isNaN(_alphaTo)) 
				target.alpha = super.correctValue(_localAlphaStart + (_alphaChange * _position));
		}

		
		// IManageable implementation
		public function getActiveTargets():Array 
		{
			return [_target];
		}

		public function getActiveProperties():Array 
		{
			return ["alpha"];
		}

		public function isHandling(properties:Array):Boolean 
		{
			if(state == PlayStates.STOPPED)
                return false;
                
			return (properties.indexOf("alpha") > -1);
		}

		public function releaseHandling(...params):void 
		{
			stop();
		}
	}
}
