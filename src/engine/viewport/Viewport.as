/**
 * Written by Kenneth and Chun Kit
 * */
package engine.viewport
{
	import engine.audio.BusManager;
	import engine.audio.IPositionalSound;
	import engine.audio.PositionalSound;
	import engine.audio.PositionalSoundInitOptions;
	import engine.audio.PositionalSoundProperties;
	import engine.classes.App;
	import engine.utils.Color;
	import engine.utils.Utility;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Vector3D;
	import flash.media.Sound;
//	import flash.media.SoundChannel;
//	import flash.net.URLRequest;
	
	public class Viewport extends Sprite implements IMinimapViewport
	{
		//zone classification
		public static const TOP:String = "top";
		public static const BOTTOM:String = "bottom";
		public static const LEFT:String = "left";
		public static const RIGHT:String = "right";
		public static const CORE:String = "core";
		public static const OUT:String = "out";
		
		//moving stuff
		public static const MOVE_UP:String = "M_up";
		public static const MOVE_LEFT:String = "M_left";
		public static const MOVE_RIGHT:String = "M_right";
		public static const MOVE_DOWN:String = "M_down";
		public static const MOVE_STOP:String = "M_stop";
		
		//misc constants
		public static const FAST:int = 5;
		public static const SLOW:int = 2;
		
		private var _direction:String;
		private var _isMoving:Boolean = false;
		
		//lv 0 = 100% of window size (God view)
		//lv 1 = 75%, lv 2 = 50%, lv 3 = 25%
		private var _zoomLv:Number;
		
		//half a size of the core
		private var _sizeWidth:int;
		private var _sizeHeight:int;
		
		//coordinate of the center
		private var _position_x:int;
		private var _position_y:int;
		private var _position3D:Vector3D;
		
		private var _speed:Number;
		
		//limit of the center
		private var _border_x:int;
		private var _border_y:int;
		
		//how big is the prep zone relative to the core
		private var _prepZonePercentage:Number = 2;
		
		private var _prepSizeWidth:int;
		private var _prepSizeHeight:int;
		
		//to get mainWindow height and width
		private var _app:App;
		
		//gfx stuff
		private var _viewportLines:Shape;
		
		//angle / zone lines
		private var _NEangle:Number;
		private var _NWangle:Number;
		private var _SEangle:Number;
		private var _SWangle:Number;
		
		//VP change sfx
		private var _vpChng:PositionalSound;
		private var _vpChngOpt:PositionalSoundInitOptions;
		private var _vpNoMove:PositionalSound;
		private var _vpNoMoveOpt:PositionalSoundInitOptions;
		
		public function Viewport(app:App)
		{
			_app = app;
			_speed = FAST;
			//initi center position
			_position3D = new Vector3D();
			_position3D.z = 0;
			//_position3D.x = _app.mainWindow.stage.stageWidth * 0.5;
			//_position3D.y = _app.mainWindow.stage.stageHeight * 0.5;
			
			_position3D.x = 400;   				//_app.mainWindow.stage.stageWidth * 0.5;
			_position3D.y = 300;
			this.x = _position3D.x;
			this.y = _position3D.y;
			
			//set VP change sfx
			_vpChngOpt = new PositionalSoundInitOptions;
			_vpChngOpt.fileName = "sounds/Kyun.mp3";
			_vpChngOpt.busId = BusManager.SFX;
			_vpChngOpt.isLooping = false;
			
			_vpChng =  new PositionalSound(_vpChngOpt);
			_vpChng.load();
			
			//set up VP cant move sfx
			_vpNoMoveOpt = new PositionalSoundInitOptions;
			_vpNoMoveOpt.fileName = "sounds/Ouch.mp3";
			_vpNoMoveOpt.busId = BusManager.SFX;
			_vpNoMoveOpt.isLooping = false;
			
			_vpNoMove = new PositionalSound(_vpNoMoveOpt);
			_vpNoMove.load();
			//_app.audioManager.addSoundToBus(_vpNoMove, BusManager.SFX);

			//init core and prep zones
			this.zoomLv = 4;
			
			//segregating the zones
			_NEangle = Utility.angleDifference(0,0,_sizeWidth,-_sizeHeight);
			_NWangle = Utility.angleDifference(0,0,-_sizeWidth,-_sizeHeight);
			_SEangle = Utility.angleDifference(0,0,_sizeWidth,_sizeHeight);
			_SWangle = Utility.angleDifference(0,0,-_sizeWidth,_sizeHeight);
			

			//*TRY* to draw core
			_viewportLines = new Shape();
			_viewportLines.graphics.lineStyle(3,255);
			_viewportLines.graphics.moveTo(-_sizeWidth,-_sizeHeight);
			_viewportLines.graphics.lineTo(_sizeWidth,-_sizeHeight);
			_viewportLines.graphics.lineTo(_sizeWidth,_sizeHeight);
			_viewportLines.graphics.lineTo(-_sizeWidth,_sizeHeight);
			_viewportLines.graphics.lineTo(-_sizeWidth,-_sizeHeight);
			
			//draw prep zone
			_viewportLines.graphics.lineStyle(3,0x00FF00);
			_viewportLines.graphics.moveTo(-_prepSizeWidth,-_prepSizeHeight);
			_viewportLines.graphics.lineTo(_prepSizeWidth,-_prepSizeHeight);
			_viewportLines.graphics.lineTo(_prepSizeWidth,_prepSizeHeight);
			_viewportLines.graphics.lineTo(-_prepSizeWidth,_prepSizeHeight);
			_viewportLines.graphics.lineTo(-_prepSizeWidth,-_prepSizeHeight);
			
			//crossHair
			_viewportLines.graphics.drawCircle(_position_x, _position_y,2);
			this.addChild(_viewportLines);
			
			
		}
		
		public function get isMoving():Boolean
		{
			return _isMoving;
		}

		public function move(dir:String):void
		{
			if (dir != MOVE_STOP)
				_isMoving = true;
			else
				_isMoving = false;
			
			_direction = dir;
		}
		public function reDrawViewport():void
		{
			//*TRY* to draw core
			_viewportLines.graphics.clear();
			_viewportLines.graphics.lineStyle(3,255);
			_viewportLines.graphics.moveTo(-_sizeWidth,-_sizeHeight);
			_viewportLines.graphics.lineTo(_sizeWidth,-_sizeHeight);
			_viewportLines.graphics.lineTo(_sizeWidth,_sizeHeight);
			_viewportLines.graphics.lineTo(-_sizeWidth,_sizeHeight);
			_viewportLines.graphics.lineTo(-_sizeWidth,-_sizeHeight);
			
			//draw prep zone
			_viewportLines.graphics.lineStyle(3,0x00FF00);
			_viewportLines.graphics.moveTo(-_prepSizeWidth,-_prepSizeHeight);
			_viewportLines.graphics.lineTo(_prepSizeWidth,-_prepSizeHeight);
			_viewportLines.graphics.lineTo(_prepSizeWidth,_prepSizeHeight);
			_viewportLines.graphics.lineTo(-_prepSizeWidth,_prepSizeHeight);
			_viewportLines.graphics.lineTo(-_prepSizeWidth,-_prepSizeHeight);
			
			//crossHair
			_viewportLines.graphics.drawCircle(_position_x, _position_y,2);
			
		}
		public function updateVariable(frameTime:int):void
		{
			if (_isMoving)
			{
				if (checkWithinMovable())
				{	
					if (_direction == MOVE_UP)
					{
						if (checkUpBorder())
						{	
							this.y -= speed;
							_position3D.y = this.y;
						}
						else
						{
						//	_vpNoMove.load();
							_app.audioManager.addSoundToBus(_vpNoMove, BusManager.SFX);
							_vpNoMove.play();
						}
					}
					if (_direction == MOVE_DOWN)
					{
						if (checkBottomBorder())
						{	
							this.y += speed;
							_position3D.y = this.y;
						}
						else
						{
					//		_vpNoMove.load();
							_app.audioManager.addSoundToBus(_vpNoMove, BusManager.SFX);
							_vpNoMove.play();
						}
					}
					if (_direction == MOVE_LEFT)
					{
						if (checkLeftBorder())
						{
							this.x -= speed;
							_position3D.x = this.x;
						}
						else
						{
						//	_vpNoMove.load();
							_app.audioManager.addSoundToBus(_vpNoMove, BusManager.SFX);
							_vpNoMove.play();
						}
					}
					if (_direction == MOVE_RIGHT)
					{
						if (checkRightBorder())
						{
							this.x += speed;
							_position3D.x = this.x;
						}
						else
						{
					//		_vpNoMove.load();
							_app.audioManager.addSoundToBus(_vpNoMove, BusManager.SFX);
							_vpNoMove.play();
						}
					}
				}
			}
		}
		public function checkRightBorder():Boolean
		{
			//right border
			if (_position3D.x >= (_app.mainWindow.stage.stageWidth - _border_x))
			{
				this.x = (_app.mainWindow.stage.stageWidth - _border_x);
				_position3D.x = (_app.mainWindow.stage.stageWidth - _border_x);
				return false;
			}
			return true;
		}
		public function checkLeftBorder():Boolean
		{
			//left border
			if (_position3D.x <= _border_x)
			{
				this.x = _border_x;
				_position3D.x = _border_x;
				return false;
			}
			return true;
		}
		public function checkUpBorder():Boolean
		{
			//check top border
			if (_position3D.y <= _border_y)
			{
				this.y = _border_y;
				_position3D.y = _border_y;
				return false;
			}
			return true;
		}
		public function checkBottomBorder():Boolean
		{
			//bottom border
			if (_position3D.y >= (_app.mainWindow.stage.stageHeight - _border_y))
			{
				this.y = (_app.mainWindow.stage.stageHeight - _border_y);
				_position3D.y = (_app.mainWindow.stage.stageHeight - _border_y);
				return false;
			}
			return true;
		}
		public function checkWithinMovable():Boolean
		{
			//at 100% viewport, movement is not possible
			if (zoomLv == 0)
			{
				_position_x = _app.mainWindow.stage.stageWidth * 0.5;
				_position_y = _app.mainWindow.stage.stageHeight * 0.5;
				_position3D.x = _app.mainWindow.stage.stageWidth * 0.5;
				_position3D.y = _app.mainWindow.stage.stageHeight * 0.5;
				return false;
			}
			return true;

		}
		public function moveTo(x:int, y:int):void
		{
			_position_x = x;
			_position_y = y;
			_position3D.x = x;
			_position3D.y = y;
		}
		
		public function set zoomLv(zoomLv:Number):void
		{
			var zoomPercentage:Number = 1;
			
			
			_app.audioManager.addSoundToBus(_vpChng, BusManager.SFX);
			_vpChng.play();
			
//			var sndZoom:Sound = new Sound(new URLRequest("sounds/Kyun.mp3"));
//			var sndChan:SoundChannel; 
//			sndChan = sndZoom.play();
			
			_zoomLv = zoomLv;
			switch (zoomLv)
			{
				case 0:
					zoomPercentage = 1;
					BusManager.getBusManager().getBus(BusManager.MASTER).volume = 0.4;
					break;
				case 1:
					zoomPercentage = 0.75;
					BusManager.getBusManager().getBus(BusManager.MASTER).volume = 0.5;
					break;
				case 2:
					zoomPercentage = 0.55;
					BusManager.getBusManager().getBus(BusManager.MASTER).volume = 0.65;
					break;
				case 3:
					zoomPercentage = 0.38;
					BusManager.getBusManager().getBus(BusManager.MASTER).volume = 0.8;
					break;
				case 4:
					zoomPercentage = 0.10;
					BusManager.getBusManager().getBus(BusManager.MASTER).volume = 0.95;
					break;
				default:
					zoomPercentage = 1;
					BusManager.getBusManager().getBus(BusManager.MASTER).volume = 0.4;
					break;
			}
			
			//sets the w and h of the viewport
			_sizeWidth = _app.mainWindow.stage.stageWidth * zoomPercentage * 0.5;
			_sizeHeight = _app.mainWindow.stage.stageHeight * zoomPercentage * 0.5;
			
			//sets the border distances
			_border_x = _sizeWidth;
			_border_y = _sizeHeight;
			
			//prevent "hang" bug when resized
			checkUpBorder();
			checkBottomBorder();
			checkLeftBorder();
			checkRightBorder();
			
			//sets size of prepZone
			this.prepZonePercentage = _prepZonePercentage;
		}
		
		public function get zoomLv():Number
		{
			return _zoomLv;
		}
		
		public function set sizeWidth(width:int):void
		{
			_sizeWidth = width * 0.5;
		}
		
		public function set sizeHeight(height:int):void
		{
			_sizeHeight = height * 0.5;
		}
		
		public function get sizeWidth():int
		{
			return _sizeWidth * 2;
		}
		
		public function get sizeHeight():int
		{
			return _sizeHeight * 2;
		}
		
		public function get position3D():Vector3D
		{
			return _position3D;
		}
		public function set position_x(x:int):void
		{
			_position_x = x;
			_position3D.x = x;
		}
		
		public function set position_y(y:int):void
		{
			_position_y = y;
			_position3D.y = y;
		}
		
		public function get position_x():int
		{
			return _position3D.x;
		}
		
		public function get position_y():int
		{
			return _position3D.y;
		}
		
		public function set speed(speed:Number):void
		{
			_speed = speed;
		}
		
		public function get speed():Number
		{
			return _speed;
		}
		
		public function set border_x(border_x:int):void
		{
			_border_x = border_x;
		}
		
		public function set border_y(border_y:int):void
		{
			_border_y = border_y;
		}
		
		public function get border_x():int
		{
			return _border_x;
		}
		
		public function get border_y():int
		{
			return _border_y;
		}
		
		
		
		public function set prepZonePercentage(prepZonePercent:Number):void
		{
			if (prepZonePercent >= 1)
				_prepZonePercentage = prepZonePercent;
			else
				_prepZonePercentage = 1;
			
			_prepSizeWidth = _sizeWidth * _prepZonePercentage;
			_prepSizeHeight = _sizeHeight * _prepZonePercentage;
		}
		
		public function get prepZonePercentage():Number
		{
			return _prepZonePercentage;
		}
		
		public function checkZone(IPSnd:IPositionalSound):String
		{
			//checks if is outside prep zone
			//checks top
			if (IPSnd.position.y < (_position3D.y - _prepSizeHeight))
				return OUT;
			
			//checks bottom
			if (IPSnd.position.y > (_position3D.y + _prepSizeHeight))
				return OUT;
			
			//checks left
			if (IPSnd.position.x < (_position3D.x - _prepSizeWidth))
				return OUT;
			
			//checks right
			if (IPSnd.position.x > (_position3D.x + _prepSizeWidth))
				return OUT;
			
			//IPSnd is within prep zone
			//checks core
			if ( (IPSnd.position.y >= (_position3D.y - _sizeHeight))
				&& (IPSnd.position.y <= (_position3D.y + _sizeHeight))
				&& (IPSnd.position.x >= (_position3D.x - _sizeWidth))
				&& (IPSnd.position.x <= (_position3D.x + _sizeWidth)) )
				return CORE;
			
			//IPSnd is not in core, checks which prep zone is it in
			var angleZone:Number = Utility.angleDifference(this._position3D.x, this._position3D.y,IPSnd.position.x, IPSnd.position.y);
			
			//right
			if ((angleZone <= _SEangle) && (angleZone > _NEangle))
				return RIGHT;
			
			//top
			if ((angleZone <= _NEangle) && (angleZone > _NWangle))
				return TOP;
			
			//bottom
			if ((angleZone > _SEangle) && (angleZone < _SWangle))
				return BOTTOM;
			
			//those left are left... literally
			return LEFT;
		}
	}
}