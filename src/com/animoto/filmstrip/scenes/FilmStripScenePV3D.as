package com.animoto.filmstrip.scenes
{
	import com.animoto.filmstrip.FilmStrip;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	import org.papervision3d.core.proto.CameraObject3D;
	import org.papervision3d.core.proto.SceneObject3D;
	import org.papervision3d.events.RendererEvent;
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.view.Viewport3D;
	
	public class FilmStripScenePV3D extends AbstractFilmStripScene implements IFilmStripScene
	{
		public var scene:SceneObject3D;
		public var camera:CameraObject3D;
		public var viewport:Viewport3D;
		public var renderer:BasicRenderEngine;
		public var viewportLayersToRender:Array;
		
		public function get actualContentWidth():int {
			return viewport.width;
		}
		
		public function get actualContentHeight():int {
			return viewport.height;
		}
		
		public function FilmStripScenePV3D(scene:SceneObject3D, camera:CameraObject3D, viewport:Viewport3D, renderer:BasicRenderEngine, viewportLayersToRender:Array=null)
		{
			this.scene = scene;
			this.camera = camera;
			this.viewport = viewport;
			this.renderer = renderer;
			this.viewportLayersToRender = viewportLayersToRender;
		}
	}
}