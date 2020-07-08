package engine.ai.visualizers
{
	import engine.utils.Color;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class TaskConnector extends Sprite
	{
		public static const NORMAL:int = 0;
		public static const HIGHLIGHT:int = 1;
		
		protected var _fromTask:TaskVisualizer;
		protected var _toTask:TaskVisualizer;
		
		protected var _normalShape:Shape;
		protected var _highlightShape:Shape;
		
		protected var _state:int;
		
		public function TaskConnector(from:TaskVisualizer, to:TaskVisualizer)
		{
			super();
			
			if(from == null || to == null) {
				// TODO: Error handling
				trace("TaskConnector::ctor() Null parameter(s).");
			}
			
			_fromTask = from;
			_toTask = to;
			
			_state = NORMAL;
			
			_highlightShape = null;
			
			_normalShape = new Shape();
			_normalShape.graphics.lineStyle(1, Color.BLACK);
			_normalShape.graphics.moveTo(_fromTask.rightConnector.x, _fromTask.rightConnector.y);
			_normalShape.graphics.lineTo(_toTask.leftConnector.x, _toTask.leftConnector.y);
			this.addChild(_normalShape);
			
			this.addEventListener(MouseEvent.MOUSE_OVER, handleMouseEvents);
			this.addEventListener(MouseEvent.MOUSE_OUT, handleMouseEvents);
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
			}
		}
		
		public function changeState(state:int):void
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
			if(_highlightShape == null) {
				_highlightShape = new Shape();
				_highlightShape.graphics.lineStyle(1.5, Color.RED);
				_highlightShape.graphics.moveTo(_fromTask.rightConnector.x, _fromTask.rightConnector.y);
				_highlightShape.graphics.lineTo(_toTask.leftConnector.x, _toTask.leftConnector.y);
			}
			
			if(this.contains(_normalShape)) {
				this.removeChild(_normalShape);
			}
			
			if(!this.contains(_highlightShape)) {
				this.addChild(_highlightShape);
			}
			
			_toTask.state = TaskVisualizer.HIGHLIGHT;
		}
		
		protected function dehighlight():void
		{
			if(this.contains(_highlightShape)) {
				this.removeChild(_highlightShape);
			}
			
			if(!this.contains(_normalShape)) {
				this.addChild(_normalShape);
			}
			
			_toTask.state = TaskVisualizer.NORMAL;
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