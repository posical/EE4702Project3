package engine.audio.visualizers
{
	import engine.audio.Bus;
	import engine.events.BusEvent;
	import engine.ui.ToggleButton;
	import engine.ui.VerticalSlider;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class BusVisualizer extends Sprite
	{
		private var _bus:Bus;
		private var _canvas:Sprite;
		private var _slider:VerticalSlider;
		private var _childVisualizers:Vector.<BusVisualizer>;
		private var _muteButton:ToggleButton;
		
		public function BusVisualizer(bus:Bus)
		{
			super();
			
			_bus = bus;
			_bus.addEventListener(BusEvent.VOLUME_CHANGE, onVolumeChange);
			_canvas = new Sprite();
			this.addChild(_canvas);
			
			_childVisualizers = new Vector.<BusVisualizer>();
			
			_slider = new VerticalSlider(bus.name, _bus.volume*100, 1, 0, 100);
			_slider.x = 10;
			_slider.y = 150;
			_slider.addEventListener(Event.CHANGE, onSliderChange);
			_canvas.addChild(_slider);
			
			_muteButton = new ToggleButton("Mute");
			_muteButton.width = 40;
			_muteButton.height = 25;
			_muteButton.x = -10;
			_muteButton.y = _slider.height + 30;
			_muteButton.addEventListener(MouseEvent.CLICK, onMuteButtonClicked);
			_canvas.addChild(_muteButton);
		}
		
		private function onVolumeChange(e:BusEvent):void
		{
			if(e.type == BusEvent.VOLUME_CHANGE) {
				_slider.value = _bus.volume * 100.0;
			}
		}
		
		public function changeSliderValue(change:Number):void
		{
			_slider.value += change;
			_bus.volume += change / 100.0;
			
			for each(var vis:BusVisualizer in _childVisualizers) {
				vis.changeSliderValue(change);
			}
		}
				
		private function onSliderChange(e:Event):void
		{
			var change:Number = _slider.value - _bus.volume * 100.0;
			this.changeSliderValue(change);
		}
		
		private function onMuteButtonClicked(e:MouseEvent):void
		{
			if(_muteButton.isSelected) {
				mute();
			} else {
				unmute();
			}
		}
		
		public function addChildVisualizer(vis:BusVisualizer):void
		{
			if(vis) {
				_childVisualizers.push(vis);
			}
		}
		
		public function mute():void
		{
			_bus.mute();
			_slider.isDisabled = true;
			_slider.value = 0;
			
			for each(var vis:BusVisualizer in _childVisualizers) {
				if(!vis.isMute) {
					vis.mute();
				}
			}
		}
		
		public function unmute():void
		{
			_bus.unmute();
			_slider.isDisabled = false;
			_slider.value = _bus.volume * 100.0;
				
			for each(var vis:BusVisualizer in _childVisualizers) {
				if(!vis.isMute) {
					vis.unmute();
				}
			}
		}
		
		public function get isMute():Boolean
		{
			return _muteButton.isSelected;
		}

	}
}