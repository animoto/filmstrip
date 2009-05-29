package com.animoto.filmstrip
{
	public class DeltaManager
	{
		/**
		 * Increases the influence of rotation values for determining blur amount,
		 * since rotation values are often weaker than motion values.
		 */
		public static var rotationMultiplier:Number = 20;
		
		public static var props: String = "x|y|z|rotationX|rotationY|rotationZ|zoom|focus";
		
		public var target: Object;
		public var lastDelta: Number = 0;
		
		public var starts: Object = new Object();
		public var deltas: Object = new Object();
		
		public function DeltaManager(target:Object)
		{
			this.target = target;
		}
		
		public function recordStartValues():void {
			var pa:Array = props.split("|");
			for each (var prop:String in pa) {
				if (target.hasOwnProperty(prop)) {
					try {
						var value:Number = target[prop];
						if (!isNaN(value)) {
							starts[prop] = value;
						}
					}
					catch (e:Error) {
					}
				}
			}
		}
		
		public function getCompoundDelta():Number {
			var cd:Number = 0;
			for (var prop:String in starts) {
				var delta:Number = Math.abs( target[prop] - starts[prop] );
				deltas[prop] = delta;
				if (prop.indexOf("rotation")==0) {
					delta *= rotationMultiplier;
				}
				//trace(target,prop,delta);
				cd += delta;
			}
			lastDelta = cd;
			return cd;
		}
	}
}