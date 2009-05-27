package com.animoto.filmstrip
{
	public class FilmStripBlurMode
	{
		public static const NONE: String = "none";
		
		/**
		 * Draw subframes into a single bitmap.
		 * 
		 * This option is slightly faster and less memory-intensive, but due
		 * to Flash Player's inherent limitation of premultiplying alpha during
		 * bitmap draw, this option will sometimes result in a darkening and 
		 * degradation of the blur area. That doesn't always happen though,
		 * so try it both ways.
		 * 
		 */
		public static const MATTE_SUBFRAMES: String = "matteSubframes";
		
		/**
		 * Separate bitmaps are generated for each subframe.
		 * 
		 * I came up with this as a workaround for the premultiplied-alpha issue:
		 * allow the player to handle blending all the way through frame capture.
		 * This is memory-intensive but allows the player to retain alpha information
		 * for each subframe. Seems to work pretty well.
		 * 
		 */
		public static const SPLIT_SUBFRAMES: String = "splitSubframes";
	}
}