package engine.audio
{
	public class NonPositionalSoundProperties extends Object
	{
		private var _volume:Number;
		private var _pan:Number;
		private var _readCursor:int;
		
		public function NonPositionalSoundProperties()
		{
			super();
			
			reset();
		}
		
		public function copyFrom(properties:NonPositionalSoundProperties):void
		{
			_volume = properties.volume;
			_pan = properties.pan;
			_readCursor = properties.readCursor;
		}
		
		public function reset():void
		{
			_volume = SoundDef.VOLUME_MAX;
			_pan = SoundDef.PAN_CENTER;
			_readCursor = 0;
		}

		public function get volume():Number
		{
			return _volume;
		}

		public function set volume(value:Number):void
		{
			_volume = Math.max(SoundDef.VOLUME_MIN, Math.min(SoundDef.VOLUME_MAX, value));
		}

		public function get pan():Number
		{
			return _pan;
		}

		public function set pan(value:Number):void
		{
			_pan = Math.max(SoundDef.PAN_LEFT_ONLY, Math.min(SoundDef.PAN_RIGHT_ONLY, value));
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