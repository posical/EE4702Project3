package engine.base
{
	import engine.classes.App;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * <p>
	 * Provides the basic mechanism for a game flow state.
	 * This class should not be used "as it" but to be inherited.
	 * </p><p>
	 * Subclasses should override the following functions:
	 * <ul>
	 * <li>init()</li>
	 * <li>reset()</li>
	 * <li>onEnterFrame(frameTime:Number)</li>
	 * <li>cleanUp()</li>
	 * <li>setupEventListeners()</li>
	 * <li>removeEventListeners()</li>
	 * <li>handleEvents(e:Event)</li>
	 * </ul>
	 * 
	 * Subclasses should also initialize its state id to a unique identifier in
	 * its constructor.
	 * </p>
	 */
	public class State extends Sprite
	{
		/**
		 * The App that the State registered to.
		 */
		protected var _app:App;
		
		/**
		 * The canvas of the State. All graphics should be added here. 
		 */
		protected var _canvas:Sprite;
		
		/**
		 * Indicate whether the State is to be cleaned up.
		 */
		protected var _isToBeCleanedUp:Boolean;
		
		protected var _stateId:String;
		protected var _isPaused:Boolean;
		protected var _isInitialized:Boolean;
		
		/**
		 * Constructor.
		 * @param app The App that this State will be registered to.
		 */
		public function State(app:App)
		{
			super();
			
			trace("State::ctor().");
			
			if(app == null) {
				throw new Error("State::ctor() Bad App reference.");
			}
			_app = app;
			
			_stateId = "Generic State";
			_isPaused = false;
			_isInitialized = false;
			_isToBeCleanedUp = false;
		}
		
		/**
		 * <p>
		 * Add this State to the stage.
		 * </p><p>
		 * This function should not be called directly as it will
		 * be called by StateManager when it is appropriate.
		 * </p>
		 */
		public function addToStage():void
		{
			if(_app == null) {
				throw new Error("State::addToStage() Bad App reference.");
			}
			
			_app.canvas.addChild(this);
			setupEventListeners();
		}
		
		/**
		 * <p>
		 * Remove this State from the stage.
		 * </p><p>
		 * This function should not be called directly as it will
		 * be called by StateManager when it is appropriate.
		 * </p>
		 */
		public function removeFromStage():void
		{
			if(_app == null) {
				throw new Error("State::removeFromStage() Bad App reference.");
			}
			
			_app.canvas.removeChild(this);
			removeEventListeners();
		}
		
		/**
		 * <p>
		 * Initialize the State.
		 * </p><p>
		 * Subclasses should override this function and call its parent counterpart
		 * before any other code.
		 * </p>
		 */
		public function init():void
		{
			if(_isToBeCleanedUp) {
				handleCleanUp();
			}
			
			if(!_isInitialized) {
				_canvas = new Sprite();
				addChild(_canvas);
				_isInitialized = true;
				_isPaused = false;
			}
		}
		
		/**
		 * Deinitialize the State.
		 */
		public function deInit():void
		{
			if(_isInitialized) {
				_isToBeCleanedUp = true;
			}
		}
		
		/**
		 * <p>
		 * Reset the State. Useful for "Try again?" scenario.
		 * </p><p>
		 * Subclasses should override this function to provide its
		 * own mechanism of resetting.
		 * </p>
		 */
		public function reset():void
		{ }
		
		/**
		 * <p>
		 * Pause the State.
		 * </p><p>
		 * Subclasses should override this function and call its parent counterpart
		 * before any other code.
		 * </p>
		 */
		public function pause():void
		{
			trace("State::pause() Pausing State: " + _stateId);
			
			if(!_isPaused) {
				_isPaused = true;
			}
		}
		
		/**
		 * <p>
		 * Resume the State.
		 * </p><p>
		 * Subclasses should override this function and call its parent counterpart
		 * before any other code.
		 * </p>
		 */
		public function resume():void
		{
			trace("State::resume() Resuming State: " + _stateId);
			
			if(_isPaused) {
				_isPaused = false;
			}
		}
		
		/**
		 * <p>
		 * This function will be called when a ENTER_FRAME event occurs.
		 * </p><p>
		 * This function will be called even when the State is paused.
		 * Thus subclasses should provide its own mechanism to deal
		 * with paused and resumed State.
		 * </p>
		 */
		public function onEnterFrame(frameTime:Number):void
		{ }
		
		/**
		 * Calls cleanUp() if there is the need.
		 */
		public function handleCleanUp():void
		{
			if(_isToBeCleanedUp) {
				cleanUp();
				_isToBeCleanedUp = false;
			}
		}
		
		/**
		 * Setup event listeners. Instead of having the assignments of event listeners
		 * scattered, it's better to put all of them here.
		 */
		protected function setupEventListeners():void
		{ }
		
		/**
		 * Remove all event listeners that is previously assigned.
		 */
		protected function removeEventListeners():void
		{ }
		
		/**
		 * <p>
		 * This function should be ideally the event listener for all events.
		 * However, if the function is getting bloated, this function should be
		 * used as a redirection point of the listeners.
		 * </p><p>
		 * For example, handleEvents() will check for a KeyboardEvent and call
		 * handleKeyboardEvents() to handle the event.
		 * </p>
		 */
		protected function handleEvents(e:Event):void
		{ }
		
		/**
		 * <p>
		 * Clean up the State. Real clean up is to be done here.
		 * </p><p>
		 * Subclasses that override this function should call its parent counterpart
		 * as the last statement of this function (after any other code).
		 * </p>
		 */
		protected function cleanUp():void
		{
			_canvas = null;
		}
		
		////////////////////////////////////////////
		// Accessors and Mutators
		////////////////////////////////////////////
		
		/**
		 * The unique identifier of the State.
		 */
		public function get stateId():String
		{
			return _stateId;
		}
		
		/**
		 * Indicate whether the State is paused.
		 */
		public function get isPaused():Boolean
		{
			return _isPaused;
		}
		
		/**
		 * Indicate whether the State is initialized.
		 */
		public function get isInitialized():Boolean
		{
			return _isInitialized;
		}
	}
}