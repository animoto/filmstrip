/**
 * Copyright (c) 2008 Moses Gunesch
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
	import org.papervision3d.core.proto.SceneObject3D;
	import org.papervision3d.core.render.IRenderEngine;
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
		public var scene:SceneObject3D;
		public var camera:CameraObject3D;
		public var viewport:Viewport3D;
		public var renderer:IRenderEngine;
		public var viewportLayersToRender:Array;
		
		public function SelectiveBitmapDraw3D(bitmapData:BitmapData, scene:SceneObject3D, camera:CameraObject3D, viewport:Viewport3D, renderer:IRenderEngine, viewportLayersToRender:Array=null)
		{
			super(bitmapData);
			this.scene = scene;
			this.camera = camera;
			this.viewport = viewport;
			this.renderer = renderer;
			this.viewportLayersToRender = viewportLayersToRender;
		}
		
		public function draw(container:DisplayObject3D, selectiveChildren:Array, source:IBitmapDrawable, matrix:Matrix=null, colorTransform:ColorTransform=null, blendMode:String=null, clipRect:Rectangle=null, smoothing:Boolean=false):void {
			var doRestore:Boolean = manualPreDraw(container, selectiveChildren);
			bitmapData.draw(source, matrix, colorTransform, blendMode, clipRect, smoothing);
			if (doRestore) {
				manualPostDraw();
			}
		}
		
		public function manualPreDraw(container:DisplayObject3D, selectiveChildren:Array):Boolean {
			super.setParents(container, selectiveChildren);
			if (toggleChildren(container) > 0) {
				doRender();
			}
			return (toggleChildren(container) > 0);
		}
		
		public function manualPostDraw():void {
			super.restore();
			doRender();
		}
		
		// -== Private Methods ==-
		
		protected function toggleChildren(container:DisplayObject3D):int {
			var count: int = 0;
			for each (var node:DisplayObject3D in container.children) {
				if (node.visible) {
					if (parents[node]==null) {
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
		
		protected function doRender():void {
			if (viewportLayersToRender!=null && renderer is BasicRenderEngine) {
				(renderer as BasicRenderEngine).renderLayers(scene, camera, viewport, viewportLayersToRender);
			}
			else {
				renderer.renderScene(scene, camera, viewport);
			}
		}
	}
}