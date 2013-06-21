package
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import behaviours.BounceBehaviour;
	
	import starling.display.Shape;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class BoxesShapeExample extends Sprite
	{	
		private var _behaviours			:Array;
		private var numEntities			:int = 1000;
		private var entityIndex			:uint;
		
		public function BoxesShapeExample()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAdded);

			_behaviours = [];
		}
		
		private function onAdded ( e:Event ):void
		{		
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		private function enterFrameHandler( event:Event ):void
		{
			if (entityIndex < numEntities) {
				entityIndex ++;
				createBehaviour();
			}
			
			for ( var i:uint = 0; i < _behaviours.length; i ++ ) {
				var behaviour:BounceBehaviour = _behaviours[i];
				behaviour.step();
			}
		}
		
		
		private function createBehaviour():void
		{
			// Add the BounceBehaviour to the scene
			var randomVelocity:Point = new Point(Math.random() * 10, (Math.random() * 10) - 5);
			var bounceBehaviour:BounceBehaviour = new BounceBehaviour();
			bounceBehaviour.velocity = randomVelocity;
			bounceBehaviour.boundsRect = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
			
			// Add a Shape to the scene
			var shape:Shape = new Shape();
			addChild(shape);
			shape.x = 20;
			shape.y = 20;
			
			// Rect drawn with drawRect()
			shape.graphics.lineStyle(1);
			shape.graphics.beginFill(Math.random() * 0xFFFFFF);
			shape.graphics.drawRect(0, 0, 30, 30);
			shape.graphics.endFill();
			
			// Pass reference to skin to bounceBehaviour
			bounceBehaviour.shape = shape;
			_behaviours.push(bounceBehaviour);
		}
	}
}