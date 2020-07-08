package engine.audio
{
	import engine.console.LogConsole;
	import engine.viewport.*;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.getTimer;

	/**
	 * <p>SoundManager is a class to manage sound resources being created
	 * and called to play. They are not the actual sound data but references
	 * to the file. Its main responsibility is to ensure the number of sound
	 * sources requested by the user is automatically paired down to a
	 * manageable number by allowing the user to specify premixes when the
	 * number of sound instances exceed by a certain number.</p>
	 * <p>The SoundManager keeps track of its own time before allowing
	 * onUpdate() to run.</p>
	 * */
	public class SoundManager extends EventDispatcher
	{
		private static var _instance:SoundManager = new SoundManager();
		
//		private var tempMasterBus:Vector.<IPlayable>;
//		private var masterBus:Vector.<IPlayable>;
		
		private var tempBuses:Vector.<Vector.<IPlayable>>;
		private var buses:Vector.<Vector.<IPlayable>>;
		
		private var sndGrpArray:Vector.<SoundGroup>;
		private var absSndTypeArray:Vector.<AbstractSoundType>;
		
		private var onUpdateStartTime:Number;
		private static const ON_UPDATE_TIME_INTERVAL:uint = 500; // SoundManager processing interval
		
		private var _audioMgr:AudioManager;
		
		private var _eventLogs:Vector.<LogConsole>;
		public function get eventLogs():Vector.<LogConsole> { return _eventLogs;}

		public function addLogConsoles(lgs:Vector.<LogConsole>):void { this._eventLogs = lgs; }

		public function SoundManager(target:IEventDispatcher=null)
		{
			super(target);
			if(_instance) {
				throw new Error("SoundManager::ctor() Singleton class does not allow new allocation.");
			}
			init();
		}
		private function init():void
		{
			_audioMgr = AudioManager.getAudioManager();
			
			buses = new Vector.<Vector.<IPlayable>>();
			tempBuses = new Vector.<Vector.<IPlayable>>();
			var numOfBuses:int = 6;
			numOfBuses = BusManager.getBusManager().getNumBus();
			for (var i:int = 0;i<numOfBuses;i++)
			{
				buses.push(new Vector.<IPlayable>());
				tempBuses.push(new Vector.<IPlayable>());
			}
			
//			tempMasterBus = new Vector.<IPlayable>();
//			masterBus = new Vector.<IPlayable>();
			
			sndGrpArray = new Vector.<SoundGroup>();
			absSndTypeArray = new Vector.<AbstractSoundType>();
			
			onUpdateStartTime = getTimer();
		}
		public static function getSoundManager():SoundManager
		{
			if(!_instance) {
				_instance = new SoundManager();
			}
			return _instance;
		}
		public function createPositionalSound(options:PositionalSoundInitOptions):IPositionalSound
		{
			var posSndAsset:IPositionalSound = _audioMgr.createPositionalSound(options);
			return posSndAsset;
		}
		public function createNonPositionalSound(options:NonPositionalSoundInitOptions):INonPositionalSound
		{
			var nonPosSndAsset:INonPositionalSound = _audioMgr.createNonPositionalSound(options);
			return nonPosSndAsset;
		}
		public function createNewGroup():SoundGroup
		{
			var soundGroup:SoundGroup = new SoundGroup(this, absSndTypeArray);
			sndGrpArray.push(soundGroup);
			return soundGroup;
		}
		public function removeAllSoundsFromSoundGroups():void
		{
			for each (var sndGrp:SoundGroup in sndGrpArray)
			{
				sndGrp.removeAllSound();
			}
		}
		/** @return False if snd is not found */
		public function removeSoundFromGroups(snd:IPlayable):Boolean
		{
			var flag:Boolean;
			flag = false;
			for each (var sndGrp:SoundGroup in sndGrpArray)
			{
				if (sndGrp.removeSoundFromGroup(snd))
					flag = true;
			}
			return flag;
		}
		public function createAbstractSoundType(fn:String):AbstractSoundType
		{
			var absSndType:AbstractSoundType = new AbstractSoundType;
			absSndType.createAbstractSoundType(fn);
			absSndTypeArray.push(absSndType);
			return absSndType;
		}
		public function onUpdate():void
		{
			// if time elapsed is lesser than time interval
			if ((getTimer()-onUpdateStartTime)<ON_UPDATE_TIME_INTERVAL)
				return;
			else if (_eventLogs)
			{
				////////////////////////////
				// Process to all buses
				////////////////////////////
				var numOfBuses:int = 6;
				numOfBuses = BusManager.getBusManager().getNumBus();
				for (var i:int=0;i<numOfBuses;i++)
				{
					_eventLogs[i].clear();
					_eventLogs[i].log("[In Bus " + i + "]");
					// clear the array
					tempBuses[i].splice(0,tempBuses[i].length);
					for each (var sndGrp:SoundGroup in sndGrpArray)
					{
						_eventLogs[i].log("- " + sndGrp.name);
						var processedGroupArray:Vector.<IPlayable>;
						for each (var snd:IPlayable in sndGrp.soundGroupArray)
						{
							if (snd.options.busId == i)
								_eventLogs[i].log(snd.options.fileName);
						}
						processedGroupArray = sndGrp.processGroup();
						_eventLogs[i].log("= abstracted to =");
						for each (snd in processedGroupArray)
						{
							tempBuses[i].push(snd);
							// output to log
							if (snd.options.busId == i)
							{
								_eventLogs[i].log(snd.options.fileName);
							}
						}
					}
					updateBus(i,tempBuses[i]);	
				}
				////////////////////////////
				// end process to all buses
				////////////////////////////
				onUpdateStartTime = getTimer();
			}
		}
		//////////////////////
		// Helper functions //
		//////////////////////
		private function updateBus(i:int, snds:Vector.<IPlayable>):void
		{
			var index:int;
			// snds to be added
			for each (var snd:IPlayable in snds)
			{
				index = buses[i].indexOf(snd);
				// if snd in tempArray was not found in master bus, add to master bus
				if (index==-1)
				{
//					_eventLog.log(snd1.options.fileName + " ADDED");
					if (snd.options.busId == i)
					{
						_audioMgr.addSoundToBus(snd,snd.options.busId);
						snd.load();
						snd.play();
						buses[i].push(snd);
					}
				}
			}
			// snds to be removed
			for each (snd in buses[i])
			{
				index = snds.indexOf(snd);
				// if snd in master bus was not found in tempArray, remove from master bus
				if (index==-1)
				{
					if (snd.options.busId == i)
					{
						_audioMgr.removeSoundFromBus(snd,snd.options.busId);
						snd.pause();
						buses[i].splice(buses[i].indexOf(snd),1);
					}
				}
			}
			// for dialogue, remove when then have finished playing
			if (i == BusManager.DIALOGUE && buses[i].length > 0)
			{
				for each (snd in buses[i])
				{
					if (snd.isLooping == false
						&& snd.isPlaying == false
						&& snd.isPaused == false
						&& snd.isWaitingToBePlayed == false
						&& (snd as PositionalSound).readCursor == 0)
					{
						_audioMgr.removeSoundFromBus(snd,snd.options.busId);
						buses[i].splice(buses[i].indexOf(snd),1);
					}
				}
			}
		}
	}
}