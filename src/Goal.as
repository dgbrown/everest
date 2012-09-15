package  
{
	import org.flixel.FlxSprite;
	
	/// @author Derek Brown
	public class Goal extends FlxSprite 
	{
		[Embed(source="../assets/gfx/goal.png")]
		private static const _gfx_goalClass:Class;
		
		public static const ORIGIN_X:int = 8;
		public static const ORIGIN_Y:int = 26;
		public static const FRAME_WIDTH:int = 16;
		public static const FRAME_HEIGHT:int = 32;
		
		/// object will be placed with it's origin at the given positition
		public function Goal(X:Number=0, Y:Number=0) 
		{
			super(0, 0, _gfx_goalClass);
			centerOn( X, Y );
		}
		
		public function centerOn( X:Number, Y:Number ):void
		{
			x = X - ORIGIN_X;
			y = Y - ORIGIN_Y;
		}
		
	}

}