package engine.events
{
	import flash.events.Event;
	
	public class MuteButtonEvent extends Event
	{
		public static const MUTE:String = "MUTE";
		public static const UNMUTE:String = "UNMUTE";
		
		public function MuteButtonEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}