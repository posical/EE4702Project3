// ActionScript file
package engine.utils
{
	import engine.audio.PositionalSound;
	import engine.visualRepresentation.*;

	public class LevelOfDetailTree
	{
		private var _root:LevelOfDetailNode;
		
		//Zone params
		private var _station_x1:int = 230;
		private var _station_y1:int = 7;
		private var _station_x2:int = 490;
		private var _station_y2:int = 233;
		
		private var _studio_x1:int = 507;
		private var _studio_y1:int = 6;
		private var _studio_x2:int = 790;
		private var _studio_y2:int = 231;
		
		private var _arcade_x1:int = 508;
		private var _arcade_y1:int = 256;
		private var _arcade_x2:int = 787;
		private var _arcade_y2:int = 432;
		
		public function LevelOfDetailTree()
		{
			_root = new LevelOfDetailNode(true);
		}

		public function addAvaToRoot(ava:StaticAvatar):void
		{
			_root.addAvatar(ava);
		}
		public function get root():LevelOfDetailNode
		{
			return _root;
		}

		public function addChildToRoot(LoDNode:LevelOfDetailNode):void
		{
			_root.addAChild(LoDNode);
			LoDNode.parentNode = _root;
		}
		public function addChildTo(LoDParent:LevelOfDetailNode, LoDChild:LevelOfDetailNode):void
		{
			LoDParent.addAChild(LoDChild);
			LoDChild.parentNode = LoDParent;
		}
		public function retrieveZone(VPx:int, VPy:int):int//LevelOfDetailNode
		{
			//case 0: is in StationZone
			if (VPx > _station_x1 && VPx < _station_x2)
				if (VPy > _station_y1 && VPy < _station_y2)
					return 0;//getZoneNode(0);
			
			//case 1: is in studio
			if (VPx > _studio_x1 && VPx < _studio_x2)
				if (VPy > _studio_y1 && VPy < _studio_y2)
					return 1;
			
			//case 2: is in Arcade
			if (VPx > _arcade_x1 && VPx < _arcade_x2)
				if (VPy > _arcade_y1 && VPy < _arcade_y2)
					return 2;
			
			//case 3: in City
			return 3;
		}
		//i know,this is wrong
		//index 0 = station
		//1 = studio
		//2 = arcade
		//3 = city
		public function getZoneNode(index:int):LevelOfDetailNode
		{
			if (index < _root.retrieveDirectChildren().length && index >=0)
				return _root.retrieveDirectChildren()[index];
			else
				return null;
		}
	}
}