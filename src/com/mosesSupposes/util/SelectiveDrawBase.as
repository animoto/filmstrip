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
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	/**
	 * Base class for SelectiveBitmapDraw utils.
	 * 
	 * @version 2.0
	 * @author moses gunesch
	 */
	public class SelectiveDrawBase
	{
		public var bitmapData:BitmapData;
		public var drawSource:IBitmapDrawable;
		
		protected var offset:Point = new Point();
		protected var locked:Dictionary = new Dictionary(true);
		protected var toggled:Dictionary = new Dictionary(true);
		
		public function SelectiveDrawBase(bitmapData:BitmapData, drawSource:IBitmapDrawable)
		{
			this.bitmapData = bitmapData;
			this.drawSource = drawSource;
		}
		
		public function draw(selectiveChildren:Array, matrix:Matrix=null, colorTransform:ColorTransform=null, blendMode:String=null, clipRect:Rectangle=null, smoothing:Boolean=false):BitmapData {
			var doRestore:Boolean = manualPreDraw(selectiveChildren);
			bitmapData.draw(drawSource, matrix, colorTransform, blendMode, clipRect, smoothing);
			if (doRestore) {
				manualPostDraw();
			}
			return bitmapData;
		}
		
		public function manualPreDraw(selectiveChildren:Array):Boolean {
			return false;
		}
		
		public function manualPostDraw(redrawAfter:Boolean=true):void {
			restore();
		}
		
		public function updateBeforeDraw():void {
			
		}
		
		public function getOffset():Point {
			return offset;
		}
		
		public function destroy():void {
			bitmapData = null;
			drawSource = null;
			locked = null;
			toggled = null;
		}
		
		protected function setParents(selectiveChildren:Array, topNode:Object):void {
			var leaf:Boolean;
			for each (var node:Object in selectiveChildren) {
				leaf = true;
				do {
					if (locked[node]==null) {
						locked[node] = leaf;
					}
					node = (node.hasOwnProperty("parent") ? node.parent : null);
					leaf = false;
				}
				while (node!=null && node!=topNode);
			}
		}
		
		protected function restore():void {
			if (toggled==null) {
				return;
			}
			var target:Object;
			for (target in toggled) {
				target.visible = true;
				delete toggled[target];
			}
			for (target in locked) {
				delete locked[target];
			}
		}
	}
}