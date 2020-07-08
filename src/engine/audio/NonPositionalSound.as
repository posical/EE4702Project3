package engine.audio
{
	import engine.utils.Clock;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	public class NonPositionalSound extends EventDispatcher implements INonPositionalSound
	{
		private var _options:NonPositionalSoundInitOptions;
		private var _isInitialized:Boolean;
		private var _isLoaded:Boolean;
		private var _isPlaying:Boolean;
		private var _isPaused:Boolean;
		private var _isWaitingToBePlayed:Boolean;
		
		private var _timeToBePlayed:uint;
		private var _deadLineClock:Clock;
		
		private var _theSound:Sound;
		private var _buffer:ByteArray;
		
		private var _soundBuffer:SoundBuffer;
		
		public function NonPositionalSound(options:NonPositionalSoundInitOptions = null, target:IEventDispatcher = null)
		{
			super(target);
			
			_deadLineClock = new Clock();
			_buffer = new ByteArray();
			
			init(options);
		}
		
		public function init(options:NonPositionalSoundInitOptions):Boolean
		{
			_options = new NonPositionalSoundInitOptions();
			if(options) {
				_options.copyFrom(options);
				_isInitialized = true;
				
				_isPlaying = false;
				_isPaused = false;
				_isWaitingToBePlayed = false;
				_isLoaded = false;
			}
			return true;
		}
		
		public function onUpdate():void
		{
			if(_isWaitingToBePlayed) {
				if(_deadLineClock.getElapsedTime() > _timeToBePlayed) {
					this.stop();
				}
			}
		}
		
		public function get properties():NonPositionalSoundProperties
		{
			return _options.properties;
		}
		
		public function set properties(value:NonPositionalSoundProperties):void
		{
			if(value) {
				_options.properties = value;
			}
		}
		
		public function get volume():Number
		{
			return _options.properties.volume;
		}
		
		public function set volume(value:Number):void
		{
			_options.properties.volume = value;
		}
		
		public function get pan():Number
		{
			return _options.properties.pan;
		}
		
		public function set pan(value:Number):void
		{
			_options.properties.pan = value;
		}
		
		public function get readCursor():int
		{
			return _options.properties.readCursor;
		}
		
		public function set readCursor(value:int):void
		{
			_options.properties.readCursor = Math.max(0, value);
		}
		
		public function play():Boolean
		{
			if(!_isPlaying) {
				_isPlaying = true;
				_isPaused = false;
				_isWaitingToBePlayed = false;
				return true;
			}
			return false;
		}
		
		public function playByDeadline(time:uint):Boolean
		{
			if(!_isWaitingToBePlayed && !_isPlaying && !_isPaused) {
				_timeToBePlayed = time;
				_deadLineClock.reset();
				_isWaitingToBePlayed = true;
				return true;
			}
			return false;
		}
		
		public function pause():Boolean
		{
			if(_isPlaying && !_isPaused) {
				_isPaused = true;
				_isPlaying = false;
				_isWaitingToBePlayed = false;
				return true;
			}
			return false;
		}
		
		public function stop():Boolean
		{
			_isPlaying = false;
			_isPaused = false;
			_isWaitingToBePlayed = false;
			_options.properties.readCursor = 0;
			return true;
		}
		
		public function get isPlaying():Boolean
		{
			return _isPlaying;
		}
		
		public function get isPaused():Boolean
		{
			return _isPaused;
		}
		
		public function get isLooping():Boolean
		{
			return _options.isLooping;
		}
		
		public function get isWaitingToBePlayed():Boolean
		{
			return _isWaitingToBePlayed;
		}
		
		public function destroy():void
		{
		}
		
		public function load():Boolean
		{
			_soundBuffer = AudioManager.getAudioManager().getSoundBuffer(_options.fileName, true);
			_soundBuffer.addEventListener(Event.COMPLETE, onLoadComplete);
			_soundBuffer.addReference();
			return true;
		}
		
		public function unload():Boolean
		{
			if(_soundBuffer) {
				_soundBuffer.removeReference();
			}
			return true;
		}
		
		protected function onLoadComplete(e:Event):void
		{
			_soundBuffer.removeEventListener(Event.COMPLETE, onLoadComplete);
			_isLoaded = true;
		}
		
		public function getBuffer(bufferSize:int):ByteArray
		{
			_buffer.position = 0;
			var i:int;
			if(_isLoaded && _isPlaying) {
				var len:int = _soundBuffer.getBuffer(_buffer, _options.properties.readCursor, isLooping, bufferSize);
				_options.properties.readCursor += bufferSize;
				
				if(len > 0) {
					if(isLooping) {
						_options.properties.readCursor = len;
					} else {
						this.stop();
					}
				}
			} else {
				for(i = 0; i < bufferSize; ++i) {
					_buffer.writeFloat(0);
					_buffer.writeFloat(0);
				}
			}
			_buffer.position = 0;
			
			return _buffer;
		}
		
		public function get isInitialized():Boolean
		{
			return _isInitialized;
		}
		
		public function get isLoaded():Boolean
		{
			return _isLoaded;
		}
		
		public function get options():Object
		{
			return (_options as Object);
		}
	}
}