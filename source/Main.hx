package;


import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite
{
	// Year-Month-Day
	public static var version:String = "INDEV";
	public function new()
	{

		CustomLogger.init();
		
		super();
		addChild(new FlxGame(0, 0, states.InitState));
		addChild(new FPS(10,10,0xFFFFFFFF));
	}
}
