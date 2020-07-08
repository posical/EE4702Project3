package engine.utils
{
	/**
	 * Helper class of Color.
	 */
	public final class Color
	{
		public static const BLACK:uint = 0x000000;
		public static const GRAY:uint = 0x808080;
		public static const SILVER:uint = 0xC0C0C0;
		public static const WHITE:uint = 0xFFFFFF;
		
		public static const MAROON:uint = 0x800000;
		public static const RED:uint = 0xFF0000;
		public static const OLIVE:uint = 0x808000;
		public static const YELLOW:uint = 0xFFFF00;
		
		public static const GREEN:uint = 0x008000;
		public static const LIME:uint = 0x00FF00;
		public static const TEAL:uint = 0x008080;
		public static const AQUA:uint = 0x00FFFF;
		
		public static const NAVY:uint = 0x000080;
		public static const BLUE:uint = 0x0000FF;
		public static const PURPLE:uint = 0x800080;
		public static const FUCHSIA:uint = 0xFF00FF;
		
		public function Color()
		{ }
		
		/**
		 * Get a random color.
		 * @return A random <code>uint</code> representing a color.
		 */
		public static function randomColor():uint
		{
			return (uint)(Math.random() * (0xFFFFFF+1));
		}
	}
}