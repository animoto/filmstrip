package com.animoto.filmstrip.scenes
{
	public class FilmStripSceneBase implements IFilmStripScene
	{
		/**
		 * Required by IFilmStripScene.
		 */
		public function get controller(): FilmStripSceneController {
			if (_controller==null) {
				_controller = new FilmStripSceneController(this);
			}
			return _controller;
		}

		/**
		 * Required by IFilmStripScene, override and provide the scene's actual size.
		 */
		public function get actualContentWidth():int {
			return 0;
		}
		
		/**
		 * Required by IFilmStripScene, override and provide the scene's actual size.
		 */
		public function get actualContentHeight():int {
			return 0;
		}
		
		protected var _controller: FilmStripSceneController;
	}
}