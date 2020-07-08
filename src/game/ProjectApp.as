package game
{
	import engine.classes.App;
	
	import game.states.*;
	
	/**
	 * The main App for this project. Only State initializations have to be done in this class.
	 */
	public class ProjectApp extends App
	{
		/**
		 * Constructor.
		 * @param title The title of main window.
		 */
		public function ProjectApp(title:String="Project Application")
		{
			super(title);
		}
		
		/**
		 * State initializations.
		 */
		protected override function init():void
		{
			this.stateManager.addActiveState(new SplashState(this));
//			this.stateManager.addInactiveState(new MenuState(this));
			this.stateManager.addInactiveState(new TestState(this));
//			this.stateManager.addActiveState(new TestSoundState(this));
//			this.stateManager.addActiveState(new NewWorldState(this));

		}
	}
}