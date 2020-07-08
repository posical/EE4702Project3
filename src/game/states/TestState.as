package game.states
{
	import engine.audio.AbstractSoundType;
	import engine.audio.BusManager;
	import engine.audio.PositionalSound;
	import engine.audio.PositionalSoundInitOptions;
	import engine.audio.SoundGroup;
	import engine.audio.SoundManager;
	import engine.audio.visualizers.BusMonitor;
	import engine.base.State;
	import engine.classes.App;
	import engine.console.LogConsole;
	import engine.utils.Color;
	import engine.utils.LevelOfDetailNode;
	import engine.utils.LevelOfDetailTree;
	import engine.utils.Utility;
	import engine.viewport.Viewport;
	import engine.visualRepresentation.Cloud;
	import engine.visualRepresentation.MovableAvatar;
	import engine.visualRepresentation.NPC;
	import engine.visualRepresentation.ParadeMass;
	import engine.visualRepresentation.ParadeMassHolder;
	import engine.visualRepresentation.StaticAvatar;
	
	import flash.display.Loader;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowType;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.net.URLRequest;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	
	public class TestState extends State
	{
		private var _logConsole:LogConsole;
		private var _SndMgrEventLog:LogConsole;
		private var _viewport:Viewport;
		private var _backGround:Loader;
		private var _cloudOne:Loader;
		private var _cloudTwo:Loader;
		private var _cloudThree:Loader;
		
		private var _soundMgr:SoundManager;
		private var _eventLogs:Vector.<LogConsole>;
		
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
		//Parade
		private var _parade:ParadeMass;
		private var _paradeHolder:ParadeMassHolder;
		
		private var _cloud:Cloud;
		
		//for switching on/off parade and clouds
		private var _currParade:ParadeMass;
		private var _currCloud:Cloud;
		
		//for LOD tree
		private var _LODTree:LevelOfDetailTree;
		private var _LODNode:LevelOfDetailNode;
		private var _LODChild:LevelOfDetailNode;
		private var _tempLODNode:LevelOfDetailNode;
		//to check for changes
		private var _prevTempLODNode:LevelOfDetailNode;
		private var _prevZoomLv:int;
		
		//BGM
		private var _BGM:PositionalSound;
		private var _BGMOpt:PositionalSoundInitOptions;
		
		public function TestState(app:App)
		{
			super(app);
			
			_stateId = "Test State";
			_parade = null;			
			_prevTempLODNode = null;
			
		}
		
		public override function init():void
		{
			super.init();
			
			//set up BG			
			_backGround=new Loader();
			_backGround.load(new URLRequest("images/BG.png")); 
			addChild(_backGround);
						
			//Set up BGM
			_BGMOpt = new PositionalSoundInitOptions;
			_BGMOpt.busId = BusManager.BGM;
			_BGMOpt.fileName = "sounds/BGM.mp3";
			_BGMOpt.isLooping = true;
			_BGM = new PositionalSound(_BGMOpt);
			_app.audioManager.addSoundToBus(_BGM, BusManager.BGM);
			_BGM.load();

			//set up sound man
			_soundMgr = SoundManager.getSoundManager();
			_eventLogs = new Vector.<LogConsole>();
			for (var i:int=0;i<6;i++)
			{
				var eventLog:LogConsole = new LogConsole(_app,this);
				eventLog.changeParameters(0,0,300,_app.stage.stageHeight,0.8,0xFFFFFF,48+i);
				_eventLogs.push(eventLog);
			}
			_soundMgr.addLogConsoles(_eventLogs);

			//set up group boxes
			_grpBoxTop = _soundMgr.createNewGroup();
			_grpBoxBtm = _soundMgr.createNewGroup();
			_grpBoxRgt = _soundMgr.createNewGroup();
			_grpBoxLef = _soundMgr.createNewGroup();
			_grpBoxCor = _soundMgr.createNewGroup();
			
			_grpBoxTop.name = "Top";
			_grpBoxBtm.name = "Bottom";
			_grpBoxRgt.name = "Right";
			_grpBoxLef.name = "Left";
			_grpBoxCor.name = "Centre";
			
			_grpBoxTop.applyPhysics = true;
			_grpBoxBtm.applyPhysics = true;
			_grpBoxRgt.applyPhysics = true;
			_grpBoxLef.applyPhysics = true;
			
			//set up shops of pSnds
			_worldPSnds = new Vector.<PositionalSound>();
			_prevWorldPSnds = new Dictionary();
			
			//parade
			_parade = new ParadeMass(_app);
			//important, need to set a PSnd for the leader of the parade!
			var pLSndOpt:PositionalSoundInitOptions = new PositionalSoundInitOptions();
			pLSndOpt.isLooping = true;
			pLSndOpt.busId = BusManager.BACKGROUND;
			pLSndOpt.fileName = "sounds/Parade01.mp3";
			var pLSnd:PositionalSound = _soundMgr.createPositionalSound(pLSndOpt) as PositionalSound;
			_parade.addPSnd(pLSnd);
			


			
			// Abstraction
			var optionsDiag01:PositionalSoundInitOptions = new PositionalSoundInitOptions;
			var optionsDiag02:PositionalSoundInitOptions = new PositionalSoundInitOptions;
			var someSoundType1:AbstractSoundType = _soundMgr.createAbstractSoundType("absClap");
			optionsDiag01.fileName = "sounds/clap05.mp3";	//abs 5
			optionsDiag01.busId = BusManager.ENVIRONMENT;
			optionsDiag01.isLooping = true;
			optionsDiag01.abstractSoundType = "absClap";
			someSoundType1.addChild(5,_soundMgr.createPositionalSound(optionsDiag01));
			optionsDiag02.fileName = "sounds/clap010.mp3";	//abs 10
			optionsDiag02.abstractSoundType = "absClap";
			optionsDiag02.busId = BusManager.ENVIRONMENT;
			optionsDiag02.isLooping = true;
			someSoundType1.addChild(10,_soundMgr.createPositionalSound(optionsDiag02));
			
			var k:int = 0;
			var pMSndOpt:PositionalSoundInitOptions = new PositionalSoundInitOptions();
							//ORDER IS IMPORTANT!
			for (k = 0; k < 15; k++)
			{
				//set up the individual movable sounds
				pMSndOpt.fileName = "sounds/clap01.mp3";	//individual
				pMSndOpt.abstractSoundType = "absClap";
				pMSndOpt.isLooping = true;
				pMSndOpt.busId = BusManager.ENVIRONMENT;
				var pMSnd:PositionalSound = _soundMgr.createPositionalSound(pMSndOpt) as PositionalSound;
				_movingRep = new MovableAvatar(_app, Color.randomColor());
				this.addChild(_movingRep);
				//attach the sounds
				_movingRep.addPSnd(pMSnd);
				_parade.addMovableAvatar(_movingRep);
				//_app.audioManager.addSoundToBus(pMSnd, 0);
			}
			
			
			//set up parade holder
			_paradeHolder = new ParadeMassHolder(_app);
			_paradeHolder.addParade(_parade);
			_currParade = _paradeHolder.retrieveParade(_worldPSnds);
			
			
			//Randomly placed static avatars
			var someSoundType2:AbstractSoundType = _soundMgr.createAbstractSoundType("someSoundType2");
			var pSSndOpt:PositionalSoundInitOptions = new PositionalSoundInitOptions();
//			for (k=0; k<3; k++)
//			{
//				var pSSndOpt:PositionalSoundInitOptions = new PositionalSoundInitOptions();
//				var pSSnd:PositionalSound = _soundMgr.createPositionalSound(pSSndOpt) as PositionalSound;
//				pSSndOpt.fileName = "sounds/Diag01.mp3";	//individual
//				pSSndOpt.abstractSoundType = "someSoundType";
//				pSSndOpt.isLooping = true;
//				_visualRep = new StaticAvatar(_app, Color.RED);
//				_visualRep.addPSnd(pSSnd);
//				_visualRep.x = Utility.randomRange(780,20);
//				_visualRep.y = Utility.randomRange(580,20);
//				_visualRep.updatePSndPosition();
//				this.addChild(_visualRep);
//				_app.audioManager.addSoundToBus(pSSnd,0);
//				
//				_worldPSnds.push(pSSnd);
//			}
			
			//init clouds. THIS ORDER IS IMPORTANT
			_cloud = new Cloud(_app);
			_movingRep = new MovableAvatar(_app);
			
			this.addChild(_movingRep);
			_cloud.addACloud(_movingRep);
			
			_movingRep = new MovableAvatar(_app);
			
			this.addChild(_movingRep);
			_cloud.addACloud(_movingRep);
			
			_cloud.cleanUp();
			
			//Make LOD tree==============================
			_LODTree = new LevelOfDetailTree();
			//===========================================
			//STATIC SOUNDS==============================
			//Train station
				//BG snd
			var pSndOpt:PositionalSoundInitOptions = new PositionalSoundInitOptions();
			pSndOpt.fileName = "sounds/Station01.mp3";
			pSndOpt.busId = BusManager.BACKGROUND;
			var pSnd:PositionalSound = _soundMgr.createPositionalSound(pSndOpt) as PositionalSound;
			
			_visualRep = new StaticAvatar(_app,Color.RED);
			_visualRep.x = 357;
			_visualRep.y = 123;
			_visualRep.addPSnd(pSnd);
			_visualRep.updatePSndPosition();
				//create its node, and link it to parent
			_LODNode = new LevelOfDetailNode();
			_LODNode.addAvatar(_visualRep);
			_LODNode.debugZone = "Station";
			_LODTree.addChildToRoot(_LODNode);
//			this.addChild(_visualRep);
			
						//ChooChoo01
			pSndOpt = new PositionalSoundInitOptions();
			pSndOpt.fileName = "sounds/ChooChoo01.mp3";
			pSndOpt.busId = BusManager.ENVIRONMENT;
			pSnd = _soundMgr.createPositionalSound(pSndOpt) as PositionalSound;
			
			_visualRep = new StaticAvatar(_app,Color.RED);
			_visualRep.x = 330;
			_visualRep.y = 24;
			_visualRep.addPSnd(pSnd);
			_visualRep.updatePSndPosition();
			//create its node, and link it to Station
			_LODChild = new LevelOfDetailNode();
			_LODChild.debugZone = "ChooChoo01";
			_LODChild.addAvatar(_visualRep);
			_LODTree.addChildTo(_LODNode,_LODChild);
						
				//Vending machines
					//Vending 1
			pSndOpt = new PositionalSoundInitOptions();
			pSndOpt.fileName = "sounds/Vend01.mp3";
			pSndOpt.busId = BusManager.ENVIRONMENT;
			pSnd = _soundMgr.createPositionalSound(pSndOpt) as PositionalSound;
			
			_visualRep = new StaticAvatar(_app,Color.RED);
			_visualRep.x = 268;
			_visualRep.y = 226;
			_visualRep.addPSnd(pSnd);
			_visualRep.updatePSndPosition();
			//create its node, and link it to Station
			_LODChild = new LevelOfDetailNode();
			_LODChild.debugZone = "Vend_1";
			_LODChild.addAvatar(_visualRep);
			_LODTree.addChildTo(_LODNode,_LODChild);
					
					//Vending 2
			pSndOpt = new PositionalSoundInitOptions();
			pSndOpt.fileName = "sounds/Vend01.mp3";
			pSndOpt.busId = BusManager.ENVIRONMENT;
			pSnd = _soundMgr.createPositionalSound(pSndOpt) as PositionalSound;
			
			_visualRep = new StaticAvatar(_app,Color.RED);
			_visualRep.x = 310;
			_visualRep.y = 230;
			_visualRep.addPSnd(pSnd);
			_visualRep.updatePSndPosition();
			//create its node, and link it to Station
			_LODChild = new LevelOfDetailNode();
			_LODChild.debugZone = "Vend_2";
			_LODChild.addAvatar(_visualRep);
			_LODTree.addChildTo(_LODNode,_LODChild);
			
					//Vending 3
			pSndOpt = new PositionalSoundInitOptions();
			pSndOpt.fileName = "sounds/Vend01.mp3";
			pSndOpt.busId = BusManager.ENVIRONMENT;
			pSnd = _soundMgr.createPositionalSound(pSndOpt) as PositionalSound;
			
			_visualRep = new StaticAvatar(_app,Color.RED);
			_visualRep.x = 356;
			_visualRep.y = 230;
			_visualRep.addPSnd(pSnd);
			_visualRep.updatePSndPosition();
			//create its node, and link it to Station
			_LODChild = new LevelOfDetailNode();
			_LODChild.debugZone = "Vend_3";
			_LODChild.addAvatar(_visualRep);
			_LODTree.addChildTo(_LODNode,_LODChild);
			
					//Vending 4
			pSndOpt = new PositionalSoundInitOptions();
			pSndOpt.fileName = "sounds/Vend01.mp3";
			pSndOpt.busId = BusManager.ENVIRONMENT;
			pSnd = _soundMgr.createPositionalSound(pSndOpt) as PositionalSound;
			
			_visualRep = new StaticAvatar(_app,Color.RED);
			_visualRep.x = 404;
			_visualRep.y = 230;
			_visualRep.addPSnd(pSnd);
			_visualRep.updatePSndPosition();
			//create its node, and link it to Station
			_LODChild = new LevelOfDetailNode();
			_LODChild.debugZone = "Vend_4";
			_LODChild.addAvatar(_visualRep);
			_LODTree.addChildTo(_LODNode,_LODChild);
			
					//Vending 5
			pSndOpt = new PositionalSoundInitOptions();
			pSndOpt.fileName = "sounds/Vend01.mp3";
			pSndOpt.busId = BusManager.ENVIRONMENT;
			pSnd = _soundMgr.createPositionalSound(pSndOpt) as PositionalSound;
			
			_visualRep = new StaticAvatar(_app,Color.RED);
			_visualRep.x = 447;
			_visualRep.y = 230;
			_visualRep.addPSnd(pSnd);
			_visualRep.updatePSndPosition();
			//create its node, and link it to Station
			_LODChild = new LevelOfDetailNode();
			_LODChild.debugZone = "Vend_5";
			_LODChild.addAvatar(_visualRep);
			_LODTree.addChildTo(_LODNode,_LODChild);
			
			
			//Studio
				//BG snd
			pSndOpt = new PositionalSoundInitOptions();
			pSndOpt.fileName = "sounds/RockBand01.mp3";
			pSndOpt.busId = BusManager.BACKGROUND;
			pSnd = _soundMgr.createPositionalSound(pSndOpt) as PositionalSound;
			
			_visualRep = new StaticAvatar(_app,Color.RED);
			_visualRep.x = 654;
			_visualRep.y = 123;
			_visualRep.addPSnd(pSnd);
			_visualRep.updatePSndPosition();
			//create its node, and link it to parent
			_LODNode = new LevelOfDetailNode();
			_LODNode.debugZone = "Studio";
			_LODNode.addAvatar(_visualRep);
			_LODTree.addChildToRoot(_LODNode);
//											this.addChild(_visualRep);

			
						//Piano01
			pSndOpt = new PositionalSoundInitOptions();
			pSndOpt.fileName = "sounds/Piano01.mp3";
			pSndOpt.busId = BusManager.ENVIRONMENT;
			pSnd = _soundMgr.createPositionalSound(pSndOpt) as PositionalSound;
			
			_visualRep = new StaticAvatar(_app,Color.RED);
			_visualRep.x = 544;
			_visualRep.y = 37;
			_visualRep.addPSnd(pSnd);
			_visualRep.updatePSndPosition();
			//create its node, and link it to parent
			_LODChild = new LevelOfDetailNode();
			_LODChild.debugZone = "Piano01";
			_LODChild.addAvatar(_visualRep);
			_LODTree.addChildTo(_LODNode,_LODChild);
			
						//Piano02
			pSndOpt = new PositionalSoundInitOptions();
			pSndOpt.fileName = "sounds/Piano02.mp3";
			pSndOpt.busId = BusManager.ENVIRONMENT;
			pSnd = _soundMgr.createPositionalSound(pSndOpt) as PositionalSound;
			
			_visualRep = new StaticAvatar(_app,Color.RED);
			_visualRep.x = 759;
			_visualRep.y = 49;
			_visualRep.addPSnd(pSnd);
			_visualRep.updatePSndPosition();
			//create its node, and link it to parent
			_LODChild = new LevelOfDetailNode();
			_LODChild.debugZone = "Piano02";
			_LODChild.addAvatar(_visualRep);
			_LODTree.addChildTo(_LODNode,_LODChild);

			
						//Drums01
			pSndOpt = new PositionalSoundInitOptions();
			pSndOpt.fileName = "sounds/Drums01.mp3";
			pSndOpt.busId = BusManager.ENVIRONMENT;
			pSnd = _soundMgr.createPositionalSound(pSndOpt) as PositionalSound;
			
			_visualRep = new StaticAvatar(_app,Color.RED);
			_visualRep.x = 653;
			_visualRep.y = 40;
			_visualRep.addPSnd(pSnd);
			_visualRep.updatePSndPosition();
			//create its node, and link it to parent
			_LODChild = new LevelOfDetailNode();
			_LODChild.debugZone = "Drums01";
			_LODChild.addAvatar(_visualRep);
			_LODTree.addChildTo(_LODNode,_LODChild);
			
						//Drums02
			pSndOpt = new PositionalSoundInitOptions();
			pSndOpt.fileName = "sounds/Drums02.mp3";
			pSndOpt.busId = BusManager.ENVIRONMENT;
			pSnd = _soundMgr.createPositionalSound(pSndOpt) as PositionalSound;
			
			_visualRep = new StaticAvatar(_app,Color.RED);
			_visualRep.x = 743;
			_visualRep.y = 192;
			_visualRep.addPSnd(pSnd);
			_visualRep.updatePSndPosition();
			//create its node, and link it to parent
			_LODChild = new LevelOfDetailNode();
			_LODChild.debugZone = "Drums02";
			_LODChild.addAvatar(_visualRep);
			_LODTree.addChildTo(_LODNode,_LODChild);
			
						//Vocals01
			pSndOpt = new PositionalSoundInitOptions();
			pSndOpt.fileName = "sounds/Vocals01.mp3";
			pSndOpt.busId = BusManager.ENVIRONMENT;
			pSnd = _soundMgr.createPositionalSound(pSndOpt) as PositionalSound;
			
			_visualRep = new StaticAvatar(_app,Color.RED);
			_visualRep.x = 648;
			_visualRep.y = 207;
			_visualRep.addPSnd(pSnd);
			_visualRep.updatePSndPosition();
			//create its node, and link it to parent
			_LODChild = new LevelOfDetailNode();
			_LODChild.debugZone = "Vocals01";
			_LODChild.addAvatar(_visualRep);
			_LODTree.addChildTo(_LODNode,_LODChild);

			
						//Guitar01
			pSndOpt = new PositionalSoundInitOptions();
			pSndOpt.fileName = "sounds/Guitar01.mp3";
			pSndOpt.busId = BusManager.ENVIRONMENT;
			pSnd = _soundMgr.createPositionalSound(pSndOpt) as PositionalSound;
			
			_visualRep = new StaticAvatar(_app,Color.RED);
			_visualRep.x = 753;
			_visualRep.y = 115;
			_visualRep.addPSnd(pSnd);
			_visualRep.updatePSndPosition();
			//create its node, and link it to parent
			_LODChild = new LevelOfDetailNode();
			_LODChild.debugZone = "Guitar01";
			_LODChild.addAvatar(_visualRep);
			_LODTree.addChildTo(_LODNode,_LODChild);


						//Guitar02
			pSndOpt = new PositionalSoundInitOptions();
			pSndOpt.fileName = "sounds/Guitar02.mp3";
			pSndOpt.busId = BusManager.ENVIRONMENT;
			pSnd = _soundMgr.createPositionalSound(pSndOpt) as PositionalSound;
			
			_visualRep = new StaticAvatar(_app,Color.RED);
			_visualRep.x = 546;
			_visualRep.y = 192;
			_visualRep.addPSnd(pSnd);
			_visualRep.updatePSndPosition();
			//create its node, and link it to parent
			_LODChild = new LevelOfDetailNode();
			_LODChild.debugZone = "Guitar02";
			_LODChild.addAvatar(_visualRep);
			_LODTree.addChildTo(_LODNode,_LODChild);
			
			
			//Arcade
				//BG snd
			pSndOpt = new PositionalSoundInitOptions();
			pSndOpt.fileName = "sounds/ArcadeRoom01.mp3";
			pSndOpt.busId = BusManager.BACKGROUND;
			pSnd = _soundMgr.createPositionalSound(pSndOpt) as PositionalSound;
			
			_visualRep = new StaticAvatar(_app,Color.RED);
			_visualRep.x = 655;
			_visualRep.y = 349;
			_visualRep.addPSnd(pSnd);
			_visualRep.updatePSndPosition();
			//create its node, and link it to parent
			_LODNode = new LevelOfDetailNode();
			_LODNode.debugZone = "Arcade";
			_LODNode.addAvatar(_visualRep);
			_LODTree.addChildToRoot(_LODNode);
//													this.addChild(_visualRep);

						//Set up abstract group for arcade mac
			var optionsArcade:PositionalSoundInitOptions = new PositionalSoundInitOptions;
			var ArcadeType:AbstractSoundType = _soundMgr.createAbstractSoundType("absArcade");
			optionsArcade.fileName = "sounds/ArcadeMacA01.mp3";
			optionsArcade.abstractSoundType = "absArcade";
			optionsArcade.busId = BusManager.ENVIRONMENT;
			ArcadeType.addChild(1,_soundMgr.createPositionalSound(optionsArcade));
			
						//ArcadeMac01
			pSndOpt = new PositionalSoundInitOptions();
			pSndOpt.fileName = "sounds/ArcadeMac01.mp3";
			pSndOpt.busId = BusManager.ENVIRONMENT;
			pSndOpt.abstractSoundType = "absArcade"
			pSnd = _soundMgr.createPositionalSound(pSndOpt) as PositionalSound;
			
			_visualRep = new StaticAvatar(_app,Color.AQUA);
			_visualRep.x = 525;
			_visualRep.y = 279;
			_visualRep.addPSnd(pSnd);
			_visualRep.updatePSndPosition();
			//create its node, and link it to parent
			_LODChild = new LevelOfDetailNode();
			_LODChild.debugZone = "ArcadeMac01";
			_LODChild.addAvatar(_visualRep);
			_LODTree.addChildTo(_LODNode,_LODChild);
			
//			this.addChild(_visualRep);
			
						//ArcadeMac02
			pSndOpt = new PositionalSoundInitOptions();
			pSndOpt.fileName = "sounds/ArcadeMac02.mp3";
			pSndOpt.busId = BusManager.ENVIRONMENT;
			pSndOpt.abstractSoundType = "absArcade";
			pSnd = _soundMgr.createPositionalSound(pSndOpt) as PositionalSound;
			
			_visualRep = new StaticAvatar(_app,Color.AQUA);
			_visualRep.x = 525;
			_visualRep.y = 329;
			_visualRep.addPSnd(pSnd);
			_visualRep.updatePSndPosition();
			//create its node, and link it to parent
			_LODChild = new LevelOfDetailNode();
			_LODChild.debugZone = "ArcadeMac02";
			_LODChild.addAvatar(_visualRep);
			_LODTree.addChildTo(_LODNode,_LODChild);
			
//			this.addChild(_visualRep);
			
						//ArcadeMac03
			pSndOpt = new PositionalSoundInitOptions();
			pSndOpt.fileName = "sounds/ArcadeMac03.mp3";
			pSndOpt.busId = BusManager.ENVIRONMENT;
			pSndOpt.abstractSoundType = "absArcade";
			pSnd = _soundMgr.createPositionalSound(pSndOpt) as PositionalSound;
			
			_visualRep = new StaticAvatar(_app,Color.AQUA);
			_visualRep.x = 525;
			_visualRep.y = 368;
			_visualRep.addPSnd(pSnd);
			_visualRep.updatePSndPosition();
			//create its node, and link it to parent
			_LODChild = new LevelOfDetailNode();
			_LODChild.debugZone = "ArcadeMac03";
			_LODChild.addAvatar(_visualRep);
			_LODTree.addChildTo(_LODNode,_LODChild);
			
//			this.addChild(_visualRep);
			
						//ArcadeMac04
			pSndOpt = new PositionalSoundInitOptions();
			pSndOpt.fileName = "sounds/ArcadeMac04.mp3";
			pSndOpt.busId = BusManager.ENVIRONMENT;
			pSndOpt.abstractSoundType = "absArcade";
			pSnd = _soundMgr.createPositionalSound(pSndOpt) as PositionalSound;
			
			_visualRep = new StaticAvatar(_app,Color.AQUA);
			_visualRep.x = 525;
			_visualRep.y = 412;
			_visualRep.addPSnd(pSnd);
			_visualRep.updatePSndPosition();
			//create its node, and link it to parent
			_LODChild = new LevelOfDetailNode();
			_LODChild.debugZone = "ArcadeMac04";
			_LODChild.addAvatar(_visualRep);
			_LODTree.addChildTo(_LODNode,_LODChild);
			
//			this.addChild(_visualRep);
			
						//ArcadeMac05
			pSndOpt = new PositionalSoundInitOptions();
			pSndOpt.fileName = "sounds/ArcadeMac05.mp3";
			pSndOpt.busId = BusManager.ENVIRONMENT;
			pSndOpt.abstractSoundType = "absArcade";
			pSnd = _soundMgr.createPositionalSound(pSndOpt) as PositionalSound;
			
			_visualRep = new StaticAvatar(_app,Color.AQUA);
			_visualRep.x = 626;
			_visualRep.y = 279;
			_visualRep.addPSnd(pSnd);
			_visualRep.updatePSndPosition();
			//create its node, and link it to parent
			_LODChild = new LevelOfDetailNode();
			_LODChild.debugZone = "ArcadeMac05";
			_LODChild.addAvatar(_visualRep);
			_LODTree.addChildTo(_LODNode,_LODChild);
			
//			this.addChild(_visualRep);
			
						//ArcadeMac06
			pSndOpt = new PositionalSoundInitOptions();
			pSndOpt.fileName = "sounds/ArcadeMac06.mp3";
			pSndOpt.busId = BusManager.ENVIRONMENT;
			pSndOpt.abstractSoundType = "absArcade";
			pSnd = _soundMgr.createPositionalSound(pSndOpt) as PositionalSound;
			
			_visualRep = new StaticAvatar(_app,Color.AQUA);
			_visualRep.x = 626;
			_visualRep.y = 329;
			_visualRep.addPSnd(pSnd);
			_visualRep.updatePSndPosition();
			//create its node, and link it to parent
			_LODChild = new LevelOfDetailNode();
			_LODChild.debugZone = "ArcadeMac06";
			_LODChild.addAvatar(_visualRep);
			_LODTree.addChildTo(_LODNode,_LODChild);
			
//			this.addChild(_visualRep);
			
						//ArcadeMac07
			pSndOpt = new PositionalSoundInitOptions();
			pSndOpt.fileName = "sounds/ArcadeMac07.mp3";
			pSndOpt.busId = BusManager.ENVIRONMENT;
			pSndOpt.abstractSoundType = "absArcade";
			pSnd = _soundMgr.createPositionalSound(pSndOpt) as PositionalSound;
			
			_visualRep = new StaticAvatar(_app,Color.AQUA);
			_visualRep.x = 626;
			_visualRep.y = 368;
			_visualRep.addPSnd(pSnd);
			_visualRep.updatePSndPosition();
			//create its node, and link it to parent
			_LODChild = new LevelOfDetailNode();
			_LODChild.debugZone = "ArcadeMac07";
			_LODChild.addAvatar(_visualRep);
			_LODTree.addChildTo(_LODNode,_LODChild);
			
//			this.addChild(_visualRep);
			
						//ArcadeMac08
			pSndOpt = new PositionalSoundInitOptions();
			pSndOpt.fileName = "sounds/ArcadeMac08.mp3";
			pSndOpt.busId = BusManager.ENVIRONMENT;
			pSndOpt.abstractSoundType = "absArcade";
			pSnd = _soundMgr.createPositionalSound(pSndOpt) as PositionalSound;
			
			_visualRep = new StaticAvatar(_app,Color.AQUA);
			_visualRep.x = 626;
			_visualRep.y = 412;
			_visualRep.addPSnd(pSnd);
			_visualRep.updatePSndPosition();
			//create its node, and link it to parent
			_LODChild = new LevelOfDetailNode();
			_LODChild.debugZone = "ArcadeMac08";
			_LODChild.addAvatar(_visualRep);
			_LODTree.addChildTo(_LODNode,_LODChild);
			
//			this.addChild(_visualRep);
			
						//ArcadeMac09
			pSndOpt = new PositionalSoundInitOptions();
			pSndOpt.fileName = "sounds/ArcadeMac09.mp3";
			pSndOpt.busId = BusManager.ENVIRONMENT;
			pSndOpt.abstractSoundType = "absArcade";
			pSnd = _soundMgr.createPositionalSound(pSndOpt) as PositionalSound;
			
			_visualRep = new StaticAvatar(_app,Color.AQUA);
			_visualRep.x = 684;
			_visualRep.y = 279;
			_visualRep.addPSnd(pSnd);
			_visualRep.updatePSndPosition();
			//create its node, and link it to parent
			_LODChild = new LevelOfDetailNode();
			_LODChild.debugZone = "ArcadeMac09";
			_LODChild.addAvatar(_visualRep);
			_LODTree.addChildTo(_LODNode,_LODChild);
			
//			this.addChild(_visualRep);
			
						//ArcadeMac10
			pSndOpt = new PositionalSoundInitOptions();
			pSndOpt.fileName = "sounds/ArcadeMac10.mp3";
			pSndOpt.busId = BusManager.ENVIRONMENT;
			pSndOpt.abstractSoundType = "absArcade";
			pSnd = _soundMgr.createPositionalSound(pSndOpt) as PositionalSound;
			
			_visualRep = new StaticAvatar(_app,Color.AQUA);
			_visualRep.x = 684;
			_visualRep.y = 329;
			_visualRep.addPSnd(pSnd);
			_visualRep.updatePSndPosition();
			//create its node, and link it to parent
			_LODChild = new LevelOfDetailNode();
			_LODChild.debugZone = "ArcadeMac10";
			_LODChild.addAvatar(_visualRep);
			_LODTree.addChildTo(_LODNode,_LODChild);
			
//			this.addChild(_visualRep);
			
			
						//ArcadeMac11
			pSndOpt = new PositionalSoundInitOptions();
			pSndOpt.fileName = "sounds/ArcadeMac11.mp3";
			pSndOpt.busId = BusManager.ENVIRONMENT;
			pSndOpt.abstractSoundType = "absArcade";
			pSnd = _soundMgr.createPositionalSound(pSndOpt) as PositionalSound;
			
			_visualRep = new StaticAvatar(_app,Color.AQUA);
			_visualRep.x = 684;
			_visualRep.y = 368;
			_visualRep.addPSnd(pSnd);
			_visualRep.updatePSndPosition();
			//create its node, and link it to parent
			_LODChild = new LevelOfDetailNode();
			_LODChild.debugZone = "ArcadeMac11";
			_LODChild.addAvatar(_visualRep);
			_LODTree.addChildTo(_LODNode,_LODChild);
			
//			this.addChild(_visualRep);
			
						//ArcadeMac12
			pSndOpt = new PositionalSoundInitOptions();
			pSndOpt.fileName = "sounds/ArcadeMac12.mp3";
			pSndOpt.busId = BusManager.ENVIRONMENT;
			pSndOpt.abstractSoundType = "absArcade";
			pSnd = _soundMgr.createPositionalSound(pSndOpt) as PositionalSound;
			
			_visualRep = new StaticAvatar(_app,Color.AQUA);
			_visualRep.x = 684;
			_visualRep.y = 412;
			_visualRep.addPSnd(pSnd);
			_visualRep.updatePSndPosition();
			//create its node, and link it to parent
			_LODChild = new LevelOfDetailNode();
			_LODChild.debugZone = "ArcadeMac12";
			_LODChild.addAvatar(_visualRep);
			_LODTree.addChildTo(_LODNode,_LODChild);
			
//			this.addChild(_visualRep);
			
						//ArcadeMac13
			pSndOpt = new PositionalSoundInitOptions();
			pSndOpt.fileName = "sounds/ArcadeMac13.mp3";
			pSndOpt.busId = BusManager.ENVIRONMENT;
			pSndOpt.abstractSoundType = "absArcade";
			pSnd = _soundMgr.createPositionalSound(pSndOpt) as PositionalSound;
			
			_visualRep = new StaticAvatar(_app,Color.AQUA);
			_visualRep.x = 782;
			_visualRep.y = 279;
			_visualRep.addPSnd(pSnd);
			_visualRep.updatePSndPosition();
			//create its node, and link it to parent
			_LODChild = new LevelOfDetailNode();
			_LODChild.debugZone = "ArcadeMac13";
			_LODChild.addAvatar(_visualRep);
			_LODTree.addChildTo(_LODNode,_LODChild);
			
//			this.addChild(_visualRep);
			
						//ArcadeMac14
			pSndOpt = new PositionalSoundInitOptions();
			pSndOpt.fileName = "sounds/ArcadeMac14.mp3";
			pSndOpt.busId = BusManager.ENVIRONMENT;
			pSndOpt.abstractSoundType = "absArcade";
			pSnd = _soundMgr.createPositionalSound(pSndOpt) as PositionalSound;
			
			_visualRep = new StaticAvatar(_app,Color.AQUA);
			_visualRep.x = 782;
			_visualRep.y = 329;
			_visualRep.addPSnd(pSnd);
			_visualRep.updatePSndPosition();
			//create its node, and link it to parent
			_LODChild = new LevelOfDetailNode();
			_LODChild.debugZone = "ArcadeMac14";
			_LODChild.addAvatar(_visualRep);
			_LODTree.addChildTo(_LODNode,_LODChild);
			
//			this.addChild(_visualRep);
			
						//ArcadeMac15
			pSndOpt = new PositionalSoundInitOptions();
			pSndOpt.fileName = "sounds/ArcadeMac15.mp3";
			pSndOpt.busId = BusManager.ENVIRONMENT;
			pSndOpt.abstractSoundType = "absArcade";
			pSnd = _soundMgr.createPositionalSound(pSndOpt) as PositionalSound;
			
			_visualRep = new StaticAvatar(_app,Color.AQUA);
			_visualRep.x = 782;
			_visualRep.y = 368;
			_visualRep.addPSnd(pSnd);
			_visualRep.updatePSndPosition();
			//create its node, and link it to parent
			_LODChild = new LevelOfDetailNode();
			_LODChild.debugZone = "ArcadeMac15";
			_LODChild.addAvatar(_visualRep);
			_LODTree.addChildTo(_LODNode,_LODChild);
			
//			this.addChild(_visualRep);
			
						//ArcadeMac16
			pSndOpt = new PositionalSoundInitOptions();
			pSndOpt.fileName = "sounds/ArcadeMac16.mp3";
			pSndOpt.busId = BusManager.ENVIRONMENT;
			pSndOpt.abstractSoundType = "absArcade";
			pSnd = _soundMgr.createPositionalSound(pSndOpt) as PositionalSound;
			
			_visualRep = new StaticAvatar(_app,Color.AQUA);
			_visualRep.x = 782;
			_visualRep.y = 412;
			_visualRep.addPSnd(pSnd);
			_visualRep.updatePSndPosition();
			//create its node, and link it to parent
			_LODChild = new LevelOfDetailNode();
			_LODChild.debugZone = "ArcadeMac16";
			_LODChild.addAvatar(_visualRep);
			_LODTree.addChildTo(_LODNode,_LODChild);
			
//			this.addChild(_visualRep);
			
			//City
				//BG snd
			pSndOpt = new PositionalSoundInitOptions();
			pSndOpt.fileName = "sounds/Traffic01.mp3";
			pSndOpt.busId = BusManager.BACKGROUND;
			pSnd = _soundMgr.createPositionalSound(pSndOpt) as PositionalSound;
			
			_visualRep = new StaticAvatar(_app,Color.RED);
			_visualRep.x = 92;
			_visualRep.y = 526;
			_visualRep.addPSnd(pSnd);
			_visualRep.updatePSndPosition();
			//create its node, and link it to parent
			_LODNode = new LevelOfDetailNode();
			_LODNode.debugZone = "City";
			_LODNode.addAvatar(_visualRep);
			_LODTree.addChildToRoot(_LODNode);
			//===========================================
			
			
			//Viewport
			_logConsole = new LogConsole(_app,this);
			_viewport = new Viewport(_app);
			
			var _char1:NPC = new NPC(_viewport,_worldPSnds,325,101,-90,_app,Color.FUCHSIA,true);
			var	_char2:NPC = new NPC(_viewport,_worldPSnds,630,132,0,_app,Color.FUCHSIA,true);
			var _char3:NPC = new NPC(_viewport,_worldPSnds,214,328,170,_app,Color.FUCHSIA,true);
			var	_char4:NPC = new NPC(_viewport,_worldPSnds,563,369,180,_app,Color.FUCHSIA,true);
			var _char5:NPC = new NPC(_viewport,_worldPSnds,370,434,37,_app,Color.FUCHSIA,true);
			
			pSndOpt.fileName = "sounds/Diag01.mp3";
			pSndOpt.busId = BusManager.DIALOGUE;
			_char1.pushVectSnd(_soundMgr.createPositionalSound(pSndOpt) as PositionalSound);
			pSndOpt.fileName = "sounds/Diag02.mp3";
			pSndOpt.busId = BusManager.DIALOGUE;
			_char1.pushVectSnd(_soundMgr.createPositionalSound(pSndOpt) as PositionalSound);
			pSndOpt.fileName = "sounds/Diag03.mp3";
			pSndOpt.busId = BusManager.DIALOGUE;
			_char1.pushVectSnd(_soundMgr.createPositionalSound(pSndOpt) as PositionalSound);
			pSndOpt.fileName = "sounds/Diag04.mp3";
			pSndOpt.busId = BusManager.DIALOGUE;
			_char1.pushVectSnd(_soundMgr.createPositionalSound(pSndOpt) as PositionalSound);
			pSndOpt.fileName = "sounds/Diag05.mp3";
			pSndOpt.busId = BusManager.DIALOGUE;
			_char1.pushVectSnd(_soundMgr.createPositionalSound(pSndOpt) as PositionalSound);
			
			pSndOpt.fileName = "sounds/Diag11.mp3";
			pSndOpt.busId = BusManager.DIALOGUE;
			_char2.pushVectSnd(_soundMgr.createPositionalSound(pSndOpt) as PositionalSound);
			pSndOpt.fileName = "sounds/Diag12.mp3";
			pSndOpt.busId = BusManager.DIALOGUE;
			_char2.pushVectSnd(_soundMgr.createPositionalSound(pSndOpt) as PositionalSound);			
			pSndOpt.fileName = "sounds/Diag13.mp3";
			pSndOpt.busId = BusManager.DIALOGUE;
			_char2.pushVectSnd(_soundMgr.createPositionalSound(pSndOpt) as PositionalSound);			
			pSndOpt.fileName = "sounds/Diag14.mp3";
			pSndOpt.busId = BusManager.DIALOGUE;
			_char2.pushVectSnd(_soundMgr.createPositionalSound(pSndOpt) as PositionalSound);			
			pSndOpt.fileName = "sounds/Diag15.mp3";
			pSndOpt.busId = BusManager.DIALOGUE;
			_char2.pushVectSnd(_soundMgr.createPositionalSound(pSndOpt) as PositionalSound);			
			pSndOpt.fileName = "sounds/Diag16.mp3";
			pSndOpt.busId = BusManager.DIALOGUE;
			_char2.pushVectSnd(_soundMgr.createPositionalSound(pSndOpt) as PositionalSound);			
			pSndOpt.fileName = "sounds/Diag17.mp3";
			pSndOpt.busId = BusManager.DIALOGUE;
			_char2.pushVectSnd(_soundMgr.createPositionalSound(pSndOpt) as PositionalSound);			
			
			pSndOpt.fileName = "sounds/Diag31.mp3";
			pSndOpt.busId = BusManager.DIALOGUE;
			_char3.pushVectSnd(_soundMgr.createPositionalSound(pSndOpt) as PositionalSound);			
			pSndOpt.fileName = "sounds/Diag32.mp3";
			pSndOpt.busId = BusManager.DIALOGUE;
			_char3.pushVectSnd(_soundMgr.createPositionalSound(pSndOpt) as PositionalSound);			
			pSndOpt.fileName = "sounds/Diag33.mp3";
			pSndOpt.busId = BusManager.DIALOGUE;
			_char3.pushVectSnd(_soundMgr.createPositionalSound(pSndOpt) as PositionalSound);			
			pSndOpt.fileName = "sounds/Diag34.mp3";
			pSndOpt.busId = BusManager.DIALOGUE;
			_char3.pushVectSnd(_soundMgr.createPositionalSound(pSndOpt) as PositionalSound);			
			pSndOpt.fileName = "sounds/Diag35.mp3";
			pSndOpt.busId = BusManager.DIALOGUE;
			_char3.pushVectSnd(_soundMgr.createPositionalSound(pSndOpt) as PositionalSound);			
			
			pSndOpt.fileName = "sounds/Diag41.mp3";
			pSndOpt.busId = BusManager.DIALOGUE;
			_char4.pushVectSnd(_soundMgr.createPositionalSound(pSndOpt) as PositionalSound);			
			pSndOpt.fileName = "sounds/Diag42.mp3";
			pSndOpt.busId = BusManager.DIALOGUE;
			_char4.pushVectSnd(_soundMgr.createPositionalSound(pSndOpt) as PositionalSound);			
			pSndOpt.fileName = "sounds/Diag43.mp3";
			pSndOpt.busId = BusManager.DIALOGUE;
			_char4.pushVectSnd(_soundMgr.createPositionalSound(pSndOpt) as PositionalSound);			
			pSndOpt.fileName = "sounds/Diag44.mp3";
			pSndOpt.busId = BusManager.DIALOGUE;
			_char4.pushVectSnd(_soundMgr.createPositionalSound(pSndOpt) as PositionalSound);			
			pSndOpt.fileName = "sounds/Diag45.mp3";
			pSndOpt.busId = BusManager.DIALOGUE;
			_char4.pushVectSnd(_soundMgr.createPositionalSound(pSndOpt) as PositionalSound);			
			
			pSndOpt.fileName = "sounds/Diag51.mp3";
			pSndOpt.busId = BusManager.DIALOGUE;
			_char5.pushVectSnd(_soundMgr.createPositionalSound(pSndOpt) as PositionalSound);			
			pSndOpt.fileName = "sounds/Diag52.mp3";
			pSndOpt.busId = BusManager.DIALOGUE;
			_char5.pushVectSnd(_soundMgr.createPositionalSound(pSndOpt) as PositionalSound);						
			pSndOpt.fileName = "sounds/Diag53.mp3";
			pSndOpt.busId = BusManager.DIALOGUE;
			_char5.pushVectSnd(_soundMgr.createPositionalSound(pSndOpt) as PositionalSound);						
			pSndOpt.fileName = "sounds/Diag54.mp3";
			pSndOpt.busId = BusManager.DIALOGUE;
			_char5.pushVectSnd(_soundMgr.createPositionalSound(pSndOpt) as PositionalSound);			
			pSndOpt.fileName = "sounds/Diag55.mp3";
			pSndOpt.busId = BusManager.DIALOGUE;
			_char5.pushVectSnd(_soundMgr.createPositionalSound(pSndOpt) as PositionalSound);						
			
			this.addChild(_char1);
			this.addChild(_char2);
			this.addChild(_char3);
			this.addChild(_char4);
			this.addChild(_char5);
			
			this.addChild(_viewport);
			trace (_worldPSnds.length);
			
			var options:NativeWindowInitOptions = new NativeWindowInitOptions;
			options.type = NativeWindowType.NORMAL;
			var vis:BusMonitor = new BusMonitor(options);
			vis.master = BusManager.getBusManager().getBus(BusManager.MASTER);
			vis.x = 10;
			vis.y = 10;
			vis.width = 700;
			vis.height = 300;
			
			vis.activate();
		}
				
		public override function pause():void
		{
			super.pause();
		}
		
		public override function resume():void
		{
			super.resume();
		}
		
		public override function reset():void
		{
			
		}
		
		public override function onEnterFrame(frameTime:Number):void
		{
			var i:int = 0;
			var tempString:String;
			_viewport.updateVariable(frameTime);
			_BGM.play();
			//TODO: go through zoomLv and LODtree to get _worldPSnds WHEN VP MOVES
			if (_viewport.isMoving)
			{
				//a temp holder, so i don't have to call the function so many times
				_tempLODNode = _LODTree.getZoneNode(_LODTree.retrieveZone(_viewport.x,_viewport.y));
				//DEBUGGING
				if (_tempLODNode)
					trace("VP is in: " + _tempLODNode.debugZone + ". ZoomLv: " + _viewport.zoomLv);
				if ( _viewport.zoomLv > 3 )
					if (_tempLODNode != _prevTempLODNode)
					{
						_soundMgr.removeAllSoundsFromSoundGroups();					
						trace("Changed room");
						_prevTempLODNode = _tempLODNode;
					}
				Utility.clearVectorOfPSnd(_worldPSnds);
				

				if (_viewport.zoomLv < 3)
				{
					//if God-view, only world map snd 
//					_BGM.play();
					
				}
				else 
				{
					//_BGM.stop();
					if (_viewport.zoomLv > 3)
					{
						//shuriken only leaf
						//CHANGE only when change in room
						//Utility.clearVectorOfPSnd(_worldPSnds);
						trace ("This zone has " + _tempLODNode.retrieveDirectChildren().length + " children");
						for (i=0; i<_tempLODNode.retrieveDirectChildren().length; i++)
						{
							_worldPSnds.push(_tempLODNode.retrieveDirectChildren()[i].avatar.pSnd);
						}
						if (_currParade)
							_currParade.reattachParadeSnd(_worldPSnds);					
					}
					else
					{
						//shuriken only rooms
						trace ("This zone has " + _LODTree.root.retrieveDirectChildren().length + " children");
						for (i=0; i<_LODTree.root.retrieveDirectChildren().length; i++)
						{
							_worldPSnds.push(_LODTree.root.retrieveDirectChildren()[i].avatar.pSnd);
							trace(_LODTree.root.retrieveDirectChildren()[i].avatar.pSnd.options.fileName);
						}
//						if (_currParade)
//						_worldPSnds.push(_currParade.getLeaderSnd());
						if (_currParade)
							_currParade.reattachParadeSnd(_worldPSnds);
					}				
				}
			}
			
//			trace("_worldPSnds.length: " + _worldPSnds.length);
		
			//Cannot check only when VP is moving, since there's a parade
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
			if(this.isPaused)
				return;
			//PARADE
			if (_currParade)
			{
				if (_currParade.everyoneOut)
				{
					_currParade.cleanUp(_worldPSnds,_soundMgr);
					_currParade = null;
				}
				else
					_currParade.updateVariables(frameTime);
			}
			
			//CLOUD
			switch (_viewport.zoomLv)
			{
				//appear and update only if zoomlv is GodView
				case 0:
					if (_currCloud)
						_currCloud.updateVariables(frameTime);
					else
					{
						_currCloud = _cloud;
						_currCloud.reappear();
					}
					break;
				//remove clouds when below GodView
				default:
					if (_currCloud)
					{
						_currCloud = null;
						_cloud.cleanUp();
					}
					break;
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
					
					case Keyboard.P:
						if(this.isPaused) {
							this.resume();
						} else {
							this.pause();
						}
						break;
					case Keyboard.Z:
						if (_viewport.zoomLv > 0)
							_viewport.zoomLv--;
						else
							_viewport.zoomLv = 4;
						
						_viewport.reDrawViewport();
						Utility.clearVectorOfPSnd(_worldPSnds);
//						if (_currParade)
//							_currParade.reattachParadeSnd(_worldPSnds);
						_soundMgr.removeAllSoundsFromSoundGroups();
						break;
					case Keyboard.X:
						if (_viewport.speed == Viewport.FAST)
							_viewport.speed = Viewport.SLOW;
						else
							_viewport.speed = Viewport.FAST;
						break;
					case Keyboard.M:
						if (!_currParade)
						{
							_currParade = _paradeHolder.retrieveParade(_worldPSnds);
						}
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