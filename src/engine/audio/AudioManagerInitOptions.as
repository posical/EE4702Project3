package engine.audio
{
	public class AudioManagerInitOptions extends Object
	{
		private var _bufferSize:uint;
		
		public function AudioManagerInitOptions()
		{
			super();
			
			reset();
		}
		
		public function reset():void
		{
			_bufferSize = SoundDef.BUFFER_MIN;
		}

		public function get bufferSize():uint
		{
			return _bufferSize;
		}

		public function set bufferSize(value:uint):void
		{
			_bufferSize = Math.max(SoundDef.BUFFER_MIN, Math.min(SoundDef.BUFFER_MAX, value));
		}
	}
}