package com.animoto.filmstrip.scenes
{
	public interface IFilmStripScene
	{
		function get controller(): FilmStripSceneController;
		
		function get actualContentWidth(): int;
		function get actualContentHeight(): int;
	}
}