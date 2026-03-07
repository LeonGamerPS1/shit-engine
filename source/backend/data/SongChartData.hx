package backend.data;

import backend.data.SongMetaData.SongMetaDataRAW;
import shaders.RGBSwap;

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
	public var notes:Array<SongNoteData>;
	public var bpm:Float;
}

typedef SongNoteData =
{
	var l:Int; // lane, dad: 0 1 2 3, BF: 4 5 6 7
	var lms:Float; // length in MS
	var tms:Float; //  time/songPos
	var t:String; // type
}

typedef SwagSectionXMLBFXML =
{
	var sectionNotes:Array<Dynamic>;
	var lengthInSteps:Int;
	var typeOfSection:Int;
	var mustHitSection:Bool;
	var bpm:Float;
	var changeBPM:Bool;
	var altAnim:Bool;
}

typedef SwagSongPsych042 =
{
	var song:String;
	var notes:Array<SwagSectionXMLBFXML>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var player3:String;
	var stage:String;

	var arrowSkin:String;
	var splashSkin:String;
	var validScore:Bool;
}

class SongChartData
{
	public var data:SongChartDataR;
	public var meta:SongMetaData;
	public var songFolder:String;

	public function new(path:String, metaPath:String, skipError:Bool = false)
	{
		var raw:Dynamic = null;
		raw = FlxG.assets.getJson(path);

		if (raw == null && !skipError)
			throw "Failed to load SongChartData at: " + path;

		if (raw != null)
			data = cast raw;
		if (raw.song != null && !(raw.song is String))
		{
			data = getConvertedShitFromLegacy(cast raw.song);
		}
		meta = SongMetaData.frompath(metaPath, skipError);
	}

	static function getConvertedShitFromLegacy(data:SwagSongPsych042):SongChartDataR
	{
		var someSongChartIG:SongChartDataR = {
			album: "unknown",
			timingChanges: [],
			bpm: data.bpm,
			characters: {
				instPath: "Inst",
				enemyVocals: ["Voices"],
				playerVocals: [],
				dad: data.player2,
				gf: data.player3,
				boyfriend: data.player1
			},
			stickerPack: "default",
			startPreview: 0,
			endPreview: 10000,
			noteStyle: "default",
			notes: [],
			offset: 0,
			speed: data.speed,
			stage: data.stage ?? 'stage',
		};

		for (section in data.notes)
		{
			for (note in section.sectionNotes)
			{
				var isPlayerNote = section.mustHitSection;
				if (note[1] > 3)
					isPlayerNote = !section.mustHitSection;
				someSongChartIG.notes.push({
					tms: note[0],
					lms: note[2],
					l: (Math.floor(note[1]) % 4) + (isPlayerNote ? 4 : 0),
					t: "normal"
				});
			}
		}
		return someSongChartIG;
	}

	public static function fromRaw(raw:Dynamic, rawMeta:Dynamic)
	{
		var newMeta = new SongChartData(null, null, true);
		newMeta.data = cast raw;
		newMeta.meta = cast SongMetaData.fromRaw(rawMeta);
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
