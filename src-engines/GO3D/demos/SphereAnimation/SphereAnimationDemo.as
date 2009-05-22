package
{
	import com.rockonflash.go3d.Tween3D;
	import com.rockonflash.go3d.properties.Value;
	import com.rockonflash.go3d.utils.Easing;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	import org.goasap.GoEngine;
	import org.goasap.managers.OverlapMonitor;
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.lights.PointLight3D;
	import org.papervision3d.materials.MovieAssetMaterial;
	import org.papervision3d.materials.shaders.FlatShader;
	import org.papervision3d.materials.shaders.ShadedMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Cube;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.objects.primitives.Sphere;
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.view.Viewport3D;

	public class SphereAnimationDemo extends Sprite
	{
		protected var viewport							:Viewport3D = new Viewport3D(0, 0, true, true);
		protected var renderer							:BasicRenderEngine = new BasicRenderEngine();		
		protected var scene3d							:Scene3D = new Scene3D();
		protected var camera							:Camera3D = new Camera3D();
		
		protected var light								:PointLight3D = new PointLight3D();
		
		protected var universe							:DisplayObject3D = new DisplayObject3D("universe");
		protected var middleObject						:Sphere;
		protected var targetObject						:Cube;
		
		protected var size								:Number = 5;
		protected var panelWidth						:Number = 91 * size;
		protected var panelHeight						:Number = 36 * size;
		protected var tweenAllPlane						:Plane = new Plane(new MovieAssetMaterial("tweenAll", false, false),panelWidth, panelHeight, 1,1);
		protected var tweenXYZPlane						:Plane = new Plane(new MovieAssetMaterial("tweenXYZ", false, false),panelWidth, panelHeight, 1,1);
		protected var tweenCustomPlane					:Plane = new Plane(new MovieAssetMaterial("tweenCustom", false, false),panelWidth, panelHeight, 1,1);
		protected var tweenRandomPlane					:Plane = new Plane(new MovieAssetMaterial("tweenRandom", false, false),panelWidth, panelHeight, 1,1);
		
		protected var tween								:Tween3D;
		
		protected var r									:Number = 2000;
		protected var duration							:Number = 2;
		
		public function SphereAnimationDemo()
		{
			super();
			init();
		}
		
		protected function init():void
		{			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			GoEngine.addManager(new OverlapMonitor());
			
			setPanelButtons();
			
			addChild(viewport);
			
			createObjects();
			
			camera.zoom = 1;
			camera.focus = 1100
			camera.moveBackward(1500);
			
			resettargetObject();
			
			stage.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
		}
		
		protected function tweenAll(e:Event=null):void
		{
			resettargetObject();
			tween = new Tween3D(targetObject, [Value.tweenTarget(middleObject)], duration, Easing.easeOutElastic);
			tween.start();
		}
		
		protected function tweenXYZ(e:Event=null):void
		{
			resettargetObject();
			tween = new Tween3D(targetObject, [Value.tweenTarget(middleObject, Value.XYZ)], duration, Easing.easeOutElastic);
			tween.start();
		}
				
		protected function tweenCustom(e:Event=null):void
		{
			resettargetObject();
			tween = new Tween3D(targetObject, [Value.tweenTarget(middleObject, [Value.X, Value.Y])], duration, Easing.easeOutElastic);
			tween.start();
		}
		
		protected function tweenRandom(e:Event=null):void
		{
			tween = new Tween3D(targetObject, [Value.x(getRandom()), Value.y(getRandom()*.5), Value.z(getRandom())], duration, Easing.easeOutElastic);
			tween.start();
		}
		
		protected function handleEnterFrame(e:Event):void
		{
			renderer.renderScene(scene3d, camera, viewport);
		}
		
		protected function resettargetObject():void
		{
			targetObject.x = getRandom();			
			targetObject.y = getRandom() * .5;
			targetObject.z = getRandom() * 4;
			targetObject.lookAt(middleObject);
		}
		
		protected var neg:Boolean = false;
		protected function getRandom():Number
		{
			neg = !neg;
			return (Math.random() * (r*.5)) * (neg ? 1 : -1);
		}	
		
		protected function createObjects():void
		{			
			//light.x = 1000000;
			//light.y = 10000;
			
			light.moveRight(3000);
			light.moveBackward(8000);
			light.moveUp(3000);
			
			scene3d.addChild(light);
			var shader:FlatShader = new FlatShader(light, 0xFFFFFF, 0x202020);
			
			var bmMiddle:MovieAssetMaterial = new MovieAssetMaterial("blueMaterial", true, false);
			var bmTarget:MovieAssetMaterial = new MovieAssetMaterial("grayMaterial", true, false);
			
			var middleMat:ShadedMaterial = new ShadedMaterial(bmMiddle, shader);
			var targetMat:ShadedMaterial = new ShadedMaterial(bmTarget, shader);
			
			middleObject = new Sphere(middleMat, 100, 12);
			var matsList:MaterialsList = new MaterialsList();
			matsList.addMaterial(bmTarget, "all");
			targetObject = new Cube(matsList, 17, 17, 400, 4,4,4);
			
			universe.addChild(middleObject);
			universe.addChild(targetObject);
			scene3d.addChild(universe);
		}
		
		protected function handleClick(e:InteractiveScene3DEvent):void
		{
			switch(e.displayObject3D.material)
			{
				case tweenAllPlane.material:
					tweenAll();
				break;
				
				case tweenXYZPlane.material:
					tweenXYZ();
				break;
				
				case tweenCustomPlane.material:
					tweenCustom();
				break;
				
				case tweenRandomPlane.material:
					tweenRandom();
				break;
			}
		}
		
		protected function setPanelButtons():void
		{
			viewport.interactiveSceneManager.addEventListener(InteractiveScene3DEvent.OBJECT_CLICK, handleClick);
			
			tweenAllPlane.material.interactive = true;
			tweenAllPlane.material.smooth = true;
			tweenXYZPlane.material.interactive = true;
			tweenXYZPlane.material.smooth = true;
			tweenCustomPlane.material.interactive = true;
			tweenCustomPlane.material.smooth = true;
			tweenRandomPlane.material.interactive = true;
			tweenRandomPlane.material.smooth = true;
			
			tweenAllPlane.moveLeft(770);
			tweenAllPlane.moveForward(1000);
			tweenAllPlane.moveUp((panelHeight * 1.7));
			
			tweenXYZPlane.moveLeft(770);
			tweenXYZPlane.moveForward(1000);
			tweenXYZPlane.moveUp((panelHeight*.5)+10);
			
			tweenCustomPlane.moveLeft(770);
			tweenCustomPlane.moveForward(1000);
			tweenCustomPlane.moveDown((panelHeight*.5)+10);
			
			tweenRandomPlane.moveLeft(770);
			tweenRandomPlane.moveForward(1000);
			tweenRandomPlane.moveDown((panelHeight * 1.7));
			
			tweenAllPlane.yaw(-25);
			tweenXYZPlane.yaw(-25);
			tweenCustomPlane.yaw(-25);
			tweenRandomPlane.yaw(-25);
			
			scene3d.addChild(tweenAllPlane);
			scene3d.addChild(tweenXYZPlane);
			scene3d.addChild(tweenCustomPlane);
			scene3d.addChild(tweenRandomPlane);
		}	
	}
}