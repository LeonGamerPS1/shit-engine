package;

import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(0, 0, states.PlayState));
		FlxG.cameras.useBufferLocking = true;
		FlxG.signals.preStateSwitch.add(() ->
		{
			var c = Conductor;
			for (ass in [c.onBeat, c.onMeasure, c.onStep])
				ass.removeAll();
		});
	}
}
