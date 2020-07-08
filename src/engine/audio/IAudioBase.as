package engine.audio
{
	public interface IAudioBase
	{
		function destroy():void;
		function load():Boolean;
		function unload():Boolean;
		function onUpdate():void;
		
		function get isInitialized():Boolean;
		function get isLoaded():Boolean;
	}
}