// ActionScript file
//Written by: Kenneth and Chun kit
//Concept contributed by Kenneth, coded by Chun Kit

package engine.visualRepresentation
{
	import engine.audio.PositionalSound;
	import engine.audio.SoundManager;
	import engine.classes.App;
	import engine.utils.Utility;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	
	public class ParadeMass extends Sprite
	{
		private var _theMass:Vector.<MovableAvatar>;
		private var _pSnd:PositionalSound;
		private var _everyoneOut:Boolean = false;
		private var _headCount:int = 0;
		private var _parent:DisplayObjectContainer; 
		
		//starting point range
		private var _startRng_x:int = 12;
		private var _endRng_x:int = 161;
		private var _rng_y:int = 300;
		
		private var _app:App;
		
		//PSnd holder of the parade
		private var _leader:MovableAvatar;
	
		public function ParadeMass(app:App)
		{
			_app = app;
			_pSnd = null;
			_theMass = new Vector.<MovableAvatar>();
			
			//init leader who holds the gong gong chang
			_leader = new MovableAvatar(app);
			
			_leader.x = (_endRng_x - _startRng_x) * 0.5;
			_leader.y = -(_rng_y * 0.5);
			_leader.setStartPt(_leader.x,_leader.y);
			//turn point
			_leader.setPivot(((_endRng_x - _startRng_x) * 0.5),502);
			//end point
			_leader.setEndPt(_app.stage.stageWidth,502);
			
			
			_theMass.push(_leader);
			
		}
		public function getLeaderSnd():PositionalSound
		{
			return _leader.pSnd;
		}
		public function reattachParade(worldSnd:Vector.<PositionalSound>):void
		{
			var i:int;
			for (i=0; i<_theMass.length; i++)
			{
				if ((!_theMass[i].parent) && (i!=0))
				{
					_parent.addChild(_theMass[i]);
				}
				_theMass[i].x = _theMass[i].startPt_x;
				_theMass[i].y = _theMass[i].startPt_y;
				_theMass[i].turnTo(_theMass[i].turningPt_x,_theMass[i].turningPt_y);
				_theMass[i].hasTurned = false;
				_theMass[i].hasChecked = false;
				worldSnd.push(_theMass[i].pSnd);
			}
		}
		public function reattachParadeSnd(worldSnd:Vector.<PositionalSound>):void
		{
			var i:int = 0;
			for (i=0; i<_theMass.length; i++)
			{
				worldSnd.push(_theMass[i].pSnd);
			}
		}
		/**
		 * Checks if everyone in the Parade have reached their end point.
		 * @return _everyoneOut true if parade ended
		 * */
		public function get everyoneOut():Boolean
		{
			//resets variable 
			if (_everyoneOut)
			{
				_everyoneOut = false;
				return true;
			}
			else
				return false;
		}
		/**
		 * Updates the position of the leader's sound
		 * */
		public function updatePSndPosition():void
		{
			_leader.updatePSndPosition();
		}
		/**
		 * Adds a sound to the leader of the parade
		 * @param pSnd a positional sound to the leader
		 * */
		public function addPSnd(pSnd:PositionalSound):void
		{
			_leader.addPSnd(pSnd); 
		}
		/**
		 * Adds a person (movable avatar) to the parade
		 * @param movAva a MovableAvatar
		 * */
		public function addMovableAvatar(movAva:MovableAvatar):void
		{
			//TODO: set the 
			//1) initial position
			//2) and pivot point
			//3) end point
			//of each avatar
			
			/*
			12,462			161,462
			
			
			
			
			
			12,582			161,582
			*/
			//get parent ONCE
			if (!_parent)
			{
				_parent = movAva.parent;
			}
			else
			{}
			//gets rand coordinate in the parade square
			var rand_x:int;
			var rand_y:int;
			var another_rand:int;
			rand_x = Utility.randomRange(_endRng_x,_startRng_x);
			rand_y = Utility.randomRange(582,462);
			another_rand = Utility.randomRange(_rng_y,0);
			//start point
			movAva.setStartPt(rand_x, -another_rand);
			movAva.x = rand_x;
			movAva.y = -another_rand;
			
			//turn point
			movAva.setPivot(rand_x,rand_y);
			//end point
			movAva.setEndPt(_app.stage.stageWidth,rand_y);
			
			//intiate facing position
			movAva.turnTo(rand_x,rand_y);
			_theMass.push(movAva);
		}
		/**
		 * cleans up the class
		 * */
		public function cleanUp(worldPSnd:Vector.<PositionalSound>, sndMan:SoundManager):void
		{
			var i:int=0;
			for (i=0; i<_theMass.length; i++)
			{
				if (_theMass[i].parent)
				{
					_theMass[i].parent.removeChild(_theMass[i]);
				}
				trace("index: "+worldPSnd.indexOf(_theMass[i].pSnd));
				if (worldPSnd.indexOf(_theMass[i].pSnd) >= 0)
					sndMan.removeSoundFromGroups(worldPSnd.splice(worldPSnd.indexOf(_theMass[i].pSnd),1)[0]);
				//_theMass[i].stopMySnd();
			}
		}
		public function updateVariables(frameTime:int):void
		{
			var i:int=0;
			for (i=0; i<_theMass.length; i++)
			{
				//havent reached turning point
				if (!_theMass[i].hasTurned)
				{
					//check if reached on next step
					//if not yet, keep moving
					if (!_theMass[i].walkedStraightTo(_theMass[i].turningPt_x, _theMass[i].turningPt_y))
					{
						_theMass[i].updateVariable();
					}
					//else, turn to end point
					else
					{
						_theMass[i].hasTurned = true;
						_theMass[i].turnTo(_theMass[i].endPt_x,_theMass[i].endPt_y);
					}
				}
				else
				{					
					if (!_theMass[i].walkedStraightTo(_theMass[i].endPt_x,_theMass[i].endPt_y))
					{
						_theMass[i].updateVariable();
					}
					else
						if (!_theMass[i].hasChecked)
						{
							_theMass[i].hasChecked = true;
							_headCount++;
						}
				}
				_theMass[i].updatePSndPosition();
			}
			//trace("headCount: " + _headCount);
			//trace("leader pos x: " + _leader.x + "     y: " + _leader.y);
			if (_headCount  >= _theMass.length)
			{
				_headCount = 0;
				_everyoneOut = true;
				//cleanUp();
			}
		}
	}
}