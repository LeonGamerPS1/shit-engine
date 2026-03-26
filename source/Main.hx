package;

import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite
{
	public static var isDebug(default, null):Bool = #if debug true #else false #end;
	// ReleaseName-Month-Year-releasecount
	public static var version:String = "INDEV-03-2026-r1";

	public function new()
	{
		CustomLogger.init();

		super();
		addChild(new FlxGame(0, 0, states.InitState));
		addChild(new FPS(10, 10, 0xFFFFFFFF));
		FlxG.signals.focusGained.add(()->{
			FlxG.sound.resume();
		});
				
	}
}
