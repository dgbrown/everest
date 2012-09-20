package  
{
	import org.flixel.*;
	
	/// @author Derek Brown
	public class MainMenu extends FlxState 
	{
		
		private var _options:FlxButton;
		private var _play:FlxButton
		
		override public function create():void 
		{
			super.create();
			
			FlxG.mouse.show();
			
			if ( FlxG.debug )
				FlxG.switchState( new NormalPlay() );
			
			var nBtns:Number = 0;
			var btnSize:FlxPoint = new FlxPoint();
			var btnSpacing:Number = 5; // 10 pixels below
			var btnStartY:Number = 50;
			
			_options = new FlxButton( 0, btnStartY, "Options", optionsBtnPressed );
			btnSize.make( _options.width, _options.height );
			_options.x = (FlxG.width * 0.5) - (btnSize.x * 0.5);
			add( _options );
			nBtns++;
			
			_play = new FlxButton( (FlxG.width * 0.5) - (btnSize.x * 0.5), btnStartY + nBtns * (btnSize.y + btnSpacing), "Play", playBtnPressed );
			add( _play );
			nBtns++;
		}
		
		private function optionsBtnPressed():void
		{
			// slide over to the options screen
		}
		
		private function backBtnPressed():void
		{
			// slide back to the main menu screen
		}
		
		private function playBtnPressed():void
		{
			FlxG.switchState( new NormalPlay() );
		}
		
	}

}