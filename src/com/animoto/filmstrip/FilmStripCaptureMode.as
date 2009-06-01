package com.animoto.filmstrip
{
	public class FilmStripCaptureMode
	{
		/**
		 * Capture each child of the scene separately (Default).
		 * 
		 * By separating out each object we can vary the amount of
		 * motion-blur based on its real motion. This is a lot slower
		 * for intensive blurs but ends up saving time in the long run 
		 * because it reduces blur amounts in slow spots. Splitting to
		 * objects also enables the use of bitmap effects.
		 * 
		 */
		public static const EACH_OBJECT: String = "eachObject";
		
		/**
		 * Capture the whole scene as a single image.
		 * 
		 * Good without motion blur or bitmap effects, if you just intend to 
		 * do a fast frame-capture of an animation. 
		 * 
		 * You can also use motion-blur with this option if you use a fixed
		 * number of subframes, but it has some drawbacks. It's often slower 
		 * (more subframes over all), and overlapping blurs interlace.
		 * 
		 */
		public static const WHOLE_SCENE: String = "wholeScene";
	}
}