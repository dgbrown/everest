package  
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Derek brown
	 */
	public class Yeti extends FlxSprite 
	{
		
		[Embed(source = "../assets/gfx/basic_yeti.png")]
		private var _gfx_yetiClass:Class;
		
		private static const MAX_HEALTH:Number = 20.0;
		private static const MOVE_SPEED:Number = 32;
		private static const HURT_MOVE_SPEED:Number = 10.0;
		private static const HURT_DURATION:Number = 1.0;
		private static const MAX_VELOCITY:Number = Yeti.MOVE_SPEED;
		private static const DRAG:Number = 80.0;
		private static const ANIM_FRAME_RATE:Number = 20.0;
		public static const RADIUS:Number = 32.0;
		public static const DAMAGE:uint = 1;
		public static const ORIGIN_X:int = 0;
		public static const ORIGIN_Y:int = 0;
		public static const THINK_HEARTBEAT:Number = 1000;
		
		public var target:Sherpa;
		public var dir:String;
		
		private var _yetiHurtUntil:Number;
		private var _lastX:Number;
		private var _lastY:Number;
		private var _world:NormalPlay;
		private var _nextThinkMark:Number;
		
		private var _map:FlxTilemap; // where am i?
		
		/// x coordinate of this object's origin, in world space
		public function get ox():Number { return x + ORIGIN_X; }
		/// y coordinate of this object's origin, in world space
		public function get oy():Number { return y + ORIGIN_Y; }
		
		public function Yeti( X:Number=0, Y:Number=0 ) 
		{
			_lastX = X;
			_lastY = Y;
			super( X, Y );
			
			loadGraphic( _gfx_yetiClass, true, false, 29, 31 );
			addAnimation( "up_idle", [0], Yeti.ANIM_FRAME_RATE, true );
			addAnimation( "down_idle", [1], Yeti.ANIM_FRAME_RATE, true );
			addAnimation( "left_idle", [2], Yeti.ANIM_FRAME_RATE, true );
			addAnimation( "right_idle", [3], Yeti.ANIM_FRAME_RATE, true );
			
			_world = FlxG.state as NormalPlay;
			
			_map = _world.tilemap;
			
			dir = "down";
			playIdle();
			
			health = Yeti.MAX_HEALTH;
			drag.make( Yeti.DRAG, Yeti.DRAG );
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
				if ( dx >= 0 )
					dir = "right";
				else
					dir = "left";
			}
			else // mostly traveling vertically
			{
				if ( dy >= 0 )
					dir = "down";
				else
					dir = "up";
			}
			
		}
		
		override public function draw():void 
		{
			super.draw();
		}
		
		override public function update():void 
		{
			// animation state
			updateDirection();
			playIdle();
			if ( target == null || _map == null )
			{
				//if ( onScreen() )
				//{
					target = _world.player;
					_map = _world.tilemap;
					_nextThinkMark = FlxU.getTicks() + THINK_HEARTBEAT;
				//}
			}
			else
			{
				var mapBounds:FlxRect = _map.getBounds();
				if ( x >= mapBounds.left && x <= mapBounds.right && y >= mapBounds.top && y <= mapBounds.bottom && FlxU.getTicks() >= _nextThinkMark )
				{
					_nextThinkMark = FlxU.getTicks() + THINK_HEARTBEAT;
					
					var newPath:FlxPath = _map.findPath( new FlxPoint( x + width * 0.5, y + height * 0.5 ), new FlxPoint( target.x + target.width * 0.5, target.y + target.height * 0.5 ), true );
					if ( newPath )
					{
						if ( path )
						{
							path.destroy();
							path = null;
							path = newPath;
						}
						else
							followPath( newPath, MOVE_SPEED );
					}
				}
			}
			super.update();
		}
		
		override public function hurt(Damage:Number):void 
		{
			_yetiHurtUntil = FlxU.getTicks() + Yeti.HURT_DURATION * 1000;
			flicker(0.5);
			super.hurt(Damage);
		}
		
		override public function kill():void 
		{
			super.kill();
			stopFollowingPath(true);
			NormalPlay(FlxG.state).enemyKilled( this );
		}
		
	}

}