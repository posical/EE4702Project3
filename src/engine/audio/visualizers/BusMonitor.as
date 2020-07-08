package engine.audio.visualizers
{
	import engine.audio.Bus;
	
	import flash.display.Loader;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.net.URLRequest;
	
	public class BusMonitor extends NativeWindow
	{
		private var _canvas:Sprite;
		private var _master:Bus;
		private var _anchorX:Number;
		private var _backgroundImage:Loader;
		
		public function BusMonitor(initOptions:NativeWindowInitOptions)
		{
			super(initOptions);
			
			this.title = "Bus System";
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			_anchorX = 30;
			
			_canvas = new Sprite();
			stage.addChild(_canvas);
			
			_backgroundImage = new Loader();
			_backgroundImage.load(new URLRequest("images/visual.png"));
			_canvas.addChild(_backgroundImage);
		}
		
		private function build(master:Bus):BusVisualizer
		{
			if(master) {
				var vis:BusVisualizer = new BusVisualizer(master);
				vis.x = _anchorX;
				_canvas.addChild(vis);
				_anchorX += 100;
				
				for each(var child:Bus in master.childBuses) {
					vis.addChildVisualizer(build(child));
				}
				return vis;
			}
			return null;
		}

		public function get master():Bus
		{
			return _master;
		}

		public function set master(value:Bus):void
		{
			_master = value;
			build(_master);
		}

	}
}