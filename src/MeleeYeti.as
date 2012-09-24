package  
{
	/**
	 * ...
	 * @author Derek brown
	 */
	public class MeleeYeti extends Yeti 
	{
		
		[Embed(source="../assets/gfx/yeti_redux.png")]
		protected var _gfx_yetiClass:Class;
		
		public function MeleeYeti(X:Number=0, Y:Number=0) 
		{
			super(X, Y);
			
			collisionWidth = 14;
			collisionHeight = 10;
			collisionRadius = 10;
			spriteWidth = 16;
			spriteHeight = 16;
			originX = 8;
			originY = 12;
			
			loadGraphic( _gfx_yetiClass, true, false, spriteWidth, spriteHeight );
			addAnimation( "up_idle", [0], _framerate, true );
			addAnimation( "down_idle", [1], _framerate, true );
			addAnimation( "left_idle", [2], _framerate, true );
			addAnimation( "right_idle", [3], _framerate, true );
			initFancyCollisions();
		}
		
	}

}