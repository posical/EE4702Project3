package engine.managers
{
	import engine.classes.App;
	import engine.events.DebugEvent;
	import engine.interfaces.IDebug;
	
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	public class StatManager extends EventDispatcher implements IDebug
	{
		private var _app:App;
		private var _isShowing:Boolean;
		
		private var _frameCount:uint;
		private var _frameTime:int;
		private var _fpsText:TextField; // Frames per second
		
		private var _watchers:Dictionary;
		private var _watcherTexts:Dictionary;
		
		private static const LINE_HEIGHT:uint = 15;
		private var _lineCount:uint;
		private var _canvas:Sprite;
		
		public function StatManager()
		{
			super();
			
			trace("StatManager::ctor().");
			
			_watchers = new Dictionary();
			_watcherTexts = new Dictionary();
			_lineCount = 0;
			_canvas = new Sprite();
			
			_isShowing = false;
			
			_frameCount = 0;
		}
		
		public function registerApp(app:App):void
		{
			if(app != null) {
				_app = app;
				
				_frameTime = getTimer();
				
				_fpsText = new TextField();
				_fpsText.text = "FPS: ";
				_fpsText.textColor = 0x000000;
				_fpsText.x = 0;
				_fpsText.y = _lineCount++ * LINE_HEIGHT;
				_fpsText.selectable = false;
				_app.alwaysOnTopLayer.addChild(_fpsText);
			} else {
				trace("StatManager::registerApp() Bad app reference.");
			}
		}
		
		public function onEnterFrame():void
		{
			_frameCount++;
			
			if(getTimer() - _frameTime >= 1000) {
				_fpsText.text = "FPS: " + _frameCount;
				_frameCount = 0;
				_frameTime = getTimer();
			}
			if(isShowing) {	
				var tempTextField:TextField;
				var tempFunction:Function;
				for(var key:String in _watcherTexts) {
					tempTextField = _watcherTexts[key] as TextField;
					tempFunction = _watchers[tempTextField] as Function;
					tempTextField.text = key + ": " + tempFunction();
				}
			}
		}
		
		public function addWatcher(label:String, getter:Function):void
		{
			var text:TextField = new TextField();
			text.text = label + ": " + getter();
			text.y = _lineCount++ * LINE_HEIGHT;
			text.textColor = 0x000000;
			text.selectable = false;
			_canvas.addChild(text);
			_watchers[text] = getter;
			_watcherTexts[label] = text;
		}
		
		public function removeWatcher(label:String):void
		{
			var textField:TextField = _watcherTexts[label];
			_canvas.removeChild(textField);
			delete _watchers[textField];
			delete _watcherTexts[label];
			
			_lineCount = 1; // For FPS
			for each(var text:TextField in _watcherTexts) {
				text.y = _lineCount++ * LINE_HEIGHT;
			}
		}
		
		public function handleDebugEvents(e:DebugEvent):void
		{
			switch(e.type) {
				case DebugEvent.ENTER_DEBUG:
					_isShowing = true;
					_app.alwaysOnTopLayer.addChild(_canvas);
					break;
				case DebugEvent.EXIT_DEBUG:
					_isShowing = false;
					_app.alwaysOnTopLayer.removeChild(_canvas);
					break;
			
			}
		}
		
		public function get isShowing():Boolean
		{
			return _isShowing;
		}
		
		public function set isShowing(show:Boolean):void
		{
			_isShowing = show;
		}
	}
}