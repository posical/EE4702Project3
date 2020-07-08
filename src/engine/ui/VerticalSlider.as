package engine.ui
{
	import engine.events.MuteButtonEvent;
	import engine.utils.Color;
	
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	
	public class VerticalSlider extends Sprite
	{
		private var _value:Number;
		private var _unit:Number;
		private var _minValue:Number;
		private var _maxValue:Number;
		
		private var _slideL:Shape;
		private var _slideR:Shape;
		private var _knob:Shape;
		private var _valueText:TextField;
		private var _labelText:TextField;
		
		private var _isKnobClicked:Boolean;
		private var _isDisabled:Boolean;
		
		public function VerticalSlider(label:String = "Slider", defaultValue:Number = 50.0,
									   unit:Number = 1.0, min:Number = 0.0, max:Number = 100.0)
		{
			super();
			
			_value = defaultValue;
			_unit = unit;
			_minValue = min;
			_maxValue = max;
			_isKnobClicked = false;
			_isDisabled = false;
			
			_slideL = new Shape();
			var gradientBoxMatrix:Matrix = new Matrix(); 
			gradientBoxMatrix.createGradientBox(100, 10, 0, 0, 0);
			_slideL.graphics.lineStyle(1.0);
			_slideL.graphics.beginGradientFill(GradientType.LINEAR, [Color.RED, Color.YELLOW, Color.LIME], [1.0, 1.0, 1.0], [0, 76, 255],
				gradientBoxMatrix, SpreadMethod.REFLECT);
			_slideL.graphics.drawRect(0, 0, 100, 10);
			_slideL.graphics.endFill();
			_slideL.x = 0;
			_slideL.y = -100;
			_slideL.rotation = 90;
			this.addChild(_slideL);
			
			_slideR = new Shape();
			_slideR.graphics.lineStyle(1.0);
			_slideR.graphics.beginGradientFill(GradientType.LINEAR, [Color.RED, Color.YELLOW, Color.LIME], [1.0, 1.0, 1.0], [0, 76, 255],
				gradientBoxMatrix, SpreadMethod.REFLECT);
			_slideR.graphics.drawRect(0, 0, 100, 10);
			_slideR.graphics.endFill();
			_slideR.x = 10;
			_slideR.y = -100;
			_slideR.rotation = 90;
			this.addChild(_slideR);
			
			_knob = new Shape();
			_knob.graphics.beginFill(Color.SILVER);
			_knob.graphics.drawCircle(0, 0, 10);
			_knob.graphics.endFill();
			_knob.graphics.beginFill(Color.BLACK);
			_knob.graphics.drawCircle(0, 0, 5);
			_knob.graphics.endFill();
			_knob.x = 0;
			_knob.y = getKnobY(value);
			this.addChild(_knob);
			
			_valueText = new TextField();
			_valueText.text = _value.toFixed(1);
			_valueText.autoSize = TextFieldAutoSize.LEFT;
			_valueText.x = -10;
			_valueText.y = 10;
			_valueText.selectable = false;
			_valueText.textColor = Color.WHITE;
			this.addChild(_valueText);
			
			_labelText = new TextField();
			_labelText.text = label;
			_labelText.autoSize = TextFieldAutoSize.CENTER;
			_labelText.x = -(_labelText.width/2);
			_labelText.y = -130;
			_labelText.selectable = false;
			_labelText.textColor = Color.WHITE;
			this.addChild(_labelText);
			
			this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			this.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			this.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			this.addEventListener(Event.CHANGE, onChange);
			this.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		}
		
		private function getKnobY(value:Number):Number
		{
			var result:Number = 0;
			
			result = value / _maxValue * _slideL.height;
			result = -result;
			
			return result;
		}
		
		private function onMouseDown(e:MouseEvent):void
		{
			_isKnobClicked = true;
		}
		
		private function onMouseMove(e:MouseEvent):void
		{
			if(!_isDisabled && _isKnobClicked) {
				var newLoc:Number = Math.max(_slideL.y, Math.min(_slideL.y+_slideL.height, e.localY));
				_knob.y += newLoc - _knob.y;
				this.dispatchEvent(new Event(Event.CHANGE));
			}
		}
		
		private function onMouseUp(e:MouseEvent):void
		{
			_isKnobClicked = false;
		}
		
		private function onMouseOut(e:MouseEvent):void
		{
			_isKnobClicked = false;
		}
		
		private function onChange(e:Event):void
		{
			this.value = -(_knob.y * _unit);
			_valueText.text = this.value.toString();
		}
		
		public function stepUp():void
		{
			this.value += _unit;
		}
		
		public function stepDown():void
		{
			this.value -= _unit;
		}
		
		public function get value():Number
		{
			return _value;
		}

		public function set value(value:Number):void
		{
			_value = Math.max(_minValue, Math.min(_maxValue, value));
			_valueText.text = this.value.toFixed(1);
			_knob.y = getKnobY(value);
		}

		public function get isDisabled():Boolean
		{
			return _isDisabled;
		}

		public function set isDisabled(value:Boolean):void
		{
			_isDisabled = value;
		}


	}
}