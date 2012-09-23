package  
{
	import org.flixel.*;
	
	/// @author Derek Brown
	public class Sherpa extends EverEnt 
	{
		
		[Embed(source="../assets/gfx/player_sherpa_redux.png")]
		private var _gfx_sherpa:Class;

		public var maxHealth:Number;
		public var dir:String; /// "up", "down", "left", or "right"
		public var nEmeralds:uint = 0;
		public var lastX:Number = 0;
		public var lastY:Number = 0;
		public var attackDamage:Number;
		public var attackRadius:Number;
		public function get movementX():Number { return x - lastX; }
		public function get movementY():Number { return y - lastY; }
		public function get moving():Boolean { return ( movementX != 0 || movementY != 0 ); }
		public function get vulnerable():Boolean { return FlxU.getTicks() >= _lastHurtMark + _hurtDuration; }
		
		private var _framerate:int;
		private var _lastHurtMark:Number = 0.0; /// when was the last time this ent was hurt?
		private var _defaultMaxHealth:int;
		private var _hurtDuration:int; /// number of milliseconds to be invulerable after being hurt
		
		public function Sherpa(X:Number=0, Y:Number=0) 
		{
			super();
			collisionWidth = 11;
			collisionHeight = 6;
			collisionRadius = 10;
			spriteWidth = 12;
			spriteHeight = 12;
			originX = 6;
			originY = 9;
			
			_framerate = 20;
			attackRadius = 25;
			attackDamage = 5;
			_hurtDuration = 1000;
			_defaultMaxHealth = maxHealth = 10;
			
			initGraphics();
			initFancyCollisions();
			
			respawnAt( X, Y );
		}
		
		private function initGraphics():void
		{
			loadGraphic( _gfx_sherpa, true, false, spriteWidth, spriteHeight, true );
			addAnimation( "up_idle", [ 0 ], _framerate, true );
			addAnimation( "up_walk", [ 1, 1, 1, 0, 0, 0, 2, 2, 2, 0, 0, 0 ], _framerate, true );
			addAnimation( "down_idle", [ 3 ], _framerate, true );
			addAnimation( "down_walk", [ 4, 4, 4, 3, 3, 3, 5, 5, 5, 3, 3, 3 ], _framerate, true );
			addAnimation( "left_idle", [ 6 ], _framerate, true );
			addAnimation( "left_walk", [ 7, 7, 7, 6, 6, 6, 8, 8, 8, 6, 6, 6 ], _framerate, true );
			addAnimation( "right_idle", [ 9 ], _framerate, true );
			addAnimation( "right_walk", [ 10, 10, 10, 9, 9, 9, 11, 11, 11, 9, 9, 9 ], _framerate, true );
		}
		
		public function respawnAt( X:Number, Y:Number ):void
		{
			centerOn( X, Y );
			
			health = _defaultMaxHealth;
			exists = true;
			alive = true;
			visible = true;
			active = true;
			dir = "down";
			playIdle(true);
		}
		
		public function respawn():void
		{
			respawnAt( ox, oy );
		}
		
		public function playAttack( Force:Boolean = true ):void
		{
			//play( dir + "_attack", Force );
		}
		
		public function playIdle( Force:Boolean = true ):void
		{
			play( dir + "_idle", Force );
		}
		
		public function playWalk( Force:Boolean = true ):void
		{
			play( dir + "_walk", Force );
		}
		
		override public function update():void 
		{
			if ( moving )
				playWalk(false);
			else
				playIdle();
				
			super.update();
			lastX = x;
			lastY = y;
		}
		
		/// returns an array of the FlxBasic objects that were successfuly hit
		public function attack( PotentialHits:FlxGroup ):Array
		{
			var confirmedHits:Array = new Array();
			for ( var i:uint = 0; i < PotentialHits.length; ++i )
			{
				if ( !(PotentialHits.members[i] is EverEnt ) )
					continue;
				
				var ent:EverEnt = PotentialHits.members[i] as EverEnt;
				if ( ent.alive )
				{	
					var hitPossible:Boolean = false;
					switch( dir )
					{
						case "up":
							hitPossible = ent.oy <= oy;
							break;
						case "down":
							hitPossible = ent.oy >= oy;
							break;
						case "left":
							hitPossible = ent.ox <= ox;
							break;
						case "right":
							hitPossible = ent.ox >= ox;
							break;
					}
					if ( hitPossible )
					{
						var dX:Number = ent.ox - ox;
						var dY:Number = ent.oy - oy;
						var dT:Number = Math.sqrt( dX * dX + dY * dY );
						
						if ( dT <= attackRadius + ent.collisionRadius )
						{
							ent.hurt( attackDamage );
							confirmedHits.push( ent as FlxBasic );
						}
					}
				}
			}
			return confirmedHits;
		}
		
		override public function hurt(Damage:Number):void 
		{
			if ( !vulnerable )
				return;
				
			_lastHurtMark = FlxU.getTicks();
			flicker( _hurtDuration / 1000 );
			super.hurt(Damage);
		}
		
	}

}