package engine.audio
{
	import flash.utils.ByteArray;

	public interface IPlayable extends IAudioBase
	{
		function play():Boolean;
		function playByDeadline(time:uint):Boolean;
		function pause():Boolean;
		function stop():Boolean;
		function getBuffer(bufferSize:int):ByteArray;
		
		function get isPlaying():Boolean;
		function get isPaused():Boolean;
		function get isLooping():Boolean;
		function get isWaitingToBePlayed():Boolean;
		
		function get options():Object;
	}
}