package engine.ai.primitives
{
	/**
	 * The ParentTask of a sequence of Task.
	 * Each of its children will be executed in turn.
	 */
	public class Sequencer extends ParentTask
	{
		/**
		 * Constructor.
		 * @param blackBoard Reference to BlackBoard.
		 */
		public function Sequencer(blackBoard:BlackBoard, taskId:String = "Sequencer")
		{
			super(blackBoard, taskId);
		}
		
		/**
		 * Called when a child finished with failure.
		 * Bail with failure.
		 */
		public override function childFailed():void
		{
			_controller.finishWithFailure();
		}
		
		public override function childStillRunning():void
		{
			_controller.stillRunning();
		}
		
		/**
		 * Called when a child finished with success.
		 * Proceed to update the next child.
		 * Bail with success if all children are executed successfully.
		 */
		public override function childSucceeded():void
		{
			var pos:int = _controller.subTasks.indexOf(_controller.currentTask);
			
			if(pos == _controller.subTasks.length - 1) {
				_controller.finishWithSuccess();
			} else {
				// Get the next enabled task in sequence
				_controller.currentTask = null;
				for(var i:int = ++pos; i < _controller.subTasks.length; ++i) {
					if(!_controller.subTasks[i].controller.isDisabled) {
						_controller.currentTask = _controller.subTasks[i];
						break;
					}
				}
				
				// All following tasks are disabled.
				if(_controller.currentTask == null) {
					_controller.finishWithSuccess();
					return;
				}
				
				if(!_controller.currentTask.checkConditions()) {
					_controller.finishWithFailure();
				} else if(!steppingMode) {
					// Start doing it right away
					this.doAction();
				}
			}
		}
		
	}
}