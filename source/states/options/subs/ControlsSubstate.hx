package states.options.subs;

class ControlsSubstate extends FlxSubState {

    var alphabetshow:Alphabet;
    override public function create() {
        var bg:FlxSprite = new FlxSprite(0,0);
        bg.makeGraphic(1,1,0xFF000000);
        bg.scale.set(FlxG.width,FlxG.height);
        bg.updateHitbox();
        bg.screenCenter();
        add(bg);

        bg.alpha = 0;
        FlxTween.tween(bg,{alpha:0.6},0.5);

        alphabetshow = new Alphabet(0,0,'Control Scheme: <ARROW KEYS + WASD>');
        alphabetshow.screenCenter();
        add(alphabetshow);
    }
}