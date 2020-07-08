package engine.ai.primitives
{
	/**
	 * The base of all task.
	 * This class should be inherited instead of using it "as is".
	 */
	public class Task extends Object
	{
		/**
		 * Reference to BlackBoard.
		 */
		protected var _bb:BlackBoard;
		
		/**
		 * Id of subclass.
		 */
		protected var _taskId:String;
		
		/**
		 * Constructor.
		 * @param blackBoard Reference to BlackBoard.
		 * @param Id to identify the subclass Task.
		 */
		public function Task(blackBoard:BlackBoard, taskId:String = "Generic Task")
		{
			super();
			
			_bb = blackBoard;
			_taskId = taskId;
		}
		
		/**
		 * Do pre-condition checks before proceeding to Task update.
		 * @return true if conditions are met, otherwise false.
		 */
		public function checkConditions():Boolean
		{
			return true;
		}
		
		/**
		 * Do start up logic of the Task.
		 */
		public function start():void
		{ }
		
		/**
		 * Do ending logic of the Task.
		 */
		public function end():void
		{ }
		
		/**
		 * Do abort logic of the Task.
		 */
		public function abort():void
		{ }
		
		/**
		 * Do the specific actions of the Task for each cycle.
		 */
		public function doAction():void
		{ }
		
		/**
		 * Get TaskController.
		 * @return TaskController of this Task.
		 */
		public function get controller():TaskController
		{
			return null;
		}
		
		public function get taskId():String
		{
			return _taskId;
		}
	}
}