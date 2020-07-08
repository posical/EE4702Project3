package engine.utils
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;

	/**
	 * Helper class in resolving the global(stage) orientation of a Sprite.
	 * This works for Sprites in the main window only.
	 */
	public final class StageMapping extends Object
	{
		/**
		 * Constructor.
		 */
		public function StageMapping()
		{
			super();
		}
		
		/**
		 * Get the global rotation of a Sprite.
		 * @param sprite The Sprite to be checked.
		 * @return The rotation of <code>sprite</code> with respect to the stage.
		 */
		public static function mapRotation(sprite:Sprite):Number
		{
			if(sprite == null) {
				throw new Error("StageMapping::mapRotation() Input sprite is null.");
			}
			var parent:DisplayObjectContainer = null;
			var result:Number = sprite.rotation;
			
			parent = sprite.parent;
			while(parent != null && parent != StageRef.stage) {
				result += parent.rotation;
				parent = parent.parent;
				
				if(parent == null) {
					throw new Error("StageMapping::mapRotation() One of the parent in chain is null.");
				}
			}
			
			return result;
		}
		
		/**
		 * Get the global x-coordinate of a Sprite.
		 * @param sprite The Sprite to be checked.
		 * @return The x-coordinate of <code>sprite</code> with respect to the stage.
		 */
		public static function mapX(sprite:Sprite):Number
		{
			if(sprite == null) {
				throw new Error("StageMapping::mapX() Input sprite is null.");
			}
			var parent:DisplayObjectContainer = null;
			var result:Number = sprite.x;
			
			parent = sprite.parent;
			while(parent != null && parent != StageRef.stage) {
				result += parent.x;
				parent = parent.parent;
				
				if(parent == null) {
					throw new Error("StageMapping::mapX() One of the parent in chain is null.");
				}
			}
			
			return result;
		}
		
		/**
		 * Get the global y-coordinate of a Sprite.
		 * @param sprite The Sprite to be checked.
		 * @return The y-coordinate of <code>sprite</code> with respect to the stage.
		 */
		public static function mapY(sprite:Sprite):Number
		{
			if(sprite == null) {
				throw new Error("StageMapping::mapY() Input sprite is null.");
			}
			var parent:DisplayObjectContainer = null;
			var result:Number = sprite.y;
			
			parent = sprite.parent;
			while(parent != null && parent != StageRef.stage) {
				result += parent.y;
				parent = parent.parent;
				
				if(parent == null) {
					throw new Error("StageMapping::mapY() One of the parent in chain is null.");
				}
			}
			
			return result;
		}
		
		/**
		 * Get the global z-coordinate of a Sprite.
		 * @param sprite The Sprite to be checked.
		 * @return The z-coordinate of <code>sprite</code> with respect to the stage.
		 */
		public static function mapZ(sprite:Sprite):Number
		{
			if(sprite == null) {
				throw new Error("StageMapping::mapZ() Input sprite is null.");
			}
			var parent:DisplayObjectContainer = null;
			var result:Number = sprite.z;
			
			parent = sprite.parent;
			while(parent != null && parent != StageRef.stage) {
				result += parent.z;
				parent = parent.parent;
				
				if(parent == null) {
					throw new Error("StageMapping::mapZ() One of the parent in chain is null.");
				}
			}
			
			return result;
		}
	}
}