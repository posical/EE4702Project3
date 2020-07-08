package engine.ai.primitives
{
	/**
	 * The ParentTask of a list of selections of Task.
	 * It will execute the first child that passes checkCondition() test.
	 * Checking will be started from the current running task.
	 */
	public class Selector extends ParentTask
	{
		/**
		 * Constructor.
		 * @param blackBoard Reference to BlackBoard.
		 */
		public function Selector(blackBoard:BlackBoard, taskId:String = "Selector")
		{
			super(blackBoard, taskId);
		}
		
		/**
		 * Choose the new task to be updated.
		 * @return The new task if found, null otherwise.
		 */
		public function chooseNewTask():Task
		{
			var task:Task = null;
			var isFound:Boolean = false;
			var pos:int = _controller.subTasks.indexOf(_controller.currentTask);
			
			while(!isFound) {
				if(pos == _controller.subTasks.length - 1) {
					isFound = true;
					task = null;
					break;
				}
				
				pos++;
				
				task = _controller.subTasks[pos];
				if(!task.controller.isDisabled && task.checkConditions()) {
					isFound = true;
				}
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
			// Get next available task
			_controller.currentTask = this.chooseNewTask();
			
			// If none, finish with failure
			if(_controller.currentTask == null) {
				_controller.finishWithFailure();
			} else if(!steppingMode) {
				// Otherwise execute it immediately
				this.doAction();
			}
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
			_controller.finishWithSuccess();
		}
	}
}