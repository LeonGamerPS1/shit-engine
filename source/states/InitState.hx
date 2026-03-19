package states;

import backend.input.Controls;
import lime.app.Application;

class InitState extends FlxState
{
	override function create()
	{
		Controls.init();
		FlxG.cameras.useBufferLocking = true;
		FlxG.signals.preStateSwitch.add(() ->
		{
			var c = Conductor;
			for (ass in [c.onBeat, c.onMeasure, c.onStep])
				ass.removeAll();
		});
		FlxG.switchState(() -> new PlayState());
	

		
	}
}
