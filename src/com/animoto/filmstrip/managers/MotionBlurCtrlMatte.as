package com.animoto.filmstrip.managers
{
	import flash.display.BitmapData;
	import flash.filters.BitmapFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	
	/**
	 * Subclass of MotionBlurController that draws all subframe images into a 
	 * single bitmap.
	 * 
	 * @author moses gunesch
	 */
	public class MotionBlurCtrlMatte extends MotionBlurController
	{
		public function MotionBlurCtrlMatte(controller:FilmStripSceneController, target:Object, wholeScene:Boolean)
		{
			super(controller, target, wholeScene);
		}
		
		override protected function captureSubframe():void {
			controller.scene.redrawScene();
			
			var ct:ColorTransform = new ColorTransform(1, 1, 1, currentAlpha());
			var filters:Array = controller.scene.getFilters(target);
			
			var bd:BitmapData = newBitmapData();
			bd.draw(drawUtil.drawSource);
			if (filters==null) {
				filters = [];
			}
			else {
				filters = filters.slice();
			}
			if (applyBoxBlur) {
				filters.push(currentBoxBlur());
			}
			var p:Point = new Point(0,0);
			for each (var filter:BitmapFilter in filters) {
				bd.applyFilter(bd, drawUtil.bitmapData.rect, p, filter);
			}
			drawUtil.bitmapData.draw(bd, null, ct, blendMode);
		}
	}
}