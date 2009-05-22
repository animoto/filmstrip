package {
	import com.animoto.filmstrip.PulseControl;
	
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	[SWF(backgroundColor="#FFFFFF", frameRate="30")]
	
	public class PulseControlTest extends Sprite
	{
		private var t:TextField;
		public function PulseControlTest()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			t = new TextField();
			t.border = true;
			t.width = 200;
			t.height = 20;
			t.x = 100;
			t.y = 100;
			addChild(t);
			
			
			var b:TextField = new TextField();
			b.border = true;
			b.background = true;
			b.backgroundColor = 0xEEEEEE;
			b.selectable = false;
			b.text = "freeze";
			b.autoSize = "left";
			b.x = 100;
			b.y = 150;
			b.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void { 
				PulseControl.freeze(); 
			});
			addChild(b);
			
			b = new TextField();
			b.border = true;
			b.background = true;
			b.backgroundColor = 0xEEEEEE;
			b.selectable = false;
			b.text = "resume";
			b.autoSize = "left";
			b.x = 100;
			b.y = 180;
			b.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void { 
				PulseControl.resume(); 
			});
			addChild(b);
			
			
			b = new TextField();
			b.border = true;
			b.background = true;
			b.backgroundColor = 0xEEEEEE;
			b.selectable = false;
			b.text = "advance";
			b.autoSize = "left";
			b.x = 100;
			b.y = 210;
			b.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void { 
				PulseControl.advance(); 
			});
			addChild(b);
			
			
			b = new TextField();
			b.border = true;
			b.background = true;
			b.backgroundColor = 0xEEEEEE;
			b.selectable = false;
			b.text = "add listener";
			b.autoSize = "left";
			b.x = 100;
			b.y = 240;
			b.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void { 
				PulseControl.addEnterFrameListener(updateTime); 
			});
			addChild(b);
			
			b = new TextField();
			b.border = true;
			b.background = true;
			b.backgroundColor = 0xEEEEEE;
			b.selectable = false;
			b.text = "remove listener";
			b.autoSize = "left";
			b.x = 100;
			b.y = 270;
			b.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void { 
				PulseControl.removeEnterFrameListener(updateTime); 
			});
			addChild(b);
			
			
		}
		
		private function updateTime(e:Event):void {
			t.text = String(PulseControl.getCurrentTime()); 
		}
		
	}
}
