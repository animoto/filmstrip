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
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	/**
	 * Allows the capture of selective children within a DisplayObject.
	 * 
	 * <p>It works by toggling visibility off for other children,
	 * then immediately restoring their visibility after draw().</p>
	 * 
	 * @version 1.0
	 * @author moses gunesch
	 */
	public class SelectiveBitmapDraw extends SelectiveDrawBase
	{
		public function SelectiveBitmapDraw(bitmapData:BitmapData)
		{
			super(bitmapData);
		}
		
		public function draw(container:DisplayObjectContainer, selectiveChildren:Array, matrix:Matrix=null, colorTransform:ColorTransform=null, blendMode:String=null, clipRect:Rectangle=null, smoothing:Boolean=false):void {
			var doRestore:Boolean = manualPre(container, selectiveChildren);
			super.manualDraw(container, selectiveChildren, doRestore, matrix, colorTransform, blendMode, clipRect, smoothing);
		}
		
		public function manualPre(container:DisplayObjectContainer, selectiveChildren:Array):Boolean {
			var count:int = super.protectParentNodes(container, selectiveChildren);
			return Boolean(count += prepareNodes(container));
		}
		
		protected function prepareNodes(container:DisplayObjectContainer):int {
			var count: int = 0;
			var node:DisplayObject;
			var numChildren:int = container.numChildren;
			for (var i:int=0; i<numChildren; i++) {
				node = container.getChildAt(i);
				if (node.visible && protectedNodes[node]==null) {
					nodesToggled[node] = 1;
					node.visible = false;
					count ++;
				}
				var c: DisplayObjectContainer = node as DisplayObjectContainer;
				if (c.numChildren>0) {
					count += prepareNodes(c);
				}
			}
			return count;
		}
	}
}