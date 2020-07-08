package engine.audioPhysics
{
	import engine.events.DebugEvent;
	import engine.events.SourceEvent;
	import engine.interfaces.IDebug;
	import engine.utils.StageMapping;
	import engine.utils.Utility;
	
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.geom.*;
	import flash.media.Sound;
	import flash.net.*;
	import flash.utils.ByteArray;
	
	public class Source extends Sprite implements IDebug
	{
		protected static const DEG_TO_RAD:Number = Math.PI / 180.0;
		protected static const RAD_TO_DEG:Number = 180.0 / Math.PI;
		
		////////////////////////////////////////////
		// Physics
		////////////////////////////////////////////
		private var _primaryConeAngle:Number;
		private var _secondaryConeAngle:Number;
		private var _propagationRange:Number;
		private var _emit:Line;
		private var _reflectNumber:uint;
		
		// Play handling
		private var _isPlaying:Boolean;
		
		////////////////////////////////////////////
		// User interactions
		////////////////////////////////////////////
		private var _isDragged:Boolean;
		private var _isRotated:Boolean;
		private var _isMouseOffStage:Boolean;
		
		////////////////////////////////////////////
		// Variables for sound playback
		////////////////////////////////////////////
		protected var _inputFileName:String;
		protected var _inputSound:Sound;
		protected var _isLoadingCompleted:Boolean;
		protected var _removeAtFinished:Boolean;
		private var _LPF:LowPassFilter=new LowPassFilter(550,1.4142135623731);
		private var _isLPF:Boolean=false;   //activates low pass filter
		private var tempEQL:EQ;
		private var tempEQR:EQ;
		
		////////////////////////////////////////////
		// Delay Effect
		////////////////////////////////////////////
		protected var _playBuffers:Vector.<ByteArray>;
		protected var _bufferCounter:uint;
		protected const MAX_BUFFER_NUM:uint = 100;
		protected var _parentSource:Source;
		
		////////////////////////////////////////////
		// Debug
		////////////////////////////////////////////
		protected var _debugCanvas:Sprite;
		
		public function Source(parent:Source, fileName:String = "", removeAtFinished:Boolean = false, emit:Line = null)
		{
			_parentSource = parent;
			
			////////////////////////////////////////////
			// Physics
			////////////////////////////////////////////
			_primaryConeAngle = 90;
			_secondaryConeAngle = 240;
			_reflectNumber = 3;
			
			// Set the propogation range based on input ray recieved (if it is provided)
			_emit = emit;
			if(_emit == null) {
				//default propogationRange
				_propagationRange = 450;
				_emit = new Line(new Vector3D(this.x,this.y,this.z), new Vector3D(this.x,this.y + this._propagationRange,this.z));
				
				//test: works now, optimize later
				updateWithEmit(_emit);
			} else {
				updateWithEmit(emit);
			}
			
			////////////////////////////////////////////
			// User Interaction
			////////////////////////////////////////////
			_isDragged = false;
			_isRotated = false;
			_isMouseOffStage = false;
			  
			if(_parentSource == null) {
				// Sound playback
				_inputFileName = fileName;
				_inputSound = new Sound(new URLRequest(fileName));
				_inputSound.addEventListener(Event.COMPLETE, handleSoundEvents);
				_inputSound.addEventListener(IOErrorEvent.IO_ERROR, handleSoundEvents);
				
				_isLoadingCompleted = false;
				_removeAtFinished = removeAtFinished;
			}
			
			// Delay Effect
			_playBuffers = new Vector.<ByteArray>();
			_bufferCounter = 0;
			
			_isPlaying = false;
			
			////////////////////////////////////////////
			// Debug
			////////////////////////////////////////////
			prepareDebugCanvas();
		}
		
		protected function prepareDebugCanvas():void
		{
			_debugCanvas = new Sprite();
			
			var _primaryConeShape:Shape = new Shape();
			_primaryConeShape.graphics.beginFill(0x000000, 0.1);
			_primaryConeShape.graphics.lineStyle (1, 0, 1, true);
			drawSector(_primaryConeShape.graphics, 0, 0, _propagationRange, _primaryConeAngle, -_primaryConeAngle/2.0);
			_primaryConeShape.graphics.endFill();
			_debugCanvas.addChild(_primaryConeShape);
			
			var _secondaryConeShape:Shape = new Shape();
			_secondaryConeShape.graphics.beginFill(0x000000, 0.05);
			_secondaryConeShape.graphics.lineStyle(1, 0x000000, 1, true);
			drawSector(_secondaryConeShape.graphics, 0, 0, _propagationRange, _secondaryConeAngle, -_secondaryConeAngle/2.0);
			_secondaryConeShape.graphics.endFill();
			_debugCanvas.addChild(_secondaryConeShape);
			
			var _sourcePointShape:Shape = new Shape();
			if(_parentSource == null) {
				_sourcePointShape.graphics.beginFill(0x00FF00);
			} else {
				_sourcePointShape.graphics.beginFill(0xFF0000);
			}
			_sourcePointShape.graphics.drawCircle(0, 0, 10);
			_sourcePointShape.graphics.endFill();
			_debugCanvas.addChild(_sourcePointShape);
			
			// _emit Graphics
			
			var emitRay:Shape = new Shape();
			emitRay.graphics.lineStyle(2,0xfff);
			emitRay.graphics.beginFill(0xCCC);
			emitRay.graphics.moveTo(this.emit.startPos.x,this.emit.startPos.y);
			emitRay.graphics.lineTo(this.emit.endPos.x,this.emit.endPos.y);
			
			_debugCanvas.addChild(emitRay);
			
		}
		
		////////////////////////////////////////////
		// Event Listeners
		////////////////////////////////////////////
		
		protected function handleMouseEvents(e:MouseEvent):void
		{
			switch (e.type) {
				////////////////////////////////////////////
				case MouseEvent.MOUSE_DOWN:
					if(e.altKey) {
						_isRotated = true;
						this.addEventListener(MouseEvent.MOUSE_MOVE, onRotating);
						
					} else {
						this.startDrag();
						_isDragged = true;
						stage.addEventListener(Event.MOUSE_LEAVE, onDragging);
						stage.addEventListener(MouseEvent.MOUSE_OUT, onDragging);
						stage.addEventListener(MouseEvent.MOUSE_OVER, onDragging);
					}
					break;
				
				////////////////////////////////////////////
				case MouseEvent.MOUSE_UP:
					if(_isDragged) {
						this.stopDrag();
						_isDragged = false;
						stage.removeEventListener(Event.MOUSE_LEAVE, onDragging);
						stage.removeEventListener(MouseEvent.MOUSE_OUT, onDragging);
						stage.removeEventListener(MouseEvent.MOUSE_OVER, onDragging);
					} else if (_isRotated) {
						_isRotated = false;
						this.removeEventListener(MouseEvent.MOUSE_MOVE, onRotating);
					}
					break;
				
				////////////////////////////////////////////
			}
		}
		
		protected function onRotating(e:MouseEvent):void
		{
			if(_isRotated && e.buttonDown) {
				this.rotation = Math.atan2(e.stageY - this.y, e.stageX - this.x) * RAD_TO_DEG;
			}
		}
		
		protected function onDragging(e:Event):void
		{
			if(e.type == Event.MOUSE_LEAVE) {
				if(_isMouseOffStage) {
					// Mouse up outside the stage
					this.stopDrag();
					stage.removeEventListener(Event.MOUSE_LEAVE, onDragging);
					stage.removeEventListener(MouseEvent.MOUSE_OUT, onDragging);
					stage.removeEventListener(MouseEvent.MOUSE_OVER, onDragging);
				}
			} else if (e.type == MouseEvent.MOUSE_OUT) {
				// Mouse left the stage
				_isMouseOffStage = true;
			} else if (e.type == MouseEvent.MOUSE_OVER) {
				// Mouse came back to the stage
				_isMouseOffStage = false;
			}
		}
		
		protected function handleSoundEvents(e:Event):void
		{
			switch(e.type) {
				////////////////////////////////////////////
				case Event.COMPLETE:
					trace("Input sound loaded.");
					_inputSound.removeEventListener(Event.COMPLETE, handleSoundEvents);
					_isLoadingCompleted = true;
					_isPlaying = true;
					break;
				
				////////////////////////////////////////////
				case IOErrorEvent.IO_ERROR:
					trace((e as IOErrorEvent).text);
					break;
				
				////////////////////////////////////////////
			}
		}
		
		public function handleDebugEvents(e:DebugEvent):void
		{
			switch(e.type) {
				////////////////////////////////////////////
				case DebugEvent.ENTER_DEBUG:
					this.addChild(_debugCanvas);
					
					this.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseEvents);
					this.addEventListener(MouseEvent.MOUSE_UP, handleMouseEvents);
					break;
				
				////////////////////////////////////////////
				case DebugEvent.EXIT_DEBUG:
					if(this.contains(_debugCanvas)) {
						this.removeChild(_debugCanvas);
					}
					
					this.removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseEvents);
					this.removeEventListener(MouseEvent.MOUSE_UP, handleMouseEvents);
					break;
				
				////////////////////////////////////////////
			}
		}
		
		public function play():void
		{
			_isPlaying = true;
		}
		
		public function pause():void
		{
			_isPlaying = false;
		}
		
		////////////////////////////////////////////
		// Others
		////////////////////////////////////////////
		
		public function onEnterFrame():void
		{
			_emit.update(this.x, this.y, 0,
				this.x + (_propagationRange*(Math.cos(this.rotation*DEG_TO_RAD))),
				this.y + (this._propagationRange*Math.sin(this.rotation*DEG_TO_RAD)),
				0);
			//trace(emit._startingCoordinate + emit._endingCoordinate);
		}
		
		public function updateWithEmit(emit:Line):void
		{
			this.x = emit.startPos.x;
			this.y = emit.startPos.y;
			this.z = emit.startPos.z;
			this.rotation = emit.directionAngleDegree;
			
			_emit = new Line(new Vector3D(), new Vector3D(emit.magnitude));
			_propagationRange = emit.magnitude;
		}
		
		public function generateAudio(bufferSize:uint):ByteArray
		{
			var byteArray:ByteArray = new ByteArray();
			var i:uint;
			
			if(!_isPlaying) {
				for(i = 0; i < len2; ++i) {
					byteArray.writeFloat(0);
					byteArray.writeFloat(0);
				}
			}
			
			if(_parentSource == null) {
				var count1:uint=0;
				var count2:uint=0;
				var tempv1:Number=new Number;
				var len1:uint = 0;
				len1 = _inputSound.extract(byteArray, bufferSize);
				
				// If we couldn't get all n, go to beginning of file
				var len2:uint = bufferSize - len1;
				if (len2 > 0) {
					if(!_removeAtFinished) {
						len2 = _inputSound.extract(byteArray, len2, 0);
					} else {
						for(i = 0; i < len2; ++i) {
							byteArray.writeFloat(0);
							byteArray.writeFloat(0);
						}
						this.dispatchEvent(new SourceEvent(SourceEvent.REMOVE_AT_FINISHED));
					}
				}
				
				/* SOUND MODIFICATION OF SOURCE SHOULD BE DONE HERE */
				byteArray.position = 0;
				var changeSide:Boolean = true;
				if(_isLPF==true){
					
					for(count1=0;count1<bufferSize;count1++){
						for(count2=0;count2<2;count2++){
							tempv1= byteArray.readFloat()
							byteArray.position--;
							byteArray.position--;
							byteArray.position--;
							byteArray.position--;
							if (changeSide)
								tempv1=this.tempEQL.process(tempv1);
							else
								tempv1=this.tempEQR.process(tempv1);
							changeSide = !changeSide;
							byteArray.writeFloat(tempv1);}
					}
					byteArray.position = 0;// Rewind the byte array
				}
			} else {
				byteArray = _parentSource.getBuffer(1); // GET ONE BUFFER AHEAD. ONE BUFFER IS ABOUT 46ms!
				byteArray.position = 0;
			}
			
			_playBuffers[_bufferCounter++] = byteArray; // Perhaps reconstructing buffer here
			_bufferCounter %= MAX_BUFFER_NUM;
			
			return byteArray;
		}
		
		public function getBuffer(jumpBefore:uint):ByteArray
		{
			var target:int = _bufferCounter - jumpBefore - 1; // Minus 1 because _bufferCounter is always 1 more than num buffers
			if(target < 0) {
				target += MAX_BUFFER_NUM; // wrapping around
			}
			var byte:ByteArray;
			if(_playBuffers.length < target || _playBuffers[target] == null) { // Just put in 0 buffers
				byte = new ByteArray();
				for(var i:uint = 0; i < 2048; ++i) { ///////////////////////////// MAGIC NUMBER //////////////////////////////////////
					byte.writeFloat(0);
					byte.writeFloat(0);
				}
			} else {
				byte = _playBuffers[target];
			}
			byte.position = 0;
			return Utility.cloneObject(byte) as ByteArray;
		}
		
		private function drawSector(graphic:Graphics, x:Number, y:Number, radius:Number, angle:Number, startA:Number):void
		{
			if (Math.abs(angle) > 360) {
				angle = 360;
			}
			
			var n:Number = Math.ceil(Math.abs(angle) / 45);
			var angleA:Number = angle / n;
			
			angleA = angleA * DEG_TO_RAD;
			startA = startA * DEG_TO_RAD;
			
			var startB:Number = startA;
			
			graphic.lineTo(x + radius * Math.cos(startA), y + radius * Math.sin(startA));
			
			for (var i:uint = 1; i <= n; i++)
			{
				startA += angleA;
				
				var angleMid1:Number = startA - angleA / 2;
				var bx:Number = x + radius / Math.cos(angleA / 2) * Math.cos(angleMid1);
				var by:Number = y + radius / Math.cos(angleA / 2) * Math.sin(angleMid1);
				var cx:Number = x + radius * Math.cos(startA);
				var cy:Number = y + radius * Math.sin(startA);
				
				graphic.curveTo(bx, by, cx, cy);
			}
		}
		
		//setting and activating the required filter
		public function setOcclusionFilter(on:Boolean, materia:uint=1):void
		{
			//TODO change this
			//this.setLPF(on, 555, 1.41);
			this._isLPF=on;
			this.tempEQL = Material.getTransmitFilterForMaterial(materia);
			this.tempEQR = Material.getTransmitFilterForMaterial(materia);
			//this._LPF=new LowPassFilter(555, 1.41);
		}
		
		////////////////////////////////////////////
		// Accessors and Mutators
		////////////////////////////////////////////
		
		public function get isLoadingCompleted():Boolean
		{
			return _isLoadingCompleted;
		}
		
		public function get primaryConeAngle():Number
		{
			return _primaryConeAngle;
		}
		
		public function set primaryConeAngle(angle:Number):void
		{
			_primaryConeAngle = Math.max(Math.min(360, angle), 0);
		}
		
		public function get secondaryConeAngle():Number
		{
			return _secondaryConeAngle;
		}
		
		public function set secondaryConeAngle(angle:Number):void
		{
			_secondaryConeAngle = Math.max(Math.min(360, angle), 0);
		}
		
		public function get propagationRange():Number
		{
			return _propagationRange;
		}
		
		public function set propagationRange(range:Number):void
		{
			_propagationRange = Math.max(range, 0);
		}
		
		public function get removeAtFinished():Boolean
		{
			return _removeAtFinished;
		}
		
		public function get pos():Vector3D
		{
			return new Vector3D(StageMapping.mapX(this), StageMapping.mapY(this), StageMapping.mapZ(this));
		}
		
		public function get lookAt():Vector3D
		{
			var result:Vector3D = new Vector3D();
			var rot:Number = StageMapping.mapRotation(this);
			result.x = Math.cos(rot * DEG_TO_RAD);
			result.y = Math.sin(rot * DEG_TO_RAD);
			result.normalize();
			return result;
		}
		
		public function get inputFileName():String
		{
			return _inputFileName;
		}
		
		public function get emit():Line
		{
			return this._emit;
		}
		
		public function set emit(line:Line):void
		{
			if(line != null) {
				updateWithEmit(line);
			}
		}
		
		public function get reflectNumber():uint
		{
			return _reflectNumber;
		}
		
		public function set reflectNumber(num:uint):void
		{
			_reflectNumber = Math.max(num, 0);
		}
		
		public function get isPlaying():Boolean
		{
			return _isPlaying;
		}
	}
}