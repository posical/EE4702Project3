// ActionScript file
package engine.utils
{
	import engine.audio.PositionalSound;
	import engine.visualRepresentation.*;
	
	public class LevelOfDetailNode
	{
		private var _debugZone:String;
		private var _stoner:StaticAvatar;
		private var _childrenNode:Vector.<LevelOfDetailNode>;
		private var _parentNode:LevelOfDetailNode;
		public function LevelOfDetailNode(isRoot:Boolean = false)
		{
			_childrenNode = new Vector.<LevelOfDetailNode>();
		}

		public function get debugZone():String
		{
			return _debugZone;
		}

		public function set debugZone(value:String):void
		{
			_debugZone = value;
		}

		public function get parentNode():LevelOfDetailNode
		{
			return _parentNode;
		}

		public function set parentNode(value:LevelOfDetailNode):void
		{
			_parentNode = value;
		}

		public function get avatar():StaticAvatar
		{
			return _stoner;
		}

		public function retrieveDirectChildren():Vector.<LevelOfDetailNode>
		{
			return _childrenNode;
		}
		public function addAChild(child:LevelOfDetailNode):void
		{
			_childrenNode.push(child);
		}
		public function addAvatar(ava:StaticAvatar):void
		{
			_stoner = ava;
		}
		
		
			
	}
}