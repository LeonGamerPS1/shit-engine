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
	

		#if sys
		Application.current.onExit.add((i) ->
		{
			var txt = "";
			for (txt2 in CustomLogger.allTraces)
			{
				txt += '\n$txt2';
			}
			if (!sys.FileSystem.exists('./logs'))
				sys.FileSystem.createDirectory("./logs");
			sys.io.File.saveContent(("./logs/" + Date.now().toString()).replace(":",'-').replace(" ",'-'), txt);
		}, false, 999);
		#end
		FlxG.switchState(() -> new PlayState());
	}
}
