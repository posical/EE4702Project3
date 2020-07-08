package engine.utils
{
	import flash.utils.getTimer;
	
	/**
	 * A simple clock to measure (elapsed) time.
	 */
	public class Clock extends Object
	{
		/** Last reset time. */
		private var _startTime:int;
		
		/**
		 * Constructor.
		 */
		public function Clock()
		{
			super();
			
			reset();
		}
		
		/**
		 * Reset the Clock.
		 */
		public function reset():void
		{
			_startTime = getTimer();
		}
		
		/**
		 * Get the elapsed time in milliseconds since the last reset.
		 * @return Elapsed time in milliseconds.
		 */
		public function getElapsedTime():int
		{
			return getTimer() - _startTime;
		}
		
		/**
		 * Set the clock to assume starting from a specific time.
		 * For example <code>aClock.startFrom(1000)</code> will assume 1000 milliseconds
		 * have elapsed for <code>aClock</code> and start counting from 1000 milliseconds.
		 * <code>aClock.reset()</code> should be used instead of <code>aClock.startFrom(0)</code> to avoid
		 * unnecessary overhead.
		 * @param start The start time in milliseconds. (Total time assumed to have elapsed)
		 */
		public function startFrom(start:int):void
		{
			_startTime = getTimer() - start;
		}
	}
}