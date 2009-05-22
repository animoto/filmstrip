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

package com.zaaz.goasap.sequence 
{
	import org.goasap.events.GoEvent;
	import org.goasap.items.LinearGo;	
	/**
	 * This class allows for callbacks to be sequenced along with other tweens
	 * without adding a callback to a particular step. This makes it simple to
	 * sequence a number of function calls, including passing parameters.
	 * 
	 * 
	 * Example:
	 * var s:SequenceCA = new SequenceCA();
	 * s.addStep(new PositionTween(clip, 4, 5, .5, 0, Quartic.easeOut));
	 * s.addStep(new CallbackTrigger(doSomething, 1]), true);	 * s.addStep(new CallbackTrigger(doSomethingWithParams, 0, [param1, param2, etc]), true);
	 * s.start()
	 * 
	 * @author Jud Holliday (flashdev@zaaz.com)
	 */
	public class CallbackTrigger extends LinearGo 
	{
		/**
		 * @closure 	The method that will be called
		 * @delay		The delay in seconds before the callback will be triggered
		 * @args	An optional array of arguments that will be passed to the method
		 */
		public function CallbackTrigger( closure:Function = null, delay:Number = NaN, args:Array = null, pulseInterval:Number = 33 ) 
		{
			super(delay, 0);
			super.useFrames = false;
			super.pulseInterval = pulseInterval;
			
			if (closure != null)
			{
				var type:String = GoEvent.START;
				addCallbackWithParams(closure, type, args);
			}
			
			if(!isNaN(delay))
				super._delay = delay;
		}
		/**
		 * Adds a callback with parameters.
		 * 
		 * @param closure	A reference to a function
		 * @param type		A GoEvent constant, default is START.
		 * @param args		An array of arguments to pass to the function
		 */
		public function addCallbackWithParams(closure:Function, type:String = GoEvent.START, args:Array = null):void 
		{
			//uses nested closure to pass arguments to the function
			
			//TODO Do thorough performance testing to ensure nested closure reference does not cause performance issues
			super.addCallback(function():void 			{ 				closure.apply(null, args); 			}, type);
		}
	}
}
