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
	import flash.display.DisplayObjectContainer;
	import flash.display.IBitmapDrawable;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	/**
	 * Allows the capture of selective children within a DisplayObject.
	 * 
	 * <p>It works by toggling visibility off for other children,
	 * then immediately restoring their visibility after draw().</p>
	 * 
	 * @version 1.0
	 * @author moses gunesch
	 */
	public class SelectiveDrawBase
	{
		public var bitmapData:BitmapData;
		
		protected var protectedNodes:Dictionary = new Dictionary(true);
		protected var nodesToggled:Dictionary = new Dictionary(true);
		
		public function SelectiveDrawBase(bitmapData:BitmapData)
		{
			this.bitmapData = bitmapData;
		}
		
		public function manualDraw(source:IBitmapDrawable, selectiveChildren:Array, manualRestore:Boolean=false, matrix:Matrix=null, colorTransform:ColorTransform=null, blendMode:String=null, clipRect:Rectangle=null, smoothing:Boolean=false):void {
			bitmapData.draw(source, matrix, colorTransform, blendMode, clipRect, smoothing);
			if (manualRestore) {
				restoreNodes();
			}
		}
		
		protected function protectParentNodes(topNode:Object, selectiveChildren:Array):int {
			var protectCount:int = 0;
			for each (var node:Object in selectiveChildren) {
				if (node==topNode) {
					break;
				}
				do {
					if (protectedNodes[node]==null) {
						protectedNodes[node] = 1;
						protectCount++;
					}
					if (node.hasOwnProperty("parent") ? node.parent : null);
				}
				while (node!=null);
			}
			return protectCount;
		}
		
		protected function restoreNodes():void {
			if (nodesToggled==null) {
				return;
			}
			var target:Object;
			for (target in nodesToggled) {
				target.visible = true;
				delete nodesToggled[target];
			}
			for (target in protectedNodes) {
				delete protectedNodes[target];
			}
		}
	}
}