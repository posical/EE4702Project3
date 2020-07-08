package engine.audio
{
	import flash.geom.Vector3D;

	public class ReceiverProperties extends Object
	{
		private var _position:Vector3D;
		private var _lookAt:Vector3D;
		private var _upVector:Vector3D;
		
		public function ReceiverProperties()
		{
			super();
			
			reset();
		}
		
		public function reset():void
		{
			_position.setTo(0, 0, 0);
			_lookAt.setTo(1.0, 0, 0);
			_upVector.setTo(0, 0, 1.0);
		}
		
		public function setPosition(x:Number, y:Number, z:Number):void
		{
			_position.setTo(x, y, z);
		}
		
		public function setLookAt(x:Number, y:Number, z:Number):void
		{
			_lookAt.setTo(x, y, z);
		}
		
		public function setUpVector(x:Number, y:Number, z:Number):void
		{
			_upVector.setTo(x, y, z);
		}

		public function get position():Vector3D
		{
			return _position;
		}

		public function set position(value:Vector3D):void
		{
			_position = value;
		}

		public function get lookAt():Vector3D
		{
			return _lookAt;
		}

		public function set lookAt(value:Vector3D):void
		{
			_lookAt = value;
		}

		public function get upVector():Vector3D
		{
			return _upVector;
		}

		public function set upVector(value:Vector3D):void
		{
			_upVector = value;
		}
	}
}