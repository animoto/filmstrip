package com.animoto.filmstrip.scenes
{
	import com.mosesSupposes.util.SelectiveBitmapDraw3D;
	import com.mosesSupposes.util.SelectiveDrawBase;
	
	import flash.display.BitmapData;
	
	import org.papervision3d.core.proto.CameraObject3D;
	import org.papervision3d.core.proto.DisplayObjectContainer3D;
	import org.papervision3d.core.proto.SceneObject3D;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.view.Viewport3D;
	
	/**
	 * See FilmStripSceneBase for documentation.
	 * 
	 * @author moses gunesch
	 */
	public class FilmStripScenePV3D extends FilmStripSceneBase
	{
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
		
		public function FilmStripScenePV3D(scene3D:SceneObject3D, camera:CameraObject3D, viewport:Viewport3D, renderer:BasicRenderEngine)
		{
			this.scene3D = scene3D;
			this.camera = camera;
			this.viewport = viewport;
			this.renderer = renderer;
		}
		
		override public function getVisibleChildren():Array {
			return inventory(scene3D);
		}
		
		override public function getSelectiveDrawUtil(data:BitmapData):SelectiveDrawBase {
			return new SelectiveBitmapDraw3D(data, scene3D, camera, viewport, renderer);
		}
		
		override public function redrawScene():void {
			renderer.renderScene(scene3D, camera, viewport);
		}
		
		protected function inventory(container:DisplayObjectContainer3D):Array {
			var a:Array = new Array();
			for each (var node:DisplayObject3D in container.children) {
				if (node.visible) {
					a.push(node);
					if (node.numChildren>0) {
						a = a.concat(inventory(node));
					}
				}
			}
			// Sort by screen depth -- probably needed eventually
			//a.sortOn("screenZ", Array.DESCENDING | Array.NUMERIC);
			return a;
		}
	}
}