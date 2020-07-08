package engine.utils
{
	/**
	 * @author Nicola Bortignon
	 * @version 1.0
	 * 
	 * LLRB Node implementation based on Robert Sedgewick's
	 * Left-Leaning Red-Black Trees - Paper - 2008
	 * http://www.cs.princeton.edu/~rs/
	 *
	 */
	 
	public class Node
	{
		private var _key:uint;
		private var _value:Object;
		private var _left:Node;
		private var _right:Node;
		private var _color:Boolean;
		private var _height:int; 
		private static const RED:Boolean = true;
		private static const BLACK:Boolean  = false;
		
		public function Node(key:uint,value:Object){
			_key = key;
			_value = value;
			_color = RED;
			_height = 1;
		}

		public function get height():int
		{
			return _height;
		}

		public function set height(value:int):void
		{
			_height = value;
		}

		public function set value(value:Object):void
		{
			_value = value;
		}

		public function get right():Node
		{
			return _right;
		}

		public function set right(value:Node):void
		{
			_right = value;
		}

		public function get left():Node
		{
			return _left;
		}

		public function set left(value:Node):void
		{
			_left = value;
		}

		public function get color():Boolean
		{
			return _color;
		}

		public function set color(value:Boolean):void
		{
			_color = value;
		}

		public function get value():Object
		{
			return _value;
		}

		public function get key():uint
		{
			return _key;
		}
		
		public function set key(value:uint):void
		{
			_key = value;
		}
		
		public function toString():String{
			return "["+key+","+value+","+color+"]";
		}
	}
}