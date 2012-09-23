package  
{
	import org.flixel.*;
	
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
		
		override public function drawDebug(Camera:FlxCamera = null):void 
		{
			super.drawDebug(Camera);
			var px:Number = ox - FlxG.camera.scroll.x * scrollFactor.x;
			var py:Number = oy - FlxG.camera.scroll.y * scrollFactor.y;
			var pc:uint = 0x000000;
			FlxG.camera.buffer.setPixel( px, py - 1, pc );
			FlxG.camera.buffer.setPixel( px - 1, py, pc );
			FlxG.camera.buffer.setPixel( px, py, 0xFFFFFF );
			FlxG.camera.buffer.setPixel( px + 1, py, pc );
			FlxG.camera.buffer.setPixel( px, py + 1, pc );
		}
		
		public function centerOn( X:Number, Y:Number ):void
		{
			x = X - originX;
			y = Y - originY;
		}
		
		protected function initFancyCollisions():void
		{
			width = collisionWidth;
			height = collisionHeight;
			offset.make( originX - collisionWidth * 0.5, originY - collisionHeight * 0.5 );
			originX -= offset.x;
			originY -= offset.y;
		}
		
	}

}