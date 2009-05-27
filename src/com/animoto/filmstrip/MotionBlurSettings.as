package com.animoto.filmstrip
{
	import flash.display.BlendMode;
	import flash.geom.Point;
	
	/**
	 * These settings are used depending on your filmStrip's blurMode and captureMode settings.
	 * 
	 * Change any of these settings in your program's setup code to customize blur output.
	 * For example the following will result in a much heavier blur:
	 * <pre>
	 * MotionBlurSettings.strength = 2;
	 * MotionBlurSettings.maxSubframes = 32;
	 * MotionBlurSettings.millisecondsPerSubframe = 2;
	 * </pre>
	 * @author moses gunesch
	 */
	public class MotionBlurSettings
	{
		// -== Global Blur Settings. ==-
		
		/**
		 * General multiplier factored into subframe calculation (greater than zero).
		 */
		public static var strength:Number = 1;
		
		/**
		 * Maximum number of frames any blur can generate (1 or more).
		 */
		public static var maxFrames:uint = 16;
		
		/**
		 * Milliseconds animation is changed each frame (1 or higher, higher numbers
		 * have the effect of spreading subframes apart).
		 */
		public static var subframeDuration:int = 1;
		
		/**
		 * Use -1 or 1 for either a trailing blur or "forward" blur, respectively.
		 * (Wish list item: allow in-between values to pan blur in both directions)
		 */
		public static var offset: Number = -1.0;
		
		/**
		 * Typically NORMAL works although subframes can have the effect of darkening
		 * the target -- LIGHTEN looks pretty good when matting subframes.
		 */
		public static var blendMode: String = BlendMode.NORMAL;

		/**
		 * Maximum amount of alpha for the first subframe; others will be less (0-1).
		 */
		public static var peakAlpha: Number = 0.25;
		
		/**
		 * A standard BlurFilter applied to each capture softens edges of subframes.
		 */
		public static var applyBoxBlur: Boolean = true;
		
		/**
		 * Low and high limits for box blur, if applyBoxBlur is true.
		 */
		public static var boxBlurRange: Point = new Point(1.5, 3.0);
		
		/**
		 * Subframe step multiplier for box blur, if applyBoxBlur is true.
		 */
		public static var boxBlurMultiplier: Number = 0.1;
		
		/**
		 * When false, the number of subframes is estimated based on the target object's motion.
		 */
		public static var useFixedFrameCount: Boolean = false;
		
		/**
		 * If usefixedFrameCount is true, each frame will draw this many subframes.
		 */
		public static var fixedFrameCount: int = 10;
		
		/**
		 * Subframes required for blur to be processed (1 or higher), usefixedFrameCount is false.
		 */
		public static var threshold:int = 1;
	}
}