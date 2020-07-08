package engine.ai.visualizers
{
	import engine.ai.primitives.Decorator;
	import engine.ai.primitives.PrioritySelector;
	import engine.ai.primitives.RandomSelector;
	import engine.ai.primitives.Selector;
	import engine.ai.primitives.Sequencer;
	import engine.ai.primitives.Task;
	import engine.utils.Color;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public class TaskVisualizer extends Sprite
	{
		protected var _tree:TreeVisualizer;
		protected var _links:Vector.<TaskConnector>;
		protected var _task:Task;
		protected var _text:TextField;
		
		public static const NORMAL:int = 0;
		public static const HIGHLIGHT:int = 1;
		
		protected var _state:int;
		
		public function TaskVisualizer(task:Task, tree:TreeVisualizer)
		{
			super();
			
			if(task == null) {
				throw new Error("TaskVisualizer::ctor() Bad task reference.");
			}
			_task = task;
			_tree = tree;
			_state = NORMAL;
			_links = new Vector.<TaskConnector>();
			
			_text = new TextField();
			_text.background = true;
			_text.autoSize = TextFieldAutoSize.LEFT;
			_text.text = task.taskId;
			_text.borderColor = Color.RED;
			_text.selectable = false;
			this.addChild(_text);
			
			if(task is Decorator) {
				_text.text = "DEC> " + _text.text;
			} else if(task is Sequencer) {
				_text.text = "SEQ> " + _text.text;
			} else if(task is Selector) {
				_text.text = "SEL> " + _text.text;
			} else if(task is PrioritySelector) {
				_text.text = "P.SEL> " + _text.text;
			} else if(task is RandomSelector) {
				_text.text = "R.SEL> " + _text.text;
			}
			
			this.addEventListener(MouseEvent.MOUSE_OVER, handleMouseEvents);
			this.addEventListener(MouseEvent.MOUSE_OUT, handleMouseEvents);
			this.addEventListener(MouseEvent.CLICK, handleMouseEvents);
		}
		
		public function linkToNode(task:TaskVisualizer):void
		{
			if(task != null) {
				var line:TaskConnector = new TaskConnector(this, task);
				_tree.canvas.addChild(line);
				
				_links.push(line);
			}
		}
		
		protected function handleMouseEvents(e:MouseEvent):void
		{
			switch(e.type) {
				case MouseEvent.MOUSE_OVER:
					changeState(HIGHLIGHT);
					break;
				case MouseEvent.MOUSE_OUT:
					changeState(NORMAL);
					break;
				case MouseEvent.CLICK:
					if(_task.controller.isDisabled) {
						_task.controller.enable();
					} else {
						_task.controller.disable();
					}
					break;
			}
		}
		
		protected function changeState(state:int):void
		{
			if(_state == state)
				return;
			
			_state = state;
			switch(state) {
				case HIGHLIGHT:
					highlight();
					break;
				case NORMAL:
				default:
					dehighlight();
					break;
			}
		}
		
		protected function highlight():void
		{
			_text.border = true;
			
			for each(var link:TaskConnector in _links) {
				link.state = TaskConnector.HIGHLIGHT;
			}
		}
		
		protected function dehighlight():void
		{
			_text.border = false;
			
			for each(var link:TaskConnector in _links) {
				link.state = TaskConnector.NORMAL;
			}
		}
		
		public function update(e:Event):void
		{
			updateColor();
		}
		
		private function updateColor():void
		{
			if(_task.controller.isDisabled) {
				_text.backgroundColor = Color.SILVER;
			} else if(!_task.controller.isStarted) { // Ready
				_text.backgroundColor = Color.LIME;
			} else if (_task.controller.isFinished) {
				if(_task.controller.isSucceeded) {
					_text.backgroundColor = Color.AQUA;
				} else {
					_text.backgroundColor = Color.RED;
				}
			} else { // Running
				_text.backgroundColor = Color.YELLOW;
			}
		}
		
		public function get leftConnector():Vector3D
		{
			return new Vector3D(this.x, this.y + this.height/2);
		}
		
		public function get rightConnector():Vector3D
		{
			return new Vector3D(this.x + this.width, this.y + this.height/2);
		}
		
		public function get state():int
		{
			return _state;
		}
		
		public function set state(value:int):void
		{
			changeState(value);
		}
	}
}