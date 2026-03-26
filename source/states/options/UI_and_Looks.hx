package states.options;

class UI_and_Looks extends BaseOptionCat
{
	public override function create()
	{
		super.create();
		addOption("Hold Covers", new Option("holdCovers", BOOL));
        addOption("Opaque Sustains", new Option("opaqueSustains", BOOL));
        addOption("Down Scroll", new Option("downScroll", BOOL));
	}
}