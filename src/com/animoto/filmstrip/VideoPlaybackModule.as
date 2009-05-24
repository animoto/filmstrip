package com.animoto.filmstrip
{
	import com.animoto.animotor.events.OutputModuleEvent;
	import com.animoto.animotor.events.RenderEvent;
	import com.animoto.animotor.interfaces.IAnimotorRenderer;
	import com.animoto.animotor.interfaces.IOutputModule;
	
	import flash.display.Bitmap;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	/**
	 * You have to add this module to the stage at a high level to see the playback,
	 * which starts after render.
	 * 
	 * @author moses gunesch
	 */
	public class VideoPlaybackModule extends Bitmap
	{
		public var loop:Boolean;
		
		public var queue:IAnimotorRenderer;
		
		public var frameEvents: Array = new Array();
		
		public var timer: Timer = new Timer(1);
		
		public var currentFrame: int = -1;
		
		public var playing:Boolean = false;
		
		public var pausedTF: TextField = new TextField();
		
		private var startTime:Number;
		
		public function VideoPlaybackModule(queue:IAnimotorRenderer=null, loop:Boolean=true) {
			super();
			this.loop = loop;
			if (queue!=null)
				init(queue);
		}

		public function init(queue:IAnimotorRenderer):void {
			//trace("VideoPlaybackModule.init()");
			this.queue = queue;
			queue.addEventListener(RenderEvent.FRAME_RENDERED, handleRenderEvents, false, 0, true);
			queue.addEventListener(RenderEvent.RENDER_COMPLETE, handleRenderEvents, false, 0, true);
			timer.delay = 1000 / queue.vo.frameRate;
			timer.addEventListener(TimerEvent.TIMER, nextFrame);
		}
		
		public function handleRenderEvents(e:RenderEvent=null):void {
			switch (e.type) {
				case RenderEvent.FRAME_RENDERED: 
					frameEvents.push(e);
					return;
					
				case RenderEvent.RENDER_COMPLETE: 
					queue.removeEventListener(RenderEvent.FRAME_RENDERED, handleRenderEvents);
					queue.removeEventListener(RenderEvent.RENDER_COMPLETE, handleRenderEvents);
					queue = null;
					playVideo();
					return;
			}
		}
		public function playVideo():void {
			startTime = getTimer();
			reset();
			playing = true;
			togglePausedTF(false);
			nextFrame();
			timer.start();
			this.parent.addEventListener(MouseEvent.MOUSE_DOWN, togglePlay);
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyPress);
		}
		
		public function togglePlay(e:MouseEvent=null):void {
//			if (!playing) {
//				playVideo();
//				togglePausedTF(false);
//			}
//			else {
				if (playing) {
					timer.stop();
					togglePausedTF(true);
				}
				else {
					timer.start();
					togglePausedTF(false);
				}
//			}
			playing = !playing;
		}
		
		public function nextFrame(e:TimerEvent=null):void {
			if (++currentFrame>=frameEvents.length && playing) {
				trace("Playback done, took "+( ((getTimer()-startTime)*.001).toFixed(1) )+"s.");
				if (loop)
					playVideo();
				else
					reset();
			}
			var storedEvent:RenderEvent = frameEvents[currentFrame];
			this.bitmapData = storedEvent.bitmapData;
			this.dispatchEvent(new OutputModuleEvent(OutputModuleEvent.FRAME_SHOWN, storedEvent.time));
		}
		
		public function reset():void {
			currentFrame = -1;
			timer.reset();
			togglePausedTF(false);
			this.parent.removeEventListener(MouseEvent.MOUSE_DOWN, togglePlay);
			this.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleKeyPress);
		}
		
		protected function togglePausedTF(show:Boolean):void {
			if (this.parent==null)
				return;
			
			if (this.parent.contains(pausedTF))
				this.parent.removeChild(pausedTF);
				
			if (show) {
				pausedTF.text = "PAUSED";
				pausedTF.background = true;
				pausedTF.backgroundColor = 0xFFFFFF;
				pausedTF.setTextFormat(new TextFormat("_sans", 24, 0x0, true));
				pausedTF.selectable = false;
				pausedTF.autoSize = TextFieldAutoSize.LEFT;
				if (frameEvents.length>0) {
					pausedTF.x = frameEvents[0].bitmapData.width / 2 - pausedTF.width / 2 + this.x;
					pausedTF.y = frameEvents[0].bitmapData.height / 2 - pausedTF.height / 2 + this.y;
				}
				else {
					pausedTF.x = this.x + 100;
					pausedTF.y = this.y + 50;
				}
				this.parent.addChild(pausedTF);
			}
		}
		
		protected function handleKeyPress(event:KeyboardEvent):void {
			if ( event.keyCode == Keyboard.SPACE ) {
				togglePlay();
				return;
			}
			if (event.keyCode == Keyboard.RIGHT ) {
				if (playing)
					togglePlay();
				if (currentFrame==frameEvents.length-1)
					currentFrame = -1;
				nextFrame();
			}
			else if ( event.keyCode == Keyboard.LEFT ) {
				if (playing)
					togglePlay();
				if ( (currentFrame-=2) < 0 )
					currentFrame = frameEvents.length-2;
				nextFrame();
			}
		}
	}
}