package engine.audio
{
	import flash.geom.Vector3D;

	public interface IReceiver
	{
		function init(options:ReceiverInitOptions):Boolean;
		
		function get properties():ReceiverProperties;
		function set properties(value:ReceiverProperties):void;
		
		function get position():Vector3D;
		function set position(value:Vector3D):void;
		function setPosition(x:Number, y:Number, z:Number):void;
		
		function get lookAt():Vector3D;
		function set lookAt(value:Vector3D):void;
		function setLookAt(x:Number, y:Number, z:Number):void;
		
		function get upVector():Vector3D;
		function set upVector(value:Vector3D):void;
		function setUpVector(x:Number, y:Number, z:Number):void;
	}
}