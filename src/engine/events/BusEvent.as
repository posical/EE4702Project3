package engine.events
{
	import flash.events.Event;
	
	public class BusEvent extends Event
	{
		public static const MIX_DONE:String = "MixDone";
		public static const VOLUME_CHANGE:String = "VolChange";
		
		private var _volume:Number;
		private var _left:Number;
		private var _right:Number;
		
		public function BusEvent(type:String, volume:Number = -1, left:Number = -1, right:Number = -1,
								 bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			_volume = volume;
			_left = left;
			_right = right;
		}

		public function get left():Number
		{
			return _left;
		}

		public function get right():Number
		{
			return _right;
		}

		public function get volume():Number
		{
			return _volume;
		}


	}
}