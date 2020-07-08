package engine.interfaces
{
	import engine.audioPhysics.Line;
	import engine.audioPhysics.Receiver;
	import engine.audioPhysics.Source;
	import engine.audioPhysics.Wall;
	
	public interface ISoundObstructable
	{
		////////////////////////////////////////////
		// Reflection
		////////////////////////////////////////////
		function hasReflectedRayFromLine(incidentRay:Line):Boolean;
		
		function hasReflectedRayFromSource(incidentSource:Source):Boolean;
		
		function calculateReflectedRayFromLine(incidentRay:Line):Line;
		
		function generateVirtualSource(incidentSource:Source):Source;
		
		////////////////////////////////////////////
		// Occlussion
		////////////////////////////////////////////
		function isOccludingSourceFromReceiver(s:Source, r:Receiver):Boolean;
		function applyOcclusionFilter(w:Wall):void;
		
		////////////////////////////////////////////
		// Accessors and Mutators
		////////////////////////////////////////////
		function get surface():Line;
		
		function get reflectiveFactor():Number;
		
		function set reflectiveFactor(d:Number):void;
	}
}