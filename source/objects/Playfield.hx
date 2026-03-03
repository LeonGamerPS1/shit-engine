package objects;

class Playfield extends FlxGroup
{
	public var dadStrumline:Strumline;
	public var bfStrumline:Strumline;

	public function new(skin:String = "default", keys:Int = 4)
	{
		super();
		dadStrumline = cast(add(new Strumline(this, skin, keys)));
        bfStrumline = cast(add(new Strumline(this, skin, keys)));

        dadStrumline.isBot = true;
        dadStrumline.strums.setPosition(100,50);
        bfStrumline.strums.setPosition(100 + (FlxG.width / 2),50);
        
	}
}
