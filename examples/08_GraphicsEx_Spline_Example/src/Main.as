package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import starling.core.Starling;
	
	
	[SWF(width="1024", height="768", frameRate="60", backgroundColor="#000000")]
	public class Main extends Sprite 
	{
		private var _starling:Starling;

		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			_starling = new Starling(NaturalSplineExample, stage);
			stage.color = 0x00000000;
			_starling.antiAliasing = 1;
			_starling.start();
			
			
		}
	}	
	
}