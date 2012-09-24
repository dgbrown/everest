package  
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Derek brown
	 */
	public class Snowball extends EverEnt
	{
		
		[Embed(source="../assets/gfx/snowball.png")]
		protected var _gfx_snowballClass:Class;
		
		public var moveSpeed:Number; /// how many pixels per second to move
		
		public function Snowball( X:Number=0, Y:Number=0, TravelDirection:FlxPoint = null ) 
		{
			super();
			
			moveSpeed = 100;
			
			if ( TravelDirection )
			{
				velocity.x = TravelDirection.x * moveSpeed;
				velocity.y = TravelDirection.y * moveSpeed;
			}
			
			x = X;
			y = Y;
			
			//makeGraphic( 4, 4, 0xffffffff, false );
			loadGraphic( _gfx_snowballClass, false );
			
			collisionWidth = 5;
			collisionHeight = 5;
			collisionRadius = 4;
			spriteWidth = 5;
			spriteHeight = 5;
			originX = 2;
			originY = 2;
			initFancyCollisions();
		}
		
	}

}