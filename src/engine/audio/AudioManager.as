package engine.audio
{
	import engine.audio.visualizers.SoundBufferMonitor;
	
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowType;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.media.Sound;
	import flash.utils.Dictionary;
	
	public final class AudioManager extends EventDispatcher implements IAudioManager
	{
		public static const MAX_OUTPUT_NUM:uint = 10;
		
		private static var _instance:AudioManager = new AudioManager();
		
		private var _options:AudioManagerInitOptions;
		private var _stats:AudioManagerStats;
		
		private var _isInitialized:Boolean;
		
		private var _receiver:Receiver;
		private var _outputSounds:Vector.<Sound>;
		
		private var _buffers:Dictionary;
		
		public function AudioManager(target:IEventDispatcher=null)
		{
			super(target);
			
			if(_instance) {
				throw new Error("AudioManager::ctor() Singleton class does not allow new allocation.");
			}
			
			_stats = new AudioManagerStats();
			_receiver = new Receiver();
			_outputSounds = new Vector.<Sound>();
			
			_buffers = new Dictionary();
		}
		
		public static function getAudioManager():AudioManager
		{
			if(!_instance) {
				var options:AudioManagerInitOptions = new AudioManagerInitOptions();
				_instance = new AudioManager();
				_instance.init(options);
			}
			
			return _instance;
		}
		
		public function onUpdate():void
		{
		}
		
		public function init(options:AudioManagerInitOptions):Boolean
		{
			if(options) {
				_options = options;
				_isInitialized = true;
				return true;
			}
			_isInitialized = false;
			return false;
		}
		
		public function cleanUp():void
		{
		}
		
		public function addSoundToBus(sound:IPlayable, busId:int):Boolean
		{
			return BusManager.getBusManager().addSoundToBus(sound, busId);
		}
		
		public function removeSoundFromBus(sound:IPlayable, busId:int):Boolean
		{
			return BusManager.getBusManager().removeSoundFromBus(sound, busId);
		}
		
		public function isInitialized():Boolean
		{
			return _isInitialized;
		}
		
		public function requestOutputSound():Sound
		{
			var result:Sound = null;
			
			if(_outputSounds.length < MAX_OUTPUT_NUM) {
				result = new Sound();
			}
			return result;
		}
		
		public function releaseOutputSound(sound:Sound):void
		{
			if(sound) {
				var index:int = _outputSounds.indexOf(sound);
				_outputSounds.splice(index, 1);
				sound = null;
			}
		}
		
		public function getSoundBuffer(fileName:String, load:Boolean = false):SoundBuffer
		{
			var result:SoundBuffer = null;
			
			if(_buffers[fileName]) {
				result = _buffers[fileName];
			} else {
				_buffers[fileName] = new SoundBuffer(fileName, load);
				result = _buffers[fileName];
			}
			
			return result;
		}
		
		public function createNonPositionalSound(options:NonPositionalSoundInitOptions = null):INonPositionalSound
		{
			var result:INonPositionalSound = null;
			result = new NonPositionalSound(options);
			return result;
		}
		
		public function createPositionalSound(options:PositionalSoundInitOptions = null):IPositionalSound
		{
			var result:IPositionalSound = null;
			result = new PositionalSound(options);
			return result;
		}
		
		public function stopAll():Boolean
		{
			BusManager.getBusManager().getBus(BusManager.MASTER).stop();
			return true;
		}
		
		public function pauseAll():Boolean
		{
			BusManager.getBusManager().getBus(BusManager.MASTER).pause();
			return true;
		}
		
		public function resumeAll():Boolean
		{
			BusManager.getBusManager().getBus(BusManager.MASTER).play();
			return true;
		}
		
		public function get stats():AudioManagerStats
		{
			return _stats;
		}
		
		public function get receiver():IReceiver
		{
			return _receiver;
		}
		
		public function get soundVolume():Number
		{
			return 0;
		}
		
		public function set soundVolume(value:Number):void
		{
		}
		
		public function get musicVolume():Number
		{
			return 0;
		}
		
		public function set musicVolume(value:Number):void
		{
			
		}
	}
}