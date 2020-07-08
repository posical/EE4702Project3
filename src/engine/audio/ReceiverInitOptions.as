package engine.audio
{
	public class ReceiverInitOptions extends Object
	{
		private var _properties:ReceiverProperties;
		
		public function ReceiverInitOptions()
		{
			super();
			
			reset();
		}
		
		public function reset():void
		{
			if(_properties)
				_properties.reset();
		}

		public function get properties():ReceiverProperties
		{
			return _properties;
		}

		public function set properties(value:ReceiverProperties):void
		{
			_properties = value;
		}
	}
}