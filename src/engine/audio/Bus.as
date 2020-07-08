package engine.audio
{
	import engine.events.BusEvent;
	
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.SampleDataEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.ByteArray;
	
	public class Bus extends EventDispatcher
	{
		public static const KILL_NEWEST:int = 0;
		public static const KILL_OLDEST:int = 1;
		public static const KILL_RANDOM:int = 2;
		public static const KILL_LOWEST_PRIORITY:int = 3;
		
		protected var _isPlaying:Boolean;
		protected var _isPaused:Boolean;
		protected var _isMute:Boolean;
		
		protected var _childBuses:Vector.<Bus>;
		protected var _managedSound:Vector.<IPlayable>;
		
		protected var _outputSound:Sound;
		protected var _channel:SoundChannel;
		protected var _soundTransform:SoundTransform;
		protected var _volumeBeforeMute:Number;
		protected var _busId:int;
		
		protected var _name:String;
		protected var _volume:Number;
		
		protected var _killStrategy:int;
		protected var _maxConcurrentSound:int;
		
		public function Bus(busId:int = -1, name:String = "Default Bus", target:IEventDispatcher=null)
		{
			super(target);
			
			refreshOutputSound();
			
			_isPlaying = false;
			_isPaused = false;
			_isMute = false;
			_name = name;
			_volume = 1.0;
			
			_busId = busId;
			_soundTransform = new SoundTransform();
			_managedSound = new Vector.<IPlayable>();
			_childBuses = new Vector.<Bus>();
			
			_killStrategy = KILL_LOWEST_PRIORITY;
			_maxConcurrentSound = 10;
		}
		
		public function addSound(sound:IPlayable):void
		{
			_managedSound.push(sound);
		}
		
		public function removeSound(sound:IPlayable):void
		{
			var index:int = _managedSound.indexOf(sound);
			_managedSound.splice(index, 1);
		}
		
		public function addChildBus(child:Bus):void
		{
			if(_childBuses.indexOf(child) < 0) {
				_childBuses.push(child);
			}
		}
		
		public function removeChildBus(child:Bus):void
		{
			var index:int = _childBuses.indexOf(child);
			
			if(index < 0) {
				_childBuses.splice(index, 1);
			}
		}
		
		public function play():void
		{
			if(!_isPlaying) {
				if(_outputSound == null) {
					var success:Boolean = refreshOutputSound();
					if(!success) {
						trace("Bus::play() Unable to request output rights from AudioManager.");
						return;
					}
				}
				
				if(_channel) {
					_channel.removeEventListener(Event.SOUND_COMPLETE, onSoundFinished);
				}
				_channel = _outputSound.play();
				_channel.addEventListener(Event.SOUND_COMPLETE, onSoundFinished);
				_isPlaying = true;
				_isPaused = false;
				
				// Play all children
				for each(var child:Bus in _childBuses) {
					child.play();
				}
			}
		}
		
		public function pause():void
		{
			if(_isPlaying && !_isPaused) {
				_isPlaying = false;
				_isPaused = true;
				
				for each(var sound:IPlayable in _managedSound) {
					sound.pause();
				}
				
				// Pause all children
				for each(var child:Bus in _childBuses) {
					child.pause();
				}
			}
		}
		
		public function stop():void
		{
			if(_channel) {
				_channel.stop();
				_isPlaying = false;
				_isPaused = false;
				
				AudioManager.getAudioManager().releaseOutputSound(_outputSound);
				_outputSound = null;
				_outputSound.removeEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
				_channel.removeEventListener(Event.SOUND_COMPLETE, onSoundFinished);
				_channel = null;
				
				// Stop all children
				for each(var child:Bus in _childBuses) {
					child.stop();
				}
			}
		}
		
		public function mute():void
		{
			_isMute = true;
			_volumeBeforeMute = _soundTransform.volume;
			changeVolume(0);
		}
		
		public function unmute():void
		{
			_isMute = false;
			changeVolume(_volumeBeforeMute);
		}
		
		private function changeVolume(value:Number):void
		{
			_soundTransform.volume = Math.max(0.0, Math.min(1.0, value));
			_channel.soundTransform = _soundTransform;
			
			for each(var child:Bus in _childBuses) {
				child.volume = value;
			}
			
			this.dispatchEvent(new BusEvent(BusEvent.VOLUME_CHANGE, _soundTransform.volume));
		}
		
		public function get isPlaying():Boolean
		{
			return _isPlaying;
		}
		
		public function get isPaused():Boolean
		{
			return _isPaused;
		}
		
		public function get busId():int
		{
			return _busId;
		}
		
		public function onUpdate():void
		{ }
		
		protected function prioritySort(obj1:IPlayable, obj2:IPlayable):int
		{
			var result:int = 0;
			var p1:int = 0, p2:int = 0;
			
			if(obj1 is PositionalSound) {
				p1 = (obj1.options as PositionalSoundInitOptions).priority;
			} else {
				p1 = (obj1.options as NonPositionalSoundInitOptions).priority;
			}
			
			if(obj2 is PositionalSound) {
				p2 = (obj2.options as PositionalSoundInitOptions).priority;
			} else {
				p2 = (obj2.options as NonPositionalSoundInitOptions).priority;
			}
			
			result = p1-p2;
			
			return result;
		}
		
		protected function onSampleData(e:SampleDataEvent):void
		{
			var i:int;
			var output:ByteArray;
			var isAdded:Boolean = false;
//			var c:Clock = new Clock();
			
			if(_killStrategy == KILL_LOWEST_PRIORITY) {
				_managedSound.sort(prioritySort);
			}
			
			for(i = 0; i < _managedSound.length && i < _maxConcurrentSound; ++i) {
				if(_managedSound[i].isPlaying) {
					if(!isAdded) {
						output = _managedSound[i].getBuffer(SoundDef.BUFFER_SIZE);
						isAdded = true;
					} else {
						output = this.mixBuffers(_managedSound[i].getBuffer(SoundDef.BUFFER_SIZE), output, SoundDef.BUFFER_SIZE);
					}
				} else {
					_managedSound.splice(i, 1);
				}
			}

//			trace(c.getElapsedTime());
			if(output) {
				if(_managedSound.length > 0) {
					output.position = 0;
					
					for(i = 0; i < SoundDef.BUFFER_SIZE; ++i) {
						e.data.writeFloat(output.readFloat());
						e.data.writeFloat(output.readFloat());
					}
				} else {
					for(i = 0; i < SoundDef.BUFFER_SIZE; ++i) {
						e.data.writeFloat(0);
						e.data.writeFloat(0);
					}
				}
			}
		}
		
		protected function mixBuffers(buf1:ByteArray, buf2:ByteArray, size:uint):ByteArray
		{
			buf1.position = buf2.position = 0;
			var left:Number, right:Number;
			var output:ByteArray = new ByteArray();
			var i:int;
			
			if(buf1 != buf2) {
				for(i = 0; i < size; ++i) {
					left = buf1.readFloat() + buf2.readFloat();
					right = buf1.readFloat() + buf2.readFloat();
					
					left = Math.min(1.0, Math.max(-1.0, left));
					right = Math.min(1.0, Math.max(-1.0, right));
					
					output.writeFloat(left);
					output.writeFloat(right);
				}
			} else {
				for(i = 0; i < size; ++i) {
					left = Math.min(1.0, Math.max(-1.0, 2*buf1.readFloat()));
					right = Math.min(1.0, Math.max(-1.0, 2*buf1.readFloat()));
					
					output.writeFloat(left);
					output.writeFloat(right);
				}
			}
			
			return output;
		}
		
		protected function onSoundFinished(e:Event):void
		{
			_channel.removeEventListener(Event.SOUND_COMPLETE, onSoundFinished);
			_channel = _outputSound.play();
			_channel.addEventListener(Event.SOUND_COMPLETE, onSoundFinished);
		}
		
		protected function refreshOutputSound():Boolean
		{
			if(_outputSound) {
				_outputSound.removeEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
				_outputSound = null;
			}
			
			if(AudioManager.getAudioManager()) {
				_outputSound = AudioManager.getAudioManager().requestOutputSound();
				_outputSound.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
				return true;
			} else {
				_outputSound = null;
				_channel = null;
				trace("Bus::refreshOutputSound() Null AudioManager.");
			}
			return false;
		}
		
		public function get childBuses():Vector.<Bus>
		{
			return _childBuses;
		}

		public function get name():String
		{
			return _name;
		}

		public function set name(value:String):void
		{
			_name = value;
		}
		
		public function get isMute():Boolean
		{
			return _isMute;
		}

		public function get volume():Number
		{
			return _soundTransform.volume;
		}

		public function set volume(value:Number):void
		{
			changeVolume(value);
		}
	}
}