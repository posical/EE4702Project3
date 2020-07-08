package engine.audioPhysics
{
	public class PanningGain extends Object
	{
		private var _left:Number;
		private var _right:Number;
		
		public function PanningGain()
		{
			super();
			_left = 1;
			_right = 1;
		}
		
		public function get leftGain():Number
		{
			return _left;
		}
		
		public function set leftGain(gain:Number):void
		{
			_left = gain;
		}
		
		public function get rightGain():Number
		{
			return _right;
		}
		
		public function set rightGain(gain:Number):void
		{
			_right = gain;
		}
	}
}