package engine.ai.primitives
{
	/**
	 * Base class for other decorators.
	 */
	public class Decorator extends Task
	{
		private var _task:Task;
		
		public function Decorator(blackBoard:BlackBoard, task:Task, taskId:String = "Generic Decorator")
		{
			super(blackBoard, taskId);
			init(task);
		}
		
		private function init(task:Task):void
		{
			_task = task;
			_task.controller.setTask(this);
			trace("shit");
		}
		
		public override function checkConditions():Boolean
		{
			return _task.checkConditions();
		}
		
		public override function end():void
		{
			_task.end();
		}
		
		public override function get controller():TaskController
		{
			return _task.controller;
		}
		
		public override function start():void
		{
			_task.start();
		}
		
		public function get task():Task
		{
			return _task;
		}
		
		public override function doAction():void
		{
			_task.doAction();
		}
	}
}