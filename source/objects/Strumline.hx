package objects;

import backend.NoteSkin;
import backend.data.SongChartData.SongNoteData;
import flixel.math.FlxRect;

class Strumline extends FlxGroup
{
	public var strums:FlxTypedSpriteGroup<Strum>;
	public var playfield:Playfield;
	public var isBot:Bool = false;

	public var unspawnedNotes:Array<Note> = [];
	public var skin:String = "default";
	public var zone:Float = 2500;
	public var speed:Float;

	public function new(pf:Playfield, skin:String = "default", keys:Int = 4)
	{
		super();
		this.playfield = pf;

		strums = new FlxTypedSpriteGroup();
		add(strums);
		notes = new FlxTypedGroup<Note>();
		notes.active = false;
		add(notes);

		genstrums(keys, skin);
	}

	function genstrums(keys:Int = 4, skin:String = "default")
	{
		this.skin = skin;
		for (i in 0...keys)
		{
			var strum:Strum = new Strum(skin, i, keys);
			strum.x = (160 * 0.7) * NoteSkin.noteScaleMults[keys - 1] * i;
			strums.add(strum);
		}
	}
	public function generateNotes(noteSet:Array<SongNoteData>)
	{
		if (noteSet == null || noteSet.length < 1)
			return;
		for (shit in unspawnedNotes)
			killNote(shit);

		var oldbpm = Conductor.bpm;
		for (i in 0...noteSet.length)
		{
			var noteData = noteSet[i];
			var note:Note = new Note(noteData, this);
			note.setPosition(-5000, -5000);
			unspawnedNotes.push(note);
			note.prevNote = unspawnedNotes[unspawnedNotes.length - 1] ?? note;
			var hmm = note.noteData.lms;

			if (hmm > 0)
			{
				var cock = hmm / Conductor.stepLength;

				for (segmentID in 0...Math.floor(cock))
				{
					var sData = Reflect.copy(noteData);
					sData.tms += Conductor.stepLength * segmentID;
					sData.tms += Conductor.stepLength / 2;
					var isEnd = (segmentID) == Math.floor(cock) - 1;
					var noteHold:Note = new Note(sData, this, true, isEnd);
					unspawnedNotes.push(noteHold);
					noteHold.setPosition(-5000, -5000);
					noteHold.parentNote = note;
					noteHold.prevNote = unspawnedNotes[unspawnedNotes.length - 1];
				}
			}
		}
		Conductor.bpm = oldbpm;
		trace('generating notes. for dad? ${isBot}. Amount? around ${unspawnedNotes.length} Notes including holds.');
	}

	public function killNote(note:Note)
	{
		notes.remove(note, true);
		note?.destroy();
		unspawnedNotes.remove(note);
	}

	public var notes:FlxTypedGroup<Note>;

	public override function update(elapsed:Float)
	{
		if (unspawnedNotes.length > 0)
		{
			final note = unspawnedNotes[0];
			final realZone = zone / speed / note.multSpeed;
			if (note.noteData.tms <= (Conductor.time - Conductor.offset) + realZone)
			{
				var note:Note = unspawnedNotes[0];
				notes.insert(0, note);
				notes.sort(FlxSort.byY);
				unspawnedNotes.remove(note);
			}
		}
		notes.sort(FlxSort.byY);
		notes.forEachAlive(updateNote);
		super.update(elapsed);
	}

	public dynamic function updateNote(note:Note)
	{
		var strum = strums.members[note.noteData.l % strums.length];
		note.x = strum.x + (strum.width * 0.5 - note.width * 0.5);
		final distance = (note.noteData.tms - Conductor.time) * (0.45 * speed * note.multSpeed) * (strum.flipScroll ? -1 : 1);
		note.y = strum.y + distance;
		if (!note.hit && isBot && note.noteData.tms <= Conductor.time)
		{
			strum.playAnim("confirm", true);
			note.hit = true;

			strum.rT = 0.15;
			if (!note.isSustainNote)
				killNote(note);
		}

		var center = strum.y + (160 * 0.7 * 0.5);
		if (strum.flipScroll)
		{
			note.flipY = true;
			if ((note.parentNote != null && note.parentNote.hit)
				&& note.y - note.offset.y * note.scale.y + note.height >= center
				&& (isBot || (note.hit || (note.prevNote.hit && !note.canBeHit))))
			{
				var swagRect = new FlxRect(0, 0, note.frameWidth, note.frameHeight);
				swagRect.height = (center - note.y) / note.scale.y;
				swagRect.y = note.frameHeight - swagRect.height;
				note.clipRect = swagRect.round();
			}
		}
		else
		{
			if ((note.parentNote != null && note.parentNote.hit)
				&& note.y + note.offset.y * note.scale.y <= center
				&& (isBot || (note.hit || (note.prevNote.hit && !note.canBeHit))))
			{
				var swagRect = new FlxRect(0, 0, note.width / note.scale.x, note.height / note.scale.y);
				swagRect.y = (center - note.y) / note.scale.y;
				swagRect.height -= swagRect.y;
				note.clipRect = swagRect.round();
			}
		}

		if (note.noteData.tms <= Conductor.time - (350 / note.multSpeed / speed))
		{
			killNote(note);
		}
	}
}
