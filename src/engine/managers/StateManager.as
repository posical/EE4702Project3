package engine.managers
{
	import engine.base.State;
	import engine.classes.App;
	
	import flash.events.EventDispatcher;
	
	/**
	 * Provides the mechanism of a Finite State Machine for game states.
	 * StateManager will control the flow of each different States.
	 */
	public class StateManager extends EventDispatcher
	{
		private var _app:App;
		private var _states:Vector.<State>;
		private var _deadStates:Vector.<State>;
		
		/**
		 * Constructor.
		 */
		public function StateManager()
		{
			trace("StateManager::ctor().");
			
			_states = new Vector.<State>();
			_deadStates = new Vector.<State>();
		}
		
		/**
		 * Register this manager to primary App.
		 * @param app A reference to the primary App.
		 */
		public function registerApp(app:App):void
		{
			if(app != null) {
				_app = app;
			} else {
				throw new Error("StateManager::registerApp() Bad app reference.");
			}
		}
		
		/**
		 * Add an active State.
		 * Add a State and set it to be active. Only the active State
		 * will be added to stage. Active stage will be initialized.
		 * Current active State will be paused and removed from stage, if any.
		 * @state The State that is added to be the active State.
		 */
		public function addActiveState(state:State):void
		{
			if(state == null) {
				throw new Error("StateManager::addActiveState() Attempt to add null State.");
			}
			
			if(!isEmpty()) {
				_states[_states.length-1].pause();
				_states[_states.length-1].removeFromStage();
			}
			
			trace("StateManager::addActiveState() Adding State: " + state.stateId);
			
			_states.push(state);
			_states[_states.length-1].init();
			_states[_states.length-1].addToStage();
		}
		
		/**
		 * Add an inactive State.
		 * Add a State without setting it to be active. This will add the 
		 * State to the bottom of the State stack without initialization.
		 * @state The State that is added to be an inactive State.
		 */
		public function addInactiveState(state:State):void
		{
			if(state == null) {
				throw new Error("StateManager::addInactiveState() Attempt to add null State.");
			}
			
			trace("StateManager::addInactiveState() Adding State: " + state.stateId);
			
			_states.splice(0, 0, state);
		}
		
		/**
		 * Deactivate current active State.
		 * This will pause the current active State and move it to the bottom
		 * of the stack. The current top State will be set as the active State.
		 * @deInit true to deinitialize the State as well.
		 */
		public function deactivateActiveState(deInit:Boolean = false):void
		{
			if(isEmpty()) {
				trace("StateManager::deactivateActiveState() No State.");
				_app.quit(App.STATUS_NO_STATE);
				return;
			}
			
			// Deactivate active State
			var curr:State = _states.pop();
			trace("StateManager::deactivateActiveState() Deactivating State: " + curr.stateId);
			curr.pause();
			curr.removeFromStage();
			
			if(deInit) {
				curr.deInit();
			}
			_states.splice(0, 0, curr);
			curr = null;
			
			// Activate previous available State
			trace("StateManager::deactivateActiveState() Activating previous available State, if any...");
			if(!isEmpty()) {
				curr = _states[_states.length-1];
				if(curr.isInitialized) {
					curr.resume();
				} else {
					curr.init();
				}
				curr.addToStage();
			} else {
				trace("StateManager::deactivateActiveState() No previous State.");
				_app.quit(App.STATUS_OK);
			}
		}
		
		/**
		 * Remove current active State.
		 * This will pause, deinitialize and remove the current active State from
		 * the stack. It will be clean up when handleCleanUp() is called.
		 * The current top State will be set as the active State.
		 */
		public function removeActiveState():void
		{
			if(isEmpty()) {
				trace("StateManager::removeActiveState() No State.");
				_app.quit(App.STATUS_NO_STATE);
				return;
			}
			
			// Remove active State and store it to _deadStates
			var curr:State = _states.pop();
			trace("StateManager::removeActiveState() Removing State: " + curr.stateId);
			curr.pause();
			curr.removeFromStage();
			curr.deInit();
			_deadStates.push(curr);
			curr = null;
			
			// Activate previous available State
			trace("StateManager::removeActiveState() Activating previous available State, if any...");
			if(!isEmpty()) {
				curr = _states[_states.length-1];
				if(curr.isInitialized) {
					curr.resume();
				} else {
					curr.init();
				}
				curr.addToStage();
			} else {
				trace("StateManager::removeActiveState() No previous State.");
				_app.quit(App.STATUS_OK);
			}
		}
		
		/**
		 * Reset current active State.
		 * This will call reset() of the current active State.
		 */
		public function resetActiveState():void
		{
			if(isEmpty()) {
				trace("StateManager::resetActiveState() No State.");
				_app.quit(App.STATUS_NO_STATE);
				return;
			}
			
			// Reset active State
			var curr:State = _states[_states.length-1];
			trace("StateManager::resetActiveState() Resetting State: " + curr.stateId);
			curr.pause();
			curr.reset();
			curr.resume();
			curr = null;
		}
		
		/**
		 * Set a particular State to be active.
		 * If found, the State with stateId will be set as the active State.
		 * @param stateId The id of the State to be activated.
		 */
		public function setActiveState(stateId:String):void
		{
			if(isEmpty()) {
				trace("StateManager::setActiveState() No State.");
				_app.quit(App.STATUS_NO_STATE);
				return;
			}
			
			// Iterate _states to find the State
			for(var i:uint = 0; i < _states.length; ++i) {
				if(_states[i].stateId == stateId) {
					trace("StateManager::setActiveState() Setting active State: " + _states[i].stateId);
					var newActiveState:State = _states[i];
					_states.splice(i, 1);
					
					// Pause current active State
					if(!isEmpty()) {
						_states[_states.length-1].pause();
						_states[_states.length-1].removeFromStage();
					}
					
					// Activate new active State
					_states.push(newActiveState);
					var curr:State = _states[_states.length-1];
					if(curr.isInitialized) {
						curr.resume();
					} else {
						curr.init();
					}
					curr.addToStage();
					curr = null;
					break;
				}
			}
		}
		
		/**
		 * Handle clean up.
		 * This will clean up removed State from memory.
		 */
		public function handleCleanUp():void
		{
			if(_deadStates.length > 0) {
				// Remove only one State per call, basically to distribute the processing time
				var curr:State = _deadStates.pop();
				
				if(curr.isInitialized) {
					curr.deInit();
				}
				curr.handleCleanUp();
				curr = null;
			}
		}
		
		/**
		 * Get the current active State.
		 * @return Currently active State.
		 */
		public function getActiveState():State
		{
			if(isEmpty()) {
				trace("StateManager::getActiveState() No State.");
				_app.quit(App.STATUS_NO_STATE);
				return null;
			}
			
			return _states[_states.length-1];
		}
		
		/**
		 * Check if the State stack is empty.
		 * @return true if no State, otherwise false.
		 */
		private function isEmpty():Boolean
		{
			return (_states.length == 0);
		}
	}
}