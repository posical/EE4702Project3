package engine.interfaces
{
	import engine.events.DebugEvent;

	/**
	 * Interfaces for classes that respond to DebugEvent
	 */
	public interface IDebug
	{
		function handleDebugEvents(e:DebugEvent):void;
	}
}