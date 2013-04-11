package
{
	import flash.utils.getTimer;
	
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.display.graphics.Stroke;
	import starling.events.Event;
	
	public class StrokeJointTest extends Sprite
	{
		private var stroke			:Stroke;
		private var startTime		:int;
		
		public function StrokeJointTest()
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
			
			for ( var i:int = 0; i < 1600; i++ )
			{
				stroke.clear();
				stroke.addVertex( 100, 200, 50 );
				stroke.addVertex( 300, 100, 50 );
				stroke.addVertex( Starling.current.nativeStage.mouseX, Starling.current.nativeStage.mouseY, 50 );
			}
			stroke.validateNow();
			trace(getTimer()-startTime);
		}
	}
}