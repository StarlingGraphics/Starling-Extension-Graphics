package boxbenchmark
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import boxbenchmark.behaviours.BounceBehaviour;
	
	import starling.display.Shape;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class BoxesShapeBenchmark extends Benchmark
	{	
		private var _behaviours			:Vector.<BounceBehaviour>;
		private var maxEntities			:int = 1000;
		private var numEntities			:int = 0;
		
		private var entityIndex			:uint;
		protected var _numCompleteFrames:int = 0;
		
		public function BoxesShapeBenchmark()
		{
			_behaviours = new Vector.<BounceBehaviour>(maxEntities, true);
			numEntities = 0;
		}
		
		override public function get benchmarkName() : String
		{
			return "BoxesShapeBenchmark";
		}
		
		
		override public function isDone() : Boolean
		{
			if ( _numCompleteFrames > 120 )
				return true;
			return false;	
		}
		
		override public function startBenchmark() : void
		{
			
		}
		
		override public function updateBenchmark():void 
		{
			if (entityIndex < maxEntities) {
				entityIndex ++;
				createBehaviour();
				numEntities++;
			}
			else
			{
				_numCompleteFrames++;
			}
			
			for ( var i:uint = 0; i < numEntities; i++ ) {
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
			_behaviours[numEntities] = bounceBehaviour;
		}
	}
}