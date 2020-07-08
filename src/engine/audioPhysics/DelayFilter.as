/*this is the delay A.K.A echo filter/generator
	it modifies individual byte to generate echo by replaying the shifted sound and a later time(playing the sound twice at a softer tone)

To use it, call <.process(feedback, length, mix)>
	              -feedback is the amount of delay between real sound and echo
                  -length is set default at 17640,
                  -mix decides the number of echo sources, 0.1=1 extra source
                                                           0.2=2 extra source

*/


package engine.audioPhysics
{
	public class DelayFilter
	{
		private var buffer:Vector.<Number>;
		private var _length:int;
		private var readPointer:int = 0;
		private var _mix:Number;
		private var writePointer:int = 0;
		private var _feedback:Number;
		private var invMix:Number;
		private var delayValue:Number;
		
		
		public function DelayFilter(feedback:Number, length:Number , mix:Number){
			super();
			this._feedback = feedback;
			this.length = length;
			this._mix = mix;
		}
		
		public function set length(length:int):void{
			
			
			var newBuffer:Vector.<Number> = new Vector.<Number>(length, true);
			if (this.buffer){
				newBuffer.concat(this.buffer);
			};
			this.buffer = newBuffer;
			this.writePointer = 0;
			this._length = length;
		}
		
		public function process(input:Number):Number{
			this.readPointer = ((this.writePointer - this._length) + 1);
			if (this.readPointer < 0){
				this.readPointer = (this.readPointer + this._length);
			};
			this.delayValue = this.buffer[this.readPointer];
			this.buffer[this.writePointer] = ((input * (1 - this._feedback)) + (this.delayValue * this._feedback));
			if (++this.writePointer == this._length){
				this.writePointer = 0;
			};
			return (((input * (1 - this._mix)) + (this.delayValue * this._mix)));
		}
		
	}
}