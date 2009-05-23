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
	import flash.utils.Dictionary;
	
	/**
	 * Allows the capture of selective children within a DisplayObject.
	 * 
	 * <p>It works by toggling visibility off for other children,
	 * then immediately restoring their visibility after draw().</p>
	 * 
	 * @version 2.0
	 * @author moses gunesch
	 */
	public class SelectiveDrawBase
	{
		public var bitmapData:BitmapData;
		
		protected var parents:Dictionary = new Dictionary(true);
		protected var toggled:Dictionary = new Dictionary(true);
		
		public function SelectiveDrawBase(bitmapData:BitmapData)
		{
			this.bitmapData = bitmapData;
		}
		
		protected function setParents(topNode:Object, selectiveChildren:Array):void {
			for each (var node:Object in selectiveChildren) {
				if (node==topNode) {
					break;
				}
				do {
					if (parents[node]==null) {
						parents[node] = 1;
					}
					if (node.hasOwnProperty("parent") ? node.parent : null);
				}
				while (node!=null);
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
			for (target in parents) {
				delete parents[target];
			}
		}
	}
}