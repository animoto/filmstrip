package {
	import com.animoto.filmstrip.FilmStrip;
	import com.animoto.filmstrip.FilmStripEvent;
	import com.animoto.filmstrip.output.PlaybackFromRAM;
	import com.animoto.filmstrip.scenes.FilmStripScenePV3D;
	
	import filmstripexamples.Dice;
	import filmstripexamples.OverlappingDice;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;

	[SWF(backgroundColor="#FFFFFF", frameRate="30")]
	
	public class MultiFilmStripExample extends Sprite
	{
		private var dice:Dice;
		private var dice2:OverlappingDice;
		private var f:FilmStrip;
		private var playbackBitmap:PlaybackFromRAM;
		private var outputDisplay:Sprite;
		private var diceLoaded:int=0;
		
		public function MultiFilmStripExample()
		{
			super();
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			
			// Working animations:
			
			dice = new Dice();
			addChild(dice);
			
			dice2 = new OverlappingDice();
			addChild(dice2);
			
			stage.addEventListener(MouseEvent.CLICK, start); // click to start if line below is commented. 
															// when running, click to stop.
			
			
			// Comment out to start on click instead.
			dice.addEventListener(Event.COMPLETE, diceLoad);
			dice2.addEventListener(Event.COMPLETE, diceLoad);
		}
		
		private function diceLoad(event:Event):void {
			if (++diceLoaded==2) {
				start();
			}
			else trace("diceLoaded:" + 
					diceLoaded);
		}
		
		private function start(event:Event=null): void {
			
			if (f!=null) {
				if (f.rendering) {
					f.stopRendering();
				}
				return;
			}
			
			// 1. Patch your animation library to use PulseControl
			
			// 2. Wrap the scene to render in a new FilmStripScene
			var scene:FilmStripScenePV3D = new FilmStripScenePV3D(dice.scene, dice.camera, dice.viewport, dice.renderer);
			var scene2:FilmStripScenePV3D = new FilmStripScenePV3D(dice2.scene, dice2.camera, dice2.viewport, dice2.renderer);
			
			// 3. Make a FilmStrip with one or more scenes.
			f = new FilmStrip(scene);
			f.addScene(scene2);
			f.addEventListener(FilmStripEvent.RENDER_STOPPED, resize);
			f.backgroundColor = 0xf0ecaf;
			f.bufferMilliseconds = 1;
			f.subframeBufferMilliseconds = 0;
			f.durationInSeconds = 3;
			f.frameRate = 30;
			f.transparent = true;
			
			playbackBitmap = new PlaybackFromRAM(f);
			
			outputDisplay = new Sprite();
			outputDisplay.graphics.drawRect(0, 0, dice.viewport.viewportWidth, dice.viewport.viewportHeight);
			playbackBitmap.x = playbackBitmap.y = 5;
			//playbackBitmap.filters = [new DropShadowFilter(4,45,0,0.25,5,5)];
			outputDisplay.addChild(playbackBitmap);
			
//			f.bitmapScene.graphics.lineStyle(1, f.backgroundColor, 1);
//			f.bitmapScene.graphics.drawRect(0, 0, dice.viewport.viewportWidth, dice.viewport.viewportHeight);
//			f.bitmapScene.x = 5;
//			f.bitmapScene.y = dice.viewport.height + 5;
//			outputDisplay.addChild(f.bitmapScene);
			
			dice.scaleX = dice.scaleY = 0.5;
			outputDisplay.scaleX = outputDisplay.scaleY = 0.5;
			dice.x = dice2.x = outputDisplay.getBounds(this).right + 5;
			dice2.scaleX = dice2.scaleY = 0.5;
			dice2.y = outputDisplay.getBounds(this).bottom + 5;
			addChild(outputDisplay);
			
			f.startRendering();
		}
		
		private function resize(event:FilmStripEvent):void {
			removeChild(dice);
			outputDisplay.removeChild(f.bitmapScene);
			outputDisplay.scaleX = outputDisplay.scaleY = 1;
		}
		
		
		// -== notes ==-
		
		// Need a 2D animated scene -- ready to test!
		// Need to do a test w/ photo -- prove premult issue!
		//  - Decide on matted frames or not based on photo test
		// FrameDump: maybe revamp if time
		// Tree structured objects should work -- test.
		//  - Need to add parent transforms to delta in this build
		
	}
}
