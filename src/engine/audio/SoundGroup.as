package engine.audio
{
import engine.audio.IPlayable;
	/**SoundGroup class provides grouping for sounds as<br>
	 * as specified by the user.
	 * */
	public class SoundGroup
	{
		
		private var _soundMgr:SoundManager;
		/**
		 * Holds the sounds that have been given to the SoundGroup by the user<br>
		 * Is not altered within the class other than being sorted.
		 * */
		private var _soundGroupArray:Vector.<IPlayable>;
		public function get soundGroupArray():Vector.<IPlayable> { return _soundGroupArray; }
		/**
		 * Is refreshed everytime when processGroup is called.
		 * */
		private var groupToBusArray:Vector.<IPlayable>;
		private var absSndTypesArray:Vector.<AbstractSoundType>;
		private var findPremixParameters:Object;
		
		private var _name:String;
		public function get name():String { return _name; }
		public function set name(name:String):void { _name = name; }
		
		private var _applyPhysics:Boolean;
		public function get applyPhysics():Boolean { return _applyPhysics; }
		public function set applyPhysics(ap:Boolean):void { _applyPhysics = ap; }
		
		public function SoundGroup(sndMgr:SoundManager,absSndTypesArray:Vector.<AbstractSoundType>)
		{
			_soundGroupArray = new Vector.<IPlayable>();
			groupToBusArray = new Vector.<IPlayable>();
			this.absSndTypesArray = absSndTypesArray;
			this._soundMgr = sndMgr;
			findPremixParameters = new Object;
			findPremixParameters.count = 1;
			findPremixParameters.i = 1;
			findPremixParameters.indexOfGroupToBusArray = 1;
			this._applyPhysics = false;
		}
		public function addSoundtoGroup(snd:IPlayable):void
		{
			soundGroupArray.push(snd);
//			trace("sound shuriken-ed");
		}
		public function removeSoundFromGroup(snd:IPlayable):Boolean
		{
			var index:int = soundGroupArray.indexOf(snd);
			// snd was found
			if (index!=-1)
			{
//				trace("sound gone");
				soundGroupArray.splice(index,1);
				return true;
			}
			else
			{
				return false;
			}
		}
		public function removeAllSound():void
		{
			soundGroupArray.splice(0,soundGroupArray.length);
			_soundMgr.eventLogs[0].log("All sounds removed from group: " + _name);
		}
		/**
		 * processGroup() 
		 * 
		 * */
		public function processGroup():Vector.<IPlayable>
		{
			// clear the array to bus
			groupToBusArray.splice(0,groupToBusArray.length);

			var len:int = soundGroupArray.length;
			//only process when there is more than 1 sound in the group
			if (len > 1)
			{
				var count:int = 1;
				var indexOfGroupToBusArray:int = 1;
				// sort the files according to options.abstractSoundType
				soundGroupArray.sort(compareAbstractSoundType);
				// shallow copy the soundGroupArray - not an actual copy 
				groupToBusArray = soundGroupArray.concat();
	
				for (var i:int=1;i<len;i++)
				{
					if (i < len-1)
					{
						// if the sounds are the same
						if (compareAbstractSoundType(soundGroupArray[i-1],soundGroupArray[i]) == 0)
						{
							count++;
						}
						// when the sounds are different
						else if (count>1)
						{
							findPremixParameters.count = count;
							findPremixParameters.i = i;
							findPremixParameters.indexOfGroupToBusArray = indexOfGroupToBusArray;
							findPremix(findPremixParameters);
							count = findPremixParameters.count;
							i = findPremixParameters.i;
							indexOfGroupToBusArray = findPremixParameters.indexOfGroupToBusArray;							
						}
						else
						{
							count = 1;
						}
					}
					// handle the last group, for they shall not be forgotten
					else if ((i == len-1)&&(compareAbstractSoundType(soundGroupArray[i-1],soundGroupArray[i]) == 0))
					{
						findPremixParameters.count = count+1;
						findPremixParameters.i = i;
						findPremixParameters.indexOfGroupToBusArray = indexOfGroupToBusArray+1;
						findPremix(findPremixParameters);
					}
					else if ((i == len-1)&&(compareAbstractSoundType(soundGroupArray[i-1],soundGroupArray[i]) != 0))
					{
						findPremixParameters.count = count;
						findPremixParameters.i = i;
						findPremixParameters.indexOfGroupToBusArray = indexOfGroupToBusArray;
						findPremix(findPremixParameters);
					}
					++indexOfGroupToBusArray;
				}
			}
			else if (len == 1)
			{
				// push the only snd in the array to the bus
				groupToBusArray.push(soundGroupArray[0]);
			}
			return groupToBusArray;
		}
		
		//////////////////////
		// Helper functions //
		//////////////////////
		private function findPremix(findPremixParameters:Object):IPlayable
		{
			var absSndType:AbstractSoundType;
			absSndType = getAbstractSoundType(soundGroupArray[findPremixParameters.i]);
			var premix:IPlayable;
			premix = absSndType.getPremix(findPremixParameters.count);
			// premix is found
			if (premix)
			{
//				trace("God the premix is here");
				// remove the abstracted sounds
				groupToBusArray.splice(findPremixParameters.indexOfGroupToBusArray-findPremixParameters.count,findPremixParameters.count);
				// add the premix to the array to be sent to bus
				groupToBusArray.push(premix);
				// update the for loop parameters
				findPremixParameters.indexOfGroupToBusArray-=findPremixParameters.count;
				findPremixParameters.count = 1;
			}
			// premix not found, sounds are not abstracted
			else
			{
//				trace("so tell me you didn't found it");
			}
			// Restart the count the for the next sound abstract type
			return premix;
		}
		private function getAbstractSoundType(snd:IPlayable):AbstractSoundType
		{
			var found:Boolean;
			found = false;
			var i:int;
			var len:int;
			var abstractSoundTypeOfSnd:String = snd.options.abstractSoundType;
			i = 0;
			len = absSndTypesArray.length;
			while ((!found)&&(i<len))
			{
				if (absSndTypesArray[i].abstractSoundType == abstractSoundTypeOfSnd)
					found = true;
				i++;
			}
			return absSndTypesArray[i-1];
		}
		private function compareAbstractSoundType(snd1:IPlayable,snd2:IPlayable):int
		{
			if ((snd1.options.abstractSoundType)>(snd2.options.abstractSoundType))
				return 1;
			else if ((snd1.options.abstractSoundType)<(snd2.options.abstractSoundType))
				return -1;
			else
				return 0;
		}
	}
}