package engine.audio
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Vector3D;
	
	public class Receiver extends EventDispatcher implements IReceiver
	{
		private var _options:ReceiverInitOptions;
		
		public function Receiver(options:ReceiverInitOptions = null, target:IEventDispatcher = null)
		{
			super(target);
			
			_options = (options == null) ? new ReceiverInitOptions() : options;
			init(_options);
		}
		
		public function init(options:ReceiverInitOptions):Boolean
		{
			if(options) {
				_options = options;
				
				return true;
			} else {
				throw new Error("Receiver::init() Null options.");
			}
			return false;
		}
		
		public function get properties():ReceiverProperties
		{
			return _options.properties;
		}
		
		public function set properties(value:ReceiverProperties):void
		{
			_options.properties = value;
		}
		
		public function get position():Vector3D
		{
			return _options.properties.position;
		}
		
		public function set position(value:Vector3D):void
		{
			_options.properties.position = value;
		}
		
		public function setPosition(x:Number, y:Number, z:Number):void
		{
			_options.properties.position.setTo(x, y, z);
		}
		
		public function get lookAt():Vector3D
		{
			return _options.properties.lookAt;
		}
		
		public function set lookAt(value:Vector3D):void
		{
			_options.properties.lookAt = value;
		}
		
		public function setLookAt(x:Number, y:Number, z:Number):void
		{
			_options.properties.lookAt.setTo(x, y, z);
		}
		
		public function get upVector():Vector3D
		{
			return _options.properties.upVector;
		}
		
		public function set upVector(value:Vector3D):void
		{
			_options.properties.upVector = value;
		}
		
		public function setUpVector(x:Number, y:Number, z:Number):void
		{
			_options.properties.upVector.setTo(x, y, z);
		}
	}
}