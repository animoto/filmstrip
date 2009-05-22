/**
 * Copyright (c) 2008 ZAAZ, Inc.
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

package com.zaaz.goasap.filter
{
	import flash.display.DisplayObject;
	import flash.filters.BlurFilter;

	import org.goasap.interfaces.IManageable;
	import org.goasap.items.LinearGo;
	import org.goasap.PlayStates;	

	/**
	 * A class to tween the blur of a DisplayObject.
	 * 
	 * @author Graeme Asher (flashdev@zaaz.com)
	 */
	public class BlurTween extends LinearGo implements IManageable
	{
		protected var _target:DisplayObject;
		protected var _blurXTo:Number;
		protected var _blurXStart:Number;
		protected var _blurXChange:Number;
		protected var _blurYTo:Number;
		protected var _blurYStart:Number;
		protected var _blurYChange:Number;
		protected var _quality:int;
		
		/**
		 * Constructor
		 * @param target		A DisplayObject to blur.
		 * @param blurXTo		The destination value for blurX - horizontal blur.
		 * @param blurYTo		The destination value for blurY - vertical blur.
		 * @param quality		The qulaity level of the blur. Default is 1 = low, 2 = medium, 3 = high.  You may go up to 15 but not recommended applying past 3.
		 * @param duration		The duration of the tween.
		 * @param delay			The amount of time to delay the tween before it starts.
		 * @param easing		The easing equation to use in the tween.
		 * @param blurXStart	Sets the targets blurX to this value at the start of the tween.
		 * @param blurYStart	Sets the targets blurY to this value at the start of the tween.
		 */
		public function BlurTween(target:DisplayObject = null, blurXTo:Number = NaN, blurYTo:Number = NaN, quality:int = 0, duration:Number = NaN, easing:Function = null, delay:Number = NaN, blurXStart:Number = NaN, blurYStart:Number = NaN) 
		{
			super(delay, duration, easing);
			
			if(target != null) 
				this.target = target;
			
			if(!isNaN(blurXTo))
				this.blurXTo = blurXTo;

			if(!isNaN(blurYTo)) 
				this.blurYTo = blurYTo;
				
			var filterIndex:int = getFilterIndex(BlurFilter);

			if(quality == 0) 
			{
				if(filterIndex != -1)
					_quality = target.filters[filterIndex].quality;
				else
					_quality = 1;
			}	
			else
			{
				if(quality < 1)
					quality = 1;
				if(quality > 15)
					quality = 15;
				_quality = quality;
			}
				
			if(!isNaN(blurXStart))
				_blurXStart = blurXStart;
			
			if(!isNaN(blurYStart))
				_blurYStart = blurYStart;
			
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
		 * The blurX value that will be tweened to.
		 */
		public function get blurXTo():Number 
		{
			return _blurXTo;
		}
		public function set blurXTo(value:Number):void 
		{
			if(super._state == PlayStates.STOPPED) 
			{
				if(value < 0)
					value = 0;
				if(value > 255)
					value = 255;
				_blurXTo = value;
			}
		}

		/**
		 * The blurY value that will be tweened to.
		 */
		public function get blurYTo():Number 
		{
			return _blurYTo;
		}
		public function set blurYTo(value:Number):void 
		{
			if(super._state == PlayStates.STOPPED) 
			{
				if(value < 0)
					value = 0;
				if(value > 255)
					value = 255;
				_blurYTo = value;
			}
		}

		/**
		 * Value of blurX to start from. If this is not set the existing value will be used.
		 */
		public function get blurXStart():Number
		{
			return _blurXStart;	
		}
		public function set blurXStart(value:Number):void
		{
			if(super._state == PlayStates.STOPPED) 
			{
				if(value < 0)
					value = 0;
				if(value > 255)
					value = 255;
				_blurXStart = value;	
			}
		}

		/**
		 * Value of blurY to start from. If this is not set the existing value will be used.
		 */
		public function get blurYStart():Number
		{
			return _blurYStart;	
		}
		public function set blurYStart(value:Number):void
		{
			if(super._state == PlayStates.STOPPED)
			{
				if(value < 0)
					value = 0;
				if(value > 255)
					value = 255; 
				_blurYStart = value;
			}	
		}

		
		//Overiden Methods
		override public function start():Boolean 
		{
			if(target == null || (isNaN(blurXTo) && isNaN(blurYTo)) ) 
				return false;
				
			var filterIndex:int = getFilterIndex(BlurFilter);	
			var blurFilter:BlurFilter;
			
			if (filterIndex != -1)
				blurFilter = target.filters[filterIndex];
			else
			{
				//if no blur is present create a new BlurFilter with 0 blur
				filterIndex = 0;
				blurFilter = new BlurFilter(0, 0, _quality);
			}
				
			if(isNaN(blurXStart))
				_blurXStart = blurFilter.blurX;	
			else
				blurFilter.blurX = _blurXStart;
					
			
			if(isNaN(blurYStart))
				_blurYStart = blurFilter.blurY;
			else
				blurFilter.blurY = _blurYStart;
					
				
			var currFilters:Array = target.filters;
			currFilters[filterIndex] = blurFilter;	
			target.filters = currFilters;
					
			if(super.useRelative)
			{
				_blurXChange = _blurXTo;
				_blurYChange = _blurYTo;
			}
			else 
			{
				_blurXChange = (_blurXTo - _blurXStart);
				_blurYChange = (_blurYTo - _blurYStart);
			}
			
			return super.start();
		}

		override protected function onUpdate(type:String):void 
		{
			//need to get the filter index each time in case an external process updates the filters array mid tween.
			var filterIndex:int = getFilterIndex(BlurFilter);
			var currFilters:Array = target.filters;
			
			if(!isNaN(_blurXTo))
				currFilters[filterIndex].blurX = super.correctValue(_blurXStart + (_blurXChange * _position));
				
			if(!isNaN(_blurYTo))
				currFilters[filterIndex].blurY = super.correctValue(_blurYStart + (_blurYChange * _position));
				
			target.filters = currFilters;	
		}
		
		protected function getFilterIndex(filterClass:Class):int 
		{
			for(var i:uint = 0;i < target.filters.length; i++) 
			{
				if(target.filters[i] is filterClass) 
					return i;
			}
			return -1;
		}

		
		// IManageable implementation
		public function getActiveTargets():Array 
		{
			return [_target];
		}

		public function getActiveProperties():Array 
		{
			return ["blurX", "blurY"];
		}

		public function isHandling(properties:Array):Boolean 
		{
			if(state == PlayStates.STOPPED)
                return false;
                
			return (properties.indexOf("blurX") > -1 || properties.indexOf("blurY") > -1);
		}

		public function releaseHandling(...params):void 
		{
			stop();
		}
	}
}
