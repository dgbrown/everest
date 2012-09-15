package  
{
	import flash.utils.Dictionary;
	/// @author Derek Brown
	public class LevelManager 
	{
		// TILESETS
		[Embed(source = "../assets/gfx/tiles.png")]
		private var _gfx_tilesetSnowClass:Class;
		[Embed(source = "../assets/gfx/town.png")]
		private var _gfx_tilesetTownClass:Class;
		
		// LEVEL DATA
		[Embed(source = "../assets/gfx/level01.png")]
		private static const _gfx_level01Class:Class;
		[Embed(source = "../assets/gfx/level02.png")]
		private static const _gfx_level02Class:Class;
		
		public var levels:Dictionary;
		
		public function get current():Level { return _curLevel }
		
		private var _levelNum:int;
		private var _prevLevel:Level;
		private var _curLevel:Level;
		private var _nextLevel:Level;
		
		public function LevelManager() 
		{
			levels = new Array();
			addLevel( "Town", "Town", _gfx_levelTownClass, _gfx_tilesetTownClass );
			addLevel( "Level_1", "Level 1", _gfx_level01Class, _gfx_tilesetSnowClass );
			addLevel( "Level_2", "Level 2", _gfx_level02Class, _gfx_tilesetSnowClass );
			
			_level = 1;
			_prevLevel = null;
			_curLevel = getLevel( _levelNum );
			_nextLevel = getLevel( _levelNum + 1 );
			
			_curLevel.load();
		}
		
		private function addLevel( Id:String, Name:String, LevelDataClass:Class, TilesetClass:Class ):void
		{
			levels[Name] = new Level( Id, Name, LevelDataClass, TilesetClass );
		}
		
		private function getLevel( LevelNumber:int ):Level
		{
			return levels[ "level_" + LevelNumber ];
		}
		
		public function gotoNext():Level
		{
			_prevLevel = null;
			_prevLevel = _curLevel;
			
			_curLevel.unload();
			_curLevel = null;
			_curLevel = _nextLevel;
			_curLevel.load();
			
			_nextLevel = null;
			_nextLevel = getLevel( ++_levelNum );
			
			return _curLevel;
		}
		
		public function gotoPrev():Level
		{
			_nextLevel = null;
			_nextLevel = _curLevel;
			
			_curLevel.unload();
			_curLevel = null;
			_curLevel = _prevLevel;
			_curLevel.load();
			
			_prevLevel = null;
			_prevLevel = getLevel( --_levelNum );
			
			return _curLevel;
		}
		
		public function gotoTown():Level
		{
			_prevLevel = _nextLevel = null;
			_prevLevel = _curLevel;
			_nextLevel = _curLevel;
			
			_curLevel.unload();
			_curLevel = null;
			_curLevel = _levels["town"];
			_curLevel.load();
			
			return _curLevel;
		}
		
	}

}