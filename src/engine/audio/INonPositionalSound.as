package engine.audio
{
	public interface INonPositionalSound extends IPlayable
	{
		function init(options:NonPositionalSoundInitOptions):Boolean;
		
		function get properties():NonPositionalSoundProperties;
		function set properties(value:NonPositionalSoundProperties):void;
				
		function get volume():Number;
		function set volume(value:Number):void;
		
		function get pan():Number;
		function set pan(value:Number):void;
		
		function get readCursor():int;
		function set readCursor(value:int):void;
		
	}
}