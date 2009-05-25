/**
 * Copyright (c) 2009 Moses Gunesch
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package com.mosesSupposes.util
{
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import org.papervision3d.core.proto.CameraObject3D;
	import org.papervision3d.core.proto.DisplayObjectContainer3D;
	import org.papervision3d.core.proto.SceneObject3D;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.view.Viewport3D;
	
	/**
	 * Allows the capture of selective children within a PaperVision3D scene.
	 * 
	 * <p>It works by toggling visibility off for other children,
	 * then immediately restoring their visibility after draw().
	 * The process involves rendering the 3D scene twice.</p>
	 * 
	 * @version 1.0
	 * @author moses gunesch
	 */
	public class SelectiveBitmapDraw3D extends SelectiveDrawBase
	{
		public var topContainer:DisplayObjectContainer3D;
		public var scene:SceneObject3D;
		public var camera:CameraObject3D;
		public var viewport:Viewport3D;
		public var renderer:BasicRenderEngine;
		public var viewportLayersToRender:Array;
		
		/**
		 * Constructor. 
		 * 
		 * @param bitmapData				BitmapData to draw to, accessible in the property <code>bitmapData</code>. 
		 * @param scene						3D scene, and default top-level object to work within.
		 * @param camera					3D camera.
		 * @param viewport					3D viewport, and default <code>drawSource</code>.
		 * @param renderer					3D render engine.
		 * @param viewportLayersToRender	Pass a value here to use the <code>renderLayers</code> method of the renderer
		 * 									if it's a BasicRenderEngine. 
		 * 
		 */
		public function SelectiveBitmapDraw3D(bitmapData:BitmapData, scene:SceneObject3D, camera:CameraObject3D, viewport:Viewport3D, renderer:BasicRenderEngine, viewportLayersToRender:Array=null)
		{
			super(bitmapData, viewport as IBitmapDrawable);
			topContainer = scene;
			this.scene = scene;
			this.camera = camera;
			this.viewport = viewport;
			this.renderer = renderer;
			this.viewportLayersToRender = viewportLayersToRender;
		}
		
		/**
		 * Full draw cycle including toggle, capture, and restore.
		 * 
		 * <p>If any objects are toggled, the 3D scene is re-rendered once before, then once
		 * again after the capture.</p>
		 * 
		 * @param selectiveChildren		Objects to leave visible for the capture, others are turned off.
		 * @param matrix				Param passed to BitmapData.draw().
		 * @param colorTransform		Param passed to BitmapData.draw().
		 * @param blendMode				Param passed to BitmapData.draw().
		 * @param clipRect				Param passed to BitmapData.draw().
		 * @param smoothing				Param passed to BitmapData.draw().
		 * @return 
		 */
		override public function draw(selectiveChildren:Array, matrix:Matrix=null, colorTransform:ColorTransform=null, blendMode:String=null, clipRect:Rectangle=null, smoothing:Boolean=false):BitmapData {
			return super.draw(selectiveChildren, matrix, colorTransform, blendMode, clipRect, smoothing);
		}
		
		// -== Advanced Methods ==-
		
		/**
		 * (Advanced) Performs toggling off of objects not in the <code>selectiveChildren</code> Array.
		 * 
		 * <p>You'd only want to use this method if you aren't using this class' draw() method,
		 * and after doing your own capture you should call manualPostDraw(). The 3D scene is
		 * re-rendered if any objects were toggled, to prepare it for capture.</p>
		 * 
		 * @param selectiveChildren		Objects to leave visible for the capture, others are turned off.
		 * 
		 * @return 						If false no objects were toggled off, which means you don't need
		 * 								to call manualPostDraw().
		 */
		override public function manualPreDraw(selectiveChildren:Array):Boolean {
			super.setParents(selectiveChildren, topContainer);
			var r:Boolean = (toggleChildren(topContainer) > 0);
			if (r) {
				doRender();
			}
			return (r);
		}
		
		/**
		 * (Advanced) If you used manualPreDraw() this restores visibility of toggled objects, then re-renders the 3D scene.
		 */
		override public function manualPostDraw(redrawAfter:Boolean=true):void {
			super.manualPostDraw();
			if (redrawAfter)
				doRender();
		}
		
		// -== Private Methods ==-
		
		/**
		 * @private
		 * 
		 * @param container		Scope to sweep.
		 * @return 				Number of objects toggled off.
		 * 
		 */
		protected function toggleChildren(container:DisplayObjectContainer3D):int {
			var count: int = 0;
			for each (var node:DisplayObject3D in container.children) {
				if (node.visible) {
					if (locked[node]==null) {
						toggled[node] = 1;
						node.visible = false;
						count++;
					}
					else if (node.numChildren>0) {
						count += toggleChildren(node);
					}
				}
			}
			return count;
		}
		
		/**
		 * @private
		 * 
		 * Renders 3D scene.
		 */
		protected function doRender():void {
			if (viewportLayersToRender!=null) {
				renderer.renderLayers(scene, camera, viewport, viewportLayersToRender);
			}
			else {
				renderer.renderScene(scene, camera, viewport);
			}
		}
	}
}