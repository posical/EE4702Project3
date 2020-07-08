package engine.ai.primitives
{
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class BehaviorTree extends EventDispatcher
	{
		protected var _root:Task;
		
		public function BehaviorTree(target:IEventDispatcher=null)
		{
			super(target);
			_root = null;
		}
		
		public function buildTree(bb:BlackBoard):void
		{ }
		
		public function start():void
		{
			if(this.root != null) {
				this.root.controller.safeStart();
			}
		}
		
		public function doAction():void
		{
			if(this.root != null) {
				this.root.doAction();
			}
		}
		
		public function end():void
		{
			if(this.root != null) {
				this.root.controller.safeEnd();
			}
		}
		
		public function get root():Task
		{
			return _root;
		}
	}
}