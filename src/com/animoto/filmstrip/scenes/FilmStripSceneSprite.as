package com.animoto.filmstrip.scenes
{
	import com.mosesSupposes.util.SelectiveBitmapDraw;
	import com.mosesSupposes.util.SelectiveDrawBase;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	
	/**
	 * FilmStrip scene wrapper for use with a Sprite or MovieClip.
	 * 
	 * See FilmStripSceneBase for documentation.
	 * 
	 * @author moses gunesch
	 */
	public class FilmStripSceneSprite extends FilmStripScene
	{
		public var sprite: DisplayObjectContainer;
		
		override public function get actualContentWidth():int {
			return sprite.width;
		}
		
		override public function get actualContentHeight():int {
			return sprite.height;
		}
		
		public function FilmStripSceneSprite(sprite:DisplayObjectContainer)
		{
			this.sprite = sprite;
		}
		
		override public function getVisibleChildren():Array {
			return inventory(sprite);
		}
		
		override public function getSelectiveDrawUtil(data:BitmapData):SelectiveDrawBase {
			return new SelectiveBitmapDraw(data, sprite);
		}
		
		protected function inventory(container:DisplayObjectContainer):Array {
			var a:Array = new Array();
			var node:DisplayObject, c:DisplayObjectContainer;
			var numChildren:int = container.numChildren;
			for (var i:int=0; i<numChildren; i++) {
				node = container.getChildAt(i);
				c = (node as DisplayObjectContainer)
				if (node.visible) {
					a.push(node);
					if (c!=null && c.numChildren>0) {
						a = a.concat(inventory(c));
					}
				}
			}
			return a;
		}
	}
}