/**
 * Written by Kenneth with help from Tashrif
 */

package engine.visualRepresentation
{
	import engine.audio.BusManager;
	import engine.audio.PositionalSound;
	import engine.classes.App;
	import engine.utils.Color;
	import engine.viewport.Viewport;
	import engine.visualRepresentation.StaticAvatar;
	
	import flash.events.MouseEvent;
	
	public class NPC extends StaticAvatar
	{
		private var _charDiag:Vector.<PositionalSound>;
		private var _diagPointer:int;
		private var _worldSnds:Vector.<PositionalSound>;
		private var _vp:Viewport;
		private var _sndP:PositionalSound;
		
		public function NPC(vp:Viewport, worldSnds:Vector.<PositionalSound>, x:int,y:int,angle:int,app:App, color:uint, clickable:Boolean)
		{
			_vp = vp;
			_worldSnds = worldSnds;
			super(app, color, true);
			this.x = x;
			this.y = y;
			this.rotation = angle;
			_charDiag = new Vector.<PositionalSound>();
			_diagPointer = 0;	
			
		}

		public function pushVectSnd(pSnd:PositionalSound):void
		{	
			this.addPSnd(pSnd);
			_charDiag.push(pSnd);
		}
	
		private function getPosSnd():PositionalSound
		{
			var i:int;
		
			i = _diagPointer;
			if(_diagPointer >= _charDiag.length-1)
			{
				_diagPointer = 0;
			}
			else if(_diagPointer < _charDiag.length-1)
			{
				_diagPointer++;
			}
		//trace("tracing " + i);
		return _charDiag[i];	
		}
	
		protected override function handleMouse(e:MouseEvent):void
		{
			if (e.type === MouseEvent.CLICK)
			{
				if(_vp.zoomLv == 3 || _vp.zoomLv == 4)
				{
					//_worldSnds.push(getPosSnd());
					if (_sndP)
					{
						if (!_sndP.isPlaying)
						{
							_sndP = getPosSnd();
							_app.audioManager.addSoundToBus(_sndP,BusManager.DIALOGUE);
							_sndP.load();
							if(_vp.checkZone(_sndP) == Viewport.CORE)
							{
							_sndP.play();
							}
						}
					}
					else
					{
						_sndP = getPosSnd();
						_app.audioManager.addSoundToBus(_sndP,BusManager.DIALOGUE);
						_sndP.load();
						if(_vp.checkZone(_sndP) == Viewport.CORE)
						{
							_sndP.play();
						}
					}
				}
			}
		}
	}	
}