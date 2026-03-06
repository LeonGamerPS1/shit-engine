package objects;

import backend.data.SongChartData;

class Playfield extends FlxGroup
{
	public var dadStrumline:Strumline;
	public var bfStrumline:Strumline;

	public var currentSong:SongChartData;

	public function new(song:SongChartData, skin:String = "default", keys:Int = 4)
	{
		super();
		Conductor.offset = song.data.offset ?? 0;
		Conductor.bpm = song.data.bpm;
		dadStrumline = cast(add(new Strumline(this, skin, keys)));
		bfStrumline = cast(add(new Strumline(this, skin, keys)));
		trace(Conductor.stepLength);

		dadStrumline.isBot = true;
		dadStrumline.strums.setPosition(100, 50);
		bfStrumline.strums.setPosition(100 + (FlxG.width / 2), 50);
		bfStrumline.speed = dadStrumline.speed = song.data.speed;
		currentSong = song;

		for (tm in song.data.timingChanges)
			Conductor.addTimeChangeAt(tm.time, tm.bpm);

		dadStrumline.generateNotes(song.data.notes.filter((n) ->
		{
			return n.l < 4;
		}));
		bfStrumline.generateNotes(song.data.notes.filter((n) ->
		{
			return n.l > 3;
		}));

	
	}
}
