package objects;

import backend.NoteSkin;
import backend.data.SongChartData.SongNoteData;
import flixel.input.keyboard.FlxKey;
import shaders.RGBSwap;

class Note extends FlxSprite
{
	public var strumline:Strumline;

	public var rgbswap:RGBSwap;
	public var noteData:SongNoteData;
	public var multSpeed:Float = 1;
	public var hit:Bool = false;
	public var isSustainNote:Bool = false;
	public var isEndNote:Bool = false;
	public var canBeHit:Bool = false;
	public var parentNote:Note;
	public var prevNote:Note;

	public function new(dir:SongNoteData, strumline:Strumline, isSusNote:Bool = false, isEndNote:Bool = false)
	{
		super();
		this.strumline = strumline;
		this.noteData = dir;
		this.isEndNote = isEndNote;
		this.isSustainNote = isSusNote;

		reload(strumline != null ? strumline.skin : 'default');
	}

	public var lastSkin = "";
	public var tempskin:Sskindat;

	function reload(skin = "default")
	{
		lastSkin = skin;
		tempskin = NoteSkin.getSkin(skin);
		applySkinRaw(tempskin);
	}

	public function applySkinRaw(tempskin:Sskindat)
	{
		var color:String = NoteSkin.noteColors[noteData.l % 4];
		frames = Paths.getSparrowAtlas('noteskins/${tempskin.name}/${tempskin.image}');
		animation.addByPrefix("arrow", '${color}0', 24, true);
		animation.addByPrefix("hold", '${color} hold piece0', 24, true);
		animation.addByPrefix("end", '${color} hold end0', 24, true);
		scale.set(tempskin.scale, tempskin.scale);


		antialiasing = tempskin.antialiasing;
		playAnim("arrow", false);
		if (isSustainNote)
			playAnim(!isEndNote ? 'hold' : 'end');
		updateHitbox();
		alpha = isSustainNote ? 0.6 : 1;
		if(isSustainNote && !isEndNote) {
			scale.y *=  Conductor.stepLength / 100 * 1.2 * strumline.speed;
			updateHitbox();
		}
	}

	override function update(d:Float)
	{
		super.update(d);
	}

	public var dir:SongNoteData;

	public function playAnim(s:String, force:Bool = false)
	{
		animation.play(s, force);
		centerOffsets();
		centerOrigin();
	}

	public var staticshader:FlxShader;

	override function destroy()
	{
		tempskin = null;
		shader = null;
		rgbswap = null;
		super.destroy();
	}
}
