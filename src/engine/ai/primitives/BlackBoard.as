package engine.ai.primitives
{
	import engine.classes.App;
	
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;

	public class BlackBoard extends Object
	{
		public static var app:App;
		
		public function BlackBoard(theApp:App)
		{
			super();
			
			app = theApp;
		}
	}
}