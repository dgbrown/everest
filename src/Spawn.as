package  
{
	import org.flixel.FlxSprite;
	
	/// @author Derek Brown
	public class Spawn extends FlxSprite 
	{
		
		[Embed(source = "../assets/gfx/spawn.png")]
		private const _gfx_spawnClass:Class;
		
		public static const ORIGIN_X:int = 8;
		public static const ORIGIN_Y:int = 11;
		
		/// x coordinate of this object's origin, in world space
		public function get ox():Number { return x - ORIGIN_X; }
		/// y coordinate of this object's origin, in world space
		public function get oy():Number { return y - ORIGIN_Y; }
		
		/// origin starts centered at the given coordinates
		public function Spawn( X:Number, Y:Number ) 
		{
			super( 0, 0, _gfx_spawnClass );
			centerOn( X, Y );
		}
		
		public function centerOn( X:Number, Y:Number ):void
		{
			x = X - ORIGIN_X;
			y = Y - ORIGIN_Y;
		}
		
	}

}