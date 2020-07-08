package engine.ai.decorators
{
	import engine.ai.primitives.BlackBoard;
	import engine.ai.primitives.Decorator;
	import engine.ai.primitives.Task;
	import engine.utils.Clock;
	
	// PS: A decorator is actually a task. Just that it decorates the task.
	// It's sort of like a middleman to carry out all of the original
	// task's function on its behalf, such that additional logic can be
	// added at some point.
	/**
	 * Disable a 
	 */
	public class DisableAfterFinishDecorator extends Decorator
	{
		private var _duration:int;
		private var _clock:Clock;
		
		/**
		 * Constructor.
		 * @param duration Time in milliseconds to be delayed.
		 * @param blackBoard Reference to BlackBoard.
		 * @param task The Task to be decorated.
		 * TODO: cater negative duration
		 */
		public function DisableAfterFinishDecorator(duration:int, blackBoard:BlackBoard,
													task:Task, taskId:String = "DisableAfterFinish")
		{
			super(blackBoard, task, taskId);
			
			_duration = duration;
			
			_clock = new Clock();
			_clock.startFrom(duration);
		}
		
		// PS: Here checkConditions() is overriden to add more checking.
		public override function checkConditions():Boolean
		{
			return super.checkConditions() && (_clock.getElapsedTime() >= _duration);
		}
		
		// PS: end() is overriden to reset the clock to start tracking time.
		public override function end():void
		{
			super.end();
			_clock.reset();
		}
	}
}