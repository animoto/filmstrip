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
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.IBitmapDrawable;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	/**
	 * Allows the capture of selective children within a DisplayObject.
	 * 
	 * <p>It works by toggling visibility off for other children,
	 * then immediately restoring their visibility after draw().</p>
	 * 
	 * @version 2.0
	 * @author moses gunesch
	 */
	public class SelectiveBitmapDraw extends SelectiveDrawBase
	{
		public var topContainer:DisplayObjectContainer;
		
		/**
		 * Constructor. 
		 * 
		 * @param bitmapData	BitmapData to draw to, accessible in the property <code>bitmapData</code>. 
		 * @param source		Source object for BitmapData.draw(), and default top-level object to work within.
		 */
		public function SelectiveBitmapDraw(bitmapData:BitmapData, source:DisplayObjectContainer)
		{
			super(bitmapData, source as IBitmapDrawable);
			this.topContainer = source;
		}
		
		/**
		 * Full draw cycle including toggle, capture, and restore.
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
		 * and after doing your own capture you should call manualPostDraw().</p>
		 * 
		 * @param selectiveChildren		Objects to leave visible for the capture, others are turned off.
		 * 
		 * @return 						If false no objects were toggled off, which means you don't need
		 * 								to call manualPostDraw().
		 */
		override public function manualPreDraw(selectiveChildren:Array):Boolean {
			super.setParents(selectiveChildren, topContainer);
			return (toggleChildren(topContainer) > 0);
		}
		
		/**
		 * (Advanced) If you used manualPreDraw() this restores visibility of toggled objects.
		 */
		override public function manualPostDraw(redrawAfter:Boolean=true):void {
			super.manualPostDraw();
		}
		
		// -== Private Methods ==-
		
		/**
		 * @private
		 * 
		 * @param container		Scope to sweep.
		 * @return 				Number of objects toggled off.
		 * 
		 */
		protected function toggleChildren(container:DisplayObjectContainer):int {
			var count: int = 0, node:DisplayObject, c:DisplayObjectContainer;
			var numChildren:int = container.numChildren;
			for (var i:int=0; i<numChildren; i++) {
				node = container.getChildAt(i);
				c = (node as DisplayObjectContainer)
				if (node.visible) {
					if (locked[node]==null) {
						toggled[node] = 1;
						node.visible = false;
						count ++;
					}
					else if (c!=null && c.numChildren>0) {
						count += toggleChildren(c);
					}
				}
			}
			return count;
		}
	}
}