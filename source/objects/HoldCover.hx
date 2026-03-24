package objects;

import backend.NoteSkin;

class HoldCover extends FunkinSprite
{
	public function new(s:Strum)
	{
		super(0, 0);
		loadAtlas("holdCover", SPARROW);
		doShit(s);
	}

	var strum:Strum;

    var offsetx = 0;
    var offsety = 0;

	function doShit(strum:Strum)
	{
		this.strum = strum;
		var prefix = "holdCover";
		var color = NoteSkin.noteColors[strum.dir];

		addAnimPrefix("start", prefix + 'Start$color', 12);
		addAnimPrefix("hold", "holdCover" + color, 24, true);
		addAnimPrefix("end", "holdCoverEnd" + color, 24);
		playAnim("hold");
		updateHitbox();
		playAnim("hold");
		visible = false;
		animation.onFinish.add((n) ->
		{
			if (n == "start")
				playAnim("hold");
			if (n == "end")
			{
				visible = false;
				playAnim("hold");
			}
		});
	}

	public override function playAnim(animName:String, force = false, reversed = false, frame = 0)
	{
        offsety = offsetx = 0;
		super.playAnim(animName, force, reversed, frame);
		if (animation.curAnim?.curFrame == 0)
		{
			centerOffsets();
			centerOrigin();
		}
        if(animName == 'end') {
            offsetx += 50;
            offsety += 43;
        }
        if(animName == 'start') {
            offsetx -= 15;
            offsety -= 10;
        }
	}

	override function update(elapsed:Float)
	{
		setPosition(strum.x + 3 - (width) + strum.width / 4, (strum.y + 12) - (height));
        x += xx;
        y += yy;
		super.update(elapsed);
	}
}
