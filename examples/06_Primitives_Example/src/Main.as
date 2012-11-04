package  
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import starling.core.Starling;
	
	[SWF( width="800", height="600", backgroundColor="#F4F4F4", frameRate="60" )]
	public class Main extends Sprite 
	{
		private var starling	:Starling;
		
		public function Main() 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			starling = new Starling( PrimitivesExample, stage );
			
			starling.antiAliasing = 3;
			starling.start();
		}
		
	}
	
}