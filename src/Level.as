package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import org.flixel.*;
	
	/// @author Derek Brown
	public class Level 
	{
		
		public static const TILE_SIZE:int = 16;
		public static const TILE_HALFSIZE:int = TILE_SIZE * 0.5;
		
		private static const LEGEND_OBJ_SPAWN:uint = 0xff00ff;
		private static const LEGEND_OBJ_DEBRIS:uint = 0x00ff00;
		private static const LEGEND_OBJ_GOAL:uint = 0x00ffff;
		private static const LEGEND_OBJ_ENEMY_SPAWNER:uint = 0xff0000;
		
		private static const LEGEND_TILE_ICE_TOP:uint = 0x000000;
		private static const LEGEND_TILE_ICE_FRONT:uint = 0x252525;
		
		private static const LEGEND_OBJ_ENEMY01:uint = 0xeeeeee;
		private static const LEGEND_OBJ_ENEMY02:uint = 0xcccccc;
		private static const LEGEND_OBJ_ENEMY03:uint = 0xaaaaaa;
		private static const LEGEND_OBJ_ENEMY04:uint = 0x888888;
		private static const LEGEND_OBJ_ENEMY05:uint = 0x666666;
		private static const LEGEND_OBJ_ENEMY06:uint = 0x444444;
		
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
			
			var curLevelData:BitmapData = ( new _levelDataClass() as Bitmap ).bitmapData;
			
			loadTilemap( curLevelData );
			loadObjects( curLevelData );
			
			curLevelData.dispose();
			curLevelData = null;
			
			isLoaded = true;
		}
		
		private function loadTilemap( LevelData:BitmapData ):void
		{
			var csvData:String = "";
			var rowData:Array = new Array();
			var color:uint = 0x000000;
			var tileType:int = 0;
			for ( var y:int = 0; y <= LevelData.height; ++y )
			{
				rowData.length = LevelData.width;
				for ( var x:int = 0; x <= LevelData.width; ++x )
				{
					color = LevelData.getPixel( x, y );
					switch( color )
					{
						case LEGEND_TILE_ICE_FRONT:
							tileType = 2;
							break;
						case LEGEND_TILE_ICE_TOP:
							tileType = 1;
							break;
						default:
							tileType = 0;
							break;
					}
					rowData[ x ] = tileType; 
				}
				csvData += rowData.join(",") + "\n";
				rowData.length = 0;
			}
			tilemap = new FlxTilemap().loadMap( csvData, _tilesetClass, TILE_SIZE, TILE_SIZE, FlxTilemap.OFF, 0, 0, 1 )
		}
		
		private function loadObjects( LevelData:BitmapData ):void
		{
			var xp:uint = 0, yp:uint = 0, colorp:uint = 0;
			var xr:Number = 0, yr:Number = 0;
			for ( yp = 0; yp <= LevelData.height; ++yp )
			{
				for ( xp = 0; xp <= LevelData.width; ++xp )
				{
					xr = xp * TILE_SIZE + TILE_HALFSIZE;
					yr = yp * TILE_SIZE + TILE_HALFSIZE;
					colorp = LevelData.getPixel( xp, yp );
					switch( colorp )
					{
						case LEGEND_OBJ_SPAWN:
							playerSpawnPos.make( xr, yr - 16 );
							break;
						case LEGEND_OBJ_DEBRIS:
							debris.add( new Debris( xr, yr ) );
							tilemap.setTile( xp, yp, 1, false );
							break;
						case LEGEND_OBJ_GOAL:
							goalPos.make( xr, yr );
							break;
						case LEGEND_OBJ_ENEMY01:
							yetis.add( new Yeti( xr, yr ) );
							break;
						case LEGEND_OBJ_ENEMY02:
							yetis.add( new Yeti( xr, yr ) );
							break;
						case LEGEND_OBJ_ENEMY03:
							yetis.add( new Yeti( xr, yr ) );
							break;
						case LEGEND_OBJ_ENEMY04:
							yetis.add( new Yeti( xr, yr ) );
							break;
						case LEGEND_OBJ_ENEMY05:
							yetis.add( new Yeti( xr, yr ) );
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