package com.rockonflash.go3d
{
	import com.rockonflash.go3d.properties.Go3DProperty;
	import com.rockonflash.go3d.properties.Value;
	
	import org.goasap.PlayStates;
	import org.goasap.events.GoEvent;
	import org.goasap.interfaces.IManageable;
	import org.goasap.items.LinearGo;
	import org.papervision3d.objects.DisplayObject3D;

	public class Tween3D extends LinearGo implements IManageable
	{		
		protected var _target					:DisplayObject3D = null;
		
		protected var _x						:Number;
		protected var _y						:Number;
		protected var _z						:Number;
		
		protected var _rotationX				:Number;
		protected var _rotationY				:Number;
		protected var _rotationZ				:Number;
		
		protected var _scale						:Number;
		protected var _scaleX					:Number;
		protected var _scaleY					:Number;
		protected var _scaleZ					:Number;
		
		protected var propertyChanges			:Array;
		
		public function set target( value:DisplayObject3D ):void
		{
			if( super.state != PlayStates.STOPPED ) return; 
			_target = value;
		}
		public function get target():DisplayObject3D
		{
			return _target;
		}
		
		public function set x( value:Number ):void
		{
			if( super.state != PlayStates.STOPPED ) return 
			_x = value;
			addProperty(Go3DProperty.x, value);
		}
		public function get x():Number
		{
			return _x;
		}
		
		public function set y( value:Number ):void
		{
			if( super.state != PlayStates.STOPPED ) return 
			_y = value
			addProperty(Go3DProperty.y, value);
		}
		public function get y():Number
		{
			return _y;
		}
		
		public function set z( value:Number ):void
		{
			if( super.state != PlayStates.STOPPED ) return 
			_z = value;
			addProperty(Go3DProperty.z, value);
		}
		public function get z():Number
		{
			return _z;
		}
		
		public function set rotationX( value:Number ):void
		{
			if( super.state != PlayStates.STOPPED ) return 
			_rotationX = value;
			addProperty(Go3DProperty.rotationX, value);
		}
		public function get rotationX():Number
		{
			return _rotationX;
		}
		
		public function set rotationY( value:Number ):void
		{
			if( super.state != PlayStates.STOPPED ) return 
			_rotationY = value;
			addProperty(Go3DProperty.rotationY, value);
		}
		public function get rotationY():Number
		{
			return _rotationY;
		}
		
		public function set rotationZ( value:Number ):void
		{
			if( super.state != PlayStates.STOPPED ) return 
			_rotationZ = value;
			addProperty(Go3DProperty.rotationZ, value);
		}
		public function get rotationZ():Number
		{
			return _rotationZ;
		}
		
		public function set scale( value:Number ):void
		{
			if( super.state != PlayStates.STOPPED ) return 
			_scale = value;
			addProperty(Go3DProperty.scale, value);
		}
		public function get scale():Number
		{
			return _scale;
		}
		
		public function set scaleX( value:Number ):void
		{
			if( super.state != PlayStates.STOPPED ) return 
			_scaleX = value;
			addProperty(Go3DProperty.scaleX, value);
		}
		public function get scaleX():Number
		{
			return _scaleX;
		}
		
		public function set scaleY( value:Number ):void
		{
			if( super.state != PlayStates.STOPPED ) return 
			_scaleY = value;
			addProperty(Go3DProperty.scaleY, value);
		}
		public function get scaleY():Number
		{
			return _scaleY;
		}
		
		public function set scaleZ( value:Number ):void
		{
			if( super.state != PlayStates.STOPPED ) return 
			_scaleZ = value;
			addProperty(Go3DProperty.scaleZ, value);
		}
		public function get scaleZ():Number
		{
			return _scaleZ;
		}
		
		public function Tween3D(
									target:DisplayObject3D=null, 
									propertyChanges:Array=null,
									duration:Number=NaN, 
									easing:Function=null, 
									delay:Number=NaN)
		{
			super(delay, duration, easing);
			
			this.propertyChanges = propertyChanges ? propertyChanges : [];
			
			if( propertyChanges && propertyChanges.length == 1 && propertyChanges[0] is Value )
				this.propertyChanges = Value.setAllPropertiesToTarget(propertyChanges[0] as Value);
			
			this.target = target;
			
			if( easing != null ) super._easing = easing;
			addEventListener(GoEvent.START, handleStart, false, 0, true);
		}
		
		override public function start():Boolean
		{
			if( !target || propertyChanges.length == 0 ) return false;
			
			return super.start(); 
		}
		
		protected function handleStart(e:GoEvent):void
		{
			updateStartValues();
		}
		
		protected function updateStartValues():void
		{
			for each( var gp:Go3DProperty in propertyChanges )
			{
				gp.useRelative = super.useRelative;
				gp.start = target[gp.targetProperty];
			}
		}	
		
		override protected function onUpdate(type:String):void
		{
			for each( var gp:Go3DProperty in propertyChanges )
			{
				if( isNaN(gp.start) || isNaN(gp.change) ) continue;
				target[gp.targetProperty] = super.correctValue(gp.start + ( gp.change * _position )); 
			}
		}
		
		protected function addProperty(property:String, value:Number):void
		{
			if( isHandling([property]) )
			{
				var gp:Go3DProperty = getGo3DProperty(property);
				if( gp ) gp.end = value;
			}
			else 
				propertyChanges.push(new Go3DProperty(property, NaN, value));
		}
		
		public function getActiveTargets():Array
		{
			return [target];
		}
		
		public function getActiveProperties():Array
		{
			var ary:Array = [];
			for each( var gp:Go3DProperty in propertyChanges )
				ary.push(gp.targetProperty);
				
			return ary;
		}
		
		public function getGo3DProperty(property:String):Go3DProperty
		{
			for each( var gp:Go3DProperty in propertyChanges )
			{
				if( gp.targetProperty == property ) return gp;
			}
			
			return null;
		}
		
		public function isHandling (properties : Array) : Boolean
		{
			for each( var gp:Go3DProperty in propertyChanges )
			{
				if( properties.indexOf(gp.targetProperty) > -1 ) return true;
			}
			return false;
		}
		
		public function releaseHandling(...params):void
		{
			stop();
		}
	}
}