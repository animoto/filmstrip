package filmstripexamples
{
	import caurina.transitions.Tweener;
	
	import com.animoto.filmstrip.PulseControl;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.core.proto.LightObject3D;
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.materials.MovieMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.primitives.Cube;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.view.Viewport3D;
	
	public class Dice extends ExampleScene
	{
		public static var greenMM: MovieMaterial;
		public static var greenMaterial: MaterialObject3D;
		public static var greyMaterial: MaterialObject3D;
		public static var whiteMaterial: MaterialObject3D;
		
		public var scene: Scene3D;
		public var camera:Camera3D;
		public var viewport:Viewport3D;
		public var renderer:BasicRenderEngine;
		public var light: LightObject3D;
		public var cube1: Cube;
		public var cube2: Cube;
		public var floor: Plane;
		public var cubeSize:Number = 150;
		public var facesLoaded:int = 0;
		
		public var face1:Bitmap;
		public var face2:Bitmap;
		public var face3:Bitmap;
		public var face4:Bitmap;
		public var face5:Bitmap;
		public var face6:Bitmap;
		
		[Embed(source="../../embed/red1.png")]
		public var red1:Class;
		
		[Embed(source="../../embed/red2.png")]
		public var red2:Class;
		
		[Embed(source="../../embed/red3.png")]
		public var red3:Class;
		
		[Embed(source="../../embed/red4.png")]
		public var red4:Class;
		
		[Embed(source="../../embed/red5.png")]
		public var red5:Class;
		
		[Embed(source="../../embed/red6.png")]
		public var red6:Class;
		
		public function Dice()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, setupScene);
		}
		
		public function setupScene(event:Event=null):void {
			viewport = new Viewport3D(contentWidth, contentHeight, false, false, true, true);
			renderer = new BasicRenderEngine();
			camera = new Camera3D();
			camera.zoom = 1;
			camera.focus = 700;
			scene = new Scene3D();
			
//			light = new LightObject3D();
//			light.z = -500;
//			light.x = 400;
//			light.y = 400;
			
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
  			
			floor = new Plane(greenMM, 1000, 1000);
			floor.y = -50;
			floor.pitch(90);
			scene.addChild(floor);
			
			var diceml:MaterialsList = getDiceMatList();
			cube1 = new Cube(diceml, cubeSize, cubeSize, cubeSize, 2, 2, 2);
			cube1.x = -1500;
			cube1.y = 600;
			cube2 = new Cube(diceml, cubeSize, cubeSize, cubeSize, 2, 2, 2);
			cube2.x = -600;
			cube2.y = 600;
			
			var soften:BlurFilter = new BlurFilter(1, 1, 1);
			
			viewport.getChildLayer(cube1);
			viewport.getChildLayer(cube2);
//			viewport.getChildLayer(floor);
			
			scene.addChild(cube1);
			scene.addChild(cube2);
			
			begin();
		}
		
		public function getDiceMatList():MaterialsList {
			//return new MaterialsList({ all : whiteMaterial });
			var pngs:Array = [new red1(), new red2(), new red3(), new red4(), new red5(), new red6()];
			var faces:Array = new Array();
			for (var i:int=0; i<6; i++) {
				var face:BitmapMaterial = new BitmapMaterial((pngs[i] as Bitmap).bitmapData, false);
				face.oneSide = false;
				face.smooth = true;
				faces.splice(Math.floor(Math.random()*faces.length), 0, face);
				
				// or uncomment splice and use this code and the light code above to apply lighting to the dice.
//				var shader:FlatShader = new FlatShader(light);
//				var sm:ShadedMaterial = new ShadedMaterial(face, shader);
//				sm.oneSide = false;
//				sm.smooth = true;
//				faces.push(sm);
			}
			return new MaterialsList({top:faces[0], bottom:faces[1], left:faces[2], right:faces[3], front:faces[4], back:faces[5]});
		}
		
		public function begin(event:Event=null):void {
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
			
			// Advanced: If you do need an update handler fired every frame (careful: also fired every blur 
			// subframe!) you can use PulseControl.addEngineListener instead in step 1 above.
		}
		
		public function update(e:Event=null):void {
			renderer.renderScene(scene, camera, viewport);
		}
		
		public function runAnimation():void {
			 
			Tweener.addTween(cube1, {x:100, z:100, rotationX:360, time:1.7, transition:"easeoutcirc"});
			Tweener.addTween(cube1, {rotationY:180, rotationZ:-180, y:cubeSize/2, time:1.7, transition:"easeoutbounce"});
			
			Tweener.addTween(cube2, {rotationY:-90, rotationX:360, rotationZ:360, z:-250, time:1.6, transition:"easeoutquad"});
			Tweener.addTween(cube2, {y:cubeSize/2, time:1.6, transition:"easeoutbounce"});
			Tweener.addTween(cube2, {x:500, time:.6, transition:"easeoutquad"});
			Tweener.addTween(cube2, {x:100, time:1, delay:.6, transition:"easeoutquad"}); // bounce back
			
			Tweener.addTween(camera, {x:-320, y:350, z:-800, rotationY:35, rotationX:15, time:1, transition:"easeinoutsine"});
			
/* 
			// Go animation sequence using John Grden's GO3D extension
			
			var tweenGroup:PlayableGroup = new PlayableGroup();
			tweenGroup.addChild( new Tween3D(cube1, [Value.x(200), Value.z(100), Value.rotationX(360)], 1.7, Easing.easeOutCirc) );
			tweenGroup.addChild( new Tween3D(cube1, [Value.rotationY(180), Value.rotationZ(-180), Value.y(cubeSize/2)], 1.7, Easing.easeOutBounce) );
			
			tweenGroup.addChild( new Tween3D(cube2, [Value.rotationY(-90), Value.rotationX(360), Value.rotationZ(360), Value.z(-250)], 1.6, Easing.easeOutQuad) );
			tweenGroup.addChild( new Tween3D(cube2, [Value.y(cubeSize/2)], 1.6, Easing.easeOutBounce) );
			tweenGroup.addChild( new Sequence(	new Tween3D(cube2, [Value.x(500)], .6, Easing.easeOutQuad),
												new Tween3D(cube2, [Value.x(100)], 1, Easing.easeOutCirc) ) );
			
			tweenGroup.addChild( new Tween3D(camera, [Value.x(-320), Value.y(350), Value.z(-800), Value.rotationY(35), Value.rotationX(15)], 1, Easing.easeInOutSine) );
			
			tweenGroup.start(); */
		}
	}
}