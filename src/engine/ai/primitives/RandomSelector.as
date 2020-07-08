package engine.ai.primitives
{
	/**
	 * The ParentTask of a list of selections of Task.
	 * It will execute the first RANDOM child that passes checkCondition() test.
	 * Checking will be started from the current running task.
	 */
	public class RandomSelector extends ParentTask
	{
		
		public function RandomSelector(blackBoard:BlackBoard, taskId:String="Random Sel")
		{
			super(blackBoard, taskId);
		}
		
		public override function start():void
		{
			_controller.currentTask = chooseNewTask();
		}
		
		public override function doAction():void
		{
			if(_controller.currentTask == null) {
				_controller.currentTask = chooseNewTask();
			}
			super.doAction();
		}
		
		/**
		 * Choose the new task to be updated.
		 * @return The new task if found, null otherwise.
		 */
		public function chooseNewTask():Task
		{
			var task:Task = null;
			if(_controller.subTasks.length > 0) {
				var pos:int = Math.floor(Math.random() * _controller.subTasks.length);
				task = _controller.subTasks[pos];
			}
			return task;
		}
		
		/**
		 * Called when a child finished with failure.
		 * This will find a new child to be updated.
		 * If none is found, this selector will finish with failure.
		 */
		public override function childFailed():void
		{
			_controller.currentTask = null;
			_controller.finishWithFailure();
		}
		
		public override function childStillRunning():void
		{
			_controller.stillRunning();
		}
		
		/**
		 * Called when a child finished with success.
		 * This selector will finish with success.
		 */
		public override function childSucceeded():void
		{
			_controller.currentTask = null;
			_controller.finishWithSuccess();
		}
	}
}