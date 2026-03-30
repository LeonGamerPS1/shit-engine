package states;

import backend.input.Controls;
import backend.modding.PolymodHandler;
import backend.settings.SaveData;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileCircle;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import lime.app.Application;
import states.menus.TitleState;

class InitState extends flixel.addons.transition.FlxTransitionableState
{
	override function create()
	{
		SaveData.init();
		PolymodHandler.init();
		Controls.init();
		FlxG.cameras.useBufferLocking = true;
		FlxG.signals.preStateCreate.add((s) ->
		{
			var c = Conductor;
			for (ass in [c.onBeat, c.onMeasure, c.onStep])
				ass.removeAll();
			Paths.clear();
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
		var dia = FlxGraphic.fromClass(GraphicTransTileCircle);
		FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 0.5, FlxPoint.get(0, -1), {
			asset: dia,
			width: 32,
			height: 32,
			frameRate: 122
		}, FlxRect.get(0, 0, FlxG.width, FlxG.height), TOP);
		FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.5, FlxPoint.get(0, 1), {
			asset: dia,
			width: 32,
			height: 32,
			frameRate: 122
		}, FlxRect.get(0, 0, FlxG.width, FlxG.height), TOP);
		FlxG.switchState(new states.menus.TitleState());
		FlxG.switchState(() -> new TitleState());
	}
}
