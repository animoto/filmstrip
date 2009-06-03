package com.animoto.filmstrip.managers
{
	import flash.display.Bitmap;
	import flash.filters.BlurFilter;
	
	/**
	 * Subclass of MotionBlurController that draws all subframe images into a 
	 * single bitmap.
	 * 
	 * @author moses gunesch
	 */
	public class SplitBlurController extends MotionBlurController
	{
		public function SplitBlurController(controller:FilmStripSceneController, target:Object, wholeScene:Boolean)
		{
			super(controller, target, wholeScene);
		}
		
		override protected function captureSubframe():void {
			controller.scene.redrawScene();
			refreshDrawUtil();
			drawUtil.bitmapData.draw(drawUtil.drawSource);
			
			var bitmap:Bitmap = new Bitmap(drawUtil.bitmapData);
			bitmap.blendMode = blendMode;
			bitmap.alpha = currentAlpha();
			
			if (applyBoxBlur) {
				var boxblur:BlurFilter = currentBoxBlur();
				bitmap.filters = [ boxblur ];
				if (index==1) { // retroactively box-blur primary frame on first subframe
					(container.getChildAt(0) as Bitmap).filters = [ boxblur ];
				}
			}
			var filters:Array = controller.scene.getFilters(target, true);
			if (filters!=null) {
				bitmap.filters = filters.concat(bitmap.filters);
			}
			
			container.addChild(bitmap);
			drawUtil.bitmapData = null;
		}
	}
}