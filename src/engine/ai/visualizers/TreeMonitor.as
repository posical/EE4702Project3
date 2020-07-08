package engine.ai.visualizers
{
	import engine.ai.primitives.ParentTask;
	import engine.ai.primitives.Task;
	import engine.classes.App;
	import engine.ui.ToggleButton;
	
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowType;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	public class TreeMonitor extends NativeWindow
	{
		protected var _app:App;
		protected var _canvas:Sprite;
		
		protected var _steppingModeButton:ToggleButton;
		protected var _trees:Dictionary;
		protected var _treeButtonCount:int;
		protected var _treeVisualizers:Dictionary;
		
		public function TreeMonitor(app:App, initOptions:NativeWindowInitOptions)
		{
			super(initOptions);
			
			if(app == null) {
				throw new Error("TreeMonitor::ctor() Bad App reference.");
			}
			_app = app;
			
			_treeButtonCount = 0;
			
			this.title = "Tree Monitor";
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			_canvas = new Sprite();
			stage.addChild(_canvas);
			
			_steppingModeButton = new ToggleButton("Stepping Mode");
			_steppingModeButton.x = 10;
			_steppingModeButton.y = 10;
			_steppingModeButton.width = 160;
			_steppingModeButton.height = 20;
			_canvas.addChild(_steppingModeButton);
			_steppingModeButton.addEventListener(MouseEvent.CLICK, onSteppingToggle);
			
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, handleMouseEvents);
			
			_trees = new Dictionary();
			_treeVisualizers = new Dictionary();
		}
		
		protected function handleMouseEvents(e:MouseEvent):void
		{
			switch(e.type) {
				case MouseEvent.MOUSE_WHEEL:
					if(_canvas.height > this.height) {
						if(e.delta > 0 && _canvas.y < 0) { // Upward Scroll
							_canvas.y += e.delta * 10;
						} else if(e.delta < 0 && (_canvas.y+_canvas.height+50 > this.height)) {
							_canvas.y += e.delta * 10;
						}
					}
					break;
			}
		}
		
		public function registerTree(root:Task, id:String = "No ID"):void
		{
			if(_trees[id] == null) {
				_trees[id] = root;
				createButton(root, id);
			}
		}
		
		public function cleanUp():void
		{
			// TODO: Clean up all trees
		}
		
		protected function createButton(root:Task, id:String):void
		{
			var b:ToggleButton = new ToggleButton(id);
			b.x = 10;
			b.y = 40 * ++_treeButtonCount;
			b.width = 160;
			b.height = 30;
			_canvas.addChild(b);
			
			b.addEventListener(MouseEvent.CLICK, onTreeButtonClick);
		}
		
		protected function onTreeButtonClick(e:MouseEvent):void
		{
			if(e.type == MouseEvent.CLICK) {
				var b:ToggleButton = e.target as ToggleButton;
				
				if(b.isSelected) {
					showTree(b.buttonText);
				} else {
					hideTree(b.buttonText);
				}
			}
		}
		
		protected function showTree(id:String):void
		{
			if(_treeVisualizers[id] == null) {
				var options:NativeWindowInitOptions = new NativeWindowInitOptions;
				options.type = NativeWindowType.NORMAL;
				
				var vis:TreeVisualizer = new TreeVisualizer(_trees[id], options, id);
				vis.x = this.x + this.width;
				vis.y = this.y;
				vis.activate();
				_treeVisualizers[id] = vis;
				vis.addEventListener(Event.CLOSE,
					function(e:Event):void {
						
					});
			} else {
				(_treeVisualizers[id] as NativeWindow).activate();
			}
		}
		
		protected function hideTree(id:String):void
		{
			if(_treeVisualizers[id] != null) {
				(_treeVisualizers[id] as NativeWindow).close();
				_treeVisualizers[id] = null;
			}
		}
		
		protected function onSteppingToggle(e:MouseEvent):void
		{
			if(_steppingModeButton.isSelected) {
				ParentTask.steppingMode = true;
			} else {
				ParentTask.steppingMode = false;
			}
		}
	}
}