package engine.audioPhysics
{
	import engine.interfaces.ISoundObstructable;
	import engine.utils.StageRef;
	
	import flash.display.Sprite;
	import flash.geom.Vector3D;
	
	public class Wall extends Sprite implements ISoundObstructable 
	{
		protected static const DEG_TO_RAD:Number = Math.PI / 180.0;
		
		////////////////////////////////////////////
		// Properties
		////////////////////////////////////////////
		private var _startPos:Vector3D;
		private var _endPos:Vector3D;
		private var _surface:Line;
		private var _length:Number;
		private var _thickness:Number;
		private var _reflectiveFactor:Number;
		
		// Constructor
		public function Wall(startingPosition:Vector3D, endingPosition:Vector3D, width:Number, reflectiveFactor:Number)	
		{
			super();
			_startPos = startingPosition;
			_endPos = endingPosition;
			_surface = new Line(startingPosition, endingPosition);
			_length = _surface.magnitude;
			_thickness = width;
			_reflectiveFactor = reflectiveFactor;
			
			this.renderInCurrentScene();
			return;
		}
		
		////////////////////////////////////////////
		// Boolean Methods
		////////////////////////////////////////////
		public function hasReflectedRayFromLine(incidentRay:Line):Boolean
		{
			return (this.surface.getIntersectionWith(incidentRay) != null);
		}
		
		public function hasReflectedRayFromSource(incidentSource:Source):Boolean
		{
			return (this.surface.getIntersectionWith(incidentSource.emit) != null);
		}
		
		////////////////////////////////////////////
		// Calculation Methods for ReflectedRay
		////////////////////////////////////////////
		
		// Calculates a reflected ray from incidentRay:Line on the surface:Line of wall. Returns the reflectedRay:Line
		
		public function calculateReflectedRayFromLine(incidentRay:Line):Line
		{
			// Variables used for ReflectedRay
			var reflectedRayAngle:Number;
			var reflectedRayLength:Number;
			var reflectedRayStartPos:Vector3D = new Vector3D();
			var reflectedRayEndPos:Vector3D = new Vector3D();
			
			var intersection:Vector3D = this.surface.getIntersectionWith(incidentRay);
			
			// Temporary variables
			// TODO: Figure out what is this tempNumber7
			var tempNumber7:Number;
			
			if(this.surface.gradient == 0) { // Horizontal
				reflectedRayStartPos.x = incidentRay.startPos.x;
				reflectedRayStartPos.y = 2*this.surface.startPos.y - incidentRay.startPos.y;
			} else {
				var perpendicularX:Number = incidentRay.startPos.x + (incidentRay.startPos.y - this.surface.yItercept)*this.surface.gradient;
				tempNumber7 = perpendicularX/(1 + (this.surface.gradient)*(this.surface.gradient));
				reflectedRayStartPos.x = 2*tempNumber7 - incidentRay.startPos.x;
				reflectedRayStartPos.y = 2*tempNumber7*this.surface.gradient - incidentRay.startPos.y + 2*this.surface.yItercept;
			}
			
			// Calculate angle and length
			reflectedRayAngle = (2*this.surface.directionAngleDegree - incidentRay.directionAngleDegree) * DEG_TO_RAD;

			reflectedRayLength = Math.sqrt((((incidentRay.endPos.x - intersection.x) * (incidentRay.endPos.x - intersection.x)) + 
					((incidentRay.endPos.y - intersection.y) * (incidentRay.endPos.y - intersection.y))));
			
			// Adjust length with reflective factor
			reflectedRayLength *= this.reflectiveFactor;
			
			// Calculate the ending position
			reflectedRayEndPos.x = (intersection.x + (reflectedRayLength * Math.cos(reflectedRayAngle)));
			reflectedRayEndPos.y = (intersection.y + (reflectedRayLength * Math.sin(reflectedRayAngle)));
			
			return new Line(reflectedRayStartPos, reflectedRayEndPos);
		}
		
		// creates & returns a virtualSource:Source based on a given incidentSource:Source
		public function generateVirtualSource(incidentSource:Source):Source
		{
			var reflectedRay:Line = this.calculateReflectedRayFromLine(incidentSource.emit);
			
			//Source is removed at end as it is a reflected virtual source
			var virtualSource:Source = new Source(incidentSource, "", true, reflectedRay);
			virtualSource.reflectNumber = incidentSource.reflectNumber - 1;
			
			return virtualSource;
		}
		
		public function applyOcclusionFilter(w:Wall):void
		{
			// TODO Auto Generated method stub
			
		}
		
		public function isOccludingSourceFromReceiver(s:Source, r:Receiver):Boolean
		{
			var sourceToReceiver:Line = new Line(s.pos, r.pos);
			
			return (sourceToReceiver.getIntersectionWith(this.surface) != null);
		}
		
		////////////////////////////////////////////
		// Graphical rendering methods
		////////////////////////////////////////////
		public function renderInCurrentScene():void
		{
			this.graphics.lineStyle(this.thickness,0x3A3D42);
			this.graphics.beginFill(0x3A3D42);
			this.graphics.moveTo(this.startPos.x,this.startPos.y);
			this.graphics.lineTo(this.endPos.x,this.endPos.y);
			StageRef.stage.addChild(this);
		}
		public function removeFromCurrentStage():void
		{
			StageRef.stage.removeChild(this);		
			return;
		}
		
		////////////////////////////////////////////
		// Accessors and Mutators
		////////////////////////////////////////////
		public function get startPos():Vector3D
		{
			return _startPos;
		}
		
		public function get endPos():Vector3D
		{
			return _endPos;
		}
		
		public function get surface():Line
		{
			return _surface;
		}
		
		public function get length():Number
		{
			return _length;
		}
		
		public function get thickness():Number
		{
			return _thickness;
		}
		
		public function set thickness(w:Number):void
		{
			_thickness = w;
		}
		
		public function get reflectiveFactor():Number
		{
			return _reflectiveFactor;
		}
		
		public function set reflectiveFactor(factor:Number):void
		{
			_reflectiveFactor = Math.max(Math.min(factor, 1), 0);
		}
	}
}