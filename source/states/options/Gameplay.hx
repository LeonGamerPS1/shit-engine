package states.options;

class Gameplay extends BaseOptionCat
{
	public override function create()
	{
		super.create();

		addOption("Down Scroll", new Option("downScroll", BOOL));
		addOption("Hitsounds", new Option("hitSounds", BOOL));
		addOption("Enable Shaders", new Option("enableShaders", BOOL));
	}
}
