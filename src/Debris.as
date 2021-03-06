package  
{
	import org.flixel.FlxSprite;
	
	/// @author Derek Brown
	public class Debris extends EverEnt 
	{
		private static const FRAME_RATE:int = 20;
		
		[Embed(source="../assets/gfx/debris_tree01_redux.png")]
		private var _gfx_testDebrisClass:Class;
		private var _gfx_graphicClass:Class;
		
		/// object will be placed with origin at given coordinates
		public function Debris(X:Number=0, Y:Number=0) 
		{
			super();
			collisionWidth = 20;
			collisionHeight = 20;
			collisionRadius = 12;
			originX = 10;
			originY = 27;
			spriteWidth = 20;
			spriteHeight = 35;
			
			_gfx_graphicClass = _gfx_testDebrisClass;
			loadGraphic( _gfx_graphicClass, true, false, spriteWidth, spriteHeight, false );
			addAnimation( "normal", [0], FRAME_RATE, false );
			addAnimation( "damaged", [1], FRAME_RATE, false );
			addAnimation( "broken", [2], FRAME_RATE, false );
			
			play( "normal", true );
			health = Math.random() <= 0.666666 ? 2 : 1;
			centerOn( X, Y );
		}
		
		override public function hurt(Damage:Number):void 
		{
			if ( --health <= 0 )
				alive = false;
		}
		
		override public function update():void 
		{
			switch( health )
			{
				case 2:
					play( "normal", true );
					break;
				case 1:
					play( "damaged", true );
					break;
				case 0:
				default:
					play( "broken", true );
			}
			super.update();
		}
		
	}

}