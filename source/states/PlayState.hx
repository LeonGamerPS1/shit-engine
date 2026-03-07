package states;

import backend.data.SongChartData;
import backend.gameplay.SongLoader;
import flixel.sound.FlxSoundGroup;
import haxe.Timer;
import objects.Playfield;

class PlayState extends FlxState
{
	public var playfield:Playfield;

	public var song:SongChartData;
	public var inst:FlxSound;

	public var enemyVocals:FlxSoundGroup;
	public var playerVocals:FlxSoundGroup;

	override public function create()
	{
		Conductor.timeChanges.resize(0);
		super.create();
		song = SongLoader.loadSong("bopeebo");
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

		startCallback();
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

	public function startSong()
	{
		startedSong = true;
		inst.play();
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
		enemyVocals.volume = enemyVolume * FlxG.sound.volume;
		playerVocals.volume = playerVolume * FlxG.sound.volume;

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

		super.update(elapsed);
	}
}
