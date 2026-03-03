package backend.data;

import backend.data.SongMetaData.SongMetaDataRAW;

typedef SongTmPoint =
{
	var time:Float;
	var bpm:Float;
}

typedef SongCharacterData =
{
	var boyfriend:String;
	var gf:String;
	var dad:String;
	var instPath:String;
	var playerVocals:Array<String>;
	var enemyVocals:Array<String>;
}

typedef SongChartDataR =
{
	public var difficulties:Array<String>;
	public var characters:SongCharacterData; // for preloading lol
	public var stage:String;

	public var speed:Float;
	public var offset:Float;
	public var timingChanges:Array<SongTmPoint>;
	public var noteStyle:String;
	public var album:String;
	public var stickerPack:String;

	public var startPreview:Float;
	public var endPreview:Float;
}

typedef SongNoteData =
{
	var l:Int; // lane, dad: 0 1 2 3, BF: 4 5 6 7
	var lms:Float; // length in MS
	var tms:Float; //  time/songPos
	var t:String; // type
}

class SongChartData
{
	public var data:SongChartDataR;
	public var meta:SongMetaData;

	public function new(path:String, metaPath:String, skipError:Bool = false)
	{
		var raw:SongChartDataR = null;
		raw = FlxG.assets.getJson(path);

		if (raw == null && !skipError)
			throw "Failed to load SongChartData at: " + path;

		if (raw != null)
			data = cast raw;
		meta = SongMetaData.frompath(metaPath, skipError);
	}

	public static function fromRaw(raw:SongChartDataR, rawMeta:SongMetaDataRAW)
	{
		var newMeta = new SongChartData(null, null, true);
		newMeta.data = raw;
		newMeta.meta = SongMetaData.fromRaw(rawMeta);
		return newMeta;
	}

	public static function fromString(jsonString:String, metaString:String):SongChartData
	{
		return fromRaw(FlxG.assets.parseJson(jsonString), FlxG.assets.parseJson(metaString));
	}

	public static function frompath(Path:String, metaPath:String, skipErrors:Bool = false)
	{
		return new SongChartData(Path, metaPath, skipErrors);
	}
}
