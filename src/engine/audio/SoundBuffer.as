package engine.audio
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	public class SoundBuffer extends EventDispatcher
	{
		private var _sound:Sound;
		private var _fileName:String;
		private var _isLoaded:Boolean;
		private var _numInstance:int;
		
		public function SoundBuffer(fileName:String, load:Boolean = false, target:IEventDispatcher=null)
		{
			super(target);
			
			_fileName = fileName;
			_isLoaded = false;
			_numInstance = 0;
			
			if(load) {
				this.load(fileName);
			}
		}
		
		public function load(fileName:String = ""):void
		{
			_fileName = (fileName != "") ? fileName : _fileName;
			
			if(_fileName != "") {
				_sound = new Sound(new URLRequest(_fileName));
				_sound.addEventListener(Event.COMPLETE, onLoadComplete);
				_sound.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
			} else {
				trace("[WARNING] SoundBuffer::load() Attempt to load sound with empty filename.");
			}
		}
		
		public function getBuffer(buffer:ByteArray, cursor:uint, rewind:Boolean = true, size:uint = SoundDef.BUFFER_SIZE):int
		{
			var i:int;
			var len:int = 0;
			
			buffer.position = 0;
			if(_isLoaded) {
				len = _sound.extract(buffer, size, cursor);
				
				if(len < size) {
					if(rewind) {
						_sound.extract(buffer, size-len, 0);
					}
				}
			} else {
				for(i = 0; i < size; ++i) {
					buffer.writeFloat(0);
					buffer.writeFloat(0);
				}
				len = size;
			}
			buffer.position = 0;
			
			return size-len;
		}
		
		public function addReference():void
		{
			_numInstance++;
		}
		
		public function removeReference():void
		{
			--_numInstance;
			
			if(_numInstance < 0) {
				throw new Error("SoundBuffer::removeInstance() Over removing reference of " + _fileName);
			} else if(_numInstance == 0) {
				// TODO: unloading
			}
		}
		
		private function onLoadComplete(e:Event):void
		{
			_sound.removeEventListener(Event.COMPLETE, onLoadComplete);
			_isLoaded = true;
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function onIoError(e:IOErrorEvent):void
		{
			trace(e.text);
		}
		
		public function get isLoaded():Boolean
		{
			return _isLoaded;
		}
		
		public function get numInstance():int
		{
			return _numInstance;
		}
		
		public function get fileName():String
		{
			return _fileName;
		}
	}
}