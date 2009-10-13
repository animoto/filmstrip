package com.animoto.filmstrip.scenes
{
	import com.mosesSupposes.util.SelectiveBitmapDraw;
	import com.mosesSupposes.util.SelectiveDrawBase;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	
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
		
		override public function getVisibleChildren(target:Object=null):Array {
			if (target as DisplayObjectContainer) {
				return inventory(target as DisplayObjectContainer, Number.NEGATIVE_INFINITY);
			}
			return inventory(sprite);
		}
		
		override public function getDisplayChain(target:Object) : Array {
			var a:Array = new Array();
			while (target && target.hasOwnProperty("parent") && target.parent!=sprite) {
				a.push(target);
				target = target.parent;
			}
			return a;
		}
		
		override public function getPerpectiveObject():Object {
			return sprite;
		}
		
		override public function getSelectiveDrawUtil(data:BitmapData):SelectiveDrawBase {
			return new SelectiveBitmapDraw(data, sprite);
		}
		
		protected function inventory(container:DisplayObjectContainer, currentDepth:Number=1):Array {
			var a:Array = new Array();
			var node:DisplayObject, c:DisplayObjectContainer;
			var numChildren:int = container.numChildren;
			for (var i:int=0; i<numChildren; i++) {
				node = container.getChildAt(i);
				c = (node as DisplayObjectContainer)
				if (node.visible) {
					var isBranch:Boolean = (c && c.numChildren > 0 && super.canRecurse(c, currentDepth));
					if (!isBranch) {
						a.push(node);
					}
					else {
						var l:int = a.length;
						a = a.concat(inventory(c), currentDepth+1);
						if (a.length == l) {
							a.push(node); // turned out to be a leaf
						}
					}
				}
			}
			return a;
		}
	}
}