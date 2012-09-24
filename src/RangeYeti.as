package  
{
	import flash.geom.Point;
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Derek brown
	 */
	public class RangeYeti extends Yeti 
	{
		[Embed(source="../assets/gfx/yeti_ranged.png")]
		protected var _gfx_yetiClass:Class;
		
		protected static const AI_STATE_THROWING:uint = 3;
		
		protected var _nextThrowMark:Number;
		protected var _throwDelay:Number;
		protected var _tryThrowDistance:Number;
		protected var _quitThrowDistance:Number;
		
		public function RangeYeti(X:Number=0, Y:Number=0) 
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
			
			_throwDelay = 1111;
			_tryThrowDistance = 80;
			_quitThrowDistance = 100;
		}
		
		public function throwSnowball():void
		{
			var throwDir:FlxPoint = new FlxPoint();
			if ( target )
			{
				throwDir.x = target.ox - ox;
				throwDir.y = target.oy - oy;
				var mag:Number = Math.sqrt( throwDir.x * throwDir.x + throwDir.y * throwDir.y );
				throwDir.x /= mag;
				throwDir.y /= mag;
			}
			else
			{
				throwDir.copyFrom( _viewDir );
			}
			_world.addSnowball( new FlxPoint( ox, oy ), throwDir );
		}
		
		override protected function think():void 
		{
			super.think();
			if ( _aiState == AI_STATE_THROWING )
				thinkThrowing();
		}
		
		protected function thinkThrowing():void
		{
			if ( Math.abs( FlxU.getDistance( new FlxPoint( ox, oy ), new FlxPoint( target.ox, target.oy ) ) ) >= _quitThrowDistance )
				_aiState = AI_STATE_CHASE;
			else if( FlxU.getTicks() >= _nextThrowMark && canSee(target) )
			{
				_nextThrowMark = FlxU.getTicks() + _throwDelay;
				throwSnowball();
			}
		}
		
		override protected function thinkChase():void 
		{
			if ( Math.abs( FlxU.getDistance( new FlxPoint( ox, oy ), new FlxPoint( target.ox, target.oy ) ) ) <= _tryThrowDistance )
			{
				_aiState = AI_STATE_THROWING;
				_nextThrowMark = FlxU.getTicks() + _throwDelay * 0.5;
				pathSpeed = 0;
			}
			else
				super.thinkChase();
		}
		
	}

}