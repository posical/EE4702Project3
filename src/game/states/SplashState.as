package game.states
{
	import engine.base.State;
	import engine.classes.App;
	import engine.utils.Clock;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.net.URLRequest;
	import flash.ui.Keyboard;

	/**
	 * A State for the initial splash screen.
	 */
	public class SplashState extends State
	{
		protected static const DEFAULT_SPLASH_TIME:Number = 5000;
		
		private var _splashImage:Loader;
		private var _splashClock:Clock;
		private var _splashTime:uint;
		
		public function SplashState(app:App)
		{
			super(app);
			
			_stateId = "Splash";
		}
		
		public override function init():void
		{
			super.init();
			
			_splashImage = new Loader();
			_splashImage.load(new URLRequest("images/splash.png"));
			_canvas.addChild(_splashImage);
			
			_splashTime = DEFAULT_SPLASH_TIME;
			
			_splashClock = new Clock();
			_splashClock.reset();
		}
		
		public override function reset():void
		{ }
		
		public override function onEnterFrame(frameTime:Number):void
		{
			if(!_isPaused) {
				if(_splashClock.getElapsedTime() < _splashTime) {
					_splashImage.alpha = Math.sin(_splashClock.getElapsedTime() / _splashTime * Math.PI);
				} else {
					_app.stateManager.removeActiveState();
				}
			}
		}
		
		protected override function cleanUp():void
		{
			super.cleanUp();
		}
		
		protected override function setupEventListeners():void
		{
			_app.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleEvents);
		}
		
		protected override function removeEventListeners():void
		{
			_app.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleEvents);
		}
		
		protected override function handleEvents(e:Event):void
		{
			if(e.type === KeyboardEvent.KEY_DOWN) {
				switch((e as KeyboardEvent).keyCode) {
					case Keyboard.ESCAPE:
						_app.quit(App.STATUS_OK);
						break;
					case Keyboard.ENTER:
						_app.stateManager.removeActiveState();
						break;
				}
			}
		}
		
		////////////////////////////////////////////
		// Accessors and Mutators
		////////////////////////////////////////////
		/**
		 * The length of time duration for splash screen.
		 */
		public function get splashTime():Number
		{
			return _splashTime;
		}
		
		public function set splashTime(time:Number):void
		{
			_splashTime = Math.max(time, 0);
		}
	}
}