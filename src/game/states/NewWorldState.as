// ActionScript file
package game.states
{
	import engine.audio.AbstractSoundType;
	import engine.audio.IPositionalSound;
	import engine.audio.PositionalSound;
	import engine.audio.PositionalSoundInitOptions;
	import engine.audio.SoundGroup;
	import engine.audio.SoundManager;
	import engine.base.State;
	import engine.classes.App;
	import engine.console.LogConsole;
	import engine.utils.Color;
	import engine.utils.Utility;
	import engine.viewport.Viewport;
	import engine.visualRepresentation.Cloud;
	import engine.visualRepresentation.MovableAvatar;
	import engine.visualRepresentation.ParadeMass;
	import engine.visualRepresentation.StaticAvatar;
	
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Vector3D;
	import flash.net.URLRequest;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	
	public class NewWorldState extends State
	{
		private var _logConsole:LogConsole;
		private var _viewport:Viewport;
		private var _backGround:Loader;
		private var _cloudOne:Loader;
		private var _cloudTwo:Loader;
		private var _cloudThree:Loader;
		
		private var _soundMgr:SoundManager;
		
		//for group boxes
		private var _grpBoxTop:SoundGroup;
		private var _grpBoxBtm:SoundGroup;
		private var _grpBoxRgt:SoundGroup;
		private var _grpBoxLef:SoundGroup;
		private var _grpBoxCor:SoundGroup;
		
		//for storing ALL PSnd
		private var _worldPSnds:Vector.<PositionalSound>;
		private var _prevWorldPSnds:Dictionary;
		
		//** for VR
		private var _visualRep:StaticAvatar;
		private var _movingRep:MovableAvatar;
		private var _parade:ParadeMass;
		
		//		private var _movingCloud:MovableAvatar;
		//		private var _cloud:Cloud;
		
		public function NewWorldState(app:App)
		{
			super(app);
			
			_stateId = "Test State";
			_parade = null;
			
		}
		
		public override function init():void
		{
			//set up shops of pSnds
			//put the Snd into _worldPSnds IF it is to be heard
			_worldPSnds = new Vector.<PositionalSound>();
			_prevWorldPSnds = new Dictionary();
			
			_backGround=new Loader();
			_backGround.load(new URLRequest("images/BG.png")); 
			addChild(_backGround);
			
			_soundMgr = SoundManager.getSoundManager();
			
			//set up group boxes
			_grpBoxTop = _soundMgr.createNewGroup();
			_grpBoxBtm = _soundMgr.createNewGroup();
			_grpBoxRgt = _soundMgr.createNewGroup();
			_grpBoxLef = _soundMgr.createNewGroup();
			_grpBoxCor = _soundMgr.createNewGroup();
			
			
			
			//parade
			_parade = new ParadeMass(_app);
			//important, need to set a PSnd for the leader of the parade!
			var pLSndOpt:PositionalSoundInitOptions = new PositionalSoundInitOptions();
			pLSndOpt.fileName = "X";
			var pLSnd:PositionalSound = _soundMgr.createPositionalSound(pLSndOpt) as PositionalSound;
			_parade.addPSnd(pLSnd);
			//_worldPSnds.push(pLSnd);
			
			//---------------------------------
			// Testing Abstraction
			var optionsDiag01:PositionalSoundInitOptions = new PositionalSoundInitOptions;
			var optionsDiag02:PositionalSoundInitOptions = new PositionalSoundInitOptions;
			var someSoundType:AbstractSoundType = _soundMgr.createAbstractSoundType("someSoundType");
			optionsDiag01.fileName = "sounds/Diag11.mp3";	//abs 5
			optionsDiag01.abstractSoundType = "someSoundType";
			someSoundType.addChild(5,_soundMgr.createPositionalSound(optionsDiag01));
			optionsDiag02.fileName = "sounds/Diag17.mp3";	//abs 10
			optionsDiag02.abstractSoundType = "someSoundType";
			someSoundType.addChild(10,_soundMgr.createPositionalSound(optionsDiag02));
			
			//------------------------------------
			
			//sets up parade======================
			var k:int = 0;
			for (k = 0; k < 10; k++)
			{
				//set up the individual sounds
				var pMSndOpt:PositionalSoundInitOptions = new PositionalSoundInitOptions();
				var pMSnd:PositionalSound = _soundMgr.createPositionalSound(pMSndOpt) as PositionalSound;
		
				pMSndOpt.fileName = "sounds/Diag01.mp3";	//individual
				pMSndOpt.abstractSoundType = "someSoundType";
				pMSndOpt.isLooping = true;
				
				_movingRep = new MovableAvatar(_app);
				//attach the sounds
				_movingRep.addPSnd(pMSnd);
				_parade.addMovableAvatar(_movingRep);
				this.addChild(_movingRep);
				//pMSnd.load();
				//pMSnd.play();
				_app.audioManager.addSoundToBus(pMSnd, 0);
				//add to world
				_worldPSnds.push(pMSnd);
			}
			//================================
			
			//eg of setting up single entity
			/*
			_visualRep = new StaticAvatar(_app);
			_visualRep.x = _visualRep.y = 200;
			//set up the individual sounds
			var pSSndOpt:PositionalSoundInitOptions = new PositionalSoundInitOptions();
			pSSndOpt.fileName = "sounds/Diag01.mp3";	//individual
			pSSndOpt.abstractSoundType = "someSoundType";
			pSSndOpt.isLooping = true;
			var pSSnd:PositionalSound = _soundMgr.createPositionalSound(pSSndOpt) as PositionalSound;
			_visualRep.addPSnd(pSSnd);
			_visualRep.updatePSndPosition();
			_app.audioManager.addSoundToBus(pSSnd, 0);
			_worldPSnds.push(pSSnd);
			this.addChild(_visualRep);
			*/
			//Brute force implementation of cloud
			var rand_x1:int;
			var rand_y1:int;
			var rand_x2:int;
			var rand_y2:int;
			var rand_x3:int;
			var rand_y3:int;
			rand_x1 = Utility.randomRange(780,20);
			rand_y1 = Utility.randomRange(580,20);
			rand_x2 = Utility.randomRange(780,20);
			rand_y2 = Utility.randomRange(580,20);
			rand_x3 = Utility.randomRange(780,20);
			rand_y3 = Utility.randomRange(580,20);
			_cloudOne=new Loader();
			_cloudOne.load(new URLRequest("images/CL01.png"));
			_cloudOne.x = rand_x1;
			_cloudOne.y = rand_y1;
			addChild(_cloudOne);
			_cloudTwo=new Loader();
			_cloudTwo.load(new URLRequest("images/CL02.png")); 
			_cloudTwo.x = rand_x2;
			_cloudTwo.y = rand_y2;
			addChild(_cloudTwo);
			_cloudThree=new Loader();
			_cloudThree.load(new URLRequest("images/CL03.png")); 
			_cloudThree.x = rand_x3;
			_cloudThree.y = rand_y3;
			addChild(_cloudThree);
			
			//Viewport
			_logConsole = new LogConsole(_app,this);
			_viewport = new Viewport(_app);
			this.addChild(_viewport);
		}
		
		public override function reset():void
		{
			
		}
		
		public override function onEnterFrame(frameTime:Number):void
		{
			var i:int = 0;
			var tempString:String;
			_viewport.updateVariable(frameTime);
			
			//TODO: do grouping and shuriken to group box
			//TODO 2: implement prev state
			for (i = 0; i < _worldPSnds.length; i++)
			{
				tempString = _viewport.checkZone(_worldPSnds[i]);
				
				//removes any OUT snds from dict
				if (tempString == Viewport.OUT)
				{
					//checks if exists in prev state
					if (_prevWorldPSnds[_worldPSnds[i]])
					{
						//remove from grp and dict
						delete _prevWorldPSnds[_worldPSnds[i]];
						_soundMgr.removeSoundFromGroups(_worldPSnds[i]);
						_logConsole.log("removed snd " + _worldPSnds[i].options.fileName);
					}
				}
					//curr snd is in part of viewport
				else
				{
					//this snd has a prev state
					if (_prevWorldPSnds[_worldPSnds[i]])
					{
						//there is a change in state
						if (_prevWorldPSnds[_worldPSnds[i]] != tempString)
						{
							_logConsole.log("moving snd " + _worldPSnds[i].options.fileName + " from " + _prevWorldPSnds[_worldPSnds[i]] + " to " + tempString);
							
							_prevWorldPSnds[_worldPSnds[i]] = tempString;
							_soundMgr.removeSoundFromGroups(_worldPSnds[i]);
							
							if (tempString == Viewport.TOP)
								_grpBoxTop.addSoundtoGroup(_worldPSnds[i]);
							else if (tempString == Viewport.BOTTOM)
								_grpBoxBtm.addSoundtoGroup(_worldPSnds[i]);
							else if (tempString == Viewport.LEFT)
								_grpBoxLef.addSoundtoGroup(_worldPSnds[i]);
							else if (tempString == Viewport.RIGHT)
								_grpBoxRgt.addSoundtoGroup(_worldPSnds[i]);
							else if (tempString == Viewport.CORE)
								_grpBoxCor.addSoundtoGroup(_worldPSnds[i]);
							
							
						}
					}
						//has no prev state
					else
					{
						_logConsole.log("adding snd " + _worldPSnds[i].options.fileName + " to " + tempString);
						
						_prevWorldPSnds[_worldPSnds[i]] = tempString;
						
						if (tempString == Viewport.TOP)
							_grpBoxTop.addSoundtoGroup(_worldPSnds[i]);
						else if (tempString == Viewport.BOTTOM)
							_grpBoxBtm.addSoundtoGroup(_worldPSnds[i]);
						else if (tempString == Viewport.LEFT)
							_grpBoxLef.addSoundtoGroup(_worldPSnds[i]);
						else if (tempString == Viewport.RIGHT)
							_grpBoxRgt.addSoundtoGroup(_worldPSnds[i]);
						else if (tempString == Viewport.CORE)
							_grpBoxCor.addSoundtoGroup(_worldPSnds[i]);
					}
				}
			}
			if (_parade)
			{
				if (_parade.everyoneOut)
					_parade = null;
				else
					_parade.updateVariables(frameTime);
			}
		}
		
		protected override function cleanUp():void
		{
			
		}
		
		protected override function setupEventListeners():void
		{
			_app.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleEvents);
			_app.stage.addEventListener(KeyboardEvent.KEY_UP, handleEvents);
		}
		
		protected override function removeEventListeners():void
		{
			_app.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleEvents);
			_app.stage.removeEventListener(KeyboardEvent.KEY_UP, handleEvents);
		}
		
		protected override function handleEvents(e:Event):void
		{
			if(e.type === KeyboardEvent.KEY_DOWN) {
				switch((e as KeyboardEvent).keyCode) {
					case Keyboard.ESCAPE:
						_app.stateManager.removeActiveState();
						break;
					
					case Keyboard.W:
						_viewport.move(Viewport.MOVE_UP);
						break;
					case Keyboard.A:
						_viewport.move(Viewport.MOVE_LEFT);
						break;
					case Keyboard.S:
						_viewport.move(Viewport.MOVE_DOWN);
						break;
					case Keyboard.D:
						_viewport.move(Viewport.MOVE_RIGHT);
						break;
					case Keyboard.Z:
						if (_viewport.zoomLv > 0)
							_viewport.zoomLv--;
						else
							_viewport.zoomLv = 4;
						
						_viewport.reDrawViewport();
						break;
					case Keyboard.X:
						if (_viewport.speed == Viewport.FAST)
							_viewport.speed = Viewport.SLOW;
						else
							_viewport.speed = Viewport.FAST;
						break;
					
					
				}
				
				
			}
			
			if(e.type === KeyboardEvent.KEY_UP) {
				switch((e as KeyboardEvent).keyCode) {
					case Keyboard.W:
					case Keyboard.S:
					case Keyboard.A:
					case Keyboard.D:
						_viewport.move(Viewport.MOVE_STOP);
						break;
				}
			}
		}
	}
}