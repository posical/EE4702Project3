
package engine.console
{
	import engine.base.State;
	import engine.classes.App;
	
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	
	public class LogConsole extends Sprite// implements IUpdateable
	{
		private var consoleHotKey:uint = 192;
		private var consoleToggle:Boolean = false;
		
		private var output:TextField = new TextField;
		
		private var app:App;
		private var state:State;
			
		public function LogConsole(app:App, state:State)
		{
			super();
			
			this.app = app;
			this.state = state;
			var format:TextFormat = new TextFormat("Helvetica", 12, 0x000000, true);
			
			
			output.defaultTextFormat = format;
			output.type = TextFieldType.DYNAMIC;
			output.autoSize = TextFieldAutoSize.NONE;
			output.background = true;
			output.backgroundColor = 0x696969;
			output.multiline = true;
			output.width = app.stage.stageWidth * 0.3;
			output.height = app.stage.stageHeight - 216 +40;//game.stage.stageHeight*0.2 - input.height;
			output.selectable = false;
			output.mouseWheelEnabled = true;
			output.alpha = 0.8;
			output.wordWrap = true;
			addChild(output);
			
			this.y = 88;//app.stage.stageHeight - this.height;
			
			app.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		public function changeParameters(x:Number,y:Number,width:Number,height:Number,
										 alpha:Number,textColor:uint,hotKey:uint):void
		{
			this.x = x;
			this.y = y;
			output.width = width;
			output.height = height;
			output.alpha = alpha;
			output.textColor = textColor;
			consoleHotKey = hotKey;
		}
		
		public function log(str:String):void
		{
			output.appendText(str + "\n");
			output.scrollV = output.maxScrollV;
		}
		
		public function onKeyUp(e:KeyboardEvent):void
		{
			if (e.keyCode == consoleHotKey)
			{
				consoleToggle = !consoleToggle;
				if (consoleToggle)
				{
					state.addChild(this);
				}
				else
				{
					state.removeChild(this);
				}
			}
			
		}
		
		
		public function clear():String
		{
			output.text = "";
			return "";
		}
	}
}
		
		
		
		
		
		
		
		
		
		
		
		
		
		
