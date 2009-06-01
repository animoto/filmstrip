package com.animoto.filmstrip
{
	public class FilmStripBlurMode
	{
		public static const NONE: String = "none";
		
		/**
		 * Draws all subframes into a single bitmap (Default).
		 */
		public static const MATTE_SUBFRAMES: String = "matteSubframes";
		
		/**
		 * Separate bitmaps are generated for each subframe (Advanced).
		 * 
		 * Flash Player has an inherent limitation of premultiplying alpha during
		 * bitmap draw, which in rare cases can result in a darkening and 
		 * degradation of the blur area. This advanced mode is a workaround
		 * that lets the player handle blending all the way through frame capture
		 * by retaining each subframe as a separate bitmap. This mode is more 
		 * memory-intensive and should rarely be needed, but give it a try if you 
		 * see artifacting in your blur edges or are shooting for highest quality.
		 */
		public static const SPLIT_SUBFRAMES: String = "splitSubframes";
	}
}