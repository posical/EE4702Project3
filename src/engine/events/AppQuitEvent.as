package engine.events
{
	import flash.events.Event;
	
	/**
	 * Event that indicates an App instance is quiting. Contain exit code.
	 */
	public class AppQuitEvent extends Event
	{
		public static const QUIT:String = "quit";
		private var _exitCode:int;
		
		public function AppQuitEvent(type:String, exitCode:int, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_exitCode = exitCode;
		}
		
		public function get exitCode():int
		{
			return _exitCode;
		}
	}
}