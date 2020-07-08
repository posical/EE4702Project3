package engine.ai.primitives
{
	/**
	 * The ParentTask of a list of selections of Task.
	 * It will execute the first child that passes checkCondition() test.
	 * Running task will be ignored.
	 */
	public class PrioritySelector extends ParentTask
	{
		protected var _previousTask:Task;
		protected var _isFinding:Boolean;
		protected var _cycleEnded:Boolean; // For stepping mode
		
		/**
		 * Constructor.
		 * @param blackBoard Reference to BlackBoard.
		 */
		public function PrioritySelector(blackBoard:BlackBoard, taskId:String = "PrioritySelector")
		{
			super(blackBoard, taskId);
			
			_previousTask = null;
			_isFinding = false;
			_cycleEnded = true;
		}
		
		public override function doAction():void
		{
			if(_controller.isFinished) {
				return;
			}
			
			var theTask:Task = null;
			
			if(!_isFinding) {
				// Find first task
				for(var i:int = 0; i < _controller.subTasks.length; ++i) {
					if(_controller.subTasks[i] != null && _controller.subTasks[i].checkConditions() &&
						!_controller.subTasks[i].controller.isDisabled) {
						_previousTask = _controller.currentTask;
						_controller.currentTask = _controller.subTasks[i];
						break;
					}
				}
				_isFinding = true;
			}
			
			theTask = _controller.currentTask;
			
			if(theTask == null) {
				_controller.finishWithFailure();
			} else {
				// Find until the correct task
				
				if(!theTask.controller.isStarted) {
					// Start it if it haven't been,
					// then do it right away: Directly go to leaf in one cycle
					theTask.controller.safeStart();
					theTask.doAction();
				} else if (!theTask.controller.isFinished) {
					// Continue it if it is still running
					theTask.doAction();
				}
				
				// Check if the task is done
				if(theTask.controller.isFinished) {
					theTask.controller.safeEnd();
					
					if(theTask.controller.isSucceeded) {
						this.childSucceeded();
					} else if(theTask.controller.isFailed) {
						this.childFailed();
					}
				} else if (theTask.controller.isRunning) {
					this.childStillRunning();
				}
			}
		}
		
		public override function start():void
		{
			_isFinding = false;
			_previousTask = null;
			super.start();
		}
		
		public override function end():void
		{
			_isFinding = false;
			_previousTask = null;
			super.end();
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
			_controller.currentTask = this.chooseNewTask();
			if(_controller.currentTask == null) {
				_controller.finishWithFailure();
			} else {
				// Otherwise execute it immediately
				_isFinding = true;
				this.doAction();
			}
		}
		
		public override function childStillRunning():void
		{
			if(_previousTask != null && _controller.currentTask != _previousTask) {
				_previousTask.controller.safeAbort();
			}
			_isFinding = false;
			_controller.stillRunning();
		}
		
		/**
		 * Called when a child finished with success.
		 * This selector will finish with success.
		 */
		public override function childSucceeded():void
		{
			if(_previousTask != null && _controller.currentTask != _previousTask) {
				_previousTask.controller.safeAbort();
			}
			_isFinding = false;
			_controller.finishWithSuccess();
		}
	}
}