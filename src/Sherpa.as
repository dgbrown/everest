package  
{
	import org.flixel.*;
	
	/// @author Derek Brown
	public class Sherpa extends FlxSprite 
	{
		
		[Embed(source = "../assets/gfx/player_sherpa.png")]
		private var _gfx_sherpa:Class;
		
		public static const ORIGIN_X:int = 12;
		public static const ORIGIN_Y:int = 19;
		public static const ANIM_FRAMERATE:uint = 15;
		public static const ANIM_SWITCH_FRAMERATE:uint = 100;
		public static const ATTACK_RADIUS:Number = 20.0;
		public static const ATTACK_DAMAGE:Number = 5.0;
		public static const STARTING_MAX_HEALTH:uint = 6;
		public static const INVULN_DURATION:Number = 1.0; // half a second
		public static const COLLISION_WIDTH:int = 12;
		public static const COLLISION_HEIGHT:int = 7;
		public static const FRAME_WIDTH:int = 24;
		public static const FRAME_HEIGHT:int = 26;
		
		public var dir:String; /// ["up","down","left","right"]
		public var nEmeralds:uint = 0;
		
		private var _lastHit:Number = 0.0;
		
		/// x coordinate of this object's origin, in world space
		public function get ox():Number { return x + ORIGIN_X; }
		/// y coordinate of this object's origin, in world space
		public function get oy():Number { return y + ORIGIN_Y; }
		
		public function get isVulnerable():Boolean
		{
			return FlxU.getTicks() >= _lastHit + (1000*INVULN_DURATION);
		}
		
		public function Sherpa(X:Number=0, Y:Number=0) 
		{
			super(X, Y);
			loadGraphic( _gfx_sherpa, true, false, 24, 26, true );
			
			width = COLLISION_WIDTH;
			height = COLLISION_HEIGHT;
			offset.make( ORIGIN_X - COLLISION_WIDTH * 0.5, ORIGIN_Y - COLLISION_HEIGHT * 0.5 );
			
			addAnimation( "up_idle", [0], Sherpa.ANIM_SWITCH_FRAMERATE, true );
			addAnimation( "up_attack", [0, 1, 2, 3], Sherpa.ANIM_FRAMERATE, false );
			
			addAnimation( "down_idle", [4], Sherpa.ANIM_SWITCH_FRAMERATE, true );
			addAnimation( "down_attack", [4, 5, 6, 7], Sherpa.ANIM_FRAMERATE, false );
			
			addAnimation( "left_idle", [8], Sherpa.ANIM_SWITCH_FRAMERATE, true );
			addAnimation( "left_attack", [8, 9, 10, 11], Sherpa.ANIM_FRAMERATE, false );
			
			addAnimation( "right_idle", [12], Sherpa.ANIM_SWITCH_FRAMERATE, true );
			addAnimation( "right_attack", [12, 13, 14, 15], Sherpa.ANIM_FRAMERATE, false );
			
			addAnimationCallback( animationTick );
			
			respawnAt( X, Y );
		}
		
		public function centerOn( X:Number, Y:Number ):void
		{
			x = X - ORIGIN_X;
			y = Y - ORIGIN_Y;
		}
		
		public function respawnAt( X:Number, Y:Number ):void
		{
			centerOn( X, Y );
			
			health = Sherpa.STARTING_MAX_HEALTH;
			exists = true;
			alive = true;
			visible = true;
			active = true;
			dir = "down";
			playIdle(true);
		}
		
		public function respawn():void
		{
			respawnAt( x + ORIGIN_X, y + ORIGIN_Y );
		}
		
		public function playAttack( Force:Boolean = true ):void
		{
			play( dir + "_attack", Force );
		}
		
		public function playIdle( Force:Boolean = true ):void
		{
			play( dir + "_idle", Force );
		}
		
		private function animationTick( Name:String, Frame:uint, Index:uint ):void
		{
			if ( Name.indexOf(dir) == -1 )
				playIdle(true);
			else if ( Frame == 3 && Name.indexOf("attack") != -1 )
			{
				playIdle(true);
			}
		}
		
		/// returns an array of the FlxBasic objects that were successfuly hit
		public function attack( PotentialHits:FlxGroup ):Array
		{
			playAttack();
			var confirmedHits:Array = new Array();
			for ( var i:uint = 0; i < PotentialHits.length; ++i )
			{
				var target:FlxObject = PotentialHits.members[i];
				if ( target.alive )
				{	
					var dX:Number = target.x - x;
					var dY:Number = target.y - y;
					var dT:Number = Math.sqrt( dX * dX + dY * dY );
					
					var hitPossible:Boolean = false;
					switch( dir )
					{
						case "up":
							hitPossible = target.y <= y;
							break;
						case "down":
							hitPossible = target.y >= y;
							break;
						case "left":
							hitPossible = target.x <= x;
							break;
						case "right":
							hitPossible = target.x >= x;
							break;
						default:
							hitPossible = false;
					}
					if ( hitPossible )
					{
						if ( ( target is Yeti && dT <= Sherpa.ATTACK_RADIUS + Yeti.RADIUS ) ||
							 ( dT <= Sherpa.ATTACK_RADIUS + 22 ) )
						{
							confirmedHits.push( target );
							target.hurt( Sherpa.ATTACK_DAMAGE );
						}
					}
				}
			}
			return confirmedHits;
		}
		
		override public function hurt(Damage:Number):void 
		{
			if ( !isVulnerable )
				return;
				
			_lastHit = FlxU.getTicks();
			flicker( INVULN_DURATION );
			super.hurt(Damage);
		}
		
	}

}