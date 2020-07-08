// ActionScript file
//written by: kenneth and Chun kit
package engine.visualRepresentation
{
	import engine.classes.App;
	import engine.utils.Utility;
	import engine.utils.Color;
	
	public class MovableAvatar extends StaticAvatar
	{
		//moving variables
		private var _isMoving:Boolean = false;
		private var _speed:Number = 1;
		private var _endPt_x:int;
		private var _endPt_y:int;
		//for paradeMass
		private var _startPt_x:int;
		private var _startPt_y:int;
		private var _hasTurned:Boolean = false;
		
		//rotating variables
		private var _turningPt_x:int;
		private var _turningPt_y:int;
		private var _facingAngle:Number = 45;
		
		//checking flag for ParadeMass
		private var _hasChecked:Boolean = false;
		
		public function MovableAvatar(app:App, color:uint = Color.YELLOW)
		{
			super(app,color);
		}
		
		public function get startPt_y():int
		{
			return _startPt_y;
		}

		public function get startPt_x():int
		{
			return _startPt_x;
		}

		public function get hasChecked():Boolean
		{
			return _hasChecked;
		}

		public function set hasChecked(value:Boolean):void
		{
			_hasChecked = value;
		}

		public function get endPt_y():int
		{
			return _endPt_y;
		}

		public function set endPt_y(value:int):void
		{
			_endPt_y = value;
		}

		public function get endPt_x():int
		{
			return _endPt_x;
		}

		public function set endPt_x(value:int):void
		{
			_endPt_x = value;
		}

		public function get hasTurned():Boolean
		{
			return _hasTurned;
		}

		public function set hasTurned(value:Boolean):void
		{
			_hasTurned = value;
		}

		public function setStartPt(x:int, y:int):void
		{
			_startPt_x = x;
			_startPt_y = y;
		}
		public function setEndPt(x:int, y:int):void
		{
			_endPt_x = x;
			_endPt_y = y;
		}

		public function get turningPt_x():int
		{
			return _turningPt_x;
		}

		public function set turningPt_x(value:int):void
		{
			_turningPt_x = value;
		}

		public function get turningPt_y():int
		{
			return _turningPt_y;
		}

		public function set turningPt_y(value:int):void
		{
			_turningPt_y = value;
		}

		public function get facingAngle():Number
		{
			return _facingAngle;
		}

		public function set facingAngle(value:Number):void
		{
			_facingAngle = value;
		}

		public function updateVariable():void
		{
			 _facingAngle = this.rotation;
			if (_isMoving)
			{
				this.x += _speed * Math.cos(this.rotation * Utility.DEG_TO_RAD);// * frameTime / 1000.0;
				this.y += _speed * Math.sin(this.rotation * Utility.DEG_TO_RAD);// * frameTime / 1000.0;
			}
		}
		public function get speed():Number
		{
			return _speed;
		}
		
		public function set speed(value:Number):void
		{
			_speed = value;
		}
		public function turnTo(x:int, y:int):void
		{
			this.rotation = Utility.angleDifference(this.x,this.y,x,y);
		}
		public function setPivot(x:int, y:int):void
		{
			_turningPt_x = x;
			_turningPt_y = y;
		}
		public function walkedStraightTo(_destX:int, _destY:int):Boolean
		{
			var nextStepAngle:Number = Utility.angleDifference(this.x,this.y,_destX,_destY);

			//idea is to check if current angle is the same sign (+ or -) as the previous angle
			//if is same, havent reached yet.
			//trace ("ang diff: " + nextStepAngle);
			//trace ("this.x: " + this.x + "    this.y: " + this.y);
			if (this.rotation > 0)
			{
				if (nextStepAngle <= 0)
				{
					_isMoving = false;				
					return true;
				}
				else
				{
					this.rotation = nextStepAngle;
					_isMoving = true;	
					return false;
				}
			}
			else if (this.rotation < 0)
			{
				if (nextStepAngle >= 0)
				{
					_isMoving = false;	
					return true;
				}
				else
				{
					this.rotation = nextStepAngle;
					_isMoving = true;	
					return false;
				}	
			}
			else if (this.rotation == 0)
			{
				if (nextStepAngle == 180)
				{
					_isMoving = false;	
					return true;
				}
				else
				{
					this.rotation = nextStepAngle;
					_isMoving = true;	
					return false;
				}
			}
			else
			{
				if (nextStepAngle == 0)
				{
					_isMoving = false;	
					return true;
				}
				else
				{
					this.rotation = nextStepAngle;
					_isMoving = true;	
					return false;
				}
			}
			return false;			
		}
	}
}