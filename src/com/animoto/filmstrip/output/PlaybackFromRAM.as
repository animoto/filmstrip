package com.animoto.filmstrip.output
{
	import com.animoto.filmstrip.FilmStrip;
	import com.animoto.filmstrip.FilmStripEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	/**
	 * You have to add this module to the stage at a high level to see the playback,
	 * which starts after render.
	 * 
	 * @author moses gunesch
	 */
	public class PlaybackFromRAM extends Bitmap
	{
		public var loop:Boolean;
		public var filmStrip: FilmStrip;
		public var datas: Array = new Array();
		public var timer: Timer;
		public var currentFrame: int = -1;
		public var playing:Boolean = false;
		public var pausedTF: TextField = new TextField();
		
		public function PlaybackFromRAM(filmStrip:FilmStrip, loop:Boolean=true) {
			super();
			this.filmStrip = filmStrip;
			this.loop = loop;
			filmStrip.addEventListener(FilmStripEvent.FRAME_RENDERED, handleRenderEvents);
			filmStrip.addEventListener(FilmStripEvent.RENDER_STOPPED, handleRenderEvents);
			timer = new Timer(filmStrip.frameDuration, 0);
			timer.addEventListener(TimerEvent.TIMER, nextFrame);
		}
		
		public function handleRenderEvents(e:FilmStripEvent):void {
			switch (e.type) {
				case FilmStripEvent.FRAME_RENDERED: 
					this.bitmapData = e.data;
					datas.push(e.data);
					return;
					
				case FilmStripEvent.RENDER_STOPPED: 
					filmStrip.removeEventListener(FilmStripEvent.FRAME_RENDERED, handleRenderEvents);
					filmStrip.removeEventListener(FilmStripEvent.RENDER_STOPPED, handleRenderEvents);
					filmStrip = null;
					playVideo();
					return;
			}
		}
		public function playVideo():void {
			if (datas.length==0)
				return;
			reset();
			this.parent.addEventListener(MouseEvent.MOUSE_DOWN, togglePlay);
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyPress);
			playing = true;
			nextFrame();
			timer.start();
		}
		
		public function togglePlay(e:MouseEvent=null):void {
			if (playing) {
				timer.stop();
				togglePausedTF(true);
			}
			else {
				timer.start();
				togglePausedTF(false);
			}
			playing = !playing;
		}
		
		public function nextFrame(e:TimerEvent=null):void {
			if (++currentFrame>=datas.length && playing) {
				if (loop)
					playVideo();
				else
					reset();
			}
			this.bitmapData = datas[currentFrame] as BitmapData;
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
				if (datas.length>0) {
					pausedTF.x = datas[0].width / 2 - pausedTF.width / 2 + this.x;
					pausedTF.y = datas[0].height / 2 - pausedTF.height / 2 + this.y;
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
				if (currentFrame==datas.length-1)
					currentFrame = -1;
				nextFrame();
			}
			else if ( event.keyCode == Keyboard.LEFT ) {
				if (playing)
					togglePlay();
				if ( (currentFrame-=2) < 0 )
					currentFrame = datas.length-2;
				nextFrame();
			}
		}
	}
}