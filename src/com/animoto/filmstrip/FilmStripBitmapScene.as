package com.animoto.filmstrip
{
	import com.animoto.filmstrip.scenes.FilmStripScenePV3D;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * Renders filmstrip's scenes to a stack of images to generate a frame image.
	 * 
	 * @author moses gunesch
	 */
	public class FilmStripBitmapScene extends Sprite
	{
		public var captureMode:String = FilmStripCaptureMode.WHOLE_SCENE;
		public var drawMode:String = FilmStripDrawMode.MATTE_SUBFRAMES;
		public var bufferMilliseconds: int = 1;
		
		protected var _filmStrip: FilmStrip;
		protected var _frameCallback: Function;
		protected var _index: int;
		protected var _buffer:Timer = new Timer(1, 1);
		protected var _busy: Boolean = false;
		
		public function FilmStripBitmapScene(_filmStrip:FilmStrip, _frameCallback:Function)
		{
			super();
			this._filmStrip = _filmStrip;
			this._frameCallback = _frameCallback;
			_buffer.addEventListener(TimerEvent.TIMER_COMPLETE, renderNextScene, false, 0, true);
		}
		
		/**
		 * Renders the scene at PulseControl's current time.
		 */
		public function render():void {
			if (_busy) {
				release();
			}
			_index = 0;
			_busy = true;
			renderNextScene();
		}
		
		/**
		 * Called by FilmStrip when rendering is stopped to release references
		 * to a scene.
		 */
		public function release():void {
			clearDisplay(this);
			_buffer.reset();
			if (_busy) {
				try { (_filmStrip.scenes[_index] as FilmStripScenePV3D).release(); }
				catch (e:Error) { }
			}
			_index = 0;
			_busy = false;
		}
		
		public function destroy():void {
			release();
			_buffer.removeEventListener(TimerEvent.TIMER_COMPLETE, renderNextScene);
			_buffer = null;
			_filmStrip = null;
		}
		
		 
		// -== Render Methods ==-
		
		protected function renderNextScene(event:TimerEvent=null):void {
			var scene:FilmStripScenePV3D = _filmStrip.scenes[_index] as FilmStripScenePV3D;
			if (scene==null) {
				FilmStrip.error("FilmStrip scenes must implement IFilmStripScene.");
				if (!FilmStrip.throwErrors) {
					renderNextScene();
				}
				return;
			}
			scene.render(renderCallback, _filmStrip.width, _filmStrip.height);
		}
		
		protected function renderCallback(item:DisplayObject, sceneRendered:Boolean):void {
			if (!_busy) {
				return;
			}
			addDisplayItem(item);
			if (sceneRendered) {
				sceneComplete();
			}
			else if (bufferMilliseconds==0) {
				renderNextScene();
			}
			else {
				_buffer.delay = bufferMilliseconds;
				_buffer.start();
			}
		}
		
		protected function sceneComplete():void {
			if (++_index < _filmStrip.scenes.length) {
				renderNextScene();
				return;
			}
			
			// All done -- send frame image back to parent FilmStrip.
			_busy = false;
			var data:BitmapData = new BitmapData(_filmStrip.width, _filmStrip.height, _filmStrip.transparent, _filmStrip.backgroundColor);
			data.draw(this);
			_frameCallback(data);
		}
		
		// -== Bitmap Stack ==-
		
		protected function addDisplayItem(item:DisplayObject):void {
			addChild(item);
		}
		
		protected function clearDisplay(scope:Sprite):void {
			var n:int = scope.numChildren;
			while (--n > -1) {
				var item:DisplayObject = scope.removeChildAt(n);
				if (item is Sprite) {
					clearDisplay(item as Sprite);
				}
				else {
					try {
						(item as Bitmap).bitmapData.dispose();
					}
					catch (e:Error) {
						FilmStrip.error(e.message);
					}
				}
			}
		}
	}
}