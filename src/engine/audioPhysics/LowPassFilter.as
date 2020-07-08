
/*this is the low pass filter 
it cuts of the high frequency sound to produce the effect that the sound is coming from behind a wall.[MUFFLED]
it is used for occulsion effect
the DSP thoery behind it is not simple, and i cant explain it well to...there are alot of things i am not sure

To use it, call <.process(cutoffFrequency:Number, resonance:Number)>
-cutofffrequency is the threshold , the lower the cutoff.. the softer and lower and more muffled the sound is heard
-the reasonance is ideally set at default 1.4142135623731, feel free to play with it

*/




package engine.audioPhysics
{
	public class LowPassFilter
	{
		
		protected var output:Number;
		protected var fs:Number = 44100;
		protected var b1:Number;
		protected var b2:Number;
		private var channelCopy:LowPassFilter;
		protected var c:Number;
		protected var f:Number = 0;
		protected var out1:Number;
		protected var in1:Number;
		protected var in2:Number;
		protected var a1:Number;
		protected var a2:Number;
		protected var r:Number = 1.4142135623731;
		protected var out2:Number;
		protected var a3:Number;	
		
		public function LowPassFilter(cutoffFrequency:Number, resonance:Number){
			super();
			this.f = cutoffFrequency;
			this.r = resonance;
			this.in1 = (this.in2 = (this.out1 = (this.out2 = 0)));
			this.calculateParameters();
		}
		
		
		protected function calculateParameters():void{
			this.c = (1 / Math.tan((Math.PI * this.f) / this.fs));
			this.a1 = (1 / ((1 + (this.r * this.c)) + (this.c * this.c)));
			this.a2 = (2 * this.a1);
			this.a3 = this.a1;
			this.b1 = ((2 * (1 - (this.c * this.c))) * this.a1);
			this.b2 = (((1 - (this.r * this.c)) + (this.c * this.c)) * this.a1);
		}
		
		public function process(input:Number):Number{
			this.output = (((((this.a1 * input) + (this.a2 * this.in1)) + (this.a3 * this.in2)) - (this.b1 * this.out1)) - (this.b2 * this.out2));
			this.in2 = this.in1;
			this.in1 = input;
			this.out2 = this.out1;
			this.out1 = this.output;
			return (this.output);
		}
		
	
		
		
		
		
	}
}