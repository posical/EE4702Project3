package engine.ai.tasks
{
	import engine.ai.primitives.BlackBoard;
	import engine.ai.primitives.LeafTask;
	
	public class DummyTask extends LeafTask
	{
		public function DummyTask(blackBoard:BlackBoard, taskId:String="Dummy")
		{
			super(blackBoard, taskId);
		}
		
		public override function doAction():void
		{
			_controller.finishWithSuccess();
		}
	}
}