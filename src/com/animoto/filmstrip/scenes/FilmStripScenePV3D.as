package com.animoto.filmstrip.scenes
{
	import com.animoto.filmstrip.FilmStrip;
	import com.animoto.filmstrip.PulseControl;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	import org.papervision3d.core.proto.CameraObject3D;
	import org.papervision3d.core.proto.SceneObject3D;
	import org.papervision3d.core.render.IRenderEngine;
	import org.papervision3d.events.RendererEvent;
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.view.Viewport3D;
	
	public class FilmStripScenePV3D implements IFilmStripScene
	{
		public var scene:SceneObject3D;
		public var camera:CameraObject3D;
		public var viewport:Viewport3D;
		public var renderer:IRenderEngine;
		public var viewportLayersToRender:Array;
		
		public function get contentWidth():int {
			return viewport.width;
		}
		
		public function get contentHeight():int {
			return viewport.height;
		}
		
		protected var _filmStrip: FilmStrip;
		protected var _renderCallback: Function;
		protected var _image: BitmapData;
		protected var _requested: Boolean = false;
		protected var _width: int;
		protected var _height: int;
		
		public function FilmStripScenePV3D(scene:SceneObject3D, camera:CameraObject3D, viewport:Viewport3D, renderer:IRenderEngine, viewportLayersToRender:Array=null)
		{
			this.scene = scene;
			this.camera = camera;
			this.viewport = viewport;
			this.renderer = renderer;
			this.viewportLayersToRender = viewportLayersToRender;
			(renderer as BasicRenderEngine).addEventListener(RendererEvent.RENDER_DONE, onSceneRendered);
		}
		
		public function init(filmStrip:FilmStrip, renderCallback:Function, width:int, height:int):void {
			stopRendering();
			_filmStrip = filmStrip;
			_renderCallback = renderCallback;
			_width = width;
			_height = height;
			_image = new BitmapData(_width, _height, true, 0x0);
		}
		
		public function stopRendering():void {
			_renderCallback = null;
			_filmStrip = null;
			if (_image!=null) {
				_image.dispose();
				_image = null;
			}
			_requested = false;
			// TODO: stop render processes
		}
		
		public function renderFrame(currentTime:int):void {
			_requested = true;
			PulseControl.setTime(currentTime); // papervision renderer will trigger onSceneRendered()
		}
		
		public function onSceneRendered(event:RendererEvent):void {
			if (_requested) {
				_requested = false;
				_image.draw(viewport);
				_filmStrip.bitmapScene.addChild(new Bitmap(_image));
				_renderCallback();
			}
		}
	}
}