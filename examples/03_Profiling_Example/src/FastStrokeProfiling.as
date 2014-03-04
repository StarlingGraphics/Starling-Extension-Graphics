package
{
	import flash.utils.getTimer;
	
	import starling.core.Starling;
	import starling.display.Shape;
	import starling.display.Sprite;
	import starling.display.graphics.FastStroke;
	import starling.events.Event;
	
	public class FastStrokeProfiling extends Sprite
	{
		private var fastStroke      :FastStroke;
		private var startTime		:int;
		private var timeLog         :TimeLog;
		
		public function FastStrokeProfiling()
		{
			timeLog = new TimeLog();
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
			fastStroke = new FastStroke();
		}
		
		private function onAdded ( e:Event ):void
		{
			addChild(fastStroke);
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		private var numFrames:int = 0;
		private function enterFrameHandler( event:Event ):void
		{
			fastStroke.clear();
			startTime = getTimer();
			var stageWidth:Number = Starling.current.nativeStage.stageWidth;
			var stageHeight:Number = Starling.current.nativeStage.stageHeight;
			for ( var i:int = 0; i < 100; i++ )
			{
				var L:int = 2 + Math.random() * 20;
				
				fastStroke.moveTo(Math.random() * stageWidth, Math.random() * stageHeight);
				for ( var j:int = 0; j < L; j++ ) {
					fastStroke.lineTo(Math.random() * stageWidth, Math.random() * stageHeight);
				}
			}
			timeLog.logTime(getTimer()-startTime);
		}
	}
}