package engine.audio
{
	import engine.audio.visualizers.BusMonitor;
	
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowType;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class BusManager extends EventDispatcher
	{
		public static const MASTER:int = 0;
		public static const DIALOGUE:int = 1;
		public static const SFX:int = 2;
		public static const BGM:int = 3;
		public static const BACKGROUND:int = 4;
		public static const ENVIRONMENT:int = 5;
		
		private static var _instance:BusManager = new BusManager();
		
		private var _buses:Vector.<Bus>;
		
		public function BusManager(target:IEventDispatcher=null)
		{
			super(target);
			
			if(_instance) {
				throw new Error("BusManager::ctor() Singleton class does not allow new allocation.");
			}
			
			_buses = new Vector.<Bus>();
			this.buildSystem();
		}
		
		public static function getBusManager():BusManager
		{
			if(!_instance) {
				_instance = new BusManager();
			}
			
			return _instance;
		}
		
		public function buildSystem():void
		{
			var master:Bus = new Bus(MASTER, "Master");
			_buses.push(master);
			
			var sfx:Bus = new Bus(SFX, "SFX");
			_buses.push(sfx);
			master.addChildBus(sfx);
			
			var dialogue:Bus = new Bus(DIALOGUE, "Dialogue");
			_buses.push(dialogue);
			master.addChildBus(dialogue);
			
			var bgm:Bus = new Bus(BGM, "BGM");
			_buses.push(bgm);
			master.addChildBus(bgm);
			
			var background:Bus = new Bus(BACKGROUND, "Background");
			_buses.push(background);
			sfx.addChildBus(background);
			
			var environment:Bus = new Bus(ENVIRONMENT, "Environment");
			_buses.push(environment);
			sfx.addChildBus(environment);
			
			master.play();
		}
		
		public function addSoundToBus(sound:IPlayable, busId:int):Boolean
		{
			var bus:Bus = getBus(busId);
			if(bus) {
				bus.addSound(sound);
				return true;
			}
			
			return false;
		}
		
		public function removeSoundFromBus(sound:IPlayable, busId:int):Boolean
		{
			var bus:Bus = getBus(busId);
			if(bus) {
				bus.removeSound(sound);
				return true;
			}
			return false;
		}
		
		public function getBus(busId:int):Bus
		{
			var result:Bus = null;
			
			for each(var bus:Bus in _buses) {
				if(bus.busId == busId) {
					result = bus;
				}
			}
			
			return result;
		}
		
		public function getNumBus():int
		{
			return _buses.length;
		}
	}
}