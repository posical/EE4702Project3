package engine.ai.primitives
{
	import flash.events.EventDispatcher;

	/**
	 * Keep tracks of the state and logical flow of Task.
	 */
	public class TaskController extends EventDispatcher
	{
		/**
		 * Whether the task is finished.
		 */
		private var _isDone:Boolean;
		
		/**
		 * Whether the task is finished with success.
		 */
		private var _isSucceeded:Boolean;
		
		/**
		 * Whether the task has started.
		 */
		private var _isStarted:Boolean;
		
		/**
		 * Whether the task is disabled.
		 */
		private var _isDisabled:Boolean;
		
		/**
		 * Reference to the Task being monitored.
		 */
		private var _task:Task;
		
		/**
		 * Constructor.
		 * @param task The Task to be monitored.
		 */
		public function TaskController(task:Task)
		{
			super();
			
			setTask(task);
			init();
		}
		
		/**
		 * Do initialization.
		 */
		private function init():void
		{
			_isDone = false;
			_isSucceeded = true;
			_isStarted = false;
		}
		
		/**
		 * Sets the reference of Task.
		 * @param task The Task to be monitored.
		 */
		public function setTask(task:Task):void
		{
			_task = task;
		}
		
		/**
		 * Start the monitored class.
		 */
		public function safeStart():void
		{
			_isStarted = true;
			_task.start();
		}
		
		/**
		 * Ends the monitored class.
		 */
		public function safeEnd():void
		{
			_isDone = false;
			_isStarted = false;
			_task.end();
		}
		
		public function safeAbort():void
		{
			_isDone = false;
			_isSucceeded = true;
			_isStarted = false;
			_task.abort();
		}
		
		public function enable():void
		{
			if(_isDisabled) {
				_isDisabled = false;
				init();
			}
		}
		
		public function disable():void
		{
			if(!_isDisabled) {
				_isDisabled = true;
				safeAbort();
			}
		}
		
		/**
		 * Ends the monitored Task with success.
		 */
		public function finishWithSuccess():void
		{
			_isSucceeded = true;
			_isDone = true;
		}
		
		/**
		 * Ends the monitored Task with failure.
		 */
		public function finishWithFailure():void
		{
			_isSucceeded = false;
			_isDone = true;
		}
		
		/**
		 * Mark the monitored Task to be running and should be 
		 * called again for the next cycle.
		 */
		public function stillRunning():void
		{
			// Actually redundant
			_isStarted = true;
			_isDone = false;
		}
		
		/**
		 * Mark the monitored Task as just started.
		 */
		public function reset():void
		{
			_isDone = false;
		}
		
		/**
		 * Indicate whether the Task finished successfully.
		 * @return true if it did, false otherwise.
		 */
		public function get isSucceeded():Boolean
		{
			return _isSucceeded;
		}
		
		/**
		 * Indicate whether the Task finished with failure.
		 * @return true if it did, false otherwise.
		 */
		public function get isFailed():Boolean
		{
			return !_isSucceeded;
		}
		
		/**
		 * Indicate whether the Task finished.
		 * @return true if it did, false otherwise.
		 */
		public function get isFinished():Boolean
		{
			return _isDone;
		}
		
		public function get isRunning():Boolean
		{
			return _isStarted && !_isDone;
		}
		
		/**
		 * Indicate whether the Task has started.
		 * @return true if it has, false otherwise.
		 */
		public function get isStarted():Boolean
		{
			return _isStarted;
		}
		
		/**
		 * Indicate whether the Task is disabled.
		 * @return true if it is, false otherwise.
		 */
		public function get isDisabled():Boolean
		{
			return _isDisabled;
		}
	}
}