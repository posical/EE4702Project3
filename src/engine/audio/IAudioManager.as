package engine.audio
{
	public interface IAudioManager
	{
		function init(options:AudioManagerInitOptions):Boolean;
		function cleanUp():void;
		
		function isInitialized():Boolean;
		
		function createNonPositionalSound(options:NonPositionalSoundInitOptions=null):INonPositionalSound;
		function createPositionalSound(options:PositionalSoundInitOptions=null):IPositionalSound;
		
		function stopAll():Boolean;
		function pauseAll():Boolean;
		function resumeAll():Boolean;
		
		function get stats():AudioManagerStats;
		
		function get receiver():IReceiver;
		
		function get soundVolume():Number;
		function set soundVolume(value:Number):void;
		
		function get musicVolume():Number;
		function set musicVolume(value:Number):void;
	}
}