package game.states
{
	import engine.audio.*;
	import engine.base.State;
	import engine.classes.App;
	import engine.ui.VerticalSlider;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	public class TestSoundState extends State
	{
		public function TestSoundState(app:App)
		{
			super(app);
			
			_stateId = "Test Sound State";
		}
		
		public override function init():void
		{
			super.init();
			
			var options:NonPositionalSoundInitOptions = new NonPositionalSoundInitOptions();
			options.isLooping = true;
//			options.fileName = "/sounds/music001.mp3";
			var s:IPlayable;
			for(var i:int = 0; i < 12; ++i) {
				if(i < 5)
					options.fileName = "/sounds/Diag0" + (i+1) + ".mp3";
				else
					options.fileName = "/sounds/Diag" + (i+6) + ".mp3";
//				options.busId = i % 2;
				s = _app.audioManager.createNonPositionalSound(options);
				_app.audioManager.addSoundToBus(s, options.busId);
				s.load();
				s.play();
			}
		}
		
		public override function reset():void
		{
			
		}
		
		public override function onEnterFrame(frameTime:Number):void
		{
			
		}
		
		protected override function cleanUp():void
		{
			
		}
		
		protected override function setupEventListeners():void
		{
			_app.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleEvents);
			_app.stage.addEventListener(KeyboardEvent.KEY_UP, handleEvents);
		}
		
		protected override function removeEventListeners():void
		{
			_app.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleEvents);
			_app.stage.removeEventListener(KeyboardEvent.KEY_UP, handleEvents);
		}
		
		protected override function handleEvents(e:Event):void
		{
			if(e.type === KeyboardEvent.KEY_DOWN) {
				switch((e as KeyboardEvent).keyCode) {
					case Keyboard.ESCAPE:
						_app.stateManager.removeActiveState();
						break;
					
					case Keyboard.W:
						break;
					case Keyboard.A:
						break;
					case Keyboard.S:
						break;
					case Keyboard.D:
						break;
					case Keyboard.Z:
				}
			}
			
			if(e.type === KeyboardEvent.KEY_UP) {
				switch((e as KeyboardEvent).keyCode) {
					case Keyboard.W:
					case Keyboard.S:
					case Keyboard.A:
					case Keyboard.D:
						break;
				}
			}
		}
	}
}