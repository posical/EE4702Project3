package engine.utils
{
	import flash.display.Stage;

	/**
	 * Helper class to hold a reference to the <code>stage</code>
	 * of the main window.
	 */
	public final class StageRef extends Object
	{
		private static var _stage:Stage;
		
		/**
		 * Constructor.
		 */
		public function StageRef()
		{
			super();
			_stage = null;
		}
		
		/**
		 * The reference to the <code>stage</code> of the main window.
		 */
		public static function get stage():Stage
		{
			return _stage;
		}
		
		public static function set stage(s:Stage):void
		{
			if(s != null) {
				_stage = s;
			}
		}
	}
}