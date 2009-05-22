package {
	import com.rockonflash.go3d.Tween3D;
	import com.rockonflash.go3d.properties.Value;
	import com.rockonflash.go3d.utils.Easing;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.getDefinitionByName;
	
	import org.goasap.GoEngine;
	import org.goasap.events.GoEvent;
	import org.goasap.managers.OverlapMonitor;
	import org.goasap.utils.SequenceCA;
	import org.goasap.utils.customadvance.OnDurationComplete;
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.materials.MovieMaterial;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.view.Viewport3D;	

	//import com.rockonflash.Value.utils.Easing;
	
	public class RolodexGODemo extends Sprite
	{
		public var target							:Plane;
		public var viewport							:Viewport3D;
		public var scene							:Scene3D = new Scene3D();
		public var camera							:Camera3D = new Camera3D();
		public var renderer							:BasicRenderEngine = new BasicRenderEngine();
		
		public var sequence							:SequenceCA;
		public var tween_0							:Tween3D;
		public var tween_0b							:Tween3D;
		public var tween_1							:Tween3D;
		public var tween_2							:Tween3D;
		
		protected var doLoop						:Boolean = true;		

		public function RolodexGODemo()
		{			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			init();
		}
		
		public function init():void
		{
			GoEngine.addManager(new OverlapMonitor());
			
			viewport = new Viewport3D(0, 0, true, false);
			addChild(viewport);
			
			camera.zoom = 1;
			camera.focus = 1100;
			
			var cls:Class = getDefinitionByName("rolodex") as Class;
			var rolodex:Sprite = new cls() as Sprite;
			
			var mat:MovieMaterial = new MovieMaterial(rolodex, true, false);
			mat.smooth = true;
			
			target = new Plane(mat, 292, 168, 4, 4);
			scene.addChild(target);		
			
			reset();
			createTween();
			
			finalizeInit();
		}
		
		protected function finalizeInit():void
		{
			stage.addEventListener(MouseEvent.CLICK, handleClick);
			stage.addEventListener(Event.ENTER_FRAME, loop);
			
			loop();
			doLoop = false;
		}
		
		protected function loop(e:Event=null):void
		{
			if( !doLoop ) return; // only render when we have to
			renderer.renderScene(scene, camera, viewport);
		}
		
		protected function handleClick(e:MouseEvent):void
		{
			doTween();
		}
		
		protected function createTween():void
		{			
			sequence = new SequenceCA();
			sequence.addEventListener(GoEvent.COMPLETE, handleSequenceComplete, false, 0, true);
		
			tween_0 = new Tween3D(target, [Value.x(0), Value.y(50), Value.rotationZ(0)], 1, Easing.easeOutCubic);
		    sequence.addStep(tween_0);
		    sequence.lastStep.advance = new OnDurationComplete(.2); // advance early/overlap
		    
			tween_0b = new Tween3D(target, [Value.z(200)], 1, Easing.easeOutCubic);
		    sequence.addStep(tween_0b, true); // 2nd param groups it with previous step. param is "addToLastStep"
		    
		    tween_1 = new Tween3D(target, [Value.x(-10), Value.y(85), Value.rotationZ(15)], 1, Easing.easeOutCubic);
		    sequence.addStep(tween_1);
		    sequence.lastStep.advance = new OnDurationComplete(.25); // advance early/overlap
		    
		    tween_2 = new Tween3D(target, [Value.rotationX(0), Value.rotationY(0)], 1, Easing.easeOutBounce);
		    sequence.addStep(tween_2);
		}
		
		protected function handleSequenceComplete(e:GoEvent):void
		{
			doLoop = false;
		}
		
		protected function reset():void
		{			
			target.x = (Math.random() * (stage.stageWidth*.5));
			target.y = -350;
			target.z = -1000;
			target.rotationY = 30;
			target.rotationX = 30;
			target.rotationZ = Math.random() *-180;//-10;
			loop();
		}
		
		protected function doTween():void
		{
			reset();
			
			doLoop = true;
			sequence.start();
		}
	}
}
