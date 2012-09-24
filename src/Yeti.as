package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Derek brown
	 */
	public class Yeti extends EverEnt 
	{	
		[Embed(source="../assets/gfx/exclam.png")]
		protected static var _gfx_exclamClass:Class;
		protected static var _exclam:BitmapData = ( new _gfx_exclamClass() as Bitmap ).bitmapData;
		
		public var maxHealth:Number;
		public var moveSpeed:Number;
		public var hurtMoveSpeed:Number;
		public var hurtDuration:Number;
		public var attackDamage:Number;
		public var target:Sherpa;
		public var dir:String; /// "up", "left", "down", or "right"
		public var fov:Number;
		public var viewDist:Number;
		public var wanderDist:Number;
		
		protected static const AI_STATE_SLEEP:uint = 0;
		protected static const AI_STATE_WANDER:uint = 1;
		protected static const AI_STATE_CHASE:uint = 2;
		
		protected var _yetiHurtUntil:Number;
		protected var _lastX:Number;
		protected var _lastY:Number;
		protected var _world:NormalPlay;
		protected var _nextThinkMark:Number;
		protected var _framerate:int;
		protected var _thinkDelay:Number;
		protected var _map:FlxTilemap; /// where am i?
		protected var _aiState:uint;
		protected var _wanderDest:FlxPoint;
		protected var _lastTargetTileX:int;
		protected var _lastTargetTileY:int;
		protected var _surprisedUntil:Number;
		protected var _surprisedDuration:Number;
	
		public function Yeti( X:Number=0, Y:Number=0 ) 
		{
			super();
			
			health = maxHealth = 20;
			moveSpeed = 32;
			hurtMoveSpeed = 10;
			hurtDuration = 1000;
			drag.make( 80, 80 );
			attackDamage = 1;
			_framerate = 20;
			_thinkDelay = 1500;
			fov = 75;
			viewDist = Level.TILE_SIZE * 4;
			wanderDist = viewDist;
			_surprisedUntil = 0;
			_surprisedDuration = 1000;
			
			_world = FlxG.state as NormalPlay;
			_map = _world.tilemap;
			
			dir = "down";
			playIdle();
			
			centerOn( X, Y );
			_lastX = x;
			_lastY = y;
			
			_aiState = AI_STATE_SLEEP;
			
			setNextThink( Math.round( Math.random() * 1000 ) );
		}
		
		public function playIdle( Force:Boolean = false ):void
		{
			play( dir + "_idle", Force );
		}
		
		private function updateDirection():void
		{
			var dx:Number =	x - _lastX;
			var dy:Number = y - _lastY;
			
			if ( Math.abs( dx ) > Math.abs( dy ) ) // mostly traveling horizontally
			{
				if ( dx > 0 )
					dir = "right";
				else if( dx < 0 )
					dir = "left";
			}
			else // mostly traveling vertically
			{
				if ( dy > 0 )
					dir = "down";
				else if( dy < 0 )
					dir = "up";
			}
			
		}
		
		override public function update():void 
		{
			// animation state
			updateDirection();
			playIdle(true);
			
			if ( !_map || !target )
			{
				_map = _world.tilemap;
				target = _world.player;
				return;
			}
			
			think();
			
			super.update();
			_lastX = x;
			_lastY = y;
		}
		
		protected function think():void
		{
			if ( _aiState == AI_STATE_SLEEP )
				thinkSleep();
			if ( _aiState == AI_STATE_WANDER )
				thinkWander();
			if ( _aiState == AI_STATE_CHASE )
				thinkChase();
		}
		
		protected function thinkSleep():void
		{
			if ( target && canSee( target ) )
			{
				_surprisedUntil = FlxU.getTicks() + _surprisedDuration;
				_aiState = AI_STATE_CHASE;
			}
			else if ( FlxU.getTicks() >= _nextThinkMark )
			{
				_aiState = AI_STATE_WANDER;
			}
		}
		
		protected function thinkWander():void
		{
			if ( target && canSee( target ) )
			{
				_aiState = AI_STATE_CHASE;
				_wanderDest = null;
				_surprisedUntil = FlxU.getTicks() + _surprisedDuration;
			}
			else if ( !_wanderDest )
			{
				var potentialDestinations:Array = new Array();
				var range:FlxRect = new FlxRect( ox - wanderDist * 0.5, oy - wanderDist * 0.5, wanderDist, wanderDist );
				
				// get a list of all tile positions in a certain range, that are empty
				var emptyTileCoords:Array = _map.getTileCoords( 0 );
				for ( var i:int = 0; i < emptyTileCoords.length; ++i )
				{
					var tileCoords:FlxPoint = emptyTileCoords[ i ];
					if ( range.overlaps( new FlxRect( tileCoords.x - Level.TILE_HALFSIZE, tileCoords.y - Level.TILE_HALFSIZE, Level.TILE_SIZE, Level.TILE_SIZE ) ) )
						potentialDestinations.push( tileCoords );
				}
				
				// pick a random position from that list, find a path to it, and start following the path ( if possible )
				if ( potentialDestinations.length > 0 )
				{
					var chosenIndex:int = Math.random() * (potentialDestinations.length - 1);
					var chosenDest:FlxPoint = potentialDestinations[ chosenIndex ];
					_wanderDest = new FlxPoint( chosenDest.x, chosenDest.y );
					
					var pathToFollow:FlxPath = _map.findPath( new FlxPoint( ox, oy ), _wanderDest, true, false );
					if ( pathToFollow )
					{
						if ( path )
						{
							stopFollowingPath(false);
							path.destroy();
							path = null;
						}
						followPath( pathToFollow, moveSpeed );
					}
						
					chosenDest = null;
				}
				// cleanup
				range = null;
				emptyTileCoords = null;
				potentialDestinations = null;
			}
			else if ( FlxU.getDistance( new FlxPoint( ox, oy ), _wanderDest ) <= 5 )
			{
				_wanderDest = null;
				setNextThink( _thinkDelay );
				_aiState = AI_STATE_SLEEP;
			}
		}
		
		public function get tilex():int { return Math.floor( ox / Level.TILE_SIZE ); }
		public function get tiley():int { return Math.floor( oy / Level.TILE_SIZE ); }
		
		protected function thinkChase():void
		{
			// if the target's position has changed, generate a new path
			var targetTileX:int = Math.floor( target.ox / Level.TILE_SIZE );
			var targetTileY:int = Math.floor( target.oy / Level.TILE_SIZE );
			if ( targetTileX != _lastTargetTileX || targetTileY != _lastTargetTileY )
			{
				var pathToTarget:FlxPath = _map.findPath( new FlxPoint( ox, oy ), new FlxPoint( target.x, target.y ), true, false );
				if ( pathToTarget )
				{
					stopFollowingPath(true);
					followPath( pathToTarget, moveSpeed );
				}
			}
			// follow the path to the target
			_lastTargetTileX = targetTileX;
			_lastTargetTileY = targetTileY;
		}
		
		public function canSee( Ent:EverEnt ):Boolean
		{		
			var deltaTarget:FlxPoint = new FlxPoint( Ent.ox - ox, Ent.oy - oy ) // vector to target
			var deltaDist:Number = Math.sqrt( deltaTarget.x * deltaTarget.x + deltaTarget.y * deltaTarget.y ); // distance to target
			// normalize deltaTarget
			deltaTarget.x /= deltaDist;
			deltaTarget.y /= deltaDist;
			var deltaAngle:Number = Math.acos( _viewDir.x * deltaTarget.x + _viewDir.y * deltaTarget.y ) * (180/Math.PI) // angle between view vector and vector to target
			return deltaDist <= viewDist && deltaAngle <= fov * 0.5;
		}
		
		protected function get _viewDir():FlxPoint
		{
			var viewDir:FlxPoint = new FlxPoint();
			switch( dir )
			{
				case "up":
					viewDir.y = -1;
					break;
				case "down":
					viewDir.y = 1;
					break;
				case "left":
					viewDir.x = -1;
					break;
				case "right":
					viewDir.x = 1;
					break;
			}
			return viewDir;
		}
		
		override public function hurt(Damage:Number):void 
		{
			_wanderDest = null;
			stopFollowingPath(true);
			setNextThink( hurtDuration );
			flicker( hurtDuration / 1000 );
			super.hurt(Damage);
		}
		
		/// Tick is the delay in milliseconds before the next think
		protected function setNextThink( Tick:Number ):void
		{
			_nextThinkMark = FlxU.getTicks() + Tick;
		}
		
		
		override public function kill():void 
		{
			super.kill();
			stopFollowingPath(true);
			NormalPlay(FlxG.state).enemyKilled( this );
		}
		
		override public function destroy():void 
		{
			stopFollowingPath(true);
			path = null;
			_wanderDest = null;
			super.destroy();
		}
		
		override public function draw():void 
		{
			super.draw();
			
			if ( FlxU.getTicks() <= _surprisedUntil )
			{
				_flashPoint.x = ox - FlxG.camera.scroll.x * scrollFactor.x +  - 2;
				_flashPoint.y = y - FlxG.camera.scroll.y * scrollFactor.y - _exclam.height - 7;
				FlxG.camera.buffer.copyPixels( _exclam, _exclam.rect, _flashPoint, null, null, true );
			}
		}
	}

}