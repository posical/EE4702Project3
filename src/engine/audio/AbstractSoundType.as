package engine.audio
{
	import engine.utils.LLRBTree;
	import engine.utils.Node;
	
	public class AbstractSoundType
	{
		private var tree:LLRBTree;
		private var _abstractSoundType:String;
		public function get abstractSoundType():String { return _abstractSoundType; }
		
		public function AbstractSoundType()
		{
			tree = new LLRBTree;
		}
		public function createAbstractSoundType(ast:String):AbstractSoundType
		{
			this._abstractSoundType = ast;
			return this;
		}
		public function addChild(numInstance:uint, premixSound:IPlayable):void
		{
			tree.put(numInstance, premixSound);		
		}
		public function getPremix(num:uint):IPlayable
		{
			// tree will find the premix specified by num
			// or find a premix with a num close and lesser to it
			var premix:IPlayable = (tree.find(num) as IPlayable);
			if (premix)
				return premix;
			else
				return null;
				// tree is literally empty
				// use addChild to add premixes to the tree
		}
	}
}