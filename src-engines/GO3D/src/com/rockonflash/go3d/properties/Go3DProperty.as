package com.rockonflash.go3d.properties
{
	import org.papervision3d.objects.DisplayObject3D;
	
	
	public class Go3DProperty
	{
		public static var x							:String = "x";
		public static var y							:String = "y";
		public static var z							:String = "z";
		public static var zoom						:String = "zoom";
		
		public static var rotationX					:String = "rotationX";
		public static var rotationY					:String = "rotationY";
		public static var rotationZ					:String = "rotationZ";
		
		public static var scale                     :String = "scale";
        public static var scaleX                    :String = "scaleX";
        public static var scaleY                    :String = "scaleY";
        public static var scaleZ                    :String = "scaleZ";
		
		public var targetProperty					:String = "";
		public var target							:DisplayObject3D;
		
		protected var _end							:Number = NaN;
		protected var _start						:Number = NaN;
		
		public var useRelative						:Boolean = false;
		
		public function set start( value:Number ):void
		{
			_start = value;
			change = useRelative ? end : end - start;
		}
		public function get start():Number
		{
			return _start;
		}
		
		public function set end( value:Number ):void
		{
			_end = target ? target[targetProperty] : value;
		}
		public function get end():Number
		{
			return _end;
		}
		public var change							:Number = NaN;
		
		public function Go3DProperty(targetProperty:String, start:Number=NaN, end:Number=NaN, target:DisplayObject3D=null)
		{
			this.targetProperty = targetProperty;
			this.start = start;
			this.end = end;
		}
	}
}