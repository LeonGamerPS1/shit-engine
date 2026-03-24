package backend.data;

typedef StageJSON =
{
	var bfPos:Array<Int>;
	var dadPos:Array<Int>;
	var gfPos:Array<Int>;
	var zoom:Float;
}

class SongStageData
{
	public static function getStageJSON(stage:String = "stage"):StageJSON
	{
		var path = 'data/stages/$stage.json';
		if (!OpenFLAssets.exists(Paths.getPath(path), TEXT))
		{
			stage = 'stage';
			path = 'data/stages/stage.json';
		}

		return cast haxe.Json.parse(OpenFLAssets.getText(Paths.getPath(path)));
	}
}
