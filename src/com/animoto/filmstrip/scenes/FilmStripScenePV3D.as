package com.animoto.filmstrip.scenes
{
	import com.animoto.filmstrip.FilmStrip;
	import com.animoto.filmstrip.FilmStripBlurMode;
	import com.animoto.filmstrip.FilmStripCaptureMode;
	import com.animoto.filmstrip.PulseControl;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	import org.papervision3d.core.proto.CameraObject3D;
	import org.papervision3d.core.proto.SceneObject3D;
	import org.papervision3d.events.RendererEvent;
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.view.Viewport3D;
	
	public class FilmStripScenePV3D implements IFilmStripScene
	{
		public var scene:SceneObject3D;
		public var camera:CameraObject3D;
		public var viewport:Viewport3D;
		public var renderer:BasicRenderEngine;
		public var viewportLayersToRender:Array;
		
		public function get contentWidth():int {
			return viewport.width;
		}
		
		public function get contentHeight():int {
			return viewport.height;
		}
		
		protected static var WHOLE_NOBLUR:int = 1;
		protected static var WHOLE_MATTE:int = 2;
		protected static var WHOLE_SPLIT:int = 3;
		protected static var EACH_NOBLUR:int = 4;
		protected static var EACH_MATTE:int = 5;
		protected static var EACH_SPLIT:int = 6;
		
		protected var _filmStrip: FilmStrip;
		protected var _renderCallback: Function;
		protected var _image: BitmapData;
		protected var _requested: Boolean = false;
		protected var _width: int;
		protected var _height: int;
		protected var _mode: int;
		
		public function FilmStripScenePV3D(scene:SceneObject3D, camera:CameraObject3D, viewport:Viewport3D, renderer:BasicRenderEngine, viewportLayersToRender:Array=null)
		{
			this.scene = scene;
			this.camera = camera;
			this.viewport = viewport;
			this.renderer = renderer;
			this.viewportLayersToRender = viewportLayersToRender;
		}
		
		public function init(filmStrip:FilmStrip, renderCallback:Function, width:int, height:int):void {
			stopRendering();
			_filmStrip = filmStrip;
			_renderCallback = renderCallback;
			_width = width;
			_height = height;
			_image = new BitmapData(_width, _height, true, 0x0);
			getMode();
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
		
		// Cases are:
		
		// 
		// * NOBLUR_SNAPSHOT No motion blur + whole scene : This is just a plain frame-sequence capture of a scene, might as well include it.
		//		- single bitmap, single capture of scene
		// FASTBLUR_SNAPSHOT Motion blur + whole scene + matte subframes : Fast, but excludes layer effects and has interlacing overlap issue.
		//		- single bitmap, multiple captures drawn into it
		
		// all other cases require mapping scene objects to bitmaps or sprites.
		
		// specific useBitmap cases
		// * NOBLUR_SNAPSHOT_LAYERS No motion blur + each object : Not useful except to apply layer effects during a plain capture.
		//		- bitmaps-per-object
		// FASTBLUR_LAYERS Motion blur + each object + matte subframes : Premultiplied alpha may show, but should be faster and supports layer effects.
		//		- bitmaps-per-object, captures of each drawn in per subframe
		// * BLUR_SNAPSHOT Motion blur + whole scene + split subframes : Only benefit might be reducing premult issues & fast, if not overlapping
		//		- whole-scene bitmaps for subframe series
		
		// split subframes blur mode = useSprite
		// * BESTBLUR_LAYERS Motion blur + each object + split subframes : Most complex and best option, layer effects.
		//		- sprites-per-object, bitmaps of each subframe added into them
		
		// Processes are:
		// If whole scene, make one bitmap.
		// If each object, inventory objects in scene, make bitmap for each, or sprite for each for split subframes
		// If motionblur, get deltas, run subframe cycle...
		// 		- matte: draw to whole scene bitmap, or to object bitmap 
		// 
		
		public function renderFrame(currentTime:int):void {
			if (_filmStrip.blurMode==FilmStripBlurMode.NONE) {
				if (_filmStrip.captureMode==FilmStripCaptureMode.WHOLE_SCENE)
					wholeFrameRender();
				else (_filmStrip.captureMode==FilmStripCaptureMode.EACH_OBJECT)
					
			}
			else {
				trace("Settings not yet supported.");
			}
		}
		
		protected function wholeFrameRender():void {
			_requested = true;
			renderer.addEventListener(RendererEvent.RENDER_DONE, frameComplete);
//			PulseControl.setTime(currentTime); // papervision renderer will trigger frameComplete()
		}
		
		protected function frameComplete(event:RendererEvent):void {
			if (_requested) {
				_requested = false;
				_image.draw(viewport);
				_filmStrip.bitmapScene.addChild(new Bitmap(_image));
				_renderCallback();
			}
		}
		
		protected function getMode():int {
			return 0;
		}
	}
}