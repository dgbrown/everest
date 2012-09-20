package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import org.flixel.*;
	import org.flixel.system.FlxTile;
	
	/// @author Derek Brown
	public class NormalPlay extends FlxState 
	{	
		private const SHERPA_MOVE_SPEED:Number = 40.0;
		private const SHERPA_MAX_VELOCITY:Number = 100.0;
		private const SHERPA_DRAG:Number = 55.0;
		private const SHERPA_HURT_PUSH_FORCE:Number = 60.0;
		private const SHERPA_ATTACK_PUSH_FORCE:Number = 50.0;
		
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
		private var _lvls:LevelManager;
		private var _level:Level;
		private var _al:FlxGroup;
		
		override public function create():void 
		{	
			super.create();
			FlxG.debug = true;
			FlxG.mouse.hide();
			
			// create persistant objects
			/////////////////////////////////////////////////////////////////
			_goal = new Goal( -100, -100 );
			_playerSpawn = new Spawn( -100, -100 );
			
			_p = new Sherpa( FlxG.width * 0.5, FlxG.height * 0.5 );
			_p.maxVelocity.make( SHERPA_MAX_VELOCITY, SHERPA_MAX_VELOCITY );
			_p.drag.make( SHERPA_DRAG, SHERPA_DRAG );
	
			//_yetiSpawnTimer = new FlxTimer();
			//_yetiSpawnTimer.start( 2, 5, yetiSpawnTimerTick );
			
			_healthBar = new HealthBar( 3, 3, HealthBar.ICON_WIDTH * 6, Sherpa.STARTING_MAX_HEALTH * 0.5, 1 );
			_emeraldCounter = new EmeraldCounter( FlxG.width - EmeraldCounter.FRAME_WIDTH - 2, 2 );
			
			_healthUpTimer = new FlxTimer();
			_healthUpTimer.start( 0.25, 5, healthUpTimerTick );
			/////////////////////////////////////////////////////////////////
			
			// setup level things
			_lvls = new LevelManager();
			_level = _lvls.current;
			setupLevel( false );
		}
		
		// TODO: change to take in level to be loaded as a paramater, clean up the current level, setup based on the new one, and then update the level pointer
		private function setupLevel( CleanupPrevious:Boolean = true ):void
		{
			if ( CleanupPrevious )
			{
				remove( _map, true );
				_map = null;
				
				remove( _debris, true );
				_debris = null;
				
				remove( _yetis, true );
				_yetis = null;
				
				remove( _playerSpawn, true );
				remove( _goal, true );
				
				remove( _p, true ); // don't destroy the player, we need to keep their state
				remove( _healthBar, true );
				remove( _emeraldCounter, true );
				
				remove( _emeralds, true );
				_emeralds.destroy();
				_emeralds = null;
				
				//remove( _spawners, true );
				//_spawners = null;
			}
			
			if ( _level != null && _level.isLoaded )
			{
				add( _map = _level.tilemap );
				add( _debris = _level.debris );
				
				_goal.centerOn( _level.goalPos.x, _level.goalPos.y );
				add( _goal );
				
				_playerSpawn.centerOn( _level.playerSpawnPos.x, _level.playerSpawnPos.y );
				add( _playerSpawn );
				
				add( _yetis = _level.yetis );
				add( _emeralds = new FlxGroup() );
				
				_p.centerOn( _level.playerSpawnPos.x, _level.playerSpawnPos.y );
				add( _p );
				
				add( _healthBar );
				add( _emeraldCounter );
				
				// setup camera
				FlxG.camera.focusOn( new FlxPoint( _p.x, _p.y ) );
				FlxG.camera.follow( _p, FlxCamera.STYLE_TOPDOWN );
				_map.follow( FlxG.camera, -40 );
			}
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
			_yetis.add( new Yeti( Math.random() * FlxG.width, Math.random() * FlxG.height ) );
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
		
		private function playerTouchedGoal( obj1:FlxObject, obj2:FlxObject ):void
		{
			_level = _lvls.gotoNext();
			setupLevel();
		}
		
		public function get player():Sherpa { return _p; }
		public function get tilemap():FlxTilemap { return _map; }
		
		override public function update():void 
		{
			// check overlaps
			FlxG.overlap( _p, _emeralds, playerTouchedEmerald );
			FlxG.overlap( _p, _goal, playerTouchedGoal );
			
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
				var i:int = 0;
				
				var debrisHit:Array = _p.attack( _debris );
				for ( i = 0; i < debrisHit.length; ++i )
				{
 					var deb:Debris = debrisHit[i];
					if ( !deb.alive )
					{
						var tilex:int = deb.ox / Level.TILE_SIZE;
						var tiley:int = deb.oy / Level.TILE_SIZE;
						_map.setTile( tilex, tiley, 0, true );
					}
				}
				
				var yetisHit:Array = _p.attack( _yetis );
				for ( i = 0; i < yetisHit.length; ++i )
					push( new FlxPoint( _p.x, _p.y ), yetisHit[i], SHERPA_ATTACK_PUSH_FORCE );
			}
			
			if ( FlxG.keys.justPressed( "R" ) )
				_p.respawn();
				
			// check and resolve collisions
			FlxG.collide( _p, _yetis, playerTouchedYeti );
			FlxG.collide( _p, _map );
			FlxG.collide( _yetis, _map );
			FlxG.collide( _yetis, _yetis );
			
			// update ui state
			if ( _emeraldCounter.getValue() != _p.nEmeralds )
				_emeraldCounter.setValue( _p.nEmeralds );
			if ( _healthBar.getHeartPeices() != _p.health )
				_healthBar.setHeartPeices( _p.health );
			super.update();
		}
		
		override public function draw():void 
		{
			// _al.sort();
			super.draw();
		}
		
	}

}