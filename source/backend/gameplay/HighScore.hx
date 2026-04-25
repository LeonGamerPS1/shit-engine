package backend.gameplay;

import lime.app.Application;


typedef SongHighScoreEntry = {
    var score:Int;
    var misses:Int;
    var ratings:Array<String>;
    var accuracy:Float;
    var name:String;
}

@:structInit
class ScoreBoard {
    public var songs:Array<SongHighScoreEntry> = [{score: 0,misses:0,ratings:[],accuracy: 0,name: ""}];
    
}
class HighScore {
    static var highScoreSave:FlxSave;

    public static var scoreBoard:ScoreBoard = {};
    public static var emptyScoreBoard:ScoreBoard = {};

    public static function init() {
        highScoreSave = new FlxSave();
        highScoreSave.bind('highscores');
        highScoreSave.data.songs ??= emptyScoreBoard;
        

        Application.current.onExit.add((_) ->
		{
			for (field in Reflect.fields(scoreBoard))
			{
				Reflect.setField(highScoreSave.data, field, Reflect.getProperty(scoreBoard, field));
			}
			highScoreSave.flush();
            trace(highScoreSave.status);
            highScoreSave = null; // clean memory
		}, false, 999);

		for (field in Reflect.fields(emptyScoreBoard))
		{
			if (Reflect.hasField(scoreBoard, field))
				Reflect.setProperty(scoreBoard,field, Reflect.getProperty(highScoreSave.data, field));
			else
				Reflect.setField(scoreBoard, field, Reflect.getProperty(emptyScoreBoard, field));
		}

    }
}