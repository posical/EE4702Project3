package engine.ui
{
	import engine.utils.Color;
	
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	/**
	 * A simple implementation of a normal button.
	 */
	public class Button extends SimpleButton
	{
		protected var _width:Number;
		protected var _height:Number;
		
		protected var _upColor:int;
		protected var _downColor:int;
		protected var _hoverColor:int;
		
		protected var _state:String;
		
		protected var _buttonText:String;
		
		/**
		 * Constructor.
		 * @param text The text that appears on the button.
		 */
		public function Button(text:String = "")
		{
			super();
			
			_width = 0;
			_height = 0;
			
			_upColor = Color.LIME;
			_downColor = Color.TEAL;
			_hoverColor = Color.SILVER;
			
			this.useHandCursor = true;
			
			_buttonText = (text == "") ? "Button" : text;
		}
		
		/**
		 * Draw the Sprite for each button state.
		 */
		protected function draw():void
		{
			this.downState = createSprite(_downColor);
			this.upState = this.hitTestState = createSprite(_upColor);
			this.overState = createSprite(_hoverColor);
		}
		
		/**
		 * Create the Sprite for a button state.
		 * @param color The background color of the button.
		 * @return A sprite with <code>color</code> and button text on top of it.
		 */
		protected function createSprite(color:int):Sprite
		{
			var sprite:Sprite = new Sprite();
			sprite.graphics.beginFill(color);
			sprite.graphics.drawRoundRect(0, 0, _width, _height, 10);
			sprite.graphics.endFill();
			var text:TextField = createLabel();
			text.x = Math.round(sprite.width * 0.5 - text.width * 0.5);
			text.y = Math.round(sprite.height * 0.5 - text.height * 0.5);
			sprite.addChild(text);
			return sprite;
		}
		
		/**
		 * Create the label for button text.
		 * @return A textfield consisting button text.
		 */
		protected function createLabel():TextField
		{
			var label:TextField = new TextField();
			label.selectable = false;
			label.mouseEnabled = false;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.text = _buttonText;
			return label;
		}
		
		////////////////////////////////////////////
		// Accessors and Mutators
		////////////////////////////////////////////
		
		/**
		 * The text that appears on the button.
		 */
		public function get buttonText():String
		{
			return _buttonText;
		}
		
		public function set buttonText(text:String):void
		{
			_buttonText = text;
		}
		
		/**
		 * The width of the button.
		 * Changing this value will force the Sprite of its button states
		 * to be redrawn.
		 */
		public override function get width():Number
		{
			return _width;
		}
		
		public override function set width(value:Number):void
		{
			_width = value;
			draw();
		}
		
		/**
		 * The width of the button.
		 * Changing this value will force the Sprite of its button states
		 * to be redrawn.
		 */
		public override function get height():Number
		{
			return _height;
		}
		
		public override function set height(value:Number):void
		{
			_height = value;
			draw();
		}
	}
}