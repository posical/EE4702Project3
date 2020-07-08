//authors: Leon Ho, Seow Zhi Wei
package engine.audioPhysics
{
	//import sound.EQ;
	
	/*
	Material
	A static class that allows us to obtain color, or filter properties given a material ID
	related classes EQ.as
	*/
	public class Material
	{
		public static const CONCRETE:int = 0;
		public static const WOOD:int = 1;
		public static const GLASS:int = 2;
		public static const transEq:EQ = new EQ();
		public static const refEq:EQ = new EQ();
		
		private static function doorTransmit():void
		{
			transEq.lllg = 1;//0.43;//
			transEq.llg = 0.655;//0.23;//
			transEq.lg = 0.264;//0.1;//
			transEq.mg = 0.08;//0.09;//
			transEq.hg = 0.069;//0.1;//
			transEq.hhg = 0.069;//0.1;//
			transEq.hhhg = 0.092;//0.1;//
		}
		
		private static function doorReflect():void
		{
			refEq.lllg = 0;
			refEq.llg = 0;
			refEq.lg = 0;
			refEq.mg = 0;
			refEq.hg = 0.046;
			refEq.hhg = 0.402;
			refEq.hhhg = 1;
		}
		
		private static function concreteReflect():void
		{
			refEq.lllg = 0.997;
			refEq.llg = 0.997;
			refEq.lg = 0.933;
			refEq.mg = 0.933;
			refEq.hg = 0.920;
			refEq.hhg = 0.908;
			refEq.hhhg = 0.92;
		}
		private static function concreteTransmit():void
		{
			transEq.lllg = 0.103;
			transEq.llg = 0.103;
			transEq.lg = 0.067;
			transEq.mg = 0.067;
			transEq.hg = 0.080;
			transEq.hhg = 0.092;
			transEq.hhhg = 0.08;
		}
		
		private static function glassReflect():void
		{
			refEq.lllg = 0;
			refEq.llg = 0.046;
			refEq.lg = 0.103;
			refEq.mg = 0.195;
			refEq.hg = 0.425;
			refEq.hhg = 0.770;
			refEq.hhhg = 1;
		}
		private static function glassTransmit():void
		{
			transEq.lllg = 0.609;
			transEq.llg = 0.356;
			transEq.lg = 0.264;
			transEq.mg = 0.172;
			transEq.hg = 0.126;
			transEq.hhg = 0.092;
			transEq.hhhg = 0.069;
		}
		
		public static function getReverbFilterForMaterial(type:int):EQ
		{
			switch (type)
			{
				case CONCRETE:
					concreteReflect();
					break;
				case WOOD:
					doorReflect();
					break;
				case GLASS:
					glassReflect();
					break;
				default:
					break;
			}
			return refEq;
		}
		
		public static function getTransmitFilterForMaterial(type:int):EQ
		{
			switch (type)
			{
				case CONCRETE:
					concreteTransmit();
					break;
				case WOOD:
					doorTransmit();
					break;
				case GLASS:
					glassTransmit();
					break;
				default:
					break;
			}
			return transEq;
		}
		
		public static function getColorForMaterial(type:int):uint
		{
			var retVal:uint;
			switch (type)
			{
				case CONCRETE:
					retVal = 0x666666;
					break;
				case WOOD:
					retVal = 0xCC6600;
					break;
				case GLASS:
					retVal = 0x3BB9FF;
				default:
					break;
			}
			return retVal;
		}
	}
}