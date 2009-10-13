package com.animoto.filmstrip.scenes
{
	import com.mosesSupposes.util.SelectiveBitmapDraw3D;
	import com.mosesSupposes.util.SelectiveDrawBase;
	
	import flash.display.BitmapData;
	import flash.utils.Dictionary;
	
	import org.papervision3d.core.proto.CameraObject3D;
	import org.papervision3d.core.proto.DisplayObjectContainer3D;
	import org.papervision3d.core.proto.SceneObject3D;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.parsers.DAE;
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.view.Viewport3D;
	import org.papervision3d.view.layer.ViewportLayer;
	
	/**
	 * FilmStrip scene wrapper for use with a Papervision3D scene.
	 * 
	 * See FilmStripSceneBase for documentation.
	 * 
	 * @author moses gunesch
	 */
	public class FilmStripScenePV3D extends FilmStripScene
	{
		/**
		 * It is normally faster to simply draw from existing ViewportLayers,
		 * although one test using a DAE ran much faster with this set to false.
		 */
		public var useViewportLayerCapture: Boolean = true;
		
		public var scene3D:SceneObject3D;
		public var camera:CameraObject3D;
		public var viewport:Viewport3D;
		public var renderer:BasicRenderEngine;
		
		override public function get actualContentWidth():int {
			return viewport.viewportWidth;
		}
		
		override public function get actualContentHeight():int {
			return viewport.viewportHeight;
		}
		
		override public function get contentsHaveTransforms():Boolean {
			return false;
		}
		
		public function FilmStripScenePV3D(scene3D:SceneObject3D, camera:CameraObject3D, viewport:Viewport3D, renderer:BasicRenderEngine)
		{
			this.scene3D = scene3D;
			this.camera = camera;
			this.viewport = viewport;
			this.renderer = renderer;
			recursionExceptionClasses.push(DAE);
		}
		
		override public function getVisibleChildren(target:Object=null):Array {
			if (target as DisplayObjectContainer3D) {
				return inventory(target as DisplayObjectContainer3D, Number.NEGATIVE_INFINITY);
			}
			return inventory(scene3D);
		}
		
		override public function getDisplayChain(target:Object) : Array {
			var a:Array = new Array();
			while (target && target.hasOwnProperty("parent") && target.parent!=scene3D) {
				a.push(target);
				target = target.parent;
			}
			return a;
		}
		
		override public function getPerpectiveObject():Object {
			return camera;
		}
		
		override public function getSelectiveDrawUtil(data:BitmapData):SelectiveDrawBase {
			var d:SelectiveBitmapDraw3D = new SelectiveBitmapDraw3D(data, scene3D, camera, viewport, renderer);
			d.useViewportLayerCapture = useViewportLayerCapture;
			return d;
		}
		
		override public function redrawScene():void {
			renderer.renderScene(scene3D, camera, viewport);
		}
		
		protected function inventory(container:DisplayObjectContainer3D, currentDepth:Number=1):Array {
			var a:Array = new Array();
			var d:Dictionary = getLayerObjects(container, currentDepth);
			getSortedList(viewport.containerSprite, a, d);
			return a;
		}
		
		// Creates a separate ViewportLayer for visible objects within our recursion limits.
		protected function getLayerObjects(container:DisplayObjectContainer3D, currentDepth:Number=1, d:Dictionary=null):Dictionary {
			if (!d) {
				d = new Dictionary();
				d.leafCount = 0;
			}
			for each (var node:DisplayObject3D in container.children) {
				if (node.visible) {
					
					viewport.getChildLayer(node, true, false);
					
					var isBranch:Boolean = (node.numChildren > 0 && super.canRecurse(node, currentDepth));
					var isLeaf:Boolean = (!isBranch && renderExceptions.indexOf(node)==-1);
					
					if (isLeaf) {
						d[ node ] = isLeaf;
					}
					else {
						var count:Number = d.leafCount;
						getLayerObjects(node, currentDepth+1, d);
						if (d.leafCount == count) {
							d[ node ] = isLeaf; // turned out to be a leaf
						}
					}
				}
			}
			return d;
		}
		
		// Traverses the whole scene and populates the array with DO3Ds in their visual sort order
		protected function getSortedList(layer:ViewportLayer, a:Array, d:Dictionary):void {
			if (layer == viewport.containerSprite) {
				layer.sortChildLayers();
			}
			var layers:Array = layer.childLayers;
			for (var i:int=0; i<layers.length; i++) {
				var childLayer:ViewportLayer = layers[i] as ViewportLayer;
				
				// Currently only pushing leaf nodes into the results array. This is a pretty
				// distinct decision, it means that container nodes are not blurred directly.
				// Therefore it's best to be sure containers are just containers and not objects.
				
				// Let's say you want to parent two cubes to a sphere and animate both the cubes
				// and also the whole group. You can do this and get a compound blur on the cubes,
				// but instead of actually adding the cubes as children of the sphere directly, 
				// you should wrap all 3 objects in a plain DO3D container that you animate and 
				// make the sphere a child of the container that just sits at zero. 
				
				if (d[ childLayer.displayObject3D ] === true) {
					a.push(childLayer.displayObject3D);
					if (childLayer.childLayers.length > 0) {
						getSortedList(childLayer, a, d);
					}
				}
			}
		}
	}
}