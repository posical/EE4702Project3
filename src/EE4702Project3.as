package
{
	import engine.events.AppQuitEvent;
	
	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	
	import game.ProjectApp;
	
	[SWF(width="800", height="600", frameRate="60", backgroundColor="#FFFFFF")]
	/**
	 * Document class for EE4702 Project 3 - World Simulation.
	 */
	public class EE4702Project3 extends Sprite
	{
		/** Primary App, only one App is allowed. */
		private var _app:ProjectApp;
		
		/**
		 * Constructor.
		 */
		public function EE4702Project3()
		{
			_app = new ProjectApp("EE4702 Project 3 - World Simulation");
			stage.addChild(_app);
			_app.addEventListener(AppQuitEvent.QUIT, onQuit);
			
			_app.run();
		}
		
		/**
		 * Event handler for AppQuitEvent by App.
		 * Exit this program with exit code by App.
		 * @param e AppQuitEvent fired by App instance.
		 */
		private function onQuit(e:AppQuitEvent):void
		{
			trace("Quitting EE4702Project3 with exitCode: " + e.exitCode);
			_app = null;
			
			NativeApplication.nativeApplication.exit(e.exitCode);
		}
	}
}