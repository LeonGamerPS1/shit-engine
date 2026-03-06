package states;

import backend.data.SongChartData;
import backend.gameplay.SongLoader;
import haxe.Timer;
import objects.Playfield;

class PlayState extends FlxState
{
	public var playfield:Playfield;

	public var song:SongChartData;
	public var inst:FlxSound;

	override public function create()
	{
		Conductor.timeChanges.resize(0);
		super.create();
		add(playfield = new Playfield(song = SongLoader.loadSong("bopeebo", "ok")));
		Conductor.time = -(Conductor.beatLength * 5);
		var songFolder = song.songFolder;
		var instPath = '$songFolder/audio/${song.data.characters.instPath}.ogg';
		inst = FlxG.sound.list.add(new FlxSound());
		inst.load(FlxG.sound.cache(Paths.getPath(instPath)));

		startCallback();
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
	}

	public function startCountdown()
	{
		startedCountdown = true;
	}

	override public function update(elapsed:Float)
	{
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
		}

		
		super.update(elapsed);
	}
}
