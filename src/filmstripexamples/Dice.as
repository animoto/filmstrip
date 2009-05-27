package filmstripexamples
{
	import caurina.transitions.Tweener;
	
	import com.animoto.filmstrip.PulseControl;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BitmapFilter;
	import flash.filters.BlurFilter;
	
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.core.proto.LightObject3D;
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.events.FileLoadEvent;
	import org.papervision3d.materials.BitmapFileMaterial;
	import org.papervision3d.materials.MovieMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Cube;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.view.Viewport3D;
	import org.papervision3d.view.layer.BitmapEffectLayer;
	import org.papervision3d.view.layer.ViewportLayer;
	
	public class Dice extends Sprite
	{
		public static var greenMM: MovieMaterial;
		public static var greenMaterial: MaterialObject3D;
		public static var greyMaterial: MaterialObject3D;
		public static var whiteMaterial: MaterialObject3D;

		public var scene: Scene3D;
		public var camera:Camera3D;
		public var viewport:Viewport3D;
		public var renderer:BasicRenderEngine;
		public var filter1:BitmapFilter;
		public var filter2:BitmapFilter;
		public var _light: LightObject3D;
		public var _cube1: Cube;
		public var _cube2: Cube;
		public var _floor: Plane;
		public var cubeSize:Number = 150;
		public var facesLoaded:int = 0;
		
		public function Dice()
		{
			addEventListener(Event.ADDED_TO_STAGE, setupScene);
		}
		
		public function setupScene(event:Event=null):void {
			viewport = new Viewport3D(864, 480, false, false, true, true);
			renderer = new BasicRenderEngine();
			camera = new Camera3D();
			camera.zoom = 1;
			camera.focus = 700;
			scene = new Scene3D();
			
//			_light = new LightObject3D();
//			_light.z = -500;
//			_light.x = 400;
//			_light.y = 400;
			
			camera.x = 500;
			camera.y = 1000;
			camera.z = -1200;
			camera.zoom = 1;
			camera.rotationX = 30;
			camera.rotationY = -30;
			
			var green:Sprite = new Sprite();
			green.graphics.beginFill(0x006600, 1);
			green.graphics.drawRect(0, 0, 1000, 1000);
  			greenMM = new MovieMaterial(green);
  			greenMM.doubleSided = true;
  			
			_floor = new Plane(greenMM, 1000, 1000);
			_floor.y = -50;
			_floor.pitch(90);
			scene.addChild(_floor);
			
			var faces:Array = new Array();
			for (var i:int=0; i<6; i++) {
				var face:BitmapFileMaterial = new BitmapFileMaterial("./filmstripexamples/red"+(i+1)+".png", false);
				face.addEventListener(FileLoadEvent.LOAD_COMPLETE, faceLoaded);
				face.oneSide = false;
				face.smooth = true;
				faces.splice(Math.floor(Math.random()*faces.length), 0, face);
				
				// or uncomment splice and use this code and the _light code above to apply lighting to the dice.
//				var shader:FlatShader = new FlatShader(_light);
//				var sm:ShadedMaterial = new ShadedMaterial(face, shader);
//				sm.oneSide = false;
//				sm.smooth = true;
//				faces.push(sm);
			}
			var dml:MaterialsList = new MaterialsList({top:faces[0], bottom:faces[1], left:faces[2], right:faces[3], front:faces[4], back:faces[5]});
			var basicml:MaterialsList = new MaterialsList({ all : whiteMaterial });
			var diceml:MaterialsList = dml;
			_cube1 = new Cube(diceml, cubeSize, cubeSize, cubeSize, 2, 2, 2);
			_cube1.x = -1500;
			_cube1.y = 600;
			_cube2 = new Cube(diceml, cubeSize, cubeSize, cubeSize, 2, 2, 2);
			_cube2.x = -600;
			_cube2.y = 600;
			
			var soften:BlurFilter = new BlurFilter(1, 1, 1);
			
			scene.addChild(_cube1);
			scene.addChild(_cube2);
		}
		
		public function faceLoaded(event:FileLoadEvent):void {
			if (++facesLoaded==6) {
				begin();
			}
		}
		
		public function begin():void {
			addChild(viewport);
			runAnimation();
			dispatchEvent(new Event(Event.COMPLETE));
			
			
			// [TUTORIAL PORTION]
			// Important rules for using FilmStrip!
			// 1. replace your ENTER_FRAME listeners with PulseControl calls.
			PulseControl.addEnterFrameListener(update);
			
			// This way, enterframe is only dispatched when no FilmStrips are rendering.
			// This is faster and ensures that your code doesn't disrupt FilmStrip's rendering processes.
			
			// 2. Replace any getTimer() (or new Date.getTime()) calls in your code with 
			// PulseControl.getCurrentTime();
		}

		
		public function update(e:Event=null):void {
			renderer.renderScene(scene, camera, viewport);
		}
		
		public function runAnimation():void {
			
			Tweener.addTween(_cube1, {x:100, z:100, rotationX:360, time:1.7, transition:"easeoutcirc"});
			Tweener.addTween(_cube1, {rotationY:180, rotationZ:-180, y:cubeSize/2, time:1.7, transition:"easeoutbounce"});
			
			Tweener.addTween(_cube2, {rotationY:-90, rotationX:360, rotationZ:360, z:-250, time:1.6, transition:"easeoutquad"});
			Tweener.addTween(_cube2, {y:cubeSize/2, time:1.6, transition:"easeoutbounce"});
			Tweener.addTween(_cube2, {x:500, time:.6, transition:"easeoutquad", onComplete:function():void {
				Tweener.addTween(_cube2, {x:100, time:1, transition:"easeoutcirc"});
			}});
			
			Tweener.addTween(camera, {x:-320, y:350, z:-800, rotationY:35, rotationX:15, zoom:1, time:1, transition:"easeinoutsine"});
			

			// Go animation sequence using John Grden's GO3D extension
			
//			var tweenGroup:PlayableGroup = new PlayableGroup();
//			tweenGroup.addChild( new Tween3D(_cube1, [Value.x(200), Value.z(100), Value.rotationX(360)], 1.7, Easing.easeOutCirc) );
//			tweenGroup.addChild( new Tween3D(_cube1, [Value.rotationY(180), Value.rotationZ(-180), Value.y(cubeSize/2)], 1.7, Easing.easeOutBounce) );
//			
//			tweenGroup.addChild( new Tween3D(_cube2, [Value.rotationY(-90), Value.rotationX(360), Value.rotationZ(360), Value.z(-250)], 1.6, Easing.easeOutQuad) );
//			tweenGroup.addChild( new Tween3D(_cube2, [Value.y(cubeSize/2)], 1.6, Easing.easeOutBounce) );
//			tweenGroup.addChild( new Sequence(	new Tween3D(_cube2, [Value.x(500)], .6, Easing.easeOutQuad),
//												new Tween3D(_cube2, [Value.x(100)], 1, Easing.easeOutCirc) ) );
//			
//			tweenGroup.addChild( new Tween3D(camera, [Value.x(-320), Value.y(350), Value.z(-800), Value.rotationY(35), Value.rotationX(15), Value.zoom(1)], 1, Easing.easeInOutSine) );
//			
//			tweenGroup.start();
		}
	}
}