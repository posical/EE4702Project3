// author : Seow Zhi Wei
package engine.audioPhysics
{
	/*
	*Class EQ is the class that filters the sound and sets its timbre.
	*Utilizing the audio crossover method of separating the sound,
	*the EQ class processes the sound much faster than even the fastest FFT
	*since there are less frequency bins to calculate.
	*However, this leads to a lower amount of control over the sound.
	*Set the gains of the frequency bins (from 0-1),
	*then pass the sampled sound through EQ by calling the "process" function.
	*/
	public class EQ 
	{
		// Enable/disable
		public var active:Boolean = false;
		
		// Gain Controls
		public var lllg:Number = 1; 	// Low Low Low freq gain (63Hz bin)
		public var llg:Number = 1;		// Low Low freq gain	 (125Hz bin)
		public var lg:Number = 1;		// Low freq gain		 (250Hz bin)
		public var mg:Number = 1; 		// Mid freq gain		 (500Hz bin)
		public var hg:Number = 1; 		// Hi freq gain			 (1000Hz bin)
		public var hhg:Number = 1;		// Hi Hi freq gain		 (2000Hz bin)
		public var hhhg:Number = 1;		// Hi Hi Hi freq gain	 (4000Hz bin)
		
		// Frequencies
		private var lowlowlowfreq:Number = 63; 	// Low crossover frequency
		private var lowlowfreq:Number = 188;
		private var lowfreq:Number = 375;
		private var hifreq:Number = 750;
		private var hihifreq:Number = 1500;
		private var hihihifreq:Number = 3000;// Hi crossover frequency
		
		// Filter #1 (Low Low Low band)
		private var f1p0:Number = 0; 	// 4 poles, should give 24dB/oct
		private var f1p1:Number = 0;
		private var f1p2:Number = 0;
		private var f1p3:Number = 0;
		
		// Filter #2 (Low Low band)
		private var f2p0:Number = 0;
		private var f2p1:Number = 0;
		private var f2p2:Number = 0;
		private var f2p3:Number = 0;
		
		// Filter #3 (Low band)
		private var f3p0:Number = 0;
		private var f3p1:Number = 0;
		private var f3p2:Number = 0;
		private var f3p3:Number = 0;
		
		// Filter #4 (High band)
		private var f4p0:Number = 0;
		private var f4p1:Number = 0;
		private var f4p2:Number = 0;
		private var f4p3:Number = 0;
		
		// Filter #5 (High High band)
		private var f5p0:Number = 0;
		private var f5p1:Number = 0;
		private var f5p2:Number = 0;
		private var f5p3:Number = 0;
		
		// Filter #6 (High High High band)
		private var f6p0:Number = 0;
		private var f6p1:Number = 0;
		private var f6p2:Number = 0;
		private var f6p3:Number = 0;
		
		// Sample history buffer
		private var sdm1:Number = 0;
		private var sdm2:Number = 0;
		private var sdm3:Number = 0;
		
		private var lllf:Number;
		private var llf:Number;
		private var lf:Number;
		private var hf:Number;
		private var hhf:Number;
		private var hhhf:Number;
		
		static private const vsa:Number = 1.0 / 4294967295.0; // Very small amount (Denormal Fix)
		
		public function EQ() 
		{
			lllg = 1;
			llg = 1;
			lg = 1;
			mg = 1;
			hg = 1;
			hhg = 1;
			hhhg = 1;
			f1p0 = 0;
			f1p1 = 0;
			f1p2 = 0;
			f1p3 = 0;
			f2p0 = 0;
			f2p1 = 0;
			f2p2 = 0;
			f2p3 = 0;
			f3p0 = 0;
			f3p1 = 0;
			f3p2 = 0;
			f3p3 = 0;
			f4p0 = 0;
			f4p1 = 0;
			f4p2 = 0;
			f4p3 = 0;
			f5p0 = 0;
			f5p1 = 0;
			f5p2 = 0;
			f5p3 = 0;
			f6p0 = 0;
			f6p1 = 0;
			f6p2 = 0;
			f6p3 = 0;
			sdm1 = 0;
			sdm2 = 0;
			sdm3 = 0;
			// Calculate filter cutoff frequencies
			lllf = 2 * Math.sin(Math.PI * (lowlowlowfreq / 44100));
			llf = 2 * Math.sin(Math.PI * (lowlowfreq / 44100));
			lf = 2 * Math.sin(Math.PI * (lowfreq / 44100));
			hf = 2 * Math.sin(Math.PI * (hifreq / 44100));
			hhf = 2 * Math.sin(Math.PI * (hihifreq / 44100));
			hhhf = 2 * Math.sin(Math.PI * (hihihifreq / 44100));
			return;
		}
		
		public function process(sample:Number): Number 
		{
			// Low / Mid / High - Sample Values
			var lll:Number;
			var ll:Number;
			var l:Number;
			var m:Number;
			var h:Number;
			var hh:Number;
			var hhh:Number;
			
			// Filter #1 (lowlowlowpass)
			f1p0 += (lllf * (sample - f1p0));
			f1p1 += lllf * (f1p0 - f1p1);
			f1p2 += lllf * (f1p1 - f1p2);
			f1p3 += lllf * (f1p2 - f1p3);
			lll = f1p3;
			
			//filter #2 (lowlowpass)
			f2p0 += (llf * (sample - f2p0));
			f2p1 += llf * (f2p0 - f2p1);
			f2p2 += llf * (f2p1 - f2p2);
			f2p3 += llf * (f2p2 - f2p3);
			ll = f2p3 - f1p3; //change this
			
			// Filter #3 (lowpass)
			f3p0 += (lf * (sample - f3p0));
			f3p1 += lf * (f3p0 - f3p1);
			f3p2 += lf * (f3p1 - f3p2);
			f3p3 += lf * (f3p2 - f3p3);
			l = f3p3 - f2p3; //change this
			
			// Filter #4 (highpass)
			f4p0 += (hf * (sample - f4p0));
			f4p1 += hf * (f4p0 - f4p1);
			f4p2 += hf * (f4p1 - f4p2);
			f4p3 += hf * (f4p2 - f4p3);
			m = f4p3 - f3p3; //change this
			
			// Filter #5 (highhighpass)
			f5p0 += (hhf * (sample - f5p0));
			f5p1 += hhf * (f5p0 - f5p1);
			f5p2 += hhf * (f5p1 - f5p2);
			f5p3 += hhf * (f5p2 - f5p3);
			h = f5p3 - f4p3; //change this
			
			// Filter #6 (highhighhighpass)
			f6p0 += (hhhf * (sample - f6p0));
			f6p1 += hhhf * (f6p0 - f6p1);
			f6p2 += hhhf * (f6p1 - f6p2);
			f6p3 += hhhf * (f6p2 - f6p3);
			hh = f6p3 - f5p3; //change this
			
			// Calculate midrange (signal - (low + high))
			hhh = sample - (f6p3);
			// Scale, Combine and store
			lll *= lllg;
			ll *= llg;
			l *= lg;
			m *= mg;
			h *= hg;
			hh *= hhg;
			hhh *= hhhg;
			// Shuffle history buffer
			sdm3 = sdm2;
			sdm2 = sdm1;
			sdm1 = sample;
			// Return result
			return lll + ll + l + m + h + hh + hhh;
		}
	}
	
}