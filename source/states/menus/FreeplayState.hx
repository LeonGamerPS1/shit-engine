package states.menus;

import backend.data.WeekJsonData;
import backend.gameplay.SongLoader;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import objects.ui.HealthIcon;
import states.gameplay.LoadingScreen;

class FreeplayAlphabet extends Alphabet
{
	public var week:WeekJson;
	public var song:String;
	public var icon:HealthIcon;

	public function new(songName:String, week:WeekJson)
	{
		super(0, 0, songName.toUpperCase(), true);
		this.week = week;
		song = songName;
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
				songOBJ.alpha = 0.7;
				items.add(songOBJ);
				songOBJ.targetY = items.length - 1;
				add(songOBJ.icon);
			}
		}
		weeks = null;
		changeSelection();
	}

	function changeSelection(add:Int = 0)
	{
		item = items.members[itemIndex];
		item.alpha = 0.7;

		itemIndex = FlxMath.wrap(itemIndex + add, 0, items.length - 1);
		item = items.members[itemIndex];
		item.alpha = 1;
		FlxG.sound.play(Paths.getSound('sounds/scrollMenu'));
	}

	var selected = false;

	override function update(dT:Float)
	{
		if (!selected)
		{
			if (inputSystem.UI_DOWN_P)
				changeSelection(1);
			else if (inputSystem.UI_UP_P)
				changeSelection(-1);
			if (inputSystem.ACCEPT)
			{
				FlxG.sound.play(Paths.getSound('sounds/confirmMenu'));
				FlxFlicker.flicker(item,1,0.07);
				new FlxTimer().start(1, (?t) ->
				{
					try
					{
						FlxG.switchState(new LoadingScreen(item.song, null));
					}
					catch (e:Dynamic)
					{
						FlxG.log.error(e);
						Application.current.window.alert(e, 'error');
					}
				});
			}
		}
		for (i in 0...items.length)
		{
			var item = items.members[i];
			item.targetY = i - itemIndex;
		}
		super.update(dT);
	}
}
