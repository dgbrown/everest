package  
{
	import org.flixel.FlxSprite;
	
	/// @author Derek Brown
	public class Debris extends FlxSprite 
	{
		
		public static const ORIGIN_X:int = 10;
		public static const ORIGIN_Y:int = 27
		private static const FRAME_WIDTH:int = 20;
		private static const FRAME_HEIGHT:int = 35;
		private static const FRAME_RATE:int = 20;
		
		[Embed(source="../assets/gfx/debris_tree01.png")]
		private var _gfx_testDebrisClass:Class;
		
		private var _gfx_graphicClass:Class;
		
		/// object will be placed with origin at given coordinates
		public function Debris(X:Number=0, Y:Number=0) 
		{
			super();
			_gfx_graphicClass = _gfx_testDebrisClass;
			loadGraphic( _gfx_graphicClass, true, false, FRAME_WIDTH, FRAME_HEIGHT, false );
			addAnimation( "idle", [0], FRAME_RATE, false );
			addAnimation( "destroyed", [1], FRAME_RATE, false );
			if( Math.random() < 0.6 )
				play( "idle", true );
			else
				play( "destroyed", true );
			x = X - ORIGIN_X;
			y = Y - ORIGIN_Y;
		}
		
	}

}