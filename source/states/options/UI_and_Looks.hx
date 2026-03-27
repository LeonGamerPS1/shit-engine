package states.options;

class UI_and_Looks extends BaseOptionCat
{
	public override function create()
	{
		super.create();
	
        addOption("Down Scroll", new Option("downScroll", BOOL));
		addOption("Hitsounds", new Option("hitSounds", BOOL));

		//hud stuff
		addOption("Hold Covers", new Option("holdCovers", BOOL));
        addOption("Opaque Sustains", new Option("opaqueSustains", BOOL));
		addOption("Opponent Strums", new Option("opponentStrums", BOOL));
		addOption("Hide HUD", new Option("hideHUD", BOOL));
	}
}