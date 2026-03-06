package backend.gameplay;

import backend.data.SongChartData;
import backend.data.SongMetaData;

class SongLoader
{
	public static function loadSong(songFolderName:String, ?songDifficulty:String)
	{
		var songFolder = 'data/songs/$songFolderName';
		var metaPath = '$songFolder/meta.json';
		if (!OpenFLAssets.exists(Paths.getPath(metaPath), TEXT))
			throw "SongLoader: Failed to find metadata " + metaPath;

		var songDataOBJ:SongChartData;
		var songMetaData:SongMetaData = SongMetaData.frompath(Paths.getPath(metaPath));
		if (!songMetaData.data.difficulties.contains(songDifficulty))
		{
			FlxG.log.warn("Failed to find difficulty "
				+ '"$songDifficulty" for song ${songMetaData.data.songDisplayName}. Selecting first diff available ${songMetaData.data.difficulties[0]}');
			songDifficulty = songMetaData.data.difficulties[0];
		}

		songDataOBJ = SongChartData.frompath(Paths.getPath('$songFolder/charts/$songDifficulty.json'), null, true);
		songDataOBJ.meta = songMetaData;
        // preload audios lol
        var instPath = '$songFolder/audio/${songDataOBJ.data.characters.instPath}.ogg';
        FlxG.sound.cache(Paths.getPath(instPath));
        var vocalBasePPath = '$songFolder/audio';
		songDataOBJ.songFolder = songFolder;
        var vcsToCache = songDataOBJ.data.characters.enemyVocals.concat(songDataOBJ.data.characters.playerVocals);
        for(vc in vcsToCache)
        {
            var path = vocalBasePPath + '/$vc.ogg';
            FlxG.sound.cache(Paths.getPath(path));
        }
		return songDataOBJ;
	}
}
