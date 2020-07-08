package engine.ui
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	
	/**
	 * A simple implementation of a toggle button.
	 */
	public class ToggleButton extends Button
	{
		protected var _isSelected:Boolean;
		
		/**
		 * Constructor.
		 * @param text The text that appears on the button.
		 */
		public function ToggleButton(text:String = "")
		{
			super(text);
			
			_isSelected = false;
			
			this.addEventListener(MouseEvent.CLICK, onMouseClick);
		}
		
		/**
		 * Toggle the button.
		 */
		public function toggleButton():void
		{
			var temp:DisplayObject = this.upState;
			this.upState = this.downState;
			this.downState = temp;
			_isSelected = !_isSelected;
		}
		
		/**
		 * Event handler for MouseEvent.CLICK
		 */
		protected function onMouseClick(e:MouseEvent):void
		{
			toggleButton();
		}
		
		////////////////////////////////////////////
		// Accessors and Mutators
		////////////////////////////////////////////
		
		/**
		 * Indicate whether this button is selected (down).
		 */
		public function get isSelected():Boolean
		{
			return _isSelected;
		}
	}
}