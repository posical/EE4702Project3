package engine.events
{
	import flash.events.Event;
	
	/**
	 * Event that indicates the on/off of debug mode
	 */
	public class DebugEvent extends Event
	{
		public static const ENTER_DEBUG:String = "enterDebug";
		public static const EXIT_DEBUG:String = "exitDebug";
		
		public function DebugEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}