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
			for ( var i:int = 0; i < 400; i++ )
			{
				var ratio:Number = i/400;
				var x:Number = ratio * Starling.current.nativeStage.stageWidth;
				stroke.addBreak();
				stroke.addVertex( x, 0 );
				stroke.addVertex( x, STAGE_HEIGHT );
			}
			stroke.validateNow();
			trace(getTimer()-startTime);
		}
	}
}