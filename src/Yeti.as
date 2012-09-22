package  
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Derek brown
	 */
	public class Yeti extends EverEnt 
	{
		[Embed(source="../assets/gfx/yeti_redux.png")]
		private var _gfx_yetiClass:Class;
		
		public var maxHealth:Number;
		public var moveSpeed:Number;
		public var hurtMoveSpeed:Number;
		public var hurtDuration:Number;
		public var attackDamage:Number;
		public var target:Sherpa;
		public var dir:String; /// "up", "left", "down", or "right"
		
		private var _yetiHurtUntil:Number;
		private var _lastX:Number;
		private var _lastY:Number;
		private var _world:NormalPlay;
		private var _nextThinkMark:Number;
		private var _framerate:int;
		private var _thinkDelay:Number;
		private var _map:FlxTilemap; /// where am i?
		
		public function Yeti( X:Number=0, Y:Number=0 ) 
		{
			super();
			collisionWidth = 14;
			collisionHeight = 10;
			collisionRadius = 10;
			spriteWidth = 16;
			spriteHeight = 16;
			originX = 8;
			originY = 12;
			
			health = maxHealth = 20;
			moveSpeed = 32;
			hurtMoveSpeed = 10;
			hurtDuration = 1000;
			drag.make( 80, 80 );
			attackDamage = 1;
			_framerate = 20;
			_thinkDelay = 800;
		
			loadGraphic( _gfx_yetiClass, true, false, spriteWidth, spriteHeight );
			addAnimation( "up_idle", [0], _framerate, true );
			addAnimation( "down_idle", [1], _framerate, true );
			addAnimation( "left_idle", [2], _framerate, true );
			addAnimation( "right_idle", [3], _framerate, true );
			
			_world = FlxG.state as NormalPlay;
			_map = _world.tilemap;
			
			dir = "down";
			playIdle();
			
			centerOn( X, Y );
			_lastX = X;
			_lastY = Y;
			
			setNextThink( Math.round( Math.random() * 9000 + 1000 ) );
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
			if ( target == null || _map == null )
			{
				//if ( onScreen() )
				//{
					target = _world.player;
					_map = _world.tilemap;
					setNextThink( _thinkDelay );
				//}
			}
			else
			{
				var mapBounds:FlxRect = _map.getBounds();
				if ( FlxU.getTicks() >= _nextThinkMark )
				{
					setNextThink( _thinkDelay );
					
					var newPath:FlxPath = _map.findPath( new FlxPoint( ox, oy ), new FlxPoint( target.ox, target.oy ), true );
					if ( newPath )
					{
						if ( path )
						{
							path.destroy();
							path = null;
							path = newPath;
						}
						else
							followPath( newPath, moveSpeed );
					}
				}
			}
			super.update();
			_lastX = x;
			_lastY = y;
		}
		
		override public function hurt(Damage:Number):void 
		{
			stopFollowingPath(true);
			setNextThink( hurtDuration );
			flicker( hurtDuration / 1000 );
			super.hurt(Damage);
		}
		
		/// Tick is the delay in milliseconds before the next think
		private function setNextThink( Tick:Number ):void
		{
			_nextThinkMark = FlxU.getTicks() + Tick;
		}
		
		
		override public function kill():void 
		{
			super.kill();
			stopFollowingPath(true);
			NormalPlay(FlxG.state).enemyKilled( this );
		}
		
	}

}