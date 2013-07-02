package
{
	import flash.geom.Point;
	
	import starling.display.Shape;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class BoundsTest extends Sprite
	{	
		private var shape:Shape;
		
		public function BoundsTest()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		private function onAdded ( e:Event ):void
		{
			// Add a Shape to the scene
			shape = new Shape();
			addChild(shape);
			
			stage.addEventListener(TouchEvent.TOUCH, onTouchHandler);
		}
		
		private function onTouchHandler( event:TouchEvent ):void
		{
			var touches:Vector.<Touch> = event.getTouches(stage);

			for each (var touch:Touch in touches)
			{
				if ( touch.phase == TouchPhase.HOVER ) {
					mouseMoveHandler( event, touch );
				}
				break;
			}
		}
		
		private function mouseMoveHandler( event:TouchEvent, touch:Touch ):void
		{
			var pt:Point = touch.getLocation(stage);
			
			// Rect drawn with drawRect()
			shape.graphics.clear();
			shape.graphics.lineStyle(10);
			shape.graphics.moveTo(stage.stageWidth/2, stage.stageHeight/2);
			shape.graphics.lineTo(pt.x, pt.y);
			
			trace(shape.bounds);
		}
	}
}