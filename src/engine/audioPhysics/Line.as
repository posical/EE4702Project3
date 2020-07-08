package engine.audioPhysics
{   
	import flash.display.*;
	import flash.geom.*;
	
	/**
	 * Provides a concrete mechanism to deal with straight lines.
	 * This class uses Stage coordinates for all of its calculations.
	 */
	public class Line extends Sprite
	{
		protected static const RAD_TO_DEG:Number = 180.0 / Math.PI;
		
		/** The starting position of the line. */
		public var _startPos:Vector3D;
		
		/** The ending position of the line. */
		public var _endPos:Vector3D;
		
		/**
		 * Constructor.
		 * @param startingPosition The starting position of the line.
		 * @param endingPosition The ending position of the line.
		 */
		public function Line(startingPosition:Vector3D, endingPosition:Vector3D)
		{
			_startPos = startingPosition;
			_endPos = endingPosition;
		}
		
		/**
		 * Update the starting and ending position of the line.
		 * @param startX x-coordinate of starting position.
		 * @param startY y-coordinate of starting position.
		 * @param startZ z-coordinate of starting position.
		 * @param endX x-coordinate of ending position.
		 * @param endY y-coordinate of ending position.
		 * @param endZ z-coordinate of ending position.
		 */
		public function update(startX:Number, startY:Number, startZ:Number, endX:Number, endY:Number, endZ:Number):void
		{
			_startPos.x = startX;
			_startPos.y = startY;
			_startPos.z = startZ;
			_endPos.x = endX;
			_endPos.y = endY;
			_endPos.z = endZ;
		}
		
		/**
		 * Check whether this line is parallel to another line.
		 * @param anotherLine The line to be checked with.
		 * @return True if the lines are parallel, otherwise false.
		 */
		public function isParallelWith(anotherLine:Line):Boolean
		{
			return (this.lineVector.dotProduct(anotherLine.lineVector) == 1);
		}
		
		/**
		 * Compute the intersection of this line with another line, if there is any.
		 * @param anotherLine The line to be checked with.
		 * @return  A Vector3D that represents the intersection point. If there is no
		 * 			intersection, null is returned instead.
		 */
		public function getIntersectionWith(anotherLine:Line):Vector3D
		{
			// The following represents a single line with start and end points (Determinant Form)
			// |  x  y 1 |
			// | x1 y1 1 | = 0
			// | x2 y2 1 |
			// Thus (y1 - y2)x + (x2 - x1)y + (x1*y2 - x2*y1) = 0   (ax + by + c = 0)
			
			var intersection:Vector3D = new Vector3D();
			var a1:Number = this.startPos.y - this.endPos.y;
			var b1:Number = this.endPos.x - this.startPos.x;
			var c1:Number = (this.startPos.x * this.endPos.y) - (this.endPos.x * this.startPos.y);
			var a2:Number = anotherLine.startPos.y - anotherLine.endPos.y;
			var b2:Number = anotherLine.endPos.x - anotherLine.startPos.x;
			var c2:Number = (anotherLine.startPos.x * anotherLine.endPos.y) - (anotherLine.endPos.x * anotherLine.startPos.y);
			
			// Cramer's Rule is employed to get the intersection point
			var denominator:Number = a1*b2 - a2*b1;
			if (denominator == 0) {
				return null;
			}
			
			intersection.x = (b1*c2 - b2*c1) / denominator;
			intersection.y = (a2*c1 - a1*c2) / denominator;
			
			// These check whether the intersection point is on both lines
			// TODO: Well are these really needed, or maybe let it to be optional
			if(Math.pow(intersection.x - this.endPos.x, 2) + Math.pow(intersection.y - this.endPos.y, 2) > 
				Math.pow(this.startPos.x - this.endPos.x, 2) + Math.pow(this.startPos.y - this.endPos.y, 2))
			{
				return null;
			}
			
			if(Math.pow(intersection.x - this.startPos.x, 2) + Math.pow(intersection.y - this.startPos.y, 2) > 
				Math.pow(this.startPos.x - this.endPos.x, 2) + Math.pow(this.startPos.y - this.endPos.y, 2))
			{
				return null;
			}
			
			if(Math.pow(intersection.x - anotherLine.endPos.x, 2) + Math.pow(intersection.y - anotherLine.endPos.y, 2) > 
				Math.pow(anotherLine.startPos.x - anotherLine.endPos.x, 2) + Math.pow(anotherLine.startPos.y - anotherLine.endPos.y, 2))
			{
				return null;
			}
			
			if(Math.pow(intersection.x - anotherLine.startPos.x, 2) + Math.pow(intersection.y - anotherLine.startPos.y, 2) > 
				Math.pow(anotherLine.startPos.x - anotherLine.endPos.x, 2) + Math.pow(anotherLine.startPos.y - anotherLine.endPos.y, 2))
			{
				return null;
			}
			
			return intersection;
		}
		
		////////////////////////////////////////////
		// Accessors and Mutators
		////////////////////////////////////////////
		/**
		 * The direction of the line (vector form) in radians.
		 */
		public function get directionAngle():Number
		{
			return Math.atan2(this.lineVector.y, this.lineVector.x);
		}
		
		/**
		 * The direction of the line (vector form) in degree.
		 */
		public function get directionAngleDegree():Number
		{
			return this.directionAngle * RAD_TO_DEG;
		}
		
		/**
		 * The starting position of the line.
		 */
		public function get startPos():Vector3D 
		{
			return _startPos;
		}
		
		/**
		 * The ending position of the line.
		 */
		public function get endPos():Vector3D
		{
			return _endPos;
		}
		
		/**
		 * The magnitude (length) of the line.
		 */
		public function get magnitude():Number
		{
			return Math.sqrt(((this.lineVector.x * this.lineVector.x) + (this.lineVector.y * this.lineVector.y)));
		}
		
		/**
		 * Representation of the line in vector form. Assumes a shift of
		 * the line to be started from the origin.
		 */
		public function get lineVector():Vector3D
		{
			return new Vector3D(
				this.endPos.x - this.startPos.x,
				this.endPos.y - this.startPos.y,
				this.endPos.z - this.startPos.z);
		}
		
		/**
		 * The gradient of the line.
		 */
		public function get gradient():Number
		{
			return (this.endPos.y - this.startPos.y) / (this.endPos.x - this.startPos.x);
		}
		
		/**
		 * The y-intercept of the line.
		 */
		public function get yItercept():Number
		{
			return this.endPos.y - (this.gradient * this.endPos.x);
		}
		
	}
}

