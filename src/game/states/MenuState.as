package game.states
{
	import engine.base.State;
	import engine.classes.App;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.net.URLRequest;
	import flash.text.*;
	import flash.ui.Keyboard;

	/**
	 * A State for main menu screen.
	 */
	public class MenuState extends State
	{
		private var _menuImage:Loader;
		
		public function MenuState(app:App)
		{
			super(app);
			
			_stateId = "Menu";
		}
		
		public override function init():void
		{
			super.init();
			
			_menuImage = new Loader();
			_menuImage.load(new URLRequest("images/menu.png"));
			_canvas.addChild(_menuImage);
		}
		
		public override function resume():void
		{
			super.resume();
		}
		
		public override function reset():void
		{ }
		
		public override function onEnterFrame(frameTime:Number):void
		{
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
				}
			}
		}
	}
}