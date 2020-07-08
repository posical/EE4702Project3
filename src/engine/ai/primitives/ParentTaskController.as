package engine.ai.primitives
{
	/**
	 * TaskController for ParentTask.
	 * Adding child Task is available via this TaskController.
	 */
	public class ParentTaskController extends TaskController
	{
		/**
		 * The child Tasks.
		 */
		private var _subTasks:Vector.<Task>;
		
		/**
		 * Keeps track of the current Task.
		 */
		private var _currentTask:Task;
		
		/**
		 * Constructor.
		 * @param task The task to be monitored.
		 */
		public function ParentTaskController(task:Task)
		{
			super(task);
			
			_subTasks = new Vector.<Task>();
			_currentTask = null;
		}
		
		/**
		 * Add a new child Task to the end of the sub-task list.
		 * @param task The Task to be added.
		 */
		public function add(task:Task):void
		{
			_subTasks.push(task);
		}
		
		public override function enable():void
		{
			super.enable();
			
			for each(var task:Task in _subTasks) {
				task.controller.enable();
			}
		}
		
		public override function disable():void
		{
			super.disable();
			
			for each(var task:Task in _subTasks) {
				task.controller.disable();
			}
		}
		
		/**
		 * Resets the Task.
		 */
		public override function reset():void
		{
			super.reset();
			_currentTask = (_subTasks.length > 0) ? _subTasks[0] : null;
		}
		
		/**
		 * Get the child Tasks.
		 */
		public function get subTasks():Vector.<Task>
		{
			return _subTasks;
		}
		
		/**
		 * Get the current Task.
		 */
		public function get currentTask():Task
		{
			return _currentTask;
		}
		
		public function set currentTask(task:Task):void
		{
			_currentTask = task;
		}
	}
}