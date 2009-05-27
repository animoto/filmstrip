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
//		public var viewport:BitmapViewport3D;
		public var renderer:BasicRenderEngine;
		public var filter1:BitmapFilter;
		public var filter2:BitmapFilter;
		public var _light: LightObject3D;
		public var _holder: DisplayObject3D;
		public var _cube1: Cube;
		public var _cube2: Cube;
		public var _floor: Plane;
		public var _bel0: BitmapEffectLayer;
		public var _bel1: BitmapEffectLayer;
		public var _bel2: BitmapEffectLayer;
		public var _cube1Layer: ViewportLayer;
		public var _cube2Layer: ViewportLayer;
		public var cubeSize:Number = 150;
		public var facesLoaded:int = 0;
			
		public function Dice()
		{
			addEventListener(Event.ADDED_TO_STAGE, setupScene);
		}
		
		public function setupScene(e:Event):void {
			viewport = new Viewport3D(864, 480, false, false, true, true);
//			viewport = new BitmapViewport3D(1000, 700, false, true, 0x0, false, true);
			renderer = new BasicRenderEngine();
			camera = new Camera3D();
			camera.zoom = 1;
			camera.focus = 700;
			//camera.z = -1000;
			scene = new Scene3D();
			
//			_light = new LightObject3D();
//			_light.z = -500;
//			_light.x = 400;
//			_light.y = 400;
			
			//_stats = new StatsView(renderer);
			//addChild(_stats);
			
			// Use lighting
//  			greenMaterial = new FlatShadeMaterial(_light, 0, 0x33FF33);
//			greyMaterial = new FlatShadeMaterial(_light, 0x333333, 0x999999);
//			whiteMaterial = new FlatShadeMaterial(_light, 0xFFFFFF, 0x000000);
			
			// Don't use lighting (comment out other set)
/* 			greenMaterial = new ColorMaterial(0xFEB333);
			greyMaterial = new ColorMaterial(0x333333);
			seedMaterial = new ColorMaterial(0x006988); */
			
			draw();
			
			PulseControl.addEnterFrameListener(update, false, 9999);
			
			// For Go3D version -- Ensures scene update occurs afer all animations.
//			var pulse:UpdatePulse = new UpdatePulse();
//			pulse.addEventListener(UpdatePulse.PULSE, update);
//			GoEngine.addManager(pulse);
		}
		
		public function draw():void {
			
			camera.x = 500;
			camera.y = 1000;
			camera.z = -1200;
			camera.zoom = 1;
			camera.rotationX = 30;
			camera.rotationY = -30;
			
			var green:Sprite = new Sprite();
			//green.graphics.beginGradientFill(GradientType.LINEAR, [0x0, 0x006600], [1,1], [0,255]);
			green.graphics.beginFill(0x006600, 1);
			green.graphics.drawRect(0, 0, 1000, 1000);
  			greenMM = new MovieMaterial(green);
  			greenMM.doubleSided = true;
  			
			_floor = new Plane(greenMM, 1000, 1000);
			_floor.y = -50;
			_floor.pitch(90);
			scene.addChild(_floor);
			
			//_holder = new DisplayObject3D();
			//scene.addChild(_holder);
			
			var faces:Array = new Array();
			for (var i:int=0; i<6; i++) {
				var face:BitmapFileMaterial = new BitmapFileMaterial("./filmstripexamples/red"+(i+1)+".png", false);
				face.addEventListener(FileLoadEvent.LOAD_COMPLETE, faceLoaded);
				face.oneSide = false;
				face.smooth = true;
//				var shader:FlatShader = new FlatShader(_light);
//				var sm:ShadedMaterial = new ShadedMaterial(face, shader);
//				sm.oneSide = false;
//				sm.smooth = true;
//				faces.push(sm);
				faces.splice(Math.floor(Math.random()*faces.length), 0, face);
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
//			_cube1.useOwnContainer = true;
//			_cube2.useOwnContainer = true;
//			_floor.useOwnContainer = true;
//			_cube1.filters = [soften];
//			_cube2.filters = [soften];
//			_floor.filters = [soften];
			
			scene.addChild(_cube1);
			scene.addChild(_cube2);
//			_holder.addChild(_cube1);
//			_holder.addChild(_cube2);
			
			_cube1Layer = viewport.getChildLayer(_cube1, true, false);
			_cube2Layer = viewport.getChildLayer(_cube2, true, false);
			//camera.lookAt(_floor);
			//renderer.renderScene(scene, camera, viewport);
			
			/* 
			// BitmapEffectLayers
			_bel0 = new BitmapEffectLayer(viewport, viewport.width, viewport.height, true, 0x0, BitmapClearMode.CLEAR_PRE, false, true);
			_bel0.addDisplayObject3D(_holder);
			_bel1 = new BitmapEffectLayer(viewport, viewport.width, viewport.height, true, 0x0, BitmapClearMode.CLEAR_PRE, false, true);
			_bel1.addDisplayObject3D(_cube1);
			_bel2 = new BitmapEffectLayer(viewport, viewport.width, viewport.height, true, 0x0, BitmapClearMode.CLEAR_PRE, false, true);
			_bel2.addDisplayObject3D(_cube2);
			
			// Effects
			var effect1:BitmapLayerEffect = new BitmapLayerEffect(new BlurFilter(20, 0), true);
			_bel1.addEffect(effect1);
			var effect2:BitmapLayerEffect = new BitmapLayerEffect(new BlurFilter(20, 0), true);
			_bel2.addEffect(effect2);
			_bel2.blendMode = BlendMode.ADD;
			
			
			_bel0.addLayer(_bel1);
			_bel0.addLayer(_bel2);
			viewport.containerSprite.addLayer(_bel0);
//			viewport.containerSprite.addLayer(_bel1);
//			viewport.containerSprite.addLayer(_bel2);
			 */
		}
		
		public function faceLoaded(event:FileLoadEvent):void {
			if (++facesLoaded==6) {
				addChild(viewport);
				runAnimation();
				dispatchEvent(new Event(Event.COMPLETE));
			}
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
			
			// Test to prove _holder
//			Tweener.addTween(_holder, {scaleX:.5, scaleY:.5, scaleZ:.5, time:.5, transition:"easeincirc"});


			
//			var s:Sequence = new Sequence();
//			var t1:Tween3D = new Tween3D(_cube1, [Value.x(200), Value.rotationX(360)], 3, Easing.easeOutQuint, 0);
//			s.addStep(t1);
//			var t2:Tween3D = new Tween3D(_cube1, [Value.rotationY(180), Value.rotationZ(-90)], 2, Easing.easeOutBounce, 0);
//			s.addStep(t2);
//			
//			var cs:Sequence = new Sequence();
//			var ct1:Tween3D = new Tween3D(camera, [Value.x(500), Value.y(1200), Value.zoom(1.5)], 1.5, Easing.easeInQuad, 0);
//			cs.addStep(ct1);
//			
//			var g:PlayableGroup = new PlayableGroup(cs, s);
//			g.start();
			
			
		}
		
		public function update(e:Event=null):void {
			//trace("lookAt..");
			//camera.lookAt(_floor);
			if (PulseControl.isFrozen()==false) {
				renderer.renderScene(scene, camera, viewport);
			}
			// PROBLEM WITH PAPERVISION: Camera is not updated during renderLayers which makes it essentially unusable.
			//renderer.renderLayers(scene, camera, viewport, [/* _cube1Layer, */ _cube2Layer]);
		}
	}
}