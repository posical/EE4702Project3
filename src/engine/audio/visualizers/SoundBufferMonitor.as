package engine.audio.visualizers
{
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	public class SoundBufferMonitor extends NativeWindow
	{
		private var _canvas:Sprite;
		
		public function SoundBufferMonitor(initOptions:NativeWindowInitOptions)
		{
			super(initOptions);
			
			this.title = "Sound Buffer Monitor";
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			_canvas = new Sprite();
			stage.addChild(_canvas);
		}
	}
}