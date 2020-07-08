package engine.ai.primitives
{
	/**
	 * Leaf task in behaviour tree.
	 * 
	 * The leaf task holds a specific TaskController that
	 * takes care of control logics using composition pattern.
	 */
	public class LeafTask extends Task
	{
		/**
		 * Task controller to keep track of the state of Task.
		 */
		protected var _controller:TaskController;
		
		/**
		 * Constructor.
		 * @param blackBoard Reference to BlackBoard.
		 */
		public function LeafTask(blackBoard:BlackBoard, taskId:String = "Generic Leaf")
		{
			super(blackBoard, taskId);
			createController();
		}
		
		/**
		 * Creates the specific task controller.
		 */
		private function createController():void
		{
			_controller = new TaskController(this);
		}
		
		/**
		 * Get TaskController.
		 * @return TaskController of this Task.
		 */
		public override function get controller():TaskController
		{
			return _controller;
		}
	}
}