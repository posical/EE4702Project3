package engine.audio
{
	public class AudioManagerStats extends Object
	{
		private var _numSoundLoaded:uint;
		private var _numPositionalSoundLoaded:uint;
		
		public function AudioManagerStats()
		{
			super();
			
			reset();
		}
		
		public function reset():void
		{
			_numSoundLoaded = 0;
			_numPositionalSoundLoaded = 0;
		}

		public function get numSoundLoaded():uint
		{
			return _numSoundLoaded;
		}
		
		public function set numSoundLoaded(value:uint):void
		{
			_numSoundLoaded = value;
		}

		public function get numPositionalSoundLoaded():uint
		{
			return _numPositionalSoundLoaded;
		}

		public function set numPositionalSoundLoaded(value:uint):void
		{
			_numPositionalSoundLoaded = value;
		}
	}
}