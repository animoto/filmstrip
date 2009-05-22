/** * Copyright (c) 2008 ZAAZ, Inc. *  * Permission is hereby granted, free of charge, to any person obtaining a copy * of this software and associated documentation files (the "Software"), to deal * in the Software without restriction, including without limitation the rights * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell * copies of the Software, and to permit persons to whom the Software is * furnished to do so, subject to the following conditions: *  * The above copyright notice and this permission notice shall be included in * all copies or substantial portions of the Software. *  * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN * THE SOFTWARE. */ package com.zaaz.goasap.sound {	import flash.geom.Transform;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	import org.goasap.interfaces.IManageable;
	import org.goasap.items.LinearGo;	import org.goasap.PlayStates;
	/**	 * This is a class to tween the pan of a SoundTranform object assigned to the sound channel's souundTransform property.	 * 	 * @author Cole Peterson (flashdev@zaaz.com)	 */	public class PanTween extends LinearGo implements IManageable	{		protected var _target:SoundChannel;		protected var _panTo:Number;		protected var _panStart:Number;		protected var _panChange:Number;
		
		/**		 * Constructor		 * @param target		The target of the tween		 * @param panTo			The pan value to tween to		 * @param duration		The duration of the tween		 * @param easing		The easing equation to use		 * @param delay			Delay before tween starts		 * @param panStart		Pan value which, if set, will override the existing pan value of the target on start		 */		public function PanTween(target:SoundChannel = null, panTo:Number = NaN, duration:Number = NaN, easing:Function = null, delay:Number = NaN, panStart:Number = NaN) 		{			super(delay, duration, easing);						if(target != null) 				this.target = target;						if(!isNaN(panTo)) 				this.panTo = panTo;			if(!isNaN(panStart))				_panStart = panStart;		}
		
		//Getters & Setters			/**		 * Target of the tween		 */		public function get target():SoundChannel 		{			return _target;		}
		public function set target(target:SoundChannel):void 		{			if(super._state == PlayStates.STOPPED) 				_target = target;		}
		/**		 * Current pan of the SoundTransform object assigned to the sound channel		 */		public function get pan():Number 		{			return target.soundTransform.pan;		}
		/**		 * The pan that will be tweened to.		 */		public function get panTo():Number 		{			return _panTo;		}
		public function set panTo(value:Number):void 		{			if(super._state == PlayStates.STOPPED) 				_panTo = value;		}
		/**		 * Value of pan to start from. If this is not set the existing value will be used.		 */		public function get panStart():Number		{			return _panStart;			}
		public function set panStart(value:Number):void		{			if(super._state == PlayStates.STOPPED) 				_panStart = value;			}
		
		//Overridden methods
		override public function start():Boolean 		{			if(target == null || isNaN(panTo)) 				return false;							var transform:SoundTransform = target.soundTransform;							if(isNaN(_panStart))				_panStart = transform.pan;			else			{				transform.pan = _panStart;				target.soundTransform = transform;			}			_panChange = (_panTo - _panStart);						return super.start();		}
		override protected function onUpdate(type:String):void 		{			if(!isNaN(_panTo)) 			{				var transform:SoundTransform = target.soundTransform;				transform.pan = super.correctValue(_panStart + (_panChange * _position));				target.soundTransform = transform;			}		}
		
		// IManageable implementation		public function getActiveTargets():Array 		{			return [_target];		}
		public function getActiveProperties():Array 		{			return ["pan"];		}
		public function isHandling(properties:Array):Boolean 		{			if(state == PlayStates.STOPPED)                return false;                			return (properties.indexOf("pan") > -1);		}
		public function releaseHandling(...params):void 		{			stop();		}	}}