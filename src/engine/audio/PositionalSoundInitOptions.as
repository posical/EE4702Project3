package engine.audio
{
	public class PositionalSoundInitOptions extends Object
	{
		private var _fileName:String;
		private var _isStreaming:Boolean; // PENDING
		private var _isLooping:Boolean;
		private var _isMusic:Boolean;
		private var _priority:uint;
		private var _properties:PositionalSoundProperties;
		private var _busId:int;
		private var _abstractSoundType:String;
		public function get abstractSoundType():String { return _abstractSoundType; }
		public function set abstractSoundType(ast:String):void { _abstractSoundType = ast; }

		public function PositionalSoundInitOptions()
		{
			super();
			
			reset();
		}
		
		public function copyFrom(options:PositionalSoundInitOptions):void
		{
			reset();
			
			_fileName = options.fileName;
			_isStreaming = options.isStreaming;
			_isLooping = options.isLooping;
			_isMusic = options.isMusic;
			_priority = options.priority;
			_busId = options.busId;
			_abstractSoundType = options.abstractSoundType;
			
			_properties.copyFrom(options.properties);
		}
		
		public function reset():void
		{
			_fileName = "";
			_isStreaming = false;
			_isLooping = false;
			_isMusic = false;
			_priority = 0;
			_busId = BusManager.MASTER;
			_abstractSoundType= "";
			
			if(_properties)
				_properties.reset();
			else
				_properties = new PositionalSoundProperties;
		}

		public function get fileName():String
		{
			return _fileName;
		}

		public function set fileName(value:String):void
		{
			_fileName = value;
		}

		public function get isStreaming():Boolean
		{
			return _isStreaming;
		}

		public function set isStreaming(value:Boolean):void
		{
			_isStreaming = value;
		}

		public function get isLooping():Boolean
		{
			return _isLooping;
		}

		public function set isLooping(value:Boolean):void
		{
			_isLooping = value;
		}

		public function get isMusic():Boolean
		{
			return _isMusic;
		}

		public function set isMusic(value:Boolean):void
		{
			_isMusic = value;
		}

		public function get priority():uint
		{
			return _priority;
		}

		public function set priority(value:uint):void
		{
			_priority = value;
		}

		public function get properties():PositionalSoundProperties
		{
			return _properties;
		}

		public function set properties(value:PositionalSoundProperties):void
		{
			_properties = value;
		}

		public function get busId():int
		{
			return _busId;
		}

		public function set busId(value:int):void
		{
			_busId = value;
		}
	}
}