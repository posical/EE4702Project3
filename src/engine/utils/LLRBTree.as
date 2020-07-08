package engine.utils
{
	/**
	 * @author Nicola Bortignon
	 * @version 1.0
	 * 
	 * LLRB implementation based on Robert Sedgewick's
	 * Left-Leaning Red-Black Trees - Paper - 2008
	 * http://www.cs.princeton.edu/~rs/
	 *
	 */
	public class LLRBTree
	{
		private static const RED:Boolean = true;
		private static const BLACK:Boolean  = false;
		
		private var _root:Node;
		
		
		public function LLRBTree()
		{
		}
		
		public function size():int
		{  return sizeByNode(_root);  }
		
		private function sizeByNode(x:Node):int
		{ 
			if (x == null) return 0;
			else           return x.height;
		}
		
		public function rootRank():int
		{ 
			if (_root == null) return 0;
			else              return sizeByNode(_root.left);
		}
		
		public function height():int
		{  return heightByNode(_root);  }
		
		private function heightByNode(x:Node):int
		{ 
			if (x == null) return 0;
			else           return x.height;
		}
		
		public function contains(key:uint):Boolean
		{  return (getByKey(key) != null);  }
		
		public function getByKey(key:uint):Object
		{  return getByNodeAndKey(_root, key);  }
		
		private function getByNodeAndKey(x:Node,key:uint):Object
		{
			if (x == null)        return null;
			if (eq  (key, x.key)) return x.value;
			if (less(key, x.key)) return getByNodeAndKey(x.left,  key);
			else                  return getByNodeAndKey(x.right, key);
		}
		
		public function min():uint
		{  
			if (_root == null) return null;
			else              return minByNode(_root);
		}
		
		private function minByNode(x:Node):uint
		{
			if (x.left == null) return x.key;
			else                return minByNode(x.left);
		}
		
		public function max():uint
		{  
			if (_root == null) return null;
			else              return maxbyNode(_root);
		}
		
		private function maxbyNode(x:Node):uint
		{
			if (x.right == null) return x.key;
			else                 return maxbyNode(x.right);
		}
		
		public function put(key:uint,value:Object):void
		{
			_root = insert(_root, key, value);
			_root.color = BLACK;
		}
		public function find(key:uint):Object{
			var x:Node = _root;
			var isToLeft:Boolean = false;
			while (x != null) {
				var cmp:Number = key - (x.key); 
				
				if (cmp == 0) {
					return x.value;
				} else if (cmp < 0) {
					x = x.left;
					isToLeft = true;
				} else if (cmp > 0) {
					if(isToLeft || x == _root) {
						return x.value;
					}
					x = x.right;
					isToLeft = false;
				}
			} 
			return null;
		}
		private function insert(h:Node,key:uint,value:Object):Node
		{ 
			if (h == null) 
				return new Node(key, value);
			
			if (eq(key, h.key))
				h.value = value;
			else if (less(key, h.key)) 
				h.left = insert(h.left, key, value); 
			else 
				h.right = insert(h.right, key, value); 
			
			return fixUp(h);
		}
		
		public function deleteMin():void
		{
			_root = deleteMinByNode(_root);
			_root.color = BLACK;
		}
		
		private function deleteMinByNode(h:Node):Node
		{ 
			if (h.left == null)
				return null;
			
			if (!isRed(h.left) && !isRed(h.left.left))
				h = moveRedLeft(h);
			
			h.left = deleteMinByNode(h.left);
			
			return fixUp(h);
		}
		
		public function deleteMax():void
		{
			_root = deleteMaxByNode(_root);
			_root.color = BLACK;
		}
		
		private function deleteMaxByNode(h:Node):Node
		{ 
			if (h.right == null)
			{  
				if (h.left != null)
					h.left.color = BLACK;
				return h.left;
			}
			
			if (isRed(h.left))
				h = rotateRight(h);
			
			if (!isRed(h.right) && !isRed(h.right.left))
				h = moveRedRight(h);
			
			h.right = deleteMaxByNode(h.right);
			
			return fixUp(h);
		}
		
		public function remove(key:uint):void
		{ 
			_root = removeFromRoot(_root, key);
			_root.color = BLACK;
		}
		
		private function removeFromRoot(h:Node,key:uint):Node
		{ 
			if (less(key, h.key)) 
			{
				if (!isRed(h.left) && !isRed(h.left.left))
					h = moveRedLeft(h);
				h.left =  removeFromRoot(h.left, key);
			}
			else 
			{
				if (isRed(h.left)) 
					h = rotateRight(h);
				if (eq(key, h.key) && (h.right == null))
					return null;
				if (!isRed(h.right) && !isRed(h.right.left))
					h = moveRedRight(h);
				if (eq(key, h.key))
				{
					h.value = getByNodeAndKey(h.right, minByNode(h.right));
					h.key = minByNode(h.right);
					h.right = deleteMinByNode(h.right);
				}
				else h.right = removeFromRoot(h.right, key);
			}
			
			return fixUp(h);
		}
		
		
		
		
		// Helper methods
		
		private function less(a:uint,b:uint):Boolean { return ((a-b) <  0); }
		private function eq(a:uint,b:uint):Boolean { return ((a-b) == 0); }
		
		private function isRed(x:Node):Boolean
		{
			if (x == null) return false;
			return (x.color == RED);
		}
		
		private function colorFlip(h:Node):void
		{  
			h.color        = !h.color;
			h.left.color   = !h.left.color;
			h.right.color  = !h.right.color;
		}
		
		private function rotateLeft(h:Node):Node
		{  // Make a right-leaning 3-node lean to the left.
			var x:Node = h.right;
			h.right = x.left;
			x.left = setN(h);
			x.color = x.left.color;                   
			x.left.color = RED;                     
			return setN(x);
		}
		
		private function rotateRight(h:Node):Node
		{  // Make a left-leaning 3-node lean to the right.
			var x:Node = h.left;
			h.left = x.right;
			x.right = setN(h);
			x.color       = x.right.color;                   
			x.right.color = RED;                     
			return setN(x);
		}
		
		private function moveRedLeft(h:Node):Node
		{  // Assuming that h is red and both h.left and h.left.left
			// are black, make h.left or one of its children red.
			colorFlip(h);
			if (isRed(h.right.left))
			{ 
				h.right = rotateRight(h.right);
				h = rotateLeft(h);
				colorFlip(h);
			}
			return h;
		}
		
		private function moveRedRight(h:Node):Node
		{  // Assuming that h is red and both h.right and h.right.left
			// are black, make h.right or one of its children red.
			colorFlip(h);
			if (isRed(h.left.left))
			{ 
				h = rotateRight(h);
				colorFlip(h);
			}
			return h;
		}
		
		private function fixUp(h:Node):Node
		{
			if (isRed(h.right))
				h = rotateLeft(h);
			
			if (isRed(h.left) && isRed(h.left.left))
			{
				h = rotateRight(h);
				colorFlip(h);
			}
			
			return setN(h);
		}
		
		private function setN(h:Node):Node
		{
			h.height = sizeByNode(h.left) + sizeByNode(h.right) + 1;
			if (heightByNode(h.left) > heightByNode(h.right)) h.height = heightByNode(h.left) + 1;
			else                                  h.height = heightByNode(h.right) + 1;
			return h;
		}
		
		public function toString():String
		{  
			if (_root == null) return "";
			else              return toStringNode(_root);  
		}
		
		public function toStringNode(x:Node):String
		{  
			var s:String = "";
			if (x.left != null) s += toStringNode(x.left);
			s += x.height + " " + " " + x.key + " " + x.value + "\n";
			if (x.right != null) s += toStringNode(x.right);
			return s;
		}
	}
}