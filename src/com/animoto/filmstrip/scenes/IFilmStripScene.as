package com.animoto.filmstrip.scenes
{
	import com.animoto.filmstrip.FilmStripSceneController;
	
	public interface IFilmStripScene
	{
		function get controller(): FilmStripSceneController;
		
		function get actualContentWidth(): int;
		function get actualContentHeight(): int;
	}
}