// ActionScript file
package engine.visualRepresentation
{
	import engine.audio.PositionalSound;
	import engine.classes.App;
	public class ParadeMassHolder
	{
		private var _currParadeIndex:int;
		private var _app:App;
		private var _paradeMasses:Vector.<ParadeMass>;
		
		private var _vectOfPSnd:Vector.<PositionalSound>;
		private var _currPSndIndex:int;
		public function ParadeMassHolder(app:App)
		{
			_currParadeIndex = 0;
			_app = app;
			_paradeMasses = new Vector.<ParadeMass>();
			
			_vectOfPSnd = new Vector.<PositionalSound>();
			_currPSndIndex = 0;
		}
		public function addParade(partyTime:ParadeMass):void
		{
			this._paradeMasses.push(partyTime);
		}
		public function retrieveParade(worldSnd:Vector.<PositionalSound>):ParadeMass
		{
			if (_paradeMasses)
			{
				if (_currParadeIndex >= _paradeMasses.length)
					_currParadeIndex = 0;
				
				_paradeMasses[_currParadeIndex].reattachParade(worldSnd);
				
				return _paradeMasses[_currParadeIndex++];
			}
			return null;
		}
		
		
		
		
		
		
		
		//2nd Version
		public function addLeaderSnd(snd:PositionalSound):void
		{
			this._vectOfPSnd.push(snd);
		}
		public function retrieveParadeSnd():PositionalSound
		{
			if (_vectOfPSnd)
			{
				if (_currPSndIndex >= _vectOfPSnd.length)
					_currPSndIndex = 0;
				
				return _vectOfPSnd[_currPSndIndex++];
			}
			return null;
		}
	}
}