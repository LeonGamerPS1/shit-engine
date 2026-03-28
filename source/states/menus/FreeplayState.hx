package states.menus;

import backend.data.WeekJsonData;
import objects.ui.HealthIcon;

class FreeplayAlphabet extends Alphabet
{
	public var week:WeekJson;
	public var song:String;
	public var icon:HealthIcon;

	public function new(songName:String, week:WeekJson)
	{
		super(0, 0, songName.toUpperCase(),true);
		this.week = week;
		var index:Int = week.songs.indexOf(songName);
		icon = new HealthIcon(week.icons[index]);
		icon.sprTracker = this;
		isMenuItem = true;
	}
}

class FreeplayState extends FlxTransitionableState
{
	public var itemIndex:Int = 0;
	public var item:FreeplayAlphabet;
	public var items:FlxTypedGroup<FreeplayAlphabet> = new FlxTypedGroup<FreeplayAlphabet>();

	override public function create()
	{
		super.create();
		WeekJsonData.reload();

		add(items);

		var weekList = WeekJsonData.weekCache.keyValueIterator();
		var weeks = [];
		for (week in weekList)
			weeks.push(week.value);
		weekList = null;
		weeks.sort((w, v) ->
		{
			return w.weekOrder - v.weekOrder;
		});

		for (week in weeks)
		{
			for (song in week.songs)
			{
				var songOBJ = new FreeplayAlphabet(song, week);
				items.add(songOBJ);
				songOBJ.targetY = items.length - 1;
				add(songOBJ.icon);
			}
		}
		weeks = null;
	}
}
