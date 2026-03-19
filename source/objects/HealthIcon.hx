package objects;

import flixel.FlxG;
import flixel.FlxSprite;
import openfl.utils.Assets as OpenFlAssets;

class HealthIcon extends FlxSprite
{
	public var char:String = 'bf';
	public var isPlayer:Bool = false;
	public var isOldIcon:Bool = false;

	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	public function new(?char:String = "bf", ?isPlayer:Bool = false)
	{
		super();

		this.char = char;
		this.isPlayer = isPlayer;

		isPlayer = isOldIcon = false;

		changeIcon(char);
	}

	public function swapOldIcon()
	{
		(isOldIcon = !isOldIcon) ? changeIcon("bf-old") : changeIcon(char);
	}

	public function changeIcon(char:String)
	{
		if (!OpenFlAssets.exists(Paths.getPath('images/icons/icon-' + char + '.png')))
			char = 'face';

		loadGraphic(Paths.getGraphic('icons/icon-' + char), true, 150, 150);

		if (char.endsWith('-pixel') || char.startsWith('senpai') || char.startsWith('spirit'))
			antialiasing = false;
		else
			antialiasing = true;

		animation.add(char, [0, 1], 0, false, isPlayer);
		animation.play(char);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
