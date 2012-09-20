package  
{
	import org.flixel.FlxSprite;
	
	/// @author Derek Brown
	public class Goal extends FlxSprite 
	{
		[Embed(source="../assets/gfx/goal.png")]
		private static const _gfx_goalClass:Class;
		
		public static const ORIGIN_X:int = 8;
		public static const ORIGIN_Y:int = 12;
		public static const FRAME_WIDTH:int = 16;
		public static const FRAME_HEIGHT:int = 12;
		
		/// x coordinate of this object's origin, in world space
		public function get ox():Number { return x - ORIGIN_X; }
		/// y coordinate of this object's origin, in world space
		public function get oy():Number { return y - ORIGIN_Y; }
		
		/// object will be placed with it's origin at the given positition
		public function Goal(X:Number=0, Y:Number=0) 
		{
			super(0, 0, _gfx_goalClass);
			offset.make( 0, ORIGIN_Y );
			height = FRAME_HEIGHT;
			centerOn( X, Y );
		}
		
		public function centerOn( X:Number, Y:Number ):void
		{
			x = X - ORIGIN_X;
			y = Y - ORIGIN_Y;
		}
		
	}

}