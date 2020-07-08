package engine.audio
{
	import flash.geom.Vector3D;

	public class PositionalSoundProperties extends Object
	{
		public static const VOLUME_MAX:Number = 1.0;
		
		private var _position:Vector3D;
		private var _lookAt:Vector3D;
		private var _innerConeAngle:int;
		private var _outerConeAngle:int;
		private var _volume:Number;
		private var _outerConeVolume:Number;
		private var _minimumDistance:Number;
		private var _maximumDistance:Number;
		private var _readCursor:int;
		
		public function PositionalSoundProperties()
		{
			super();
			
			_position = new Vector3D();
			_lookAt = new Vector3D();
			
			reset();
		}
		
		public function copyFrom(properties:PositionalSoundProperties):void
		{
			_position.setTo(properties.position.x, properties.position.y, properties.position.z);
			_lookAt.setTo(properties.lookAt.x, properties.lookAt.y, properties.lookAt.z);
			_innerConeAngle = properties.innerConeAngle;
			_outerConeAngle = properties.outerConeAngle;
			_volume = properties.volume;
			_outerConeVolume = properties.outerConeVolume;
			_minimumDistance = properties.minimumDistance;
			_maximumDistance = properties.maximumDistance;
			_readCursor = properties.readCursor;
		}
		
		public function reset():void
		{
			_position.setTo(0, 0, 0);
			_lookAt.setTo(1.0, 0, 0);
			_innerConeAngle = 360;
			_outerConeAngle = 360;
			_volume = VOLUME_MAX;
			_outerConeVolume = VOLUME_MAX;
			_minimumDistance = 0;
			_maximumDistance = 100.0;
			_readCursor = 0;
		}
		
		public function setPosition(x:Number, y:Number, z:Number):void
		{
			_position.setTo(x, y, z);
		}
		
		public function setLookAt(x:Number, y:Number, z:Number):void
		{
			_lookAt.setTo(x, y, z);
		}

		public function get position():Vector3D
		{
			return _position;
		}

		public function set position(value:Vector3D):void
		{
			_position = value;
		}

		public function get lookAt():Vector3D
		{
			return _lookAt;
		}

		public function set lookAt(value:Vector3D):void
		{
			_lookAt = value;
		}

		public function get innerConeAngle():int
		{
			return _innerConeAngle;
		}

		public function set innerConeAngle(value:int):void
		{
			_innerConeAngle = value % 360;
		}

		public function get outerConeAngle():int
		{
			return _outerConeAngle;
		}

		public function set outerConeAngle(value:int):void
		{
			_outerConeAngle = value % 360;
		}

		public function get volume():Number
		{
			return _volume;
		}
		
		public function set volume(value:Number):void
		{
			_volume = Math.max(SoundDef.VOLUME_MIN, Math.min(SoundDef.VOLUME_MAX, value));
		}

		public function get outerConeVolume():Number
		{
			return _outerConeVolume;
		}

		public function set outerConeVolume(value:Number):void
		{
			_outerConeVolume = Math.max(SoundDef.VOLUME_MIN, Math.min(SoundDef.VOLUME_MAX, value));
		}

		public function get minimumDistance():Number
		{
			return _minimumDistance;
		}

		public function set minimumDistance(value:Number):void
		{
			_minimumDistance = Math.max(0, value);
		}

		public function get maximumDistance():Number
		{
			return _maximumDistance;
		}

		public function set maximumDistance(value:Number):void
		{
			_maximumDistance = Math.max(0, value);
		}

		public function get readCursor():int
		{
			return _readCursor;
		}

		public function set readCursor(value:int):void
		{
			_readCursor = Math.max(0, value);
		}
	}
}