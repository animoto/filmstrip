package tests
{
	import com.mosesSupposes.util.SelectiveBitmapDraw3D;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import org.papervision3d.core.proto.LightObject3D;
	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.materials.shadematerials.FlatShadeMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Cube;
	import org.papervision3d.view.BasicView;

	[SWF(backgroundColor="#FFFFFF", frameRate="30")]
	
	public class SelectiveBitmapDraw3DTest extends Sprite
	{
		protected var startColor:Number = 0x123456;
		protected var do3Ds:Array = new Array();
		protected var itemSize:Number = 130;
		protected var bd:BitmapData;
		protected var bitmap:Bitmap;
		protected var view:BasicView;
		protected var light:LightObject3D;
		protected var cancel:Boolean;
		
		public function SelectiveBitmapDraw3DTest()
		{
			super();
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			setup_scene();
			
			// Uncomment a test
//			setup_many_at_top_level();
			setup_tree();
			
			reset();
		}
		
		protected function setup_scene():void {
			
			// Physical scene (3D BasicView)
			view = new BasicView(300, 300, false, true);
			view.x = 50;
			view.y = 50;
			var back:Sprite = new Sprite();
			back.graphics.lineStyle(2, 0x33AA99, 1, true, LineScaleMode.NORMAL, CapsStyle.SQUARE, JointStyle.MITER);
			back.graphics.beginFill(0xFFFFFF, 1);
			back.graphics.drawRect(1, 1, 298, 298);
			view.viewport.addChildAt(back, 0);
			back.addEventListener(MouseEvent.MOUSE_DOWN, reset, false, 9999);
			light = new LightObject3D();
			light.z = 500;
			addChild(view);
			
			// Bitmap scene
			bd = new BitmapData(300, 300, true);
			bitmap = new Bitmap(bd);
			bitmap.x = 400;
			bitmap.y = 50;
			addChild(bitmap);
			
			// Draw scene border into bitmap
			bd.draw(view.viewport);
			
			// Shadows
			var shadow:DropShadowFilter = new DropShadowFilter(4, 45, 0x0, 0.25);
			view.filters = [ shadow ];
			bitmap.filters = [ shadow ];
			
			// Labels
			addChild(label(view.x, view.y-30, "Physical scene"));
			addChild(label(bitmap.x, bitmap.y-30, "Bitmap scene"));
		}
		
		protected function reset(event:MouseEvent=null): void {
			for each (var item:DisplayObject3D in do3Ds) {
				item.visible = true;
			}
			view.renderer.renderScene(view.scene, view.camera, view.viewport);
			bd.draw(view);
		}
		
		protected function test(event:InteractiveScene3DEvent):void {
			var d:SelectiveBitmapDraw3D = new SelectiveBitmapDraw3D(bd, view.scene, view.camera, view.viewport, view.renderer);
			d.draw([ event.target ]);
			cancel = true;
		}
		
		protected function setup_many_at_top_level():void {
			
			do3Ds.push(view.scene.addChild(item(-250, 0)));
			do3Ds.push(view.scene.addChild(item(0, 0)));
			do3Ds.push(view.scene.addChild(item(250, 0)));
			
			do3Ds.push(view.scene.addChild(item(-250, 250)));
			do3Ds.push(view.scene.addChild(item(0, 250)));
			do3Ds.push(view.scene.addChild(item(250, 250)));
			
			do3Ds.push(view.scene.addChild(item(-250, -250)));
			do3Ds.push(view.scene.addChild(item(0, -250)));
			do3Ds.push(view.scene.addChild(item(250, -250)));
		}
		
		protected function setup_tree():void {
			do3Ds.push(view.scene.addChild(item(0, 250)));
			do3Ds.push(do3Ds[0].addChild(item(-140, -150)));
			do3Ds.push(do3Ds[0].addChild(item(140, -150)));
			do3Ds.push(do3Ds[2].addChild(item(-100, -150)));
			do3Ds.push(do3Ds[2].addChild(item(140, -1540)));
			do3Ds.push(do3Ds[3].addChild(item(-100, -150)));
			do3Ds.push(do3Ds[3].addChild(item(100, -150)));
		}
		
		protected function item(x:Number=0, y:Number=0):DisplayObject3D {
			var m:FlatShadeMaterial = new FlatShadeMaterial(light, 0x0, startColor);
			m.interactive = true;
			var d:Cube = new Cube(new MaterialsList({all: m }), itemSize, itemSize, itemSize);
			d.x = x;
			d.y = y;
			d.name = "item"+do3Ds.length;
			d.addEventListener(InteractiveScene3DEvent.OBJECT_PRESS, test);
			return d;
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