package com.animoto.filmstrip.scenes
{
	import com.animoto.filmstrip.FilmStripSceneController;
	import com.mosesSupposes.util.SelectiveDrawBase;
	
	import flash.display.BitmapData;
	import flash.filters.BitmapFilter;
	import flash.utils.Dictionary;
	
	/**
	 * A wrapper for your physical scene that provides the render system
	 * with the information it needs and lets you apply bitmap effects.
	 * 
	 * You need to apply the PulseControl patch to your animation system
	 * for the FilmStrip rendering system to work. 
	 * 
	 * @author moses gunesch
	 */
	public class FilmStripSceneBase
	{
		protected var _controller: FilmStripSceneController;
		protected var _filters: Dictionary = new Dictionary();
		
		/**
		 * IFilmStripScene: Render controller for this scene.
		 */
		public function get controller(): FilmStripSceneController {
			if (_controller==null) {
				_controller = new FilmStripSceneController(this);
			}
			return _controller;
		}

		/**
		 * IFilmStripScene: The scene's actual size.
		 */
		public function get actualContentWidth():int {
			// override this method
			return 0;
		}
		
		/**
		 * IFilmStripScene: The scene's actual size.
		 */
		public function get actualContentHeight():int {
			// override this method
			return 0;
		}
		
		/**
		 * IFilmStripScene: Filters added are rendered to their target object.
		 * (Hint: you can animate the filter's properties directly!)
		 */
		public function addFilter(targetInScene:Object, effect:BitmapFilter):void {
			if (_filters[targetInScene]==null) {
				_filters[targetInScene] = new Array();
			}
			(_filters[targetInScene] as Array).push(effect);
		}
		
		/**
		 * IFilmStripScene: Remove filters added on a target.
		 */
		public function removeFilters(targetInScene:Object):void {
			delete _filters[targetInScene];
		}
		
		/**
		 * IFilmStripScene: Get filters added using addFilter().
		 */
		public function getFilters(targetInScene:Object):Array {
			return _filters[targetInScene];
		}
		
		/**
		 * IFilmStripScene: All children visible in the scene when called,
		 * which should be depth-sorted if it's a 3D scene.
		 */
		public function getVisibleChildren():Array {
			// override this method
			return null;
		}
		
		/**
		 * IFilmStripScene: Use the BitmapData provided to create and return
		 * a new SelectiveBitmapDraw or SelectiveBitmapDraw3D.
		 */
		public function getSelectiveDrawUtil(data:BitmapData):SelectiveDrawBase {
			// override this method
			return null;
		}
		
		/**
		 * IFilmStripScene: If it's a 3D scene, render it. 
		 */
		public function redrawScene():void {
			// override this method if your scene requires a render call.
		}
	}
}