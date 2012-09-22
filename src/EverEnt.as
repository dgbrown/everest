package  
{
	import org.flixel.FlxSprite;
	
	/**
	 * ...
	 * @author Derek brown
	 */
	public class EverEnt extends FlxSprite 
	{
		
		public var spriteWidth:int = 16;
		public var spriteHeight:int = 16;
		public var collisionWidth:int = 16;
		public var collisionHeight:int = 16;
		public var collisionRadius:Number = 14;
		public var originX:int = 8;
		public var originY:int = 8;
		public function get ox():Number { return x + originX; }
		public function get oy():Number { return y + originY; }
		
		public function EverEnt() 
		{
			super();
		}
		
		public function centerOn( X:Number, Y:Number ):void
		{
			x = X - originX;
			y = Y - originY;
		}
		
	}

}