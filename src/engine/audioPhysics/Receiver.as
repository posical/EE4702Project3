package engine.audioPhysics
{
	import engine.events.DebugEvent;
	import engine.interfaces.IDebug;
	import engine.utils.StageMapping;
	
	import flash.display.GraphicsPathCommand;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	
	public class Receiver extends Sprite implements IDebug
	{
		protected static const DEG_TO_RAD:Number = Math.PI / 180.0;
		protected static const RAD_TO_DEG:Number = 180.0 / Math.PI;
		protected static const SOUND_SPEED_KMPS:Number = 0.34029;
		
		////////////////////////////////////////////
		// Debug
		////////////////////////////////////////////
		protected var _debugCanvas:Sprite;
		
		public function Receiver()
		{
			
			////////////////////////////////////////////
			// Debug
			////////////////////////////////////////////
			prepareDebugCanvas();
		}
		
		private function prepareDebugCanvas():void
		{
			_debugCanvas = new Sprite();
			
			var vectorLines:Shape = new Shape();
			var commands:Vector.<int> = Vector.<int>([
				GraphicsPathCommand.MOVE_TO,
				GraphicsPathCommand.LINE_TO,
				GraphicsPathCommand.MOVE_TO,
				GraphicsPathCommand.LINE_TO]);
			var coordinates:Vector.<Number> = Vector.<Number>([
				-20, 0, // x, y
				50, 0,
				0, -30,
				0, 30]);
			
			vectorLines.graphics.lineStyle(1, 0x000000, 1, true);
			vectorLines.graphics.beginFill(0x000000);
			vectorLines.graphics.drawPath(commands, coordinates);
			vectorLines.graphics.endFill();
			_debugCanvas.addChild(vectorLines);
		}
		
		public function handleDebugEvents(e:DebugEvent):void
		{
			switch(e.type) {
				////////////////////////////////////////////
				case DebugEvent.ENTER_DEBUG:
					this.addChild(_debugCanvas);
					break;
				
				////////////////////////////////////////////
				case DebugEvent.EXIT_DEBUG:
					this.removeChild(_debugCanvas);
					break;
				
				////////////////////////////////////////////
			}
		}
		
		/**
		 * Check whether the Receiver can hear from a Source.
		 * This will calculate _coneGain as well.
		 * @param s Source to be checked.
		 * @return true if the Receiver can hear from Source, false otherwise.
		 */
		public function canHear(s:Source):Boolean
		{
			if(!s.isPlaying) {
				return false;
			}
			
			var relativeVector:Vector3D;
			var angleFromLookAt:Number;
			var result:Boolean = false;
			
			// Vector pointing from Receiver to Source
			relativeVector = this.pos.subtract(s.pos);
			angleFromLookAt = Vector3D.angleBetween(relativeVector, s.lookAt) * RAD_TO_DEG;
			
			if(angleFromLookAt < s.primaryConeAngle / 2) {
				if(relativeVector.length <= s.propagationRange) {
					result = true;
				}
			} else if (angleFromLookAt < s.secondaryConeAngle / 2) {
				if(relativeVector.length <= s.propagationRange) {
					result = true;
				}
			} else {
				result = false;
			}
			
			return result;
		}
		
		/**
		 * Simulate the cone effect.
		 * @param s Source to be checked.
		 * @return Cone gain depending on different cone that the Receiver resides in.
		 */
		public function coneGainFrom(s:Source):Number
		{
			var relativeVector:Vector3D;
			var gain:Number;
			var angleFromLookAt:Number;
			
			// Vector pointing from Receiver to Source
			relativeVector = this.pos.subtract(s.pos);
			angleFromLookAt = Vector3D.angleBetween(relativeVector, s.lookAt) * RAD_TO_DEG;
			
			// Gain calculation
			if(angleFromLookAt < s.primaryConeAngle / 2) {
				gain = 1;
			} else if (angleFromLookAt < s.secondaryConeAngle / 2) {
				gain = (s.secondaryConeAngle - angleFromLookAt*2) / (s.secondaryConeAngle - s.primaryConeAngle);
			} else {
				gain = 0;
			}
			
			return gain;
		}
		
		/**
		 * Simulate panning effect.
		 * @param s Source to be checked.
		 * @return Panning gain for left and right channel.
		 */
		public function panningGainFrom(s:Source):PanningGain
		{
			var gain:PanningGain = new PanningGain();
			var leftAngle:Number;
			var rightAngle:Number;
			var relativeVector:Vector3D;
			var rightdirection:Vector3D;
			var leftdirection:Vector3D;

			// Vector pointing from Receiver to Source
			relativeVector = this.pos.subtract(s.pos);
			leftdirection= (this.upVector).crossProduct(this.lookAt);
			rightdirection=(this.lookAt).crossProduct(this.upVector);
			
			rightAngle = Vector3D.angleBetween(rightdirection, relativeVector) ;
			leftAngle = Vector3D.angleBetween(leftdirection, relativeVector) ;
			gain.leftGain = Math.cos(leftAngle/2);
			gain.rightGain = Math.cos((rightAngle)/2);
			
			return gain;
		}
		
		/**
		 * Simulate delay effect.
		 * @param s Source to be checked.
		 * @return Delay in milliseconds from the Source to the Receiver.
		 */
		public function delayFrom(s:Source):Number
		{
			var distance:Number = Vector3D.distance(s.pos, this.pos);
			
			// delay is distance between objects divided by speed of sound in km/s
			// delay is returned in milliseconds
			return (distance / SOUND_SPEED_KMPS)*1000;
		}
		
		/**
		 * Simulate attenuation effect.
		 * @param s Source to be checked.
		 * @return Volume gain due to attenuation.
		 */
		public function attenuationFrom(s:Source):Number
		{
			var gain:Number = 1.0;
			var distance:Number = Vector3D.distance(s.pos, this.pos);
			
			//Set the gains as a factor of distance from source/range of source
			if(distance > s.propagationRange) {
				gain = 0;
			} else {
				gain = (s.propagationRange-distance)/ (distance + 0.2 * (distance));
			}
			
			return Math.min(gain, 1.0);
		}
		
		public function calculateLineTo(s:Source):Line
		{
			return new Line(this.pos, new Vector3D(s.x,s.y,s.z));
		}
		
		////////////////////////////////////////////
		// Accessors and Mutators
		////////////////////////////////////////////
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
		
		public function get upVector():Vector3D
		{
			// Constant up vector
			return new Vector3D(0, 0, 1);
		}
	}
	
}