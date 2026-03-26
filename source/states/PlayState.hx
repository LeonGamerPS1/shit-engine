package states;

import backend.data.SongChartData;
import backend.data.SongStageData.StageJSON;
import backend.data.SongStageData;
import backend.gameplay.SongLoader;
import backend.scripting.NxScriptM;
import flixel.math.FlxPoint;
import flixel.sound.FlxSoundGroup;
import haxe.Timer;
import nx.script.NativeProxy;
import objects.Note;
import objects.Playfield;
import objects.gameplay.Character;

class PlayState extends flixel.addons.transition.FlxTransitionableState
{
	public var playfield:Playfield;

	public static var song:SongChartData;
	public var inst:FlxSound;

	public var enemyVocals:FlxSoundGroup;
	public var playerVocals:FlxSoundGroup;

	public var camGame(get, null):FlxCamera;
	public var camHUD:FlxCamera;

	// enemy
	public var dadLayer:FlxGroup;
	public var dadPosition:FlxPoint = FlxPoint.get(100, 100);

	// gf
	public var gfLayer:FlxGroup;
	public var gfPosition:FlxPoint = FlxPoint.get(400, 130);

	// player
	public var boyfriendLayer:FlxGroup;
	public var boyfriendPosition:FlxPoint = FlxPoint.get(770, 100);

	public var dad:Character;
	public var gf:Character;
	public var bf:Character;

	public var camtracker:FlxObject = new FlxObject(0, 0, 1, 1);

	public var stageJSON:StageJSON;

	
	override public function create()
	{
		FlxG.sound.music.stop();
		camHUD = new FlxCamera();
		FlxG.cameras.add(camHUD, false);
		loadNXScripts(Paths.listDirectory('assets/data/scripts', TEXT));

		Conductor.timeChanges.resize(0);
		super.create();
		song ??= SongLoader.loadSong("bopeebo");
		stageJSON = SongStageData.getStageJSON(song.data.stage);
		boyfriendPosition.set(stageJSON.bfPos[0], stageJSON.bfPos[1]);
		dadPosition.set(stageJSON.dadPos[0], stageJSON.dadPos[1]);
		gfPosition.set(stageJSON.gfPos[0], stageJSON.gfPos[1]);
		defaultZoomGame = stageJSON.zoom;

		Conductor.bpm = song.data.bpm;
		Conductor.time = -(Conductor.beatLength * 5);

		var songFolder = song.songFolder;
		var instPath = '$songFolder/audio/${song.data.characters.instPath}.ogg';
		inst = FlxG.sound.list.add(new FlxSound());
		inst.load(FlxG.sound.cache(Paths.getPath(instPath)));

		enemyVocals = new FlxSoundGroup();
		playerVocals = new FlxSoundGroup();

		for (vocalEnemy in song.data.characters.enemyVocals)
		{
			var vocalPath = '$songFolder/audio/${vocalEnemy}.ogg';
			var flxsound:FlxSound = new FlxSound();
			flxsound.load(FlxG.sound.cache(Paths.getPath(vocalPath)));
			enemyVocals.add(flxsound);
		}
		for (playerVocal in song.data.characters.playerVocals)
		{
			var vocalPath = '$songFolder/audio/${playerVocal}.ogg';
			var flxsound:FlxSound = new FlxSound();
			flxsound.load(FlxG.sound.cache(Paths.getPath(vocalPath)));
			playerVocals.add(flxsound);
		}
		add(playfield = new Playfield(song));
		playfield.cameras = [camHUD];
		camGame.bgColor = 0xFF676767;
		for (strumLines in [playfield.dadStrumline, playfield.bfStrumline])
		{
			strumLines.onHitNote.add(hitNote);
			strumLines.onMissNote.add(missNote);
		}
		Conductor.onMeasure.add((e) ->
		{
			sectionHit();
		});
		loadNXScript('assets/data/stages/${song.data.stage}.nx');
		call('onStageLoad', [stageJSON, song.data.stage]);
		call('onCreate');
		gfLayer = new FlxGroup();
		dadLayer = new FlxGroup();
		boyfriendLayer = new FlxGroup();

		add(gfLayer);
		add(dadLayer);
		add(boyfriendLayer);

		dad = new Character(0, 0, song.data.characters.dad);
		dad.setPosition(dadPosition.x, dadPosition.y);
		dad.setPosition(dad.x + dad.json.pos_offset[0], dad.y + dad.json.pos_offset[1]);

		gf = new Character(0, 0, song.data.characters.gf);
		gf.setPosition(gfPosition.x, gfPosition.y);
		gf.setPosition(gf.x + gf.json.pos_offset[0], gf.y + gf.json.pos_offset[1]);

		bf = new Character(0, 0, song.data.characters.boyfriend, true);
		bf.setPosition(boyfriendPosition.x, boyfriendPosition.y);
		bf.setPosition(bf.x + bf.json.pos_offset[0], bf.y + bf.json.pos_offset[1]);

		gfLayer.add(gf);
		dadLayer.add(dad);
		boyfriendLayer.add(bf);

		playfield.dadStrumline.char = dad;
		playfield.bfStrumline.char = bf;

		camGame.follow(camtracker, LOCKON, 0.06);
		defaultZoomGame = 0.8;
		add(camtracker);

		song.data.events ??= [];
		for (event in song.data.events)
		{
			onEventLoad(event);
			events.push(event);
		}
		events.sort((e, e2) -> return e.t - e2.t);
		startCallback();

		call('onCreatePost');
		super.create();
	}

	public var scripts:Map<String, NxScriptM> = [];

	function loadNXScripts(paths:Array<String>)
	{
		for (hm in paths)
			loadNXScript(hm);
	}

	function loadNXScript(hm:String)
	{
		var script = scripts.get(hm);
		if (script != null)
			scripts.remove(hm);
		script?.dispose();
		if(!OpenFLAssets.exists(hm))
			return;
		script = new NxScriptM(hm, hm);
		scripts.set(hm, script);
		script.call('new');
	}

	public function call(fn:String, ?fv:Array<Dynamic>):Dynamic
	{
		var value:Dynamic = null;

		for (script in scripts.keyValueIterator())
		{
			var result = script.value.call(fn, fv);

			if (result != null)
			{
				value = result;
			}
		}

		return value;
	}

	public var events:Array<SongEventData> = [];

	public function get_camGame()
	{
		return FlxG.camera;
	}

	public function hitNote(n:Note)
	{
		call('onNoteHit', [n]);
		if (!n.strumline.isBot)
			playerVolume = 1;
		else
			enemyVolume = 1;
	}

	public function missNote(n:Note, ?dir:Int, strumline)
	{
		call('onNoteMiss', [n, dir, strumline]);
		if (strumline.isBot)
			playerVolume = 0;
	}

	var autoFocus:Bool = true;

	public function onEventLoad(event:SongEventData)
	{
		call("onEventLoad", [event]);
		if (event.n == 'change character')
		{
			var charname = event.v[1];
			var chartoreplace = event.v[0];
			var charOBJ = getCharFromString(chartoreplace);
			var oldchar = charOBJ.curCharacter;
			charOBJ.loadJson(charname ?? charOBJ.curCharacter);
			charOBJ.loadJson(oldchar);
		}
	}

	public function onEventTrigger(event:SongEventData)
	{
		call("onEventTrigger", [event]);
		if (event.n == 'change character')
		{
			var charname = event.v[0];
			var chartoreplace = event.v[1];
			var charOBJ = getCharFromString(chartoreplace);
			charOBJ.loadJson(charname ?? charOBJ.curCharacter);
			var pos = charOBJ.player ? boyfriendPosition : dadPosition;
			charOBJ.setPosition(pos.x + charOBJ.json.pos_offset[0], pos.y + charOBJ.json.pos_offset[1]);
		}
	}

	public function getCharFromString(charname:String):Character
	{
		var customChar = null;
		var char:Character = customChar;

		if (char == null)
		{
			switch (charname)
			{
				case "gf":
					char = gf;
				case "dad":
					char = dad;
				case "bf":
					char = bf;
			}
		}
		return char;
	}

	public function focusOnChar(char:Character)
	{
		camtracker.setPosition(char.getGraphicMidpoint().x, char.getGraphicMidpoint().y);
	}

	public var playerVolume:Float = 1;
	public var enemyVolume:Float = 1;
	public var focusLost:Bool = false;
	public var startTimer:FlxTimer;

	override function onFocusLost()
	{
		super.onFocusLost();
		focusLost = true;
		enemyVocals.volume = playerVocals.volume = 0;
		enemyVocals.pause();
		playerVocals.pause();
	}

	override function onFocus()
	{
		super.onFocus();
		focusLost = false;
		enemyVocals.volume = enemyVolume;
		playerVocals.volume = playerVolume;
		if (startedSong)
		{
			playerVocals.resume();
			enemyVocals.resume();
		}
	}

	var startedCountdown:Bool = false;
	var startedSong:Bool = false;

	dynamic public function startCallback()
	{
		startCountdown();
	}

	public var camBopMult:Float = 1;
	public var hudBopMult:Float = 1;
	public var defaultZoomHUD:Float = 1;
	public var defaultZoomGame:Float = 1;

	public function sectionHit()
	{
		FlxG.camera.zoom += 0.015 * camBopMult;
		camHUD.zoom += 0.03 * hudBopMult;
	}

	public function startSong()
	{
		startedSong = true;
		inst.play();
		playfield.progressBar.setRange(0, inst.length);
		FlxTween.tween(playfield.progressBar, {alpha: 1}, Conductor.beatLength / 1000);
		for (shit in playerVocals.sounds.concat(enemyVocals.sounds))
			shit.play();
	}

	public function startCountdown()
	{
		startedCountdown = true;
		startTimer = new FlxTimer().start(Conductor.beatLength / 1000, (t) ->
		{
			trace(t.loopsLeft);
		}, 4);
		startTimer.active = true;
	}

	override public function update(elapsed:Float)
	{
		FlxG.camera.zoom = FlxMath.lerp(defaultZoomGame, FlxG.camera.zoom, 0.95);
		camHUD.zoom = FlxMath.lerp(defaultZoomHUD, camHUD.zoom, 0.95);
		enemyVocals.volume = enemyVolume * inst.getActualVolume();
		playerVocals.volume = playerVolume * inst.getActualVolume();
		inst.volume = FlxG.sound.volume > 0 ? 1 : 0;

		if (startedCountdown && !startedSong)
		{
			Conductor.time += elapsed * 1000;
			if (Conductor.time >= Conductor.offset)
			{
				startSong();
				Conductor.time = inst.time;
			}
		}
		else
		{
			Conductor.time = inst.time;
			for (vocalSFX in playerVocals.sounds.concat(enemyVocals.sounds))
			{
				if (!vocalSFX.playing || !inst.playing)
					continue;
				if (Math.abs(Conductor.time - inst.time) > 10)
					vocalSFX.time = Conductor.time;
			}
		}

		if (events.length > 0)
		{
			var event = events[0];
			if (event == null)
				events.remove(event);
			else if (event.t <= Conductor.time - Conductor.offset)
			{
				var index:Int = events.indexOf(event);
				events.splice(index, 1);
				onEventTrigger(event);
			}
		}

		super.update(elapsed);
	}
}
