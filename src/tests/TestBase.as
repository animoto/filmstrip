package tests
{
	import com.animoto.filmstrip.PulseControl;
	
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	[SWF(backgroundColor="#FFFFFF", frameRate="30")]
	
	public class TestBase extends Sprite
	{
		protected var t:TextField;
		protected var target1:Sprite;
		
		public function TestBase()
		{
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		protected function onAddedToStage(event:Event):void {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			// Use PulseControl to perform updates in your code instead of enterFrame or a Timer.
			PulseControl.addEnterFrameListener(updateTime);
			
			// targets
			target1 = box(100, 50);
			setupWhitelistingTest( target1 );
			
			// draw UI
			
			readout(100, 100);
			
			button("PulseControl.freeze();", 100, 150, function(e:MouseEvent):void { 
				PulseControl.freeze(); 
			});
			
			button("PulseControl.resume();", 100, 180, function(e:MouseEvent):void { 
				PulseControl.resume(); 
			});
			
			button("advance time a frame", 100, 210, function(e:MouseEvent):void { 
				PulseControl.advanceTime(1000/15);
			});
			
			button("unwhitelist target", 100, 240, function(e:MouseEvent):void { 
				PulseControl.unwhitelist(target1);
			});
			
			button("whitelist target", 100, 270, function(e:MouseEvent):void { 
				PulseControl.whitelist(target1);
			});
			
			// Use PulseControl to perform updates in your code instead of enterFrame or a Timer.
			button("remove readout listener", 100, 300, function(e:MouseEvent):void { 
				PulseControl.removeEnterFrameListener(updateTime); 
			});
			
			button("add readout listener", 100, 330, function(e:MouseEvent):void { 
				PulseControl.addEnterFrameListener(updateTime); 
			});
		}
		
		protected function box(x:Number, y:Number):Sprite {
			var s:Sprite = new Sprite();
			s.graphics.beginGradientFill(GradientType.LINEAR, [0xFFFFFF, 0x336699], [1,1], [0,255]);
			s.x = x;
			s.y = y;
			s.graphics.drawRect(-11, -11, 22, 22);
			addChild(s);
			return s;
		}
		
		protected function setupWhitelistingTest(targets:Object):void {
			
			// Whitelisting has no effect when the list is clear, so add a dummy target.
			if (PulseControl.whitelistIsClear()) {
				var dummy:Sprite = new Sprite();
				dummy.name = "dummy_for_wl_test";
				PulseControl.whitelist( dummy );
			}
			
			// Whitelist our target so we can click "unwhitelist" to test
			PulseControl.whitelist( targets );
		}
		
		protected function readout(x:Number, y:Number):TextField {
			t = new TextField();
			t.border = true;
			t.width = 200;
			t.height = 20;
			t.x = x;
			t.y = x;
			addChild(t);
			return t;
		}
		
		protected function button(label:String, x:Number, y:Number, down:Function):TextField {
			var b:TextField = new TextField();
			b.border = true;
			b.background = true;
			b.backgroundColor = 0xEEEEEE;
			b.selectable = false;
			b.text = label;
			b.autoSize = "left";
			b.x = x;
			b.y = y;
			b.addEventListener(MouseEvent.MOUSE_DOWN, down);
			addChild(b);
			return b;
		}
		
		protected function updateTime(e:Event):void {
			t.text = String(PulseControl.getCurrentTime().toFixed(1)); 
		}
		
	}
}
