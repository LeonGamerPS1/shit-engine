package;


import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite
{
	// ReleaseName-Month-Year-releasecount
	public static var version:String = "INDEV-03-2026-r1";
	public function new()
	{

		CustomLogger.init();
		
		super();
		addChild(new FlxGame(0, 0, states.InitState));
		addChild(new FPS(10,10,0xFFFFFFFF));
	}
}
