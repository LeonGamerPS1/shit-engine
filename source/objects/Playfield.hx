package objects;

import backend.data.SongChartData;
import flixel.ui.FlxBar;

class Playfield extends FlxGroup
{
	public var dadStrumline:Strumline;
	public var bfStrumline:Strumline;

	public var currentSong:SongChartData;

	public var healthBarBG:FlxSprite;
	public var healthBar:FlxBar;

	public var health:Float = 1;
	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;

	public function new(song:SongChartData, skin:String = "default", keys:Int = 4)
	{
		super();
		Conductor.offset = song.data.offset ?? 0;
		Conductor.bpm = song.data.bpm;
		dadStrumline = cast(add(new Strumline(this, skin, keys)));
		bfStrumline = cast(add(new Strumline(this, skin, keys)));
		trace(Conductor.stepLength);

		for (sL in [dadStrumline, bfStrumline])
		{
			sL.onHitNote.add(hitNote);
			sL.onMissNote.add(missNote);
		}

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

		Conductor.onBeat.add(beatHit);
		Conductor.onStep.add(stepHit);

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.getGraphic('healthBar'));
		healthBarBG.screenCenter(X);
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x, healthBarBG.y, RIGHT_TO_LEFT, Std.int(healthBarBG.width), Std.int(healthBarBG.height), this, 'health', 0, 2);
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar
		insert(members.indexOf(healthBarBG), healthBar);

		iconP1 = new HealthIcon("bf", true);
		iconP1.y = healthBar.y - (iconP1.height / 2);

		iconP2 = new HealthIcon("dad", false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP1);
		add(iconP2);
	}

	public function missNote(n:Note, dir:Int)
	{
		health -= 0.20;
	}

	public function hitNote(n:Note)
	{
		if (health < 2 && !n.strumline.isBot)
			health += 0.04;
	}

	public function beatHit(beat:Float)
	{
		dadStrumline?.beatHit();
		bfStrumline?.beatHit();

		iconP1.scale.set(1.2,1.2);
		iconP2.scale.set(1.2,1.2);

		iconP1.updateHitbox();
		iconP2.updateHitbox();
	}

	public function stepHit(step:Float)
	{
		dadStrumline?.stepHit();
		bfStrumline?.stepHit();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		var scaleP1 = FlxMath.lerp(1, iconP1.scale.x, Math.exp(-elapsed * 8));
		var scaleP2 = FlxMath.lerp(1, iconP2.scale.x, Math.exp(-elapsed * 8));
		iconP1.scale.set(scaleP1, scaleP1);
		iconP2.scale.set(scaleP2, scaleP2);

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;
		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;
	}
}
