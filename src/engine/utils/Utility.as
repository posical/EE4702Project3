package engine.utils
{
	import engine.audio.PositionalSound;
	
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	/**
	 * Utility class for some useful functions.
	 */
	public final class Utility extends Object
	{
		public static var TO_DEG:Number = 180/Math.PI;
		public static var DEG_TO_RAD:Number = Math.PI/180;
		/**
		 * Constructor.
		 */
		public function Utility()
		{
			super();
		}
		/**
		 * As the name suggests, it gives a rand number between min and max.
		 * @param max max of the range
		 * @param min min of the range
		 * @return resultant rand number
		 * */
		public static function randomRange(max:Number, min:Number = 0):Number
		{
			return Math.random() * (max - min) + min;
		}
		public static function angleDifference(x1:Number, y1:Number, x2:Number, y2:Number):Number
		{
			
			var radAngle:Number;
			radAngle = Math.atan2(y2-y1, x2-x1);//Vector3D.angleBetween(vector1,vector2);
			
			return (radAngle * TO_DEG);
		}
		/**
		 * Count the number of key-value pairs in a Dictionary.
		 * @param d The Dictionary to be checked.
		 * @return The number of key-value pairs in <code>d</code>.
		 */
		public static function countDictionaryKey(d:Dictionary):uint
		{
			if(d == null) {
				throw new Error("Utility::countDictionarykey() null input.");
			}
			
			var n:int = 0;
			for (var key:* in d) {
				n++;
			}
			return n;
		}
		
		/**
		 * Deep cloning any object.
		 * @param obj The object to be cloned.
		 * @return The cloned object.
		 */
		public static function cloneObject(obj:Object):*
		{
			if(obj == null) {
				throw new Error("Utility::cloneObject() null input.");
			}
			
			var byte:ByteArray = new ByteArray();
			byte.writeObject(obj);
			byte.position = 0;
			return byte.readObject();
		}
		/**
		 * ONLY FOR CLEARING _worldPSnds
		 * */
		public static function clearVectorOfPSnd(vect:Vector.<PositionalSound>):void
		{
			while (vect.length > 0)
			{
				vect.pop();
			}
		}
	}
}