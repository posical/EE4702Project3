package engine.classes
{
	import engine.ai.primitives.BlackBoard;
	import engine.ai.visualizers.TreeMonitor;
	import engine.audio.AudioManager;
	import engine.audio.SoundManager;
	import engine.console.LogConsole;
	import engine.events.AppQuitEvent;
	import engine.events.DebugEvent;
	import engine.interfaces.IDebug;
	import engine.managers.StatManager;
	import engine.managers.StateManager;
	import engine.utils.Clock;
	import engine.utils.StageRef;
	
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowType;
	import flash.display.Screen;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	/**
	 * The App class provides the "game loop" for the application.
	 * This class should be inherited for any new development.
	 */
	public class App extends Sprite
	{
		// Exit codes
		public static const STATUS_OK:int = 0;
		public static const STATUS_NO_STATE:int = 1;
		
		// Managers
		private var _stateManager:StateManager;
		private var _audioManager:AudioManager;
		private var _soundMgr:SoundManager;
		
		// Monitors
		private var _treeMonitor:TreeMonitor;
		
		// Variables
		private var _mainWindow:NativeWindow;
		private var _windowTitle:String;
		
		private var _frameCount:int;
		private var _fpsClock:Clock;
		
		/**
		 * Clock used to get the difference of time from the previous frame
		 * to current frame.
		 */
		private var _frameClock:Clock;
		private var _frameTime:int;
		private var _isRunning:Boolean;
		
		/**
		 * Main canvas of this App.
		 * DisplayObject should not be added directly to stage, instead
		 * they should be added to canvas. Canvas can be considered as
		 * the lower layer of this Sprite.
		 */
		private var _canvas:Sprite;
		
		/** DisplayObject added to this will be always on top. */
		private var _alwaysOnTopLayer:Sprite;
		
		/** Whether in debug mode. */
		private var _isDebug:Boolean;
		
		/**
		 * Constructor.
		 * @param title The title of main window.
		 */
		public function App(title:String = "Default Application")
		{
			super();
			
			trace("App::ctor()");
			
			_windowTitle = title;
			_isRunning = false;
			_isDebug = false;
			
			addEventListener(Event.ADDED_TO_STAGE, preInit);
		}
		
		/**
		 * Start running the App instance.
		 * This will call the init() function for initializations of
		 * States. The logic and render loop start by the end of this
		 * function.
		 */
		public function run():void
		{
			_isRunning = true;
			
			// Initialization
			init();
			
			setupEventListeners();
			
			// Start logic and render loops
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			_frameClock.reset();
		}
		
		/**
		 * Quit the App instance.
		 * This will stop both update and render loops.
		 * After necessary clean up, AppQuitEvent will be fired.
		 * @param exitCode The exit code.
		 * */
		public function quit(exitCode:int):void
		{
			trace("Quitting application...");
			
			_isRunning = false;
			stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			cleanUp();
			
			this.dispatchEvent(new AppQuitEvent(AppQuitEvent.QUIT, exitCode));
		}
		
		/**
		 * Pre-initialization of the App instance.
		 * Event handler for Event.ADDED_TO_STAGE.
		 * This will initialize all main window properties and
		 * essential members.
		 */
		private function preInit(e:Event):void
		{
			//removeEventListener(Event.ADDED_TO_STAGE, preInit);
			
			// Reference to stage
			StageRef.stage = this.stage;
			
			// Window
			_mainWindow = stage.nativeWindow; // It DOES exists, a bug with FB4.6 intellisense
			_mainWindow.title = _windowTitle;
			
			_mainWindow.addEventListener(Event.CLOSING, handleEvents);
			_mainWindow.x = (Screen.mainScreen.bounds.width - _mainWindow.width) / 2;
			_mainWindow.y = 0;//(Screen.mainScreen.bounds.height - _mainWindow.height) /2;
			
			// Frame Clock
			_frameClock = new Clock();
			_fpsClock = new Clock();
			_frameCount = 0;
			
			// Canvas Layers
			_canvas = new Sprite();
			_alwaysOnTopLayer = new Sprite();
			stage.addChild(_canvas);
			stage.addChild(_alwaysOnTopLayer);
			
			// Managers
			_audioManager = AudioManager.getAudioManager();
			_soundMgr = SoundManager.getSoundManager();
						
			_stateManager = new StateManager();
			_stateManager.registerApp(this);
			
			// Monitors
			var options:NativeWindowInitOptions = new NativeWindowInitOptions;
			options.type = NativeWindowType.NORMAL;
			_treeMonitor = new TreeMonitor(this, options);
			_treeMonitor.x = 10;
			_treeMonitor.y = 10;
			_treeMonitor.width = 200;
//			_treeMonitor.activate();
			
			// BlackBoard static members
			BlackBoard.app = this;
		}
		
		/**
		 * Initialize States.
		 * Initial preloadable State flow should be done here.
		 * Additional dynamic State flow can be handle by each
		 * individual State.
		 */
		protected function init():void
		{
		}
		
		/**
		 * Main game loop.
		 */
		private function onEnterFrame(e:Event):void
		{
			if(_isRunning) {
				// Dispatch debug event
				if(_isDebug) {
					this.dispatchEvent(new DebugEvent(DebugEvent.ENTER_DEBUG));
				}
				
				// Update frame time
				_frameTime = _frameClock.getElapsedTime();
				_frameClock.reset();
				
				_frameCount++;
				if(_fpsClock.getElapsedTime() >= 1000) {
					_fpsClock.reset();
					_mainWindow.title = _windowTitle + " | FPS: " + _frameCount;
					_frameCount = 0;
				}
				
				this.stateManager.getActiveState().onEnterFrame(this.frameTime);
				this.audioManager.onUpdate();
				this._soundMgr.onUpdate();
				
				// StateManager cleans up dead State
				this.stateManager.handleCleanUp();
			}
		}
		
		/**
		 * Add debug listener.
		 */
		public function addDebugListener(obj:IDebug):void
		{
			if(obj != null) {
				this.addEventListener(DebugEvent.ENTER_DEBUG, obj.handleDebugEvents);
				this.addEventListener(DebugEvent.EXIT_DEBUG, obj.handleDebugEvents);
			}
		}
		
		/**
		 * Remove debug listener.
		 */
		public function removeDebugListener(obj:IDebug):void
		{
			if(obj != null) {
				this.removeEventListener(DebugEvent.ENTER_DEBUG, obj.handleDebugEvents);
				this.removeEventListener(DebugEvent.EXIT_DEBUG, obj.handleDebugEvents);
			}
		}
		
		/**
		 * Perform necessary clean up.
		 */
		private function cleanUp():void
		{
			trace("Cleaning up application...");
		}
		
		/**
		 * Main event handler.
		 * Instead of having multiple functions to handle different
		 * Events, all Events should be pointed to this handler.
		 */
		protected function handleEvents(e:Event):void
		{
			if(_isRunning) {
				switch(e.type) {
					// Quit App if main window is closing
					case Event.CLOSING:
						quit(STATUS_OK);
						break;
					
					// Resume current active State when gained focus
					case Event.ACTIVATE:
						_stateManager.getActiveState();
						break;
					// Pause current active State when lost focus
					case Event.DEACTIVATE:
						_stateManager.getActiveState();
						break;
					
					// Toogle debug mode
					case KeyboardEvent.KEY_DOWN:
						switch((e as KeyboardEvent).keyCode) {
							case Keyboard.BACKQUOTE:
								_isDebug = !_isDebug;
								if(_isDebug) {
									this.dispatchEvent(new DebugEvent(DebugEvent.ENTER_DEBUG));
								} else {
									this.dispatchEvent(new DebugEvent(DebugEvent.EXIT_DEBUG));
								}
								break;
						}
						break;
				}
			}
		}
		
		/**
		 * Setup main event handlers.
		 * All declaration of event handlers should be done here.
		 * Exception: update loop and render loop.
		 */
		protected function setupEventListeners():void
		{
			this.mainWindow.addEventListener(Event.ACTIVATE, handleEvents);
			this.mainWindow.addEventListener(Event.DEACTIVATE, handleEvents);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, handleEvents);
		}
		
		////////////////////////////////////////////
		// Accessors and Mutators
		////////////////////////////////////////////
		/**
		 * Get StateManager.
		 * @return StateManager of the App instance.
		 */
		public function get stateManager():StateManager
		{
			return _stateManager;
		}
		
		/**
		 * Get AudioManager.
		 * @return AudioManager of the App instance.
		 */
		public function get audioManager():AudioManager
		{
			return _audioManager;
		}
		/**
		 * Get SoundManager.
		 * @return SoundManager of the App instance.
		 */
		public function get soundManager():SoundManager
		{
			return _soundMgr;
		}		
		
		/**
		 * Get tree monitor.
		 * @return Tree Monitor of the App instance.
		 */
		public function get treeMonitor():TreeMonitor
		{
			return _treeMonitor;
		}
		
		/**
		 * Get the canvas.
		 * Canvas is the main container of all DisplayObjects. Use this
		 * instead of stage.
		 * @return The canvas.
		 */
		public function get canvas():Sprite
		{
			return _canvas;
		}
		
		/**
		 * Get the "always on top" layer.
		 * Any DisplayObject added to this layer will appear on top of
		 * all DisplayObject in the canvas.
		 * @return The "always on top" layer.
		 */
		public function get alwaysOnTopLayer():Sprite
		{
			return _alwaysOnTopLayer;
		}

		/** A reference to the main window. */
		public function get mainWindow():NativeWindow
		{
			return _mainWindow;
		}

		/** Indicates whether this App instance is running. */
		public function get isRunning():Boolean
		{
			return _isRunning;
		}

		public function get frameTime():int
		{
			return _frameTime;
		}
	}
}