package com.animoto.filmstrip.managers
{
	import com.animoto.filmstrip.FilmStrip;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	/**
	 * Container for a stack of images that compose a frame.
	 * 
	 * Children can be either a Bitmap or a Sprite containing multiple Bitmaps,
	 * depending on the capture mode.
	 * 
	 * @author moses gunesch
	 */
	public class FilmStripBitmapScene extends Sprite
	{
		public function FilmStripBitmapScene() {
			super();
		}
		
		public function addDisplayItems(items:Array):void {
			for each (var item:DisplayObject in items)
				addChild(item);
		}
		
		public function clearDisplay(scope:Sprite=null):void {
			if (scope==null) {
				scope = this;
			}
			var n:int = scope.numChildren;
			while (--n > -1) {
				var item:DisplayObject = scope.removeChildAt(n);
				if (item is Sprite) {
					clearDisplay(item as Sprite);
				}
				else {
					try {
						(item as Bitmap).bitmapData.dispose();
					}
					catch (e:Error) {
						FilmStrip.error(e.message);
					}
				}
			}
		}
		
		public function dump():void {
			trace("-------bitmapscene-------");
			var n:int = numChildren;
			while (--n > -1) {
				var item:DisplayObject = getChildAt(n);
				var tag:String = "> "+ n + " " + item.toString() + " " + item.name;
				if (item is Sprite && (item as Sprite).numChildren > 1) {
					trace(tag + " contains "+(item as Sprite).numChildren+" bitmaps");
				}
				else {
					trace(tag);
				}
			}
			trace("-------------------------");
		}
	}
}