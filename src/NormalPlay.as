package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import org.flixel.*;
	import org.flixel.system.FlxTile;
	
	/// @author Derek Brown
	public class NormalPlay extends FlxState 
	{
		
		[Embed(source = "../assets/gfx/testbackground.png")]
		private var _gfx_testBackground:Class;
		[Embed(source = "../assets/gfx/tiles.png")]
		private var _gfx_tilesClass:Class;
		
		[Embed(source = "../assets/gfx/level01.png")]
		private var _gfx_level01Class:Class;
		private var _gfx_level01:BitmapData = ( new _gfx_level01Class() as Bitmap ).bitmapData;
		[Embed(source = "../assets/gfx/level02.png")]
		private var _gfx_level02Class:Class;
		private var _gfx_level02:BitmapData = ( new _gfx_level02Class() as Bitmap ).bitmapData;
		
		private const SHERPA_MOVE_SPEED:Number = 40.0;
		private const SHERPA_MAX_VELOCITY:Number = 100.0;
		private const SHERPA_DRAG:Number = 55.0;
		private const SHERPA_HURT_PUSH_FORCE:Number = 60.0;
		private const SHERPA_ATTACK_PUSH_FORCE:Number = 50.0;
		
		private const TILE_SIZE:int = 16;
		private const TILE_HALFSIZE:int = TILE_SIZE * 0.5;
		
		private const LEGEND_SPAWN:uint = 0xff00ff;
		private const LEGEND_DEBRIS:uint = 0x00ff00;
		private const LEGEND_GOAL:uint = 0x00ffff;
		private const LEGEND_ENEMY_SMALLER:uint = 0xff0000;
		
		private var _p:Sherpa;
		private var _background:FlxSprite;
		private var _yetis:FlxGroup;
		private var _yetiSpawnTimer:FlxTimer;
		private var _healthBar:HealthBar;
		private var _healthUpTimer:FlxTimer;
		private var _emeraldCounter:EmeraldCounter;
		private var _emeralds:FlxGroup;
		private var _map:FlxTilemap;
		private var _debris:FlxGroup;
		private var _goal:Goal;
		private var _spawners:FlxGroup;
		private var _playerSpawn:Spawn;
		
		override public function create():void 
		{	
			super.create();
			FlxG.debug = true;
			
			// add objects
			/////////////////////////////////////////////////////////////////
			add( _map = new FlxTilemap().loadMap( FlxTilemap.imageToCSV( _gfx_level01Class ), _gfx_tilesClass, 16, 16, FlxTilemap.OFF, 0, 0, 1 ) );
			
			add( _debris = new FlxGroup() );
			
			add( _goal = new Goal( -100, -100 ) );
			add( _playerSpawn = new Spawn( -100, -100 ) );
			
			add( _yetis = new FlxGroup( 0 ) );
			add( _emeralds = new FlxGroup( 0 ) );
			
			add( _p = new Sherpa( FlxG.width * 0.5, FlxG.height * 0.5 ) );
			_p.maxVelocity.make( SHERPA_MAX_VELOCITY, SHERPA_MAX_VELOCITY );
			_p.drag.make( SHERPA_DRAG, SHERPA_DRAG );
	
			_yetiSpawnTimer = new FlxTimer();
			_yetiSpawnTimer.start( 2, 5, yetiSpawnTimerTick );
			
			add( _healthBar = new HealthBar( 3, 3, HealthBar.ICON_WIDTH * 6, Sherpa.STARTING_MAX_HEALTH * 0.5, 1 ) );
			
			add( _emeraldCounter = new EmeraldCounter( FlxG.width - EmeraldCounter.FRAME_WIDTH - 2, 2 ) );
			
			_healthUpTimer = new FlxTimer();
			_healthUpTimer.start( 0.25, 5, healthUpTimerTick );
			/////////////////////////////////////////////////////////////////
			
			// parse level file for objects
			/////////////////////////////////////////////////////////////////
			var curLevelData:BitmapData = _gfx_level01;
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
							_p.centerOn( xr, yr );
							_playerSpawn.centerOn( xr, yr );
							break;
						case LEGEND_DEBRIS:
							_debris.add( new Debris( xr, yr ) );
							_map.setTile( xp, yp, 1, false );
							break;
						case LEGEND_GOAL:
							_goal.centerOn( xr, yr );
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
			/////////////////////////////////////////////////////////////////
			
			// setup camera
			FlxG.camera.follow( _p, FlxCamera.STYLE_TOPDOWN );
			_map.follow( FlxG.camera );
		}
		
		/// pushes the AffectedObj away from the Source point by Force
		private function push( Source:FlxPoint, AffectedObj:FlxObject, Force:Number ):void
		{
			var dx:Number = AffectedObj.x - Source.x;
			var dy:Number = AffectedObj.y - Source.y;
			var a:Number = Math.atan2( dy, dx );
			AffectedObj.velocity.x += Math.cos( a ) * Force;
			AffectedObj.velocity.y += Math.sin( a ) * Force;
		}
		
		private function healthUpTimerTick( Timer:FlxTimer ):void
		{
			_healthBar.setHeartPeices( _healthBar.getHeartPeices() + 1 );
		}
		
		private function yetiSpawnTimerTick( Timer:FlxTimer ):void
		{
			_yetis.add( new Yeti( Math.random() * FlxG.width, Math.random() * FlxG.height, _p, _map ) );
			if ( Timer.loopsLeft == 0 && Timer.time == 2 && Timer.loops == 5 )
			{
				Timer.start( 8, 10, yetiSpawnTimerTick );
			}
		}
		
		public function enemyKilled( enemy:FlxSprite ):void
		{
			if ( enemy != null )
			{
				if ( Math.random() >= 1.0 - 0.25 ) // 25% chance
					_emeralds.add( new Emerald( enemy.x + enemy.width * 0.5, enemy.y + enemy.height - Emerald.ANIM_HEIGHT ) );
			}
		}
		
		private function playerTouchedEmerald( obj1:FlxObject, obj2:FlxObject ):void
		{
			obj2.kill();
			_emeralds.remove( obj2, true );
			_p.nEmeralds++;
		}
		
		private function playerTouchedYeti( obj1:FlxObject, obj2:FlxObject ):void
		{
			if ( _p.isVulnerable )
			{
				_p.hurt( Yeti.DAMAGE );
				push( new FlxPoint( obj2.x, obj2.y ), obj1, SHERPA_HURT_PUSH_FORCE );
			}
		}
		
		override public function update():void 
		{
			// check overlaps
			FlxG.overlap( _p, _emeralds, playerTouchedEmerald );
			
			// sample input and act on it
			var frameMoveSpeed:Number = SHERPA_MOVE_SPEED * FlxG.elapsed;
			if ( FlxG.keys.LEFT || FlxG.keys.RIGHT )
			{
				_p.x += FlxG.keys.LEFT ? -frameMoveSpeed : FlxG.keys.RIGHT ? frameMoveSpeed : 0;
				_p.dir = FlxG.keys.LEFT ? "left" : "right";
			}
			else if ( FlxG.keys.UP || FlxG.keys.DOWN )
			{
				_p.y += FlxG.keys.UP ? -frameMoveSpeed : FlxG.keys.DOWN ? frameMoveSpeed : 0;
				_p.dir = FlxG.keys.UP ? "up" : "down";
			}
			
			if ( FlxG.keys.justPressed( "SPACE" ) )
			{
				var yetisHit:Array = _p.attack( _yetis );
				for ( var i:uint = 0; i < yetisHit.length; ++i )
				{
					push( new FlxPoint( _p.x, _p.y ), yetisHit[i], SHERPA_ATTACK_PUSH_FORCE );
				}
			}
			
			if ( FlxG.keys.justPressed( "R" ) )
				_p.respawn();
				
			// check and resolve collisions
			FlxG.collide( _p, _yetis, playerTouchedYeti );
			FlxG.collide( _p, _map );
			
			// update ui state
			if ( _emeraldCounter.getValue() != _p.nEmeralds )
				_emeraldCounter.setValue( _p.nEmeralds );
			if ( _healthBar.getHeartPeices() != _p.health )
				_healthBar.setHeartPeices( _p.health );
			super.update();
		}
		
	}

}