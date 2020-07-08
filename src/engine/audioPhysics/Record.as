package engine.audioPhysics
{
	import engine.interfaces.ISoundObstructable;

	public class Record extends Object
	{
		private var _original:Source;
		private var _medium:ISoundObstructable;
		private var _reflected:Source;
		
		public function Record(original:Source, medium:ISoundObstructable, reflected:Source)
		{
			super();
			
			_original = original;
			_medium = medium;
			_reflected = reflected;
		}
		
		public function isMatched(original:Source, medium:ISoundObstructable, reflected:Source):Boolean
		{
			return (_original == original) && (_medium == medium) && (_reflected == reflected);
		}

		public function get original():Source
		{
			return _original;
		}

		public function set original(value:Source):void
		{
			_original = value;
		}

		public function get medium():ISoundObstructable
		{
			return _medium;
		}

		public function set medium(value:ISoundObstructable):void
		{
			_medium = value;
		}

		public function get reflected():Source
		{
			return _reflected;
		}

		public function set reflected(value:Source):void
		{
			_reflected = value;
		}


	}
}