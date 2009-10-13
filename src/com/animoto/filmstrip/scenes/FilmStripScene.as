package com.animoto.filmstrip.scenes
{
	import com.animoto.filmstrip.managers.FilmStripSceneController;
	import com.mosesSupposes.util.SelectiveDrawBase;
	
	import flash.display.BitmapData;
	import flash.filters.BitmapFilter;
	import flash.utils.Dictionary;
	
	/**
	 * A FilmStripScene is a wrapper for your physical scene that provides 
	 * the render system with the information it needs and lets you apply 
	 * bitmap effects.
	 * 
	 * You need to apply the PulseControl patch to your animation system
	 * for the FilmStrip rendering system to work. 
	 * 
	 * This is a base class that should not be used directly, instead
	 * use subclasses like FilmStripScenePV3D or FilmStripSceneSprite.
	 * The system is designed for easy expansion, so feel free to try
	 * extending it for Sandy, Away or other libraries!
	 * 
	 * @author moses gunesch
	 * 
	 */
	public class FilmStripScene
	{
		/**
		 * Setting this to 1 for example means that no nested objects should
		 * be considered, just children of the scene itself. 
		 */
		public var recursionLimit: Number = Number.POSITIVE_INFINITY;
		
		/**
		 * Specific objects to treat as leaf nodes to blur, without doing an
		 * inventory of child objects.
		 */
		public var recursionExceptions: Array = new Array();
		
		/**
		 * Specific types that should always be treated as leaf nodes to blur.
		 * For example DAE models are normally best treated as a single unit
		 * so DAE is added to this array by FilmStripScenePV3D.
		 */
		public var recursionExceptionClasses: Array = new Array();
		
		public var renderExceptions: Array = new Array();
		public var blurExceptions: Array = new Array();
		
		protected var _controller: FilmStripSceneController;
		protected var _filters: Dictionary = new Dictionary();
		protected var _subframeFilters: Dictionary = new Dictionary();
		
		/**
		 * Render controller for this scene.
		 */
		public function get controller(): FilmStripSceneController {
			if (_controller==null) {
				_controller = new FilmStripSceneController(this);
			}
			return _controller;
		}

		/**
		 * The scene's actual size.
		 */
		public function get actualContentWidth():int {
			// override this method
			return 0;
		}
		
		/**
		 * The scene's actual size.
		 */
		public function get actualContentHeight():int {
			// override this method
			return 0;
		}
		
		/**
		 * Tells MotionBlurController whether renderable children are
		 * transformable, such as Sprites, or never transformed and
		 * rendered from a single camera perpsective, such as PV3D 
		 * ViewportLayers.
		 */
		public function get contentsHaveTransforms():Boolean {
			return true;
		}
		
		/**
		 * Filters added are rendered to their target object.
		 * (Hint: you can animate the filter's properties directly!)
		 */
		public function addFilter(targetInScene:Object, effect:BitmapFilter, applyToSubframes:Boolean=false):void {
			if (_filters[targetInScene]==null) {
				_filters[targetInScene] = new Array();
			}
			(_filters[targetInScene] as Array).push(effect);
			
			if (applyToSubframes) {
				if (_subframeFilters[targetInScene]==null) {
					_subframeFilters[targetInScene] = new Array();
				}
				(_subframeFilters[targetInScene] as Array).push(effect);
			}
		}
		
		/**
		 * Remove filters added on a target.
		 */
		public function removeFilters(targetInScene:Object):void {
			delete _filters[targetInScene];
			delete _subframeFilters[targetInScene];
		}
		
		/**
		 * Get filters added using addFilter().
		 */
		public function getFilters(targetInScene:Object, forSubframe:Boolean=false):Array {
			if (forSubframe) {
				return _subframeFilters[targetInScene];
			}
			return _filters[targetInScene];
		}
		
		/**
		 * All children visible in the scene when called,
		 * which should be depth-sorted if it's a 3D scene.
		 */
		public function getVisibleChildren(target:Object=null):Array {
			// override this method
			return null;
		}
		
		/**
		 * The target and all its parents up to but not including 
		 * the scene top container.
		 */
		public function getDisplayChain(target:Object):Array {
			// override this method
			return null;
		}
		
		/**
		 * The 2D scene container or 3D camera used in 
		 * MotionBlurSettings.cameraBlurPercent.
		 */
		public function getPerpectiveObject():Object {
			return null;
		}
		
		/**
		 * Use the BitmapData provided to create and return
		 * a new SelectiveBitmapDraw or SelectiveBitmapDraw3D.
		 */
		public function getSelectiveDrawUtil(data:BitmapData):SelectiveDrawBase {
			// override this method
			return null;
		}
		
		/**
		 * If it's a 3D scene, render it. 
		 */
		public function redrawScene():void {
			// override this method if your scene requires a render call.
		}
		
		/**
		 * Clears memory pointers to ensure class can be deleted.
		 */
		public function destroy():void {
			if (_controller!=null) {
				_controller.destroy();
				_controller = null;
			}
			_filters = null;
			_subframeFilters = null;
		}
		
		
		protected function canRecurse(node:Object, currentDepth:Number):Boolean {
			if (currentDepth >= recursionLimit) {
				return false;
			}
			if (recursionExceptionClasses && recursionExceptionClasses.length > 0) {
				for each (var type:Class in recursionExceptionClasses) {
					if (node is type) {
						return false;
					}
				}
			}
			if (recursionExceptions && recursionExceptions.length > 0) {
				if (recursionExceptions.indexOf(node) > -1) {
					return false;
				}
			}
			return true;
		}
	}
}