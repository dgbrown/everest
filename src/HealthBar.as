package  
{
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.flixel.*;
	
	/// @author Derek Brown
	public class HealthBar extends FlxObject 
	{
		
		[Embed(source = "../assets/gfx/ui_heart.png")]
		private var _gfx_iconClass:Class;
		private var _gfx_icon:BitmapData = (new _gfx_iconClass() as Bitmap).bitmapData;
		
		public static var ICON_WIDTH:uint = 15;
		public static var ICON_HEIGHT:uint = 15;
		// _heartPeices
		public var _heartPeices:uint;
		public function getHeartPeices():uint { return _heartPeices; }
		public function setHeartPeices(Value:uint):void { _heartPeices = Value > _maxHearts * 2 ? _maxHearts * 2 : Value; }
		// _maxHearts
		private var _maxHearts:uint
		public function getMaxHearts():uint { return _maxHearts; }
		public function setMaxHearts(Value:uint):void
		{
			_maxHearts = Value;
			_heartPeices = _heartPeices > _maxHearts * 2 ? _maxHearts * 2 : _heartPeices;
			recalculateDimensions();
		}
		// width
		public function getWidth():Number { return width; }
		public function setWidth( Value:Number ):void
		{
			width = Value < HealthBar.ICON_WIDTH ? HealthBar.ICON_WIDTH : Value;
			recalculateDimensions();
		}
		
		private var _columns:uint;
		private var _iconFrameRects:Array;
		
		/// Height will be calculated automaticially, 2 HeartPeices = 1 Full Heart
		public function HealthBar( X:Number = 0, Y:Number = 0, Width:Number = 0, MaxHearts:uint = 5, HeartPeices:uint = 10 ) 
		{
			super(X, Y, Width, HealthBar.ICON_WIDTH);
			setMaxHearts( MaxHearts );
			_heartPeices = HeartPeices;
			
			_iconFrameRects = new Array( new Rectangle( 0, 0, HealthBar.ICON_WIDTH, HealthBar.ICON_HEIGHT )
										 ,new Rectangle( HealthBar.ICON_WIDTH, 0, HealthBar.ICON_WIDTH, HealthBar.ICON_HEIGHT )
										 ,new Rectangle( HealthBar.ICON_WIDTH * 2, 0, HealthBar.ICON_WIDTH, HealthBar.ICON_HEIGHT ) );
		}
		
		/// recalculates rows, columns, and height based on width
		private function recalculateDimensions():void
		{
			_columns = Math.floor( width / HealthBar.ICON_WIDTH );
			var rows:uint = Math.floor(_maxHearts / _columns) + (_maxHearts % _columns != 0 ? 1 : 0);
			height = rows * HealthBar.ICON_HEIGHT;
		}
		
		override public function draw():void 
		{
			var frameRect:Rectangle;
			for ( var i:uint = 1; i <= _maxHearts; ++i )
			{
				// pick graphic to display for this heart
				if ( i * 2 <= _heartPeices ) 			// draw a full heart
					frameRect = _iconFrameRects[2];
				else if ( (i * 2) - 1 == _heartPeices ) 	// draw a half heart
					frameRect = _iconFrameRects[1];
				else 									// draw an empty heart
					frameRect = _iconFrameRects[0];
				
				var tx:Number = ((i - 1) % _columns) * HealthBar.ICON_WIDTH + x;
				var ty:Number = Math.floor((i - 1) / _columns) * HealthBar.ICON_HEIGHT + y;
				var destPoint:Point = new Point(tx, ty);
				
				FlxG.camera.buffer.copyPixels(_gfx_icon, frameRect, destPoint, null, null, true);
			}
			super.draw();
		}
		
	}

}