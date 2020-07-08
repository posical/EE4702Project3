package engine.classes
{
	import engine.events.DebugEvent;
	import engine.interfaces.IDebug;
	import engine.utils.StageMapping;
	
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Vector3D;
	
	/**
	 * Anything that moves is an Entity.
	 * This class should be inherited instead of just be used "as is".
	 */
	public class Entity extends Sprite implements IDebug
	{
		// Constants
		public static const MOVE_FRONT:String = "moveFront";
		public static const MOVE_BACK:String = "moveBack";
		public static const MOVE_LEFT:String = "moveLeft";
		public static const MOVE_RIGHT:String = "moveRight";
		
		private static const DEG_TO_RAD:Number = Math.PI / 180.0;
		private static const RAD_TO_DEG:Number = 180.0 / Math.PI;
		
		// Variables
		protected var _app:App;
		
		protected var _sightRadius:int;
		protected var _sightAngle:int;
		
		////////////////////////////////////////////
		// Mechanical Physics
		////////////////////////////////////////////
		protected var _isMoving:Boolean;
		protected var _moveDirectionAngle:Number;
		protected var _maxVelocity:Number;
		protected var _velocity:Number;
		protected var _acceleration:Number;
		protected var _deceleration:Number;
		
		protected var _rotateStep:Number;
		protected var _facingAngle:Number;
		
		// Debug
		protected var _debugCanvas:Sprite;
		
		/**
		 * Constructor.
		 */
		public function Entity(app:App)
		{
			super();
			
			trace("Entity::ctor().");
			
			if(app == null) {
				throw new Error("Entity::ctor() Bad App reference.");
				return;
			}
			_app = app;
			
			_sightRadius = 100;
			_sightAngle = 60;
			
			////////////////////////////////////////////
			// Movements and Rotations
			////////////////////////////////////////////
			_isMoving = false;
			_moveDirectionAngle = 0;
			_maxVelocity = 150;
			_velocity = 0;
			_acceleration = 150;
			_deceleration = 8;
			
			_rotateStep = 0;
			_facingAngle = 0;
			
			prepareDebugCanvas();
		}
		
		/**
		 * Set this Entity to be moving.
		 * This will not actually move the Entity, it just marks the Entity
		 * to be moving.
		 * @param direction Indicates the direction of moving.
		 */
		public function move(direction:String):void
		{
			_isMoving = true;
			
			if (direction == MOVE_FRONT) {
				_moveDirectionAngle = 0;
			} else if (direction == MOVE_BACK) {
				_moveDirectionAngle = 180;
			} else if (direction == MOVE_LEFT) {
				_moveDirectionAngle = -90;
			} else if (direction == MOVE_RIGHT) {
				_moveDirectionAngle = 90;
			} else {
				_moveDirectionAngle = 0;
				_isMoving = false;
			}
		}
		
		/**
		 * Set the rotating angle in degree.
		 * This will not actually rotate the Entity, it just set an angle
		 * for the Entity to rotate over time.
		 * @param angle The angle to rotate in degree.
		 */
		public function turn(angle:Number):void
		{
			_rotateStep = angle;
		}
		
		/**
		 * Stop the Entity from rotating.
		 */
		public function stopTurn():void
		{
			_rotateStep = 0;
		}
		
		/**
		 * Stop the Entity from moving.
		 */
		public function stopMove():void
		{
			_isMoving = false;
		}
		
		/**
		 * Update frame time dependent logics.
		 * This will actually move and rotate the Entity.
		 * @param frameTime The time in milliseconds from the previous frame to
		 * current frame.
		 */
		public function onEnterFrame(frameTime:int):void
		{
			////////////////////////////////////////////
			// Mechanical physics
			////////////////////////////////////////////
			if(_isMoving) {
				_velocity += _acceleration;
				if(_velocity > _maxVelocity)
					_velocity = _maxVelocity;
			} else { // Stopping down
				if(Math.abs(_velocity) < _deceleration) {
					_velocity = 0;
				} else {
					_velocity += (_velocity > 0) ? -_deceleration : _deceleration;
				}
			}
			
			if(_rotateStep != 0) {
				_facingAngle +=  _rotateStep;
				
				while(_facingAngle < 0)
					_facingAngle += 360;
				while(_facingAngle > 360)
					_facingAngle -= 360;
			}
			
			this.rotation = _facingAngle;
			this.x += _velocity * Math.cos((_facingAngle + _moveDirectionAngle) * DEG_TO_RAD) * frameTime / 1000.0;
			this.y += _velocity * Math.sin((_facingAngle + _moveDirectionAngle) * DEG_TO_RAD) * frameTime / 1000.0;
		}
		
		protected function prepareDebugCanvas():void
		{
			_debugCanvas = new Sprite();
			
			var _lineOfSightCone:Shape = new Shape();
			_lineOfSightCone.graphics.beginFill(0x000000, 0.1);
			_lineOfSightCone.graphics.lineStyle (1, 0, 1, true);
			drawSector(_lineOfSightCone.graphics, 0, 0, _sightRadius, _sightAngle, -_sightAngle/2.0);
			_lineOfSightCone.graphics.endFill();
			_debugCanvas.addChild(_lineOfSightCone);
		}
		
		private function drawSector(graphic:Graphics, x:Number, y:Number, radius:Number, angle:Number, startA:Number):void
		{
			if (Math.abs(angle) > 360) {
				angle = 360;
			}
			
			var n:Number = Math.ceil(Math.abs(angle) / 45);
			var angleA:Number = angle / n;
			
			angleA = angleA * DEG_TO_RAD;
			startA = startA * DEG_TO_RAD;
			
			var startB:Number = startA;
			
			graphic.lineTo(x + radius * Math.cos(startA), y + radius * Math.sin(startA));
			
			for (var i:uint = 1; i <= n; i++)
			{
				startA += angleA;
				
				var angleMid1:Number = startA - angleA / 2;
				var bx:Number = x + radius / Math.cos(angleA / 2) * Math.cos(angleMid1);
				var by:Number = y + radius / Math.cos(angleA / 2) * Math.sin(angleMid1);
				var cx:Number = x + radius * Math.cos(startA);
				var cy:Number = y + radius * Math.sin(startA);
				
				graphic.curveTo(bx, by, cx, cy);
			}
		}
		
		public function handleDebugEvents(e:DebugEvent):void
		{
			switch(e.type) {
				////////////////////////////////////////////
				case DebugEvent.ENTER_DEBUG:
					this.addChildAt(_debugCanvas, 0);
					break;
				
				////////////////////////////////////////////
				case DebugEvent.EXIT_DEBUG:
					if(this.contains(_debugCanvas)) {
						this.removeChild(_debugCanvas);
					}
					break;
				
				////////////////////////////////////////////
			}
		}
		
		public function isInLineOfSight(obj:Entity):Boolean
		{
			var relativeVector:Vector3D;
			var angleFromLookAt:Number;
			var result:Boolean = false;
			
			// Vector pointing from obj to this npc
			relativeVector = obj.pos.subtract(this.pos);
			angleFromLookAt = Vector3D.angleBetween(relativeVector, this.lookAt) * RAD_TO_DEG;
			
			if((angleFromLookAt < _sightAngle / 2) && isInRadius(obj)) {
				result = true;
			} else {
				result = false;
			}
			
			return result;
		}
		
		public function isInRadius(obj:Entity):Boolean
		{
			if(obj == null) {
				return false;
			}
			
			return Vector3D.distance(this.pos, obj.pos) <= _sightRadius;
		}
		
		////////////////////////////////////////////
		// Accessors and Mutators
		////////////////////////////////////////////
		public override function set rotation(angle:Number):void
		{
			_facingAngle = angle;
			super.rotation = angle;
		}
		
		/**
		 * Get the angle in degree that this Entity is facing.
		 * The angle starts from 0 at the positive-x axis. Clockwise.
		 * @return Facing angle.
		 */
		public function get facingAngle():Number
		{
			return _facingAngle;
		}
		
		/**
		 * Set the angle in degree that this Entity is facing.
		 * The angle starts from 0 at the positive-x axis. Clockwise.
		 * @param angle The angle in degree that this Entity is to face.
		 */
		public function set facingAngle(angle:Number):void
		{
			var newAngle:Number = angle;
			
			while(newAngle < 0 || newAngle > 360) {
				if(newAngle < 0)
					newAngle += 360;
				else
					newAngle -= 360;
			}
			
			_facingAngle = newAngle;
		}
		
		/**
		 * Get the velocity (per millisecond) of this Entity.
		 * @return The velocity of this Entity.
		 */
		public function get velocity():Number
		{
			return _velocity;
		}
		
		/**
		 * Get the acceleration of this Entity.
		 * @return The acceleration of this Entity.
		 */
		public function get acceleration():Number
		{
			return _acceleration;
		}
		
		/**
		 * Set the acceleration of this Entity.
		 * @param accel Acceleration to be set
		 */
		public function set acceleration(accel:Number):void
		{
			_acceleration = accel;
		}
		
		public function get deceleration():Number
		{
			return _deceleration;
		}
		
		public function get pos():Vector3D
		{
			return new Vector3D(StageMapping.mapX(this), StageMapping.mapY(this), StageMapping.mapZ(this));
		}
		
		public function get lookAt():Vector3D
		{
			var result:Vector3D = new Vector3D();
			var rot:Number = StageMapping.mapRotation(this);
			result.x = Math.cos(rot * DEG_TO_RAD);
			result.y = Math.sin(rot * DEG_TO_RAD);
			result.normalize();
			return result;
		}
	}
}