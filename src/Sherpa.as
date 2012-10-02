package  
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
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
		public var sprinting:Boolean;
		public var maxSprintEnergy:Number;
		public var sprintEnergy:Number;
		public var sprintDrainRate:Number;
		public var sprintRegenRate:Number;
		public var exhaustedUntil:Number;
		public var exhaustedDelay:Number;
		public var swordWidth:Number;
		public var swordLength:Number;
		public var hiding:Boolean;
		public var raging:Boolean;
		public var backstabRageBoosting:Boolean;
		public var maxRageEnergy:Number;
		public var rageEnergy:Number;
		public var rageRegenRate:Number;
		public var rageDrainRate:Number;
		public var backstabRageBoostRegenRate:Number;
		public function get exhausted():Boolean { return FlxU.getTicks() < exhaustedUntil; }
		public function get movementX():Number { return x - lastX; }
		public function get movementY():Number { return y - lastY; }
		public function get moving():Boolean { return ( movementX != 0 || movementY != 0 ); }
		public function get vulnerable():Boolean { return FlxU.getTicks() >= _lastHurtMark + _hurtDuration; }
		public function get attacking():Boolean { return FlxU.getTicks() <= _lastAttackMark + _attackDuration }
		public function get canSprint():Boolean { return sprintEnergy > 0; }
		public function get canRage():Boolean { return rageEnergy == maxRageEnergy && !raging && !backstabRageBoosting && !hiding; }
		
		private var _framerate:int;
		private var _lastHurtMark:Number = 0.0; /// when was the last time this ent was hurt?
		private var _defaultMaxHealth:int;
		private var _hurtDuration:int; /// number of milliseconds to be invulerable after being hurt
		private var _lastAttackMark:Number = 0.0; /// when was the last time this ent attacked?
		private var _attackDuration:Number;
		private var _weapon:FlxSprite;
		
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
			sprinting = false;
			maxSprintEnergy = 100.0;
			sprintEnergy = maxSprintEnergy;
			sprintDrainRate = maxSprintEnergy / 3.0;
			sprintRegenRate = maxSprintEnergy / 7.0;
			exhaustedUntil = 0.0;
			exhaustedDelay = 4000;
			swordWidth = 2;
			swordLength = 20;
			hiding = false;
			raging = false;
			
			backstabRageBoosting = false;
			maxRageEnergy = 50.0;
			rageEnergy = maxRageEnergy;
			rageRegenRate = maxRageEnergy / 20.0;
			rageDrainRate = maxRageEnergy / 6.5;
			backstabRageBoostRegenRate = maxRageEnergy / 2.5;
			
			_lastAttackMark = 0.0;
			_attackDuration = 450.0;
			
			initGraphics();
			initFancyCollisions();
			
			_weapon = new FlxSprite();
			_weapon.makeGraphic( swordLength, swordWidth, 0xFFC8C8C8 );
			_weapon.origin.make( 3, swordWidth*0.5 );
			
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
			addAnimation( "hide", [ 12 ], _framerate, true );
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
			raging = false;
			backstabRageBoosting = false;
			_lastAttackMark = 0;
			_lastHurtMark = 0;
			hiding = false;
			rageEnergy = maxRageEnergy;
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
			if ( hiding )
				play( "hide", true );
			else if ( moving )
				playWalk(false);
			else
				playIdle();
				
			if ( backstabRageBoosting )
			{
				var rageRegen:Number = backstabRageBoostRegenRate * FlxG.elapsed;
				rageEnergy += rageRegen;
				if ( rageEnergy >= maxRageEnergy )
				{
					backstabRageBoosting = false;
					rageEnergy = maxRageEnergy;
				}
			}
			else if ( raging )
			{
				var rageDrain:Number = rageDrainRate * FlxG.elapsed;
				rageEnergy -= rageDrain;
				if ( rageEnergy <= 0 )
				{
					rageEnergy = 0;
					raging = false;
				}
			}
			else
			{
				var ragePassiveRagen:Number = rageRegenRate * FlxG.elapsed;
				rageEnergy += ragePassiveRagen;
				if ( rageEnergy > maxRageEnergy )
					rageEnergy = maxRageEnergy;
			}
				
			if ( sprinting && moving )
			{
				var sprintDrain:Number = sprintDrainRate * FlxG.elapsed;
				sprintEnergy -= sprintDrain;
				if ( sprintEnergy < 1 )
				{
					sprintEnergy = 0;
					exhaustedUntil = FlxU.getTicks() + exhaustedDelay;
				}
			}
			else if( !exhausted )
			{
				var sprintRegen:Number = sprintRegenRate * FlxG.elapsed;
				sprintEnergy += sprintRegen;
				if ( sprintEnergy > maxSprintEnergy )
					sprintEnergy = maxSprintEnergy;
			}
				
			super.update();
			_weapon.x = ox - 4;
			_weapon.y = oy - 3;
			lastX = x;
			lastY = y;
		}
		
		override public function draw():void 
		{
			_weapon.angle = dir == "up" ? -90 : dir == "down" ? 90 : dir == "left" ? -180 : dir == "right" ? 0 : 0;
			if ( dir == "up" || dir == "left" )
			{
				if ( attacking )
					_weapon.draw();
				super.draw();
			}
			else
			{
				super.draw();
				if ( attacking )
					_weapon.draw();
			}
			color = raging ? 0xFFB8B8 : 0xFFFFFF;
		}
		
		public function inAttackRange( Ent:EverEnt ):Boolean
		{
			var attackArea:Rectangle;
			switch( dir )
			{
				default:
				case "up":
					attackArea = new Rectangle( -swordWidth * 0.5, -swordLength, swordWidth, swordLength );
					break;
				case "left":
					attackArea = new Rectangle( -swordLength, -swordWidth * 0.5, swordLength, swordWidth );
					break;
				case "down":
					attackArea = new Rectangle( -swordWidth * 0.5, swordLength, swordWidth, swordLength );
					break;
				case "right":
					attackArea = new Rectangle( 0, -swordWidth * 0.5, swordLength, swordWidth );
					break;
			}
			
			var entRect:Rectangle = new Rectangle( Ent.ox - ox, Ent.oy - oy, Ent.collisionWidth, Ent.collisionHeight );
			return attackArea.intersects( entRect );
		}
		
		/// returns an array of the FlxBasic objects that were successfuly hit
		public function attack( PotentialHits:FlxGroup ):Array
		{
			var confirmedHits:Array = new Array();
			var backstabVictim:Yeti = null;
			
			for ( var i:uint = 0; i < PotentialHits.length; ++i )
			{
				if ( !(PotentialHits.members[i] is EverEnt ) )
					continue;
				
				var ent:EverEnt = PotentialHits.members[i] as EverEnt;
				if ( ent.alive && inAttackRange( ent ) )
				{	
					if ( ent is Yeti && (ent as Yeti).dir == dir )
					{
						backstabVictim = ent as Yeti;
						confirmedHits.length = 0;
						break;
					}
					confirmedHits.push( ent as FlxBasic );
				}
			}
			if ( backstabVictim )
			{
				backstabVictim.stabInBack();
				backstabRageBoosting = true;
			}
			else
			{
				for ( var i:uint = 0; i < confirmedHits.length; ++i )
				{
					ent.hurt( attackDamage );
				}
			}
				
			_lastAttackMark = FlxU.getTicks();
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