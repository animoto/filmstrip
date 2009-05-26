package com.animoto.filmstrip.scenes
{
	import com.mosesSupposes.util.SelectiveBitmapDraw3D;
	import com.mosesSupposes.util.SelectiveDrawBase;
	
	import flash.display.BitmapData;
	import flash.filters.BitmapFilter;
	import flash.utils.Dictionary;
	
	import org.papervision3d.core.proto.CameraObject3D;
	import org.papervision3d.core.proto.DisplayObjectContainer3D;
	import org.papervision3d.core.proto.SceneObject3D;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.view.Viewport3D;
	
	public class FilmStripScenePV3D extends FilmStripSceneBase// TODO: implements IFilmStripScene
	{
		
		
		public var scene3D:SceneObject3D;
		public var camera:CameraObject3D;
		public var viewport:Viewport3D;
		public var renderer:BasicRenderEngine;
		
		public var visibleChildren:Array;
		
		protected var filters: Dictionary = new Dictionary();
		
		/**
		 * Required by IFilmStripScene, provide the scene's actual size.
		 */
		override public function get actualContentWidth():int {
			return viewport.width;
		}
		
		/**
		 * Required by IFilmStripScene, provide the scene's actual size.
		 */
		override public function get actualContentHeight():int {
			return viewport.height;
		}
		
		public function FilmStripScenePV3D(scene3D:SceneObject3D, camera:CameraObject3D, viewport:Viewport3D, renderer:BasicRenderEngine)
		{
			this.scene3D = scene3D;
			this.camera = camera;
			this.viewport = viewport;
			this.renderer = renderer;
		}
		
		public function getSelectiveDrawUtil(data:BitmapData):SelectiveDrawBase {
			return new SelectiveBitmapDraw3D(data, scene3D, camera, viewport, renderer);
		}
		
		public function redrawScene():void {
			renderer.renderScene(scene3D, camera, viewport);
		}
		
		public function inventoryObjects():void {
			visibleChildren = inventoryScope(scene3D);
		}
		
		public function addFilter(targetInScene:Object, effect:BitmapFilter):void {
			if (filters[targetInScene]==null) {
				filters[targetInScene] = new Array();
			}
			(filters[targetInScene] as Array).push(effect);
		}
		
		public function removeFilters(targetInScene:Object):void {
			delete filters[targetInScene];
		}
		
		public function getFilters(targetInScene:Object):Array {
			return filters[targetInScene];
		}
		
		protected function inventoryScope(container:DisplayObjectContainer3D):Array {
			var a:Array = new Array();
			for each (var node:DisplayObject3D in container.children) {
				if (node.visible) {
					a.push(node);
					if (node.numChildren>0) {
						a = a.concat(inventoryScope(node));
					}
				}
				else {
					trace("Node invis: "+node);
				}
			}
			// Sort by screen depth
			//a.sortOn("screenZ", Array.DESCENDING | Array.NUMERIC);
			return a;
		}

		public function calculateDelta(currentTime:int):void {
			
		}
	}
}