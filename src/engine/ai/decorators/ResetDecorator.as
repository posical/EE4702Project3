package engine.ai.decorators
{
	import engine.ai.primitives.BlackBoard;
	import engine.ai.primitives.Decorator;
	import engine.ai.primitives.Task;

	/**
	 * Decorator that resets the Task each time it's finished.
	 */
	public class ResetDecorator extends Decorator
	{
		public function ResetDecorator(blackBoard:BlackBoard, task:Task, taskId:String = "Reset")
		{
			super(blackBoard, task, taskId);
		}
		
		public override function doAction():void
		{
			this.task.doAction();
			
			if(this.task.controller.isFinished) {
				this.task.controller.reset();
			}
		}
	}
}