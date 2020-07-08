package engine.managers
{
	import engine.audioPhysics.PanningGain;
	import engine.audioPhysics.Receiver;
	import engine.audioPhysics.ReflectionRecord;
	import engine.audioPhysics.Source;
	import engine.classes.App;
	import engine.events.DebugEvent;
	import engine.events.SourceEvent;
	import engine.interfaces.IDebug;
	import engine.interfaces.ISoundObstructable;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.EventDispatcher;
	import flash.events.SampleDataEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	/**
	 * THIS CLASS IS TO BE REWRITE AS THE PARADIGM CHANGED.
	 * AudioManager is the brain for all audio physics.
	 * It registers a receiver as the "ears" of player and
	 * determines all of the sound effects that should be applied.
	 */
	public class LegacyAudioManager extends EventDispatcher
	{
		private var _app:App;
		
		////////////////////////////////////////////
		// Objects to be managed
		////////////////////////////////////////////
		private var _receiver:Receiver;
		private var _sources:Vector.<Source>;
		private var _sourcesToRemove:Vector.<Source>;
		private var _soundObstructables:Vector.<ISoundObstructable>;
		private var _reflectionRecord:ReflectionRecord;
		
		////////////////////////////////////////////
		// Priority system
		////////////////////////////////////////////
		public static const PRIORITY_HIGH:uint = 3;
		public static const PRIORITY_NORMAL:uint = 2;
		public static const PRIORITY_LOW:uint = 1;
		
		private const NUM_CONCURRENT_SOURCE:uint = 12;
		private var _priorities:Dictionary;
		private var _audibleSources:Vector.<Source>;
		private var _priorityGains:Dictionary;
		
		private var _isPlaying:Boolean;
		
		////////////////////////////////////////////
		// Variables for sound playback
		////////////////////////////////////////////
		public static const BUFFER_SIZE:uint = 2048;
		private var _outputSound:Sound;
		private var _outputChannel:SoundChannel;
		
		private var _buffers:Dictionary;
		private var _coneGains:Dictionary;
		private var _panningGains:Dictionary;
		private var _attenuationGains:Dictionary;
		
		////////////////////////////////////////////
		
		public function LegacyAudioManager()
		{
			super();
			
			_sourcesToRemove = new Vector.<Source>();
			_soundObstructables = new Vector.<ISoundObstructable>();
			_reflectionRecord = new ReflectionRecord();
			
			_isPlaying = false;
			
			////////////////////////////////////////////
			// Priority system
			////////////////////////////////////////////
			_priorities = new Dictionary();
			_audibleSources = new Vector.<Source>();
			_priorityGains = new Dictionary();
			
			////////////////////////////////////////////
			// Sound playback
			////////////////////////////////////////////
			_sources = new Vector.<Source>();
			
			_outputSound = new Sound();
			_outputSound.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
			
			_buffers = new Dictionary();
			_coneGains = new Dictionary();
			_panningGains = new Dictionary();
			_attenuationGains = new Dictionary();
		}
		
		public function registerApp(app:App):void
		{
			if(app != null) {
				_app = app;
			} else {
				trace("AudioManager::registerApp() Bad app reference.");
			}
		}
		
		public function play():void
		{
			if(!_isPlaying) {
				_outputChannel = _outputSound.play();
				_isPlaying = true;
			}
		}
		
		public function stop():void
		{
			if(_isPlaying) {
				_outputChannel.stop();
				_isPlaying = false;
			}
		}
		
		public function clear():void
		{
			for (var i:int = _sources.length-1; i >= 0; --i) {
				removeSource(_sources[i]);
			}
			_receiver = null;
			stop();
		}
		
		public function addSource(s:Source, priority:uint = PRIORITY_NORMAL):void
		{
			if(_sources.indexOf(s) < 0) {
				_sources.push(s);
				_priorities[s] = priority;
				
				_app.addDebugListener(s);
				
				if(s.removeAtFinished) {
					s.addEventListener(SourceEvent.REMOVE_AT_FINISHED, handleSourceEvents);
				}
			}
		}
		
		private function handleSourceEvents(e:SourceEvent):void
		{
			if(e.type == SourceEvent.REMOVE_AT_FINISHED) {
				var s:Source = e.target as Source;
				s.removeEventListener(SourceEvent.REMOVE_AT_FINISHED, handleSourceEvents);
				_sourcesToRemove.push(s);
			}
		}
		
		public function removeSource(s:Source):void
		{
			if(s == null) {
				return;
			}
			
			var index:int = _sources.indexOf(s);
			
			if(index >= 0) {
				if(s.parent != null && s.parent.contains(s)) {
					s.parent.removeChild(s); // Remove from stage - FEELS NOT RIGHT, RECONSIDER LATER
				}
				_sources.splice(index, 1);
				delete _priorities[s];
				delete _priorityGains[s];
				delete _buffers[s];
				delete _coneGains[s];
				delete _panningGains[s];
				delete _attenuationGains[s];
				
				index = _audibleSources.indexOf(s);
				if(index >= 0) {
					_audibleSources.splice(index, 1);
				}
				index = _sourcesToRemove.indexOf(s);
				if(index >= 0) {
					_sourcesToRemove.splice(index, 1);
				}
				
				var reflecteds:Vector.<Source> = _reflectionRecord.getReflectedByOriginal(s);
				for each(var reflected:Source in reflecteds) {
					removeSource(reflected);
				}
				_reflectionRecord.removeAllOriginal(s);
				_reflectionRecord.removeAllReflected(s);
				
				_app.removeDebugListener(s);
			}
		}
		
		public function addSoundObstructable(soundObstructable:ISoundObstructable):void
		{
			if(_soundObstructables.indexOf(soundObstructable) < 0) {
				_soundObstructables.push(soundObstructable);
				
				if(soundObstructable is IDebug) {
					_app.addEventListener(DebugEvent.ENTER_DEBUG, (soundObstructable as IDebug).handleDebugEvents);
					_app.addEventListener(DebugEvent.EXIT_DEBUG, (soundObstructable as IDebug).handleDebugEvents);
				}
			}
		}
		
		public function removeSoundObstructable(soundObstructable:ISoundObstructable):void
		{
			var index:int = _soundObstructables.indexOf(soundObstructable);
			
			if(index >= 0) {
				_soundObstructables.splice(index, 1);
				
				_reflectionRecord.removeAllMedium(soundObstructable);
				if(soundObstructable is DisplayObject) {
					var parent:DisplayObjectContainer = (soundObstructable as DisplayObject).parent;
					if(parent != null && parent.contains(soundObstructable as DisplayObject)) {
						parent.removeChild(soundObstructable as DisplayObject);
					}
				}
				
				if(soundObstructable is IDebug) {
					_app.removeEventListener(DebugEvent.ENTER_DEBUG, (soundObstructable as IDebug).handleDebugEvents);
					_app.removeEventListener(DebugEvent.EXIT_DEBUG, (soundObstructable as IDebug).handleDebugEvents);
				}
			}
		}
		
		public function onEnterFrame():void
		{
			var s:Source;
			
			// Clean up
			for each(s in _sourcesToRemove) {
				removeSource(s);
			}
			
			// Sound Obstructions
			updateSoundObstructions();
			
			// Priority System
			updatePrioritySystem();
		}
		
		private function updateSoundObstructions():void
		{
			var s:Source;
			var reflected:Source
			var i:uint;
			var soundObstructable:ISoundObstructable;
			var dic:Dictionary;
			
			// Sound obstructions
			for each(s in _sources) {
				s.onEnterFrame();
				
				if(_receiver.canHear(s)) {
					var isOccluded:Boolean = false;
					for each(soundObstructable in _soundObstructables) {
						// Check for occlusion
						if(_reflectionRecord.getMediumByReflected(s) != soundObstructable) { // Not checking against creation medium
							/* OCCLUSION CHECKS */
							if(soundObstructable.isOccludingSourceFromReceiver(s, _receiver)) { // Occlusion occurs
								isOccluded = true;
								
								// Remove reflected sources of this source against this soundObstructable
								reflected = _reflectionRecord.getReflected(s, soundObstructable);
								removeSource(reflected);
							} else if(s.reflectNumber > 0 && soundObstructable.hasReflectedRayFromSource(s)) { // Reflection occurs
								reflected = _reflectionRecord.getReflected(s, soundObstructable);
								
								if(reflected != null) {
									// Update existing reflected sources 	
									reflected.updateWithEmit(soundObstructable.calculateReflectedRayFromLine(s.emit));
								} else {
									var newSource:Source = soundObstructable.generateVirtualSource(s);
									addSource(newSource);
									_reflectionRecord.addRecord(s, soundObstructable, newSource);
									_app.canvas.addChild(newSource);
								}
							} else { // No occlusion nor reflection
								
								// Remove reflected sources of this source against this soundObstructable
								reflected = _reflectionRecord.getReflected(s, soundObstructable);
								removeSource(reflected);
							} // if(soundObstructable.isOccludingSourceFromReceiver(s, _receiver))
						} // if(higherOrderSources == null || higherOrderSources.indexOf(s) < 0) {
					} // for each(soundObstructable in _soundObstructables)
					
					if(isOccluded) {
						s.setOcclusionFilter(true);
					} else {
						s.setOcclusionFilter(false);
					}
				} else { // Cannot be heard
					// Remove reflected sources of this source against this soundObstructable
					var reflecteds:Vector.<Source> = _reflectionRecord.getReflectedByOriginal(s);
					for each(reflected in reflecteds) {
						removeSource(reflected);
					}
				} // if(_receiver.canHear(s))
			} // for each(s in _sources)
		}
		
		private function updatePrioritySystem():void
		{
			var s:Source;
			var i:uint;
			
			for each(s in _sources) {
				// Everything occurs only when the source is can be heard by the receiver
				if(_receiver.canHear(s)) {
					// Put audible sources in according to decending priority
					if(_audibleSources.length == 0) {
						_audibleSources.push(s);
					} else if(_audibleSources.indexOf(s) < 0) {
						var isAdded:Boolean = false;
						
						for(i = 0; i < _audibleSources.length; ++i) {
							if(_priorities[s] > _priorities[_audibleSources[i]]) { // Old song tends to remain
								_audibleSources.splice(i, 0, s);
								isAdded = true;
								break;
							}
						}
						
						// Lowest priority, at the back
						if(!isAdded) {
							_audibleSources.push(s);
						}
					}
				} else { // if(_receiver.canHear(s))
					var index:int = _audibleSources.indexOf(s);
					if(index >= 0) {
						_audibleSources.splice(index, 1);
					}
				} // if(_receiver.canHear(s))
			}
			
			// Cut off extra sources
			if(_audibleSources.length > NUM_CONCURRENT_SOURCE) {
				_audibleSources.splice(NUM_CONCURRENT_SOURCE, _audibleSources.length-NUM_CONCURRENT_SOURCE);
			}
			
			// Update priority gains
			var totalPriority:uint = 0;
			for each(s in _audibleSources) {
				totalPriority += _priorities[s];
			}
			var gainLeft:Number = 1.0;
			for each(s in _audibleSources) {
				switch(_priorities[s]) {
					case PRIORITY_HIGH:
						_priorityGains[s] = 0.5;
						gainLeft -= 0.5;
						break;
					case PRIORITY_NORMAL:
						_priorityGains[s] = 0.2 * gainLeft;
						break;
					case PRIORITY_LOW:
						_priorityGains[s] = 0.05 * gainLeft;
						break;
					default:
						_priorityGains[s] = 0;
						break;
				}
			}
		}
		
		private function onSampleData(e:SampleDataEvent):void
		{
			var i:uint = 0;
			
			if(_audibleSources.length == 0) {
				for(i = 0; i < BUFFER_SIZE; ++i) {
					e.data.writeFloat(0);
					e.data.writeFloat(0);
				}
			} else {
				var byte:ByteArray;
				var s:Source;
				for each(s in _sources) {
					byte = s.generateAudio(BUFFER_SIZE);
					
					if(_audibleSources.indexOf(s) >= 0) {
						_buffers[s] = byte;
						_coneGains[s] = _receiver.coneGainFrom(s);
						_panningGains[s] = _receiver.panningGainFrom(s);
						_attenuationGains[s] = _receiver.attenuationFrom(s);
					}
				}
				
				var left:Number, right:Number;
				for(i = 0; i < BUFFER_SIZE; ++i) {
					left = right = 0;
					
					for each(s in _audibleSources) {
						left += (_buffers[s] as ByteArray).readFloat() * _coneGains[s] * _attenuationGains[s] *
							(_panningGains[s] as PanningGain).leftGain * _priorityGains[s];
						right += (_buffers[s] as ByteArray).readFloat() * _coneGains[s] * _attenuationGains[s] *
							(_panningGains[s] as PanningGain).rightGain * _priorityGains[s];
					}
					
					e.data.writeFloat(left);
					e.data.writeFloat(right);
				}
			}
		}
		
		////////////////////////////////////////////
		// Accessors and Mutators
		////////////////////////////////////////////
		public function set receiver(r:Receiver):void
		{
			if(_receiver != null) {
				_app.removeDebugListener(_receiver);
			}
			if(r != null) {
				_receiver = r;
				_app.addDebugListener(_receiver);
			}
		}
		
		public function get receiver():Receiver
		{
			return _receiver;
		}
	}
}