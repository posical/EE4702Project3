package engine.audio.visualizers
{
	import engine.audio.SoundBuffer;
	import engine.utils.Color;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	
	public class SoundBufferVisualizer extends Sprite
	{
		private var _buffer:SoundBuffer;
		private var _fileName:TextField;
		
		public function SoundBufferVisualizer(buffer:SoundBuffer)
		{
			super();
			
			_buffer = buffer;
			draw();
		}
		
		private function draw():void
		{
			_fileName = new TextField();
			_fileName.text = _buffer.fileName;
			this.addChild(_fileName);
		}
	}
}