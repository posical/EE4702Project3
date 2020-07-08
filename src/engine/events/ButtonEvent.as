package engine.events
{
	import flash.events.Event;
	/**
	 * Events for Button.
	 */
	public class ButtonEvent extends Event
	{
		public static const DOWN:String = "down";
		public static const UP:String = "up";
		public static const HOVER:String = "hover";
		
		public function ButtonEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}