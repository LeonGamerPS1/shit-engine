package objects;

import backend.NoteSkin;

class Strumline extends FlxGroup
{
	public var strums:FlxTypedSpriteGroup<Strum>;
	public var playfield:Playfield;
    public var isBot:Bool = false;

	public function new(pf:Playfield, skin:String = "default", keys:Int = 4)
	{
		super();
		this.playfield = pf;
        strums = new FlxTypedSpriteGroup();
        add(strums);
		genstrums(keys, skin);
	}

	function genstrums(keys:Int = 4, skin:String = "default")
	{
		for (i in 0...keys)
		{
			var strum:Strum = new Strum(skin, i, keys);
			strum.x = (160 * 0.7) * NoteSkin.noteScaleMults[keys - 1] * i;
			strums.add(strum);
		}
	}
}
