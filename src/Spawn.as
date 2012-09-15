package  
{
	import org.flixel.FlxSprite;
	
	/// @author Derek Brown
	public class Spawn extends FlxSprite 
	{
		
		[Embed(source = "../assets/gfx/spawn.png")]
		private const _gfx_spawnClass:Class;
		
		public static const ORIGIN_X:int = 4;
		public static const ORIGIN_Y:int = 0;
		
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