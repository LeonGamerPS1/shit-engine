package states.options.subs;

import flixel.input.keyboard.FlxKey;
import openfl.display.BitmapData;
import openfl.display.Sprite;

class ControlsSubstate extends FlxSubState
{
	var alphabetshow:Alphabet;
	var options = SaveData.currentSettings.controlSchemeOptions;

	override public function create()
	{
		var bg:FlxSprite = new FlxSprite(0, 0);
		bg.makeGraphic(1, 1, 0xFF000000);
		bg.scale.set(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		bg.alpha = 0;
		FlxTween.tween(bg, {alpha: 0.6}, 0.5);

		alphabetshow = new Alphabet(0, 0, 'Control Scheme: <p>'.replace('p',curScheme));
		alphabetshow.screenCenter();

		add(alphabetshow);
	}

	public static function applyControlSchemeToKeyboard(scheme:String = 'ARROW KEYS + WASD')
	{
		var schemeMap:Map<String, Array<FlxKey>>;

		switch (scheme)
		{
			default:
				schemeMap = [
					'note_up' => [W, UP],
					'note_left' => [A, LEFT],
					'note_down' => [S, DOWN],
					'note_right' => [D, RIGHT]
				];
			case 'DFJK':
				schemeMap = ['note_left' => [D], 'note_down' => [F], 'note_up' => [J], 'note_right' => [K]];
			case 'ASKL':
				schemeMap = ['note_left' => [A], 'note_down' => [S], 'note_up' => [K], 'note_right' => [L]];
		}
		for (key in schemeMap.keyValueIterator())
			SaveData.currentSettings.keyBinds.set(key.key, key.value);
        SaveData.currentSettings.currentScheme = scheme;
		schemeMap = null;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (inputSystem.BACK)
			close();

		if (inputSystem.ACCEPT)
		{
			applyControlSchemeToKeyboard(curScheme);
			FlxG.sound.play(Paths.getSound('sounds/confirmMenu'));
		}

		if (inputSystem.UI_RIGHT_P)
			s(1);
		else if (inputSystem.UI_LEFT_P)
			s(-1);
	}

	var index = 0;
	var curScheme = SaveData.currentSettings.currentScheme;

	function s(i:Int)
	{
		index += i;
		var length = options.length - 1;
		if (index < 0)
			index = length;
		else if (index > length)
			index = length;
		curScheme = options[index];
		alphabetshow.destroy();
		remove(alphabetshow, true);
		alphabetshow = new Alphabet(0, 0, 'Control Scheme: <p>'.replace('p',curScheme));
		alphabetshow.screenCenter();
    	FlxG.sound.play(Paths.getSound('sounds/scrollMenu'));
		add(alphabetshow);
	}
}
