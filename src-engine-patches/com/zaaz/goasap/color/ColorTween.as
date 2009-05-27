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

package com.zaaz.goasap.color
{
	import flash.display.DisplayObject;
	import flash.geom.ColorTransform;

	import org.goasap.interfaces.IManageable;
	import org.goasap.items.LinearGo;
	import org.goasap.PlayStates;	

	/**
	 * A class to tween the color of a DisplayObject based on hex value.
	 * 
	 * @author Graeme Asher (flashdev@zaaz.com)
	 */
	public class ColorTween extends LinearGo implements IManageable
	{
		protected var _target:DisplayObject;
		protected var _colorTo:Number;
		protected var _colorStart:Number;
		protected var _startCT:ColorTransform = new ColorTransform();
		protected var _changeCT:ColorTransform = new ColorTransform();
		protected var _tweenValues:ColorTransform = new ColorTransform();
		protected var _colorProps:Array = ["redMultiplier", "greenMultiplier", "blueMultiplier", "alphaMultiplier", "redOffset", "greenOffset", "blueOffset", "alphaOffset"];

		
		/**
		 * Constructor
		 * @param target		The DisplayObject to tween.
		 * @param colorTo		The hex value to tween to.
		 * @param duration		The amount of time to tween.
		 * @param delay			The amount of time to delay the start of the tween.
		 * @param easing		The easing equation for the tween.
		 * @param colorStart	Sets the target to a starting hex value, pre tweening.
		 */
		public function ColorTween(target:DisplayObject = null, colorTo:Number = NaN, duration:Number = NaN, easing:Function = null, delay:Number = NaN, colorStart:Number = NaN) 
		{
			super(delay, duration, easing);
			
			if(target != null) 
				this.target = target;

			if(!isNaN(colorTo)) 
				this.colorTo = colorTo;
				
			if(!isNaN(colorStart))
				_colorStart = colorStart;
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
		 * The color hex value that will be tweened to.
		 */
		public function get colorTo():Number 
		{
			return _colorTo;
		}
		public function set colorTo(value:Number):void 
		{
			if(super._state == PlayStates.STOPPED) 
				_colorTo = value;
		}
		
		/**
		 * Value of color to start from. If this is not set the existing value will be used.
		 */
		public function get colorStart():Number
		{
			return _colorStart;	
		}
		public function set colorStart(value:Number):void
		{
			if(super._state == PlayStates.STOPPED) 
				_colorStart = value;	
		}

		
		//Overiden Methods
		override public function start():Boolean 
		{
			if(target == null || (isNaN(colorTo))) 
				return false;
			
			if(isNaN(_colorStart))
				_startCT = target.transform.colorTransform;
			else
				_startCT.color = _colorStart;
			
			var endCT:ColorTransform = new ColorTransform();
			endCT.color = _colorTo;
			
			for each (var prop:String in _colorProps)
				_changeCT[prop] = endCT[prop] - _startCT[prop];
			
			return super.start();
		}

		override protected function onUpdate(type:String):void 
		{
			for each (var prop:String in _colorProps) 
				_tweenValues[prop] = super.correctValue(_startCT[prop] + _changeCT[prop] * _position);
				
			target.transform.colorTransform = _tweenValues;
		}

		// IManageable implementation
		public function getActiveTargets():Array 
		{
			return [_target];
		}

		public function getActiveProperties():Array 
		{
			return ["colorTransform"];
		}

		public function isHandling(properties:Array):Boolean 
		{
			if(state == PlayStates.STOPPED)
                return false;
                
			return (properties.indexOf("colorTransform") > -1);
		}

		public function releaseHandling(...params):void 
		{
			stop();
		}
	}
}
