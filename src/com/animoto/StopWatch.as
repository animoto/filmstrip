package com.animoto
{
	import flash.utils.getTimer;
	
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