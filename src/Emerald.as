package  
{
	import org.flixel.FlxSprite;
	
	/// @author Derek Brown
	public class Emerald extends FlxSprite 
	{
		
		[Embed(source = "../assets/gfx/emerald.png")]
		private var _gfx_emerald:Class;
		
		public static const ANIM_FRAMERATE:uint = 15;
		public static const ANIM_WIDTH:uint = 5;
		public static const ANIM_HEIGHT:uint = 16;
		
		public function Emerald(X:Number=0, Y:Number=0) 
		{
			super(X, Y);
			loadGraphic( _gfx_emerald, true, false, Emerald.ANIM_WIDTH, Emerald.ANIM_HEIGHT, false );
			addAnimation( "float", [ 0, 0, 1, 2, 3, 3, 3, 4, 5, 1 ], Emerald.ANIM_FRAMERATE, true );
			play( "float", true );
		}
		
	}

}