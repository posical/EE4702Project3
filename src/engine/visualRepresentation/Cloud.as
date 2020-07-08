// ActionScript file
//Written by: Kenneth and Chun Kit
package engine.visualRepresentation
{
	
	import engine.classes.App;
	import engine.utils.Utility;
	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.net.URLRequest;
	import flash.display.DisplayObjectContainer;
	
	public class Cloud extends Sprite
	{
		private var _theCloud:Vector.<MovableAvatar>;
		private var _app:App;
		private var _parent:DisplayObjectContainer;
		
		//starting point range
		private var _startRng_x:int = 800;
		private var _endRng_x:int = 900;
		private var _rng_y:int = 300;
		private var _everyCloudOut:Boolean = false;
		
		public function Cloud(app:App)
		{
			_app = app;
			_theCloud = new Vector.<MovableAvatar>();	 
		}

		public function get everyCloudOut():Boolean
		{
			return _everyCloudOut;
		}
		
		public function addACloud(movAva:MovableAvatar):void
		{
			//TODO: set the 
			//1) initial position
			//2) and pivot point
			//3) end point
			//of each avatar
			
			if (!_parent)
				_parent = movAva.parent;
			
			movAva.changeImage("images/CL01.png");
			
			//gets rand coordinate in sky, moving from right to left
			var rand_xC:int;
			var rand_yC:int;
			rand_xC = Utility.randomRange(_endRng_x,_startRng_x);
			rand_yC = Utility.randomRange(500,80);
			
			//start point
			movAva.x = rand_xC;
			movAva.y = rand_yC;
			//end point
			movAva.setEndPt(0,rand_yC);
			
			//intiate facing position
			movAva.turnTo(0,rand_yC);
			_theCloud.push(movAva);
		}
		
		public function cleanUp():void
		{
			var i:int=0;
			for (i=0; i<_theCloud.length; i++)
			{
				if (_theCloud[i].parent)
				{
					_theCloud[i].parent.removeChild(_theCloud[i]);
				}
			}
		}
		public function reappear():void
		{
			if (_parent)
			{
				var i:int=0;
				for (i=0; i<_theCloud.length; i++)
				{
					if (!_theCloud[i].parent)
						_parent.addChild(_theCloud[i]);
				}
			}
		}
		public function updateVariables(frameTime:int):void
		{
			var i:int=0;
			for (i=0; i<_theCloud.length; i++)
			{
				//check if cloud reached end point
				//keep going if havent reached
				if (!_theCloud[i].walkedStraightTo(_theCloud[i].endPt_x,_theCloud[i].endPt_y))
					_theCloud[i].updateVariable();
				//if reached, reset starting point
				else
				{
					_theCloud[i].x = _app.stage.stageWidth + 200;
					_theCloud[i].y = _theCloud[i].endPt_y;
				}
						
			}
			
			//trace("headCount: " + _headCount);
			//trace("leader pos x: " + _leader.x + "     y: " + _leader.y);
		}
	}
}
		