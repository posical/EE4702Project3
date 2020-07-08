package engine.ai.decorators
{
	import engine.ai.primitives.BlackBoard;
	import engine.ai.primitives.Decorator;
	import engine.ai.primitives.Task;
	
	public class NegateDecorator extends Decorator
	{
		public function NegateDecorator(blackBoard:BlackBoard, task:Task, taskId:String="Not")
		{
			super(blackBoard, task, taskId);
		}
		
		public override function doAction():void
		{
			this.task.doAction();
			
			if(this.task.controller.isFinished) {
				if(this.task.controller.isSucceeded) {
					this.task.controller.finishWithFailure();
				} else if(this.task.controller.isFailed) {
					this.task.controller.finishWithSuccess();
				}
			}
		}
	}
}