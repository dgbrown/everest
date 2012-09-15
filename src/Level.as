package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import org.flixel.*;
	
	/// @author Derek Brown
	public class Level 
	{
		
		private const TILE_SIZE:int = 16;
		private const TILE_HALFSIZE:int = TILE_SIZE * 0.5;
		private const LEGEND_SPAWN:uint = 0xff00ff;
		private const LEGEND_DEBRIS:uint = 0x00ff00;
		private const LEGEND_GOAL:uint = 0x00ffff;
		private const LEGEND_ENEMY_SMALLER:uint = 0xff0000;
		
		public var id:String;
		public var name:String;
		public var playerSpawnPos:FlxPoint;
		public var tilemap:FlxTilemap;
		public var yetis:FlxGroup;
		public var debris:FlxGroup;
		public var yetiSpawners:FlxGroup;
		public var goalPos:FlxPoint;
		public var isLoaded:Boolean;
		
		private var _levelDataClass:Class;
		private var _tilesetClass:Class;
		
		public function Level( Id:String, Name:String, LevelDataClass:Class, TilesetClass:Class ) 
		{
			id = Id;
			name = Name;
			_levelDataClass = LevelDataClass;
			_tilesetClass = TilesetClass;
			isLoaded = false;
		}
		
		public function load():void
		{
			debris = new FlxGroup();
			yetis = new FlxGroup();
			yetiSpawners = new FlxGroup();
			playerSpawnPos = new FlxPoint();
			goalPos = new FlxPoint();
			
			tilemap = new FlxTilemap().loadMap( FlxTilemap.imageToCSV( _levelDataClass ), _tilesetClass, TILE_SIZE, TILE_SIZE, FlxTilemap.OFF, 0, 0, 1 )
			
			var curLevelData:BitmapData = ( new _levelDataClass() as Bitmap ).bitmapData;
			var xp:uint = 0, yp:uint = 0, colorp:uint = 0;
			var xr:Number = 0, yr:Number = 0;
			for ( yp = 1; yp <= curLevelData.height; ++yp )
			{
				for ( xp = 1; xp <= curLevelData.width; ++xp )
				{
					xr = xp * TILE_SIZE + TILE_HALFSIZE;
					yr = yp * TILE_SIZE + TILE_HALFSIZE;
					colorp = curLevelData.getPixel( xp, yp );
					switch( colorp )
					{
						case LEGEND_SPAWN:
							playerSpawnPos.make( xr, yr );
							break;
						case LEGEND_DEBRIS:
							debris.add( new Debris( xr, yr ) );
							tilemap.setTile( xp, yp, 1, false );
							break;
						case LEGEND_GOAL:
							goalPos.make( xr, yr );
							break;
						/*
						case LEGEND_ENEMY_SPAWNER:
							_spawners.add( new Spawner( xr, yr ) );
							_map.setTile( xp, yp, 1, false );
							_map.setTile( xp + 1, yp, 1, false );
							break;
						*/
					}
				}
			}
			curLevelData.dispose();
			curLevelData = null;
			
			isLoaded = true;
		}
		
		public function unload():void
		{
			playerSpawnPos = null;
			tilemap.destroy();
			tilemap = null;
			yetis.destroy();
			yetis = null;
			debris.destroy();
			debris = null;
			yetiSpawners.destroy();
			goalPos = null;
			
			isLoaded = false;
		}
		
	}

}