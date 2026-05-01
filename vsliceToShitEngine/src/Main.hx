package;

import ShitEngine.SongNoteData;
import ShitEngine.SongChartDataR;
import ShitEngine.SongMetaDataRAW;
import haxe.Json;
import moonchart.formats.fnf.FNFVSlice;
import sys.io.File;
import zip.ZipWriter;
import haxe.io.Path;
import sys.FileSystem;
import ShitEngine.*;

using StringTools;

enum abstract YesNo(String) from String to String
{
	var Y = 'Y';
	var N = 'N';
}

class Main
{
	static function main():Void
	{
		var _outputfolder:String;
		var _inputDataFolder:String;
		var _inputSongFolder:String;
		var _metaJsonPath:String;
		var _chartJsonPath:String;

		Sys.println('VSLICE to Shit Engine converter v1');
		Sys.println('');
		Sys.println('File Name for ZIP when conversion is done:');
		_outputfolder = FileSystem.absolutePath('output/' + Sys.stdin().readLine() + '.zip');
		var zip = new ZipWriter();
		Sys.println('Confirm? Path is $_outputfolder' + ' Y/N:');

		var yesNo:YesNo = Sys.stdin().readLine().toUpperCase();
		if (yesNo == N)
		{
			Sys.println('Terminate');
			Sys.exit(-1);
		}

		Sys.println('Data Folder of VSLICE SONG:');
		_inputDataFolder = FileSystem.absolutePath(Sys.stdin().readLine());

		Sys.println('Song Folder of VSLICE SONG:');
		_inputSongFolder = FileSystem.absolutePath(Sys.stdin().readLine());

		Sys.println('Pick Song Meta File from list: ');
		var filesData = FileSystem.readDirectory(_inputDataFolder);
		var file2 = '';
		var ID = 0;
		for (huh in filesData)
			file2 += '\n${ID++} $huh';
		Sys.println(file2);

		_metaJsonPath = FileSystem.absolutePath(Path.addTrailingSlash(_inputDataFolder) + filesData[Std.parseInt(Sys.stdin().readLine())]);
		trace('meta path is ' + _metaJsonPath);

		Sys.println('Pick Song Chart File from list: ');
		var filesData = FileSystem.readDirectory(_inputDataFolder);
		var file2 = '';
		var ID = 0;
		for (huh in filesData)
			file2 += '\n${ID++} $huh';
		Sys.println(file2);

		_chartJsonPath = FileSystem.absolutePath(Path.addTrailingSlash(_inputDataFolder) + filesData[Std.parseInt(Sys.stdin().readLine())]);
		trace('_chartJsonPath path is ' + _chartJsonPath);
		var diffs:Array<String> = [];
		Sys.println('choose diffs, default are easy hard and normal but check the chart file for more for example type easy,hard,normal');
		diffs = Sys.stdin().readLine().split('\n');

		var rawmeta = Json.parse(File.getContent(_metaJsonPath));
		var funkinVSlice = new FNFVSlice().fromJson(File.getContent(_chartJsonPath), File.getContent(_metaJsonPath), diffs);

		// Access the converted FNF (V-Slice) format data using the following variables
		var vSliceData = funkinVSlice.data; // Contains the chart data
		var vSliceMeta = funkinVSlice.meta; // Contains the metadata

		zip.addString('extract stuff into a folder first', 'extract stuff into a folder first.txt');

		var meta:SongMetaDataRAW = {
			songDisplayName: vSliceMeta.songName,
			previewBPM: vSliceMeta.timeChanges[0].bpm,
			previewWindow: {startTime: vSliceMeta.playData.previewStart ?? 0, endTime: vSliceMeta.playData.previewEnd ?? -1},
			volume: 1,
			icon: vSliceMeta.playData.characters.opponent,
			difficulties: vSliceMeta.playData.difficulties,
			charter: vSliceMeta.charter,
			artist: vSliceMeta.artist,
			version: 1,
			generatedBy: 'Vslice->SHITV1 Converter'
		};
		zip.addString(Json.stringify(meta, '\t'), 'meta.json');

		Sys.println('added meta.json to zip entry');
		var songFiles = FileSystem.readDirectory(_inputSongFolder);
		for (songOggOrMP3 in songFiles)
		{
			var pathToPut = FileSystem.absolutePath(Path.addTrailingSlash(_inputSongFolder) + songOggOrMP3);
			Sys.println('added audio/$songOggOrMP3 to zip entry');
			var bytes = File.getBytes(pathToPut);
			zip.addBytes(bytes, 'audio/$songOggOrMP3');
		}

		for (difficulty in meta.difficulties)
		{
			trace('attempting to convert difficulty $difficulty');
			var vsliceDiff = vSliceMeta.playData;
			var instNamePost = '';
			if (vSliceMeta.playData.characters.instrumental != null)
				instNamePost += '-${vSliceMeta.playData.characters.instrumental}';

			var realOppVocals = [];
			for (opp in vSliceMeta.playData.characters.opponentVocals)
			{
				var oppVocals = 'Voices';
				var second = (opp ?? '');
				if (second != '')
					oppVocals += '-$second';
				realOppVocals.push(oppVocals);
			}

			var realPlrVocals = [];
			for (opp in vSliceMeta.playData.characters.playerVocals)
			{
				var plrButt = 'Voices';
				var second = (opp ?? '');
				if (second != '')
					plrButt += '-$second';
				if (plrButt.toLowerCase() == 'voices')
					continue;
				realPlrVocals.push(plrButt);
			}

			var diffJson:SongChartDataR = {
				characters: {
					dad: vSliceMeta.playData.characters.opponent,
					boyfriend: vSliceMeta.playData.characters.player,
					gf: vSliceMeta.playData.characters.girlfriend,
					instPath: 'Inst' + instNamePost,
					playerVocals: realPlrVocals,
					enemyVocals: realOppVocals
				},
				stage: vSliceMeta.playData.stage,
				speed: vSliceData.scrollSpeed.get(difficulty),
				offset: vSliceMeta.offsets.instrumental,
				timingChanges: [],
				noteStyle: vSliceMeta.playData.noteStyle,
				album: vSliceMeta.playData.album,
				stickerPack: rawmeta.playData.stickerPack,
				startPreview: 0,
				endPreview: -1,
				notes: [],
				bpm: vSliceMeta.timeChanges[0].bpm
			};
			for (bpmChange in vSliceMeta.timeChanges)
				diffJson.timingChanges.push({time: bpmChange.t, bpm: bpmChange.bpm});
			for(note in vSliceData.notes.get(difficulty)) {
				var noteNew:SongNoteData = {l: note.d,lms: note.l ?? 0,tms: note.t};
				if(note.k != null)
					noteNew.t = note.k;
				diffJson.notes.push(noteNew);
			}
			Sys.println('added chart charts/$difficulty.json');
			zip.addString(Json.stringify(diffJson, '\t'), 'charts/$difficulty.json');
		}

		if (!FileSystem.exists('output'))
			FileSystem.createDirectory('output');
		var bytes = zip.finalize();
		File.saveBytes(_outputfolder, bytes);
	}
}
