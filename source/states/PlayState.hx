package states;

import objects.Playfield;

class PlayState extends FlxState
{
	public var playfield:Playfield;

	override public function create()
	{
		super.create();
		add(playfield = new Playfield());
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}