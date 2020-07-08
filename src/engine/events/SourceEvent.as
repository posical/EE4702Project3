package engine.events
{
	import flash.events.Event;
	
	public class SourceEvent extends Event
	{
		public static const REMOVE_AT_FINISHED:String = "removeAtFinished";
		
		public function SourceEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}