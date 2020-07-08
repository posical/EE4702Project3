package engine.ai.primitives
{
	/**
	 * Inner node (non-leaf) of behavior tree.
	 */
	public class ParentTask extends Task
	{
		/**
		 * When this mode is set, task flow will become one-node traversal on each cycle.
		 */
		public static var steppingMode:Boolean = false;
		
		/**
		 * Task controller for ParentTask.
		 */
		protected var _controller:ParentTaskController;
		
		/**
		 * Constructor.
		 * @param blackBoard Reference to BlackBoard.
		 */
		public function ParentTask(blackBoard:BlackBoard, taskId:String = "Generic Parent")
		{
			super(blackBoard, taskId);
			createController();
		}
		
		/**
		 * Creates the specific task controller.
		 */
		private function createController():void
		{
			_controller = new ParentTaskController(this);
		}
		
		public override function checkConditions():Boolean
		{
			return super.checkConditions() && (_controller.subTasks.length > 0);
		}
		
		/**
		 * Checks whether the child has started, finished or needs
		 * updating.
		 */
		public override function doAction():void
		{
			// Return if this parent task is finished
			if(_controller.isFinished) {
				return;
			}
			
			// Return if the current task is null
			var theTask:Task = _controller.currentTask;
			if(theTask == null) {
				return;
			}
			
			// Do something on the current task
			if(!theTask.controller.isStarted) {
				// Start it if it haven't been,
				// then do it right away: Directly go to leaf in one cycle
				theTask.controller.safeStart();
				
				if(!steppingMode) {
					theTask.doAction();
				}
			} else if (!theTask.controller.isFinished) {
				// Continue it if it is still running
				theTask.doAction();
			} else if (steppingMode) {
				// Check if the task is done
				if (theTask.controller.isFinished) {
					theTask.controller.safeEnd();
					
					if(theTask.controller.isSucceeded) {
						this.childSucceeded();
					}
					if(theTask.controller.isFailed) {
						this.childFailed();
					}
				}
			}
			
			// Check if the task is done
			if (!steppingMode && theTask.controller.isFinished) {
				theTask.controller.safeEnd();
				
				if(theTask.controller.isSucceeded) {
					this.childSucceeded();
				}
				if(theTask.controller.isFailed) {
					this.childFailed();
				}
			} else if(!steppingMode && theTask.controller.isRunning) {
				this.childStillRunning();
			}
		}
		
		public override function end():void
		{ }
		
		public override function start():void
		{
			_controller.currentTask = null;
			
			for(var i:int = 0; i < _controller.subTasks.length; ++i) {
				if(_controller.subTasks[i] != null && _controller.subTasks[i].checkConditions() &&
						!_controller.subTasks[i].controller.isDisabled) {
					_controller.currentTask = _controller.subTasks[i];
					break;
				}
			}
			
			if(_controller.currentTask == null) {
				_controller.finishWithFailure();
			}
		}
		
		public override function abort():void
		{
			if(_controller.currentTask != null) {
				if(_controller.currentTask.controller.isStarted &&
					!_controller.currentTask.controller.isFinished) {
					_controller.currentTask.controller.safeAbort();
				}
			}
		}
		
		/**
		 * Called when a child finishes with success.
		 */
		public function childSucceeded():void
		{ }
		
		/**
		 * Called when a child finishes with failure.
		 */
		public function childFailed():void
		{ }
		
		/**
		 * Called when a child marks itself as still running.
		 */
		public function childStillRunning():void
		{ }
		
		public override function get controller():TaskController
		{
			return _controller;
		}
	}
}