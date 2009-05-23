package
{
	import com.mosesSupposes.util.SelectiveBitmapDraw;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.CapsStyle;
	import flash.display.GradientType;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.MouseEvent;
	import flash.filters.BevelFilter;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	[SWF(backgroundColor="#FFFFFF", frameRate="30")]
	
	public class SelectiveBitmapDrawTest extends Sprite
	{
		protected var startColor:Number = 0x1234DD;
		protected var sprites:Array = new Array();
		protected var scene:Sprite = new Sprite();
		protected var itemSize:Number = 100;
		protected var bd:BitmapData;
		protected var bitmap:Bitmap;
		
		public function SelectiveBitmapDrawTest()
		{
			super();
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			setup_scene();
			
			// Uncomment a test
			//setup_many_at_top_level();
			setup_tree();
		}
		
		protected function setup_scene():void {
			
			// Physical scene
			scene.name = "scene";
			scene.graphics.lineStyle(2, 0x33AA99, 1, true, LineScaleMode.NORMAL, CapsStyle.SQUARE, JointStyle.MITER);
			scene.graphics.beginFill(0xFFFFFF, 1);
			scene.graphics.drawRect(1, 1, 298, 298);
			scene.x = 50;
			scene.y = 50;
			addChild(scene);
			scene.addEventListener(MouseEvent.MOUSE_DOWN, reset, false, 9999);
			
			// Bitmap scene
			bd = new BitmapData(300, 300, true);
			bitmap = new Bitmap(bd);
			bitmap.x = 400;
			bitmap.y = 50;
			addChild(bitmap);
			
			// Draw scene border into bitmap
			bd.draw(scene);
			
			// Shadows
			var shadow:DropShadowFilter = new DropShadowFilter(4, 45, 0x0, 0.25);
			scene.filters = [ shadow ];
			bitmap.filters = [ shadow ];
			
			// Labels
			addChild(label(scene.x, scene.y-30, "Physical scene"));
			addChild(label(bitmap.x, bitmap.y-30, "Bitmap scene"));
		}
		
		protected function reset(event:MouseEvent): void {
			for each (var sprite:Sprite in sprites) {
				sprite.visible = true;
			}
			bd.draw(scene);
		}
		
		protected function test(event:MouseEvent):void {
			event.stopPropagation(); // prevents reset from receiving mouse click
			var d:SelectiveBitmapDraw = new SelectiveBitmapDraw(bd);
			d.draw(scene, [ event.target ]);
		}
		
		protected function setup_many_at_top_level():void {
			var ix:int = 100;
			var iy:int = 200;
			sprites.push(scene.addChild(item(ix, iy)));
			sprites.push(scene.addChild(item((ix+=20), (iy-=20))));
			sprites.push(scene.addChild(item((ix+=20), (iy-=20))));
			sprites.push(scene.addChild(item((ix+=20), (iy-=20))));
			sprites.push(scene.addChild(item((ix+=20), (iy-=20))));
			for each (var sprite:Sprite in sprites) {
				sprite.rotation = sprites.indexOf(sprite) * 22.5;
			}
		}
		
		protected function setup_tree():void {
			itemSize = 65;
			sprites.push(scene.addChild(item(140, 45)));
			sprites[0].rotation = 5;
			sprites.push(sprites[0].addChild(item(-57, 57)));
			sprites[1].rotation = 30;
			sprites.push(sprites[0].addChild(item(45, 65)));
			sprites[2].rotation = -15;
			sprites.push(sprites[2].addChild(item(-45, 65)));
			sprites[3].rotation = 15;
			sprites.push(sprites[2].addChild(item(45, 65)));
			sprites[4].rotation = -15;
			sprites.push(sprites[3].addChild(item(-45, 65)));
			sprites[5].rotation = 15;
			sprites.push(sprites[3].addChild(item(45, 65)));
			sprites[6].rotation = -15;
			for each (var sprite:Sprite in sprites) {
				sprite.name = "sprite"+((sprites.length - sprites.indexOf(sprite)) - 1);
			}
		}
		
		protected function item(x:Number=0, y:Number=0):Sprite {
			var s:Sprite = new Sprite();
			var m:Matrix = new Matrix();
			m.rotate(45);
			m.scale(.25,.25);
			s.graphics.beginGradientFill(GradientType.LINEAR, [0xFF3366, (startColor-=0x8)], [.1,.8], [0, 150], m);
			s.graphics.drawRoundRect(-itemSize*0.5, -itemSize*0.5, itemSize, itemSize, itemSize*0.25, itemSize*0.25);
			s.graphics.endFill();
			var bevel:BevelFilter = new BevelFilter(4, 45, 0xFFFFFF, 0.8, 0x0, 0.8, 4, 4, 1, 10);
			s.filters = [ bevel ];
			s.x = x;
			s.y = y;
			s.name = "sprite"+sprites.length;
			s.addEventListener(MouseEvent.MOUSE_DOWN, test);
			return s;
		}
		
		protected function label(x:int, y:int, text:String):TextField {
			var t:TextField = new TextField();
			t.x = x;
			t.y = y;
			t.autoSize = TextFieldAutoSize.LEFT;
			t.text = text;
			t.setTextFormat(new TextFormat("_typewriter", 16, 0x666666));
			return t;
		}
	}
}