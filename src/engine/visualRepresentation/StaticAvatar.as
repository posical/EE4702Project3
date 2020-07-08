// ActionScript file
//written by: Chun kit
package engine.visualRepresentation
{
	import engine.audio.PositionalSound;
	import engine.classes.App;
	import engine.utils.Color;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.display.Loader;
	import flash.display.DisplayObjectContainer;
	import flash.net.URLRequest;
	
	public class StaticAvatar extends Sprite
	{
		protected var _pSnd:PositionalSound;
		protected var _representation:Shape;
		
		protected var _app:App;
		

		public function StaticAvatar(app:App, color:uint = Color.YELLOW, clickable:Boolean = false)
		{
			super();
			
			_app = app;
			_pSnd = null;
			
			this.x = 0;
			this.y = 0;
			_representation = new Shape();
			
			_representation.graphics.beginFill(color);
			_representation.graphics.lineStyle(1,Color.BLACK);
			_representation.graphics.drawTriangles(Vector.<Number> ([10,0,-10,-10,-10,10]));
			this.addChild(_representation);
			
			if (clickable)
				this.addEventListener(MouseEvent.CLICK,handleMouse);
			
		}

		public function get pSnd():PositionalSound
		{
			return _pSnd;
		}

		protected function handleMouse(e:MouseEvent):void
		{
			if (e.type === MouseEvent.CLICK)
			{
				
			}
		}
		public function stopMySnd():void
		{
			if (_pSnd)
				_pSnd.stop();
		}
		/**
		 * call this when position of PositionalSound is needed to be updated
		 * */
		public function updatePSndPosition():void
		{
			if (_pSnd != null)
			{
				_pSnd.position.x = this.x;
				_pSnd.position.y = this.y;
			}
		}
		/**
		 * replaces the PSnd of this container.
		 * @param pSnd the PSnd to be contained
		 * */
		public function addPSnd(pSnd:PositionalSound):void
		{
			_pSnd = pSnd; 
			this.updatePSndPosition();
		}
		public function changeImage(s:String):void
		{
			var URLReq:URLRequest = new URLRequest(s);
			var imageLoader:Loader = new Loader();
			var parent:DisplayObjectContainer = _representation.parent;
			if (parent)
			{
				parent.removeChild(_representation);
			}
			
			imageLoader.load(URLReq);
			this.addChild(imageLoader);	
		
		}
	}
}