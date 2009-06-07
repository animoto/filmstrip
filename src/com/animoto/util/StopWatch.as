/*
	Copyright (c) 2009 Animoto, Inc.
	
	Permission is hereby granted, free of charge, to any person
	obtaining a copy of this software and associated documentation
	files (the "Software"), to deal in the Software without
	restriction, including without limitation the rights to use,
	copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the
	Software is furnished to do so, subject to the following
	conditions:
	
	The above copyright notice and this permission notice shall be
	included in all copies or substantial portions of the Software.
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
	OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
	HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
	OTHER DEALINGS IN THE SOFTWARE.
*/
package com.animoto.util
{
	import flash.utils.getTimer;
	
	/**
	 * Timekeeper.
	 * 
	 * @author moses gunesch
	 */
	public class StopWatch
	{
		public function get milliseconds():int {
			if (_running) {
				return _recordedTime + (getTimer() - _lastStartTime);
			}
			return _recordedTime;
		}
		public function set milliseconds(time:int):void {
			_recordedTime = time;
		}
		
		public function get seconds():int {
			return milliseconds / 1000;
		}
		public function set seconds(time:int):void {
			_recordedTime = seconds * 1000;
		}
		
		public function get running():Boolean {
			return _running;
		}
		
		protected var _lastStartTime:int;
		protected var _recordedTime:int = 0;
		protected var _running:Boolean = false;
		
		public function StopWatch() {
			
		}
		
		public function start():void {
			if (!_running) {
				_lastStartTime = getTimer();
				_running = true;
			}
		}
		
		public function pause():void {
			if (_running) {
				_recordedTime += (getTimer() - _lastStartTime);
				_running = false;
			}
		}
		
		public function reset():void {
			_running = false;
			_lastStartTime = NaN;
			_recordedTime = 0;
		}
	}
}