package
{
	import flash.utils.getTimer;
	
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.display.graphics.Stroke;
	import starling.events.Event;
	
	public class StrokeProfiling extends Sprite
	{
		private var stroke			:Stroke;
		private var startTime		:int;
		
		public function StrokeProfiling()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		private function onAdded ( e:Event ):void
		{
			stroke = new Stroke();
			addChild(stroke);
			
			
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		private var numFrames:int = 0;
		private function enterFrameHandler( event:Event ):void
		{
			startTime = getTimer();
			stroke.clear();
			const STAGE_HEIGHT:Number = Starling.current.nativeStage.stageHeight;
			for ( var i:int = 0; i < 100; i++ )
			{
				var L:int = 2 + Math.random() * 20;
				stroke.addBreak();
				for ( var j:int = 0; j < L; j++ )
				{
					stroke.addVertex( Math.random() * Starling.current.nativeStage.stageWidth, Math.random() * Starling.current.nativeStage.stageHeight );
				}
			}
			stroke.validateNow();
			trace(getTimer()-startTime);
		}
	}
}