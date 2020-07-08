package engine.audio
{
	import flash.geom.Vector3D;

	public interface IPositionalSound extends IPlayable
	{
		function init(options:PositionalSoundInitOptions):Boolean;
		
		function get properties():PositionalSoundProperties;
		function set properties(value:PositionalSoundProperties):void;
				
		function get position():Vector3D;
		function set position(value:Vector3D):void;
		function setPosition(x:Number, y:Number, z:Number):void;
		
		function get lookAt():Vector3D;
		function set lookAt(value:Vector3D):void;
		function setLookAt(x:Number, y:Number, z:Number):void;
		
		function get maxDistance():Number;
		function set maxDistance(value:Number):void;
		
		function get minDistance():Number;
		function set minDistance(value:Number):void;
		
		function get innerConeAngle():int;
		function set innerConeAngle(value:int):void;
		
		function get outerConeAngle():int;
		function set outerConeAngle(value:int):void;
		
		function get outerConeVolume():Number;
		function set outerConeVolume(value:Number):void;
		
		function get volume():Number;
		function set volume(value:Number):void;
		
		function get readCursor():int;
		function set readCursor(value:int):void;
	}
}