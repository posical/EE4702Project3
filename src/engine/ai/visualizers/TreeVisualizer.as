package engine.ai.visualizers
{
	import engine.ai.primitives.Decorator;
	import engine.ai.primitives.ParentTask;
	import engine.ai.primitives.ParentTaskController;
	import engine.ai.primitives.Task;
	
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	public class TreeVisualizer extends NativeWindow
	{
		private var _root:Task;
		private var _canvas:Sprite;
		protected static var _verticalSpacing:int = 4;
		protected static var _horizontalSpacing:int = 10;
		
		public function TreeVisualizer(root:Task, initOptions:NativeWindowInitOptions, title:String = "Tree Visualizer")
		{
			super(initOptions);
			
			if(root == null) {
				throw new Error("TreeVisualizer::ctor() Bad root reference.");
			}
			_root = root;
			
			this.title = title;
			this.width = 1024;
			this.height = 768;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			_canvas = new Sprite();
			stage.addChild(_canvas);
			
			var dic:Dictionary = new Dictionary();
			drawTree(root, 0, dic);
			
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, handleMouseEvents);
		}
		
		protected function handleMouseEvents(e:MouseEvent):void
		{
			if(e.type == MouseEvent.MOUSE_WHEEL) {
				if(_canvas.height > this.height) {
					if(e.delta > 0 && _canvas.y < 0) { // Upward Scroll
						_canvas.y += e.delta * 10;
					} else if(e.delta < 0 && (_canvas.y+_canvas.height+50 > this.height)) {
						_canvas.y += e.delta * 10;
					}
				}
			}
		}
		
		private function drawTree(root:Task, level:int, base:Dictionary):TaskVisualizer
		{
			if(root == null) {
				return null;
			}
			
			var vis:TaskVisualizer = null;
			var childVis:TaskVisualizer = null;
			
			vis = drawNode(root, level, base);
			stage.addEventListener(Event.ENTER_FRAME, vis.update);
			
			if(root is Decorator) {
				var task:Task = (root as Decorator).task;
				if(task != null) {
					childVis = drawTree(task, level+1, base);
					vis.linkToNode(childVis);
				}
			} else if(root is ParentTask) {
				var children:Vector.<Task> = (root.controller as ParentTaskController).subTasks;
				for(var i:int = 0; i < children.length; ++i) {
					childVis = drawTree(children[i], level+1, base);
					vis.linkToNode(childVis);
				}
			}
			
			return vis;
		}
		
		private function drawNode(node:Task, level:int, base:Dictionary):TaskVisualizer
		{
			if(node == null) {
				return null;
			}
			
			// Vertical positioning
			if(base[level] == null) {
				base[level] = 0;
			}

			if(level > 0 && (base[level-1]-1 > base[level])) {
				base[level] = base[level-1]-1;
			}
			
			// Draw
			var vis:TaskVisualizer = new TaskVisualizer(node, this);
			vis.x = level * 120;
			vis.y = base[level]++ * (vis.height + _verticalSpacing);
			_canvas.addChild(vis);
			
			// Set next vertical position
			for(var i:int = 0; i < level; ++i) {
				if(base[i] != null) {
					base[i] = base[level];
				}
			}
			
			return vis;
		}
		
		public function get canvas():Sprite
		{
			return _canvas;
		}
	}
}