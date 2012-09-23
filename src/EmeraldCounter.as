package  
{
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.geom.Point;
	import org.flixel.*;
	
	/// @author Derek Brown
	public class EmeraldCounter extends FlxObject 
	{
		
		[Embed(source = "../assets/gfx/ui_emerald.png")]
		private var _gfx_uiEmeraldClass:Class;
		private var _gfx_uiEmerald:BitmapData = (new _gfx_uiEmeraldClass() as Bitmap).bitmapData;
		
		public static const ICON_WIDTH:uint = 10;
		public static const ICON_HEIGHT:uint = 16;
		public static const FRAME_WIDTH:uint = ICON_WIDTH + 31;
		
		private var _value:uint = 0;
		public function getValue():uint { return _value; }
		public function setValue(Value:uint):void
		{
			_value = Value;
			_countLabel.text = _value + "x";
		}
		
		private var _countLabel:FlxText;
		
		public function EmeraldCounter(X:Number=0, Y:Number=0) 
		{
			super(X, Y, EmeraldCounter.FRAME_WIDTH, ICON_HEIGHT + 2);
			scrollFactor.make();
			_countLabel = new FlxText(0, 0, 30, "0x" );
			_countLabel.alignment = "right";
		}
		
		override public function draw():void 
		{
			FlxG.camera.buffer.copyPixels( _countLabel.pixels, _countLabel.pixels.rect, new Point(x, y + 4), null, null, true );
			FlxG.camera.buffer.copyPixels( _gfx_uiEmerald, _gfx_uiEmerald.rect, new Point(x + _countLabel.width - 1, y + 2), null, null, true );
			super.draw();
		}
		
	}

}