package
{
	import flash.utils.getTimer;
	
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.display.Shape;
	import starling.events.Event;
	
	public class StrokeProfilingGraphics extends Sprite
	{
		private var shape			:Shape;
		private var startTime		:int;
		
		public function StrokeProfilingGraphics()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		private function onAdded ( e:Event ):void
		{
			shape = new Shape();
			addChild(shape);
			
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		private var numFrames:int = 0;
		private function enterFrameHandler( event:Event ):void
		{
			startTime = getTimer();
			shape.graphics.clear();
			shape.graphics.lineStyle( 1, 0xFFFFFF );
			const STAGE_HEIGHT:Number = Starling.current.nativeStage.stageHeight;
			for ( var i:int = 0; i < 100; i++ )
			{
				var L:int = 2 + Math.random() * 20;
				
				shape.graphics.moveTo( Math.random() * Starling.current.nativeStage.stageWidth, Math.random() * Starling.current.nativeStage.stageHeight );
				for ( var j:int = 0; j < L; j++ )
				{
					shape.graphics.lineTo( Math.random() * Starling.current.nativeStage.stageWidth, Math.random() * Starling.current.nativeStage.stageHeight );
				}
			}
			trace(getTimer()-startTime);
		}
	}
}