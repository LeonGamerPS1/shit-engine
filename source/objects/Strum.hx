package objects;

import backend.NoteSkin;
import flixel.input.keyboard.FlxKey;
import shaders.RGBSwap;

class Strum extends FlxSprite
{
	public var flipScroll = false;

	public static var RESET_TIME = 0.15;

	public var rT = .0;
	public var rgbswap:RGBSwap;

	public function new(skin = "default", dir:Int = 0, k = 4)
	{
		super();
		this.dir = dir;
		reload(skin, k);
		shader = (rgbswap = new RGBSwap()).shader;
	}

	public var lastSkin = "";
	public var tempskin:Sskindat;

	function reload(skin = "default", ?keys:Int = 4)
	{
		lastSkin = skin;
		tempskin = NoteSkin.getSkin(skin);
		applySkinRaw(tempskin, keys);
	}

	public function applySkinRaw(tempskin:Sskindat, keys:Int = 4)
	{
		frames = Paths.getSparrowAtlas('noteskins/${tempskin.name}/${tempskin.image}');
		animation.addByPrefix("static", 'arrow static', 24, true);
		var direction:String = NoteSkin.strumDirections[keys - 1][dir];
		animation.addByPrefix("confirm", direction + ' confirm', 24, false);
		animation.addByPrefix("press", direction + ' press', 24, false);
		scale.set(tempskin.scale, tempskin.scale);
		updateHitbox();

		antialiasing = tempskin.antialiasing;
		playAnim("static", false, true);
	}

	override function update(d:Float)
	{
		super.update(d);

		if (rT != 0)
		{
			rT -= d;
			if (rT < 0)
			{
				rT = 0;
				playAnim('static', true, true);
			}
		}
	}

	static var angles = [-90, 180, 0, 90];

	public var dir = 0;

	public function playAnim(s:String, force:Bool = false, rotate:Bool = false)
	{
		angle = rotate ? angles[dir] : 0;
		animation.play(s, force);
		centerOffsets();
		centerOrigin();
	}

	public var staticshader:FlxShader;

	override function destroy()
	{
		tempskin = null;
		shader  = null;
		rgbswap = null;
		super.destroy();
	}
}
