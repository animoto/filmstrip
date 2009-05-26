package {
	import com.animoto.filmstrip.FilmStrip;
	import com.animoto.filmstrip.FilmStripBlurMode;
	import com.animoto.filmstrip.FilmStripCaptureMode;
	import com.animoto.filmstrip.FilmStripEvent;
	import com.animoto.filmstrip.output.PlaybackFromRAM;
	import com.animoto.filmstrip.scenes.FilmStripScenePV3D;
	
	import filmstripexamples.Dice;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;

	[SWF(backgroundColor="#FFFFFF", frameRate="30")]
	
	public class FilmStripExample extends Sprite
	{
		private var dice:Dice;
		private var f:FilmStrip;
		private var playbackBitmap:PlaybackFromRAM;
		private var outputDisplay:Sprite;
		
		public function FilmStripExample()
		{
			super();
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			dice = new Dice();
			addChild(dice);
			dice.addEventListener(Event.COMPLETE, start);
			stage.addEventListener(MouseEvent.CLICK, start);
		}
		
		private function start(event:Event=null): void {
			
			if (f!=null) {
				if (f.rendering) {
					f.stopRendering();
				}
				return;
			}
			
			var scene:FilmStripScenePV3D = new FilmStripScenePV3D(dice.scene, dice.camera, dice.viewport, dice.renderer);
			
			f = new FilmStrip(scene);
			f.addEventListener(FilmStripEvent.RENDER_STOPPED, resize);
			f.backgroundColor = 0xf0ecaf;
			f.bufferMilliseconds = 1;
			f.subframeBufferMilliseconds = 2;
			f.durationInSeconds = 3;
			f.frameRate = 30;
			
			// --== Tests ==--
			
			// FILTERS (use OverlappingDice for better illustration)
//			scene.addFilter(dice._cube1, dice.filter1);
//			scene.addFilter(dice._cube1, dice.filter2);

//			f.blurMode = FilmStripBlurMode.NONE;
			
			// WHOLE_SCENE
//			f.blurMode = FilmStripBlurMode.MATTE_SUBFRAMES;
//			MotionBlurSettings.usefixedFrameCount = true;
//			MotionBlurSettings.millisecondsPerSubframe = 2;
//			MotionBlurSettings.maxSubframes = 20;
//			f.captureMode = FilmStripCaptureMode.WHOLE_SCENE;
			
			playbackBitmap = new PlaybackFromRAM(f);
			
			outputDisplay = new Sprite();
			outputDisplay.graphics.drawRect(0, 0, dice.viewport.width, dice.viewport.height);
			playbackBitmap.x = playbackBitmap.y = 5;
			//playbackBitmap.filters = [new DropShadowFilter(4,45,0,0.25,5,5)];
			outputDisplay.addChild(playbackBitmap);
			
			f.bitmapScene.graphics.lineStyle(1, f.backgroundColor, 1);
			f.bitmapScene.graphics.drawRect(0, 0, dice.viewport.width, dice.viewport.height);
			f.bitmapScene.x = 5;
			f.bitmapScene.y = dice.viewport.height + 5;
			outputDisplay.addChild(f.bitmapScene);
			
			dice.scaleX = dice.scaleY = 0.5;
			//outputDisplay.scaleX = outputDisplay.scaleY = 0.5;
			dice.x = outputDisplay.getBounds(this).right + 5;
			addChild(outputDisplay);
			
			f.startRendering();
		}
		
		private function resize(event:FilmStripEvent):void {
			removeChild(dice);
			outputDisplay.removeChild(f.bitmapScene);
			outputDisplay.scaleX = outputDisplay.scaleY = 1;
		}
	}
}
