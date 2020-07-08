package engine.audio
{
	public class SoundDef
	{
		public static const VOLUME_MAX:Number = 1.0;
		public static const VOLUME_MIN:Number = 0.0;
		
		public static const PAN_CENTER:Number = 0.0;
		public static const PAN_LEFT_ONLY:Number = -1.0;
		public static const PAN_RIGHT_ONLY:Number = 1.0;
		
		public static const BUFFER_MIN:uint = 2048;
		public static const BUFFER_MAX:uint = 8192;
		public static const BUFFER_SIZE:uint = BUFFER_MIN;
	}
}