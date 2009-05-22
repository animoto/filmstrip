package com.rockonflash.go3d.properties
{
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.objects.DisplayObject3D;
	
	public class Value
	{
		public static const X							:String = "x";
		public static const Y							:String = "y";
		public static const Z							:String = "z";
		public static const RotationX					:String = "rotationX";
		public static const RotationY					:String = "rotationY";
		public static const RotationZ					:String = "rotationZ";
		public static const Scale						:String = "scale";
		public static const ScaleX						:String = "scaleX";
		public static const ScaleY						:String = "scaleY";
		public static const ScaleZ						:String = "scaleZ";
		
		public static const XYZ							:Array = ["x", "y", "z"];
		public static const RotationXYZ					:Array = ["rotationX", "rotationY", "rotationZ"];
		public static const ScaleXYZ					:Array = ["scale", "scaleX", "scaleY", "scaleZ"];
		
		public var properties							:Array;
		public var target								:DisplayObject3D = null;
		
		public function Value(target:DisplayObject3D, properties:Array=null)
		{
			this.target = target;
			this.properties = properties;
		}		
		
		public static function tweenTarget(target:DisplayObject3D, properties:Array=null):Value
		{
			return new Value(target, properties);
		}
		
		public static function setAllPropertiesToTarget(value:Value):Array
		{
			var target:DisplayObject3D = value.target;
			var ary:Array = [];
			
			if( value.properties != null )
			{
				for( var i:int=0; i<value.properties.length; i++)
				{
					var property:String = value.properties[i];
					ary.push(Value[property](target[property], target));
				}
			}
			else
			{
				ary.push(x(target.x));
				ary.push(y(target.y));
				ary.push(z(target.z));
				ary.push(rotationX(target.rotationX));
				ary.push(rotationY(target.rotationY));
				ary.push(rotationZ(target.rotationZ));
			}			
			
			return ary;
		}
		
		/* 
		X     X         YY  YY          ZZZZZZZ 
		  X X            YYYY               ZZ  
		   X              YY               ZZ   
		  X X             YY             ZZ     
		X     X           YY            ZZZZZZZ 
		*/
		public static function x(value:Number, target:DisplayObject3D=null):Go3DProperty
		{
			return new Go3DProperty(Go3DProperty.x, NaN, value, target);
		}
		public static function y(value:Number, target:DisplayObject3D=null):Go3DProperty
		{
			return new Go3DProperty(Go3DProperty.y, NaN, value, target);
		}
		public static function z(value:Number, target:DisplayObject3D=null):Go3DProperty
		{
			return new Go3DProperty(Go3DProperty.z, NaN, value, target);
		}
		
		// Camera zoom
		public static function zoom(value:Number, target:Camera3D=null):Go3DProperty
		{
			return new Go3DProperty(Go3DProperty.zoom, NaN, value, target);
		}
		
		/*  
		RRRRR    OOOO  TTTTTT   AAA   TTTTTT IIIIII  OOOO  NN  NN 
		RR  RR  OO  OO   TT    AAAAA    TT     II   OO  OO NNN NN 
		RRRRR   OO  OO   TT   AA   AA   TT     II   OO  OO NNNNNN 
		RR  RR  OO  OO   TT   AAAAAAA   TT     II   OO  OO NN NNN 
		RR   RR  OOOO    TT   AA   AA   TT   IIIIII  OOOO  NN  NN 
		*/
		
		public static function rotationX(value:Number, target:DisplayObject3D=null):Go3DProperty
		{
			return new Go3DProperty(Go3DProperty.rotationX, NaN, value, target);
		}
		public static function rotationY(value:Number, target:DisplayObject3D=null):Go3DProperty
		{
			return new Go3DProperty(Go3DProperty.rotationY, NaN, value, target);
		}
		public static function rotationZ(value:Number, target:DisplayObject3D=null):Go3DProperty
		{
			return new Go3DProperty(Go3DProperty.rotationZ, NaN, value, target);
		}
		
		/*  
		 SSSSS  CCCCC    AAA   LL      EEEEEEE 
		SS     CC   CC  AAAAA  LL      EE      
		 SSSS  CC      AA   AA LL      EEEE    
		    SS CC   CC AAAAAAA LL      EE      
		SSSSS   CCCCC  AA   AA LLLLLLL EEEEEEE 
		*/
		
		public static function scale(value:Number, target:DisplayObject3D=null):Go3DProperty
        {
            return new Go3DProperty(Go3DProperty.scale, NaN, value, target);
        }       
        public static function scaleX(value:Number, target:DisplayObject3D=null):Go3DProperty
        {
            return new Go3DProperty(Go3DProperty.scaleX, NaN, value, target);
        }       
        public static function scaleY(value:Number, target:DisplayObject3D=null):Go3DProperty
        {
            return new Go3DProperty(Go3DProperty.scaleY, NaN, value, target);
        }       
        public static function scaleZ(value:Number, target:DisplayObject3D=null):Go3DProperty
        {
            return new Go3DProperty(Go3DProperty.scaleZ, NaN, value, target);
        }
	}
}