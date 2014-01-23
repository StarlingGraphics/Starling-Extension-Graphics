package strokegraphicsbenchmark
{
	import flash.utils.getTimer;
	import starling.display.Shape;
	
	import starling.core.Starling;
	import starling.display.Sprite;
	
	import starling.events.Event;
	
	public class StrokeGraphicsBenchmark extends Benchmark
	{
		private var shape			:Shape;
		private var startTime		:int;
		private var numFrames:int = 0;
		
		public function StrokeGraphicsBenchmark()
		{
			
		}
		
		override public function startBenchmark() : void
		{
			shape = new Shape();
			addChild(shape );
			
		}
		
		override public function endBenchmark() : void
		{
			
		}
		
		override public function isDone() : Boolean
		{
			return ( numFrames > 480 );
		}
		
		override public function updateBenchmark( ):void
		{
			const STAGE_HEIGHT:Number = Starling.current.nativeStage.stageHeight;
	
			shape.graphics.clear();
			shape.graphics.lineStyle( 1, 0xFFFFFF );
			
			for ( var i:int = 0; i < 100; i++ )
			{
				var L:int = 200;
				
				if ( numFrames < 240 )
					L = 20;
				shape.graphics.lineStyle( 1, 0xFFFFFF * Math.random() );
				
				shape.graphics.moveTo( Math.random() * Starling.current.nativeStage.stageWidth, Math.random() * Starling.current.nativeStage.stageHeight );
				for ( var j:int = 0; j < L; j++ )
				{
					shape.graphics.lineTo( Math.random() * Starling.current.nativeStage.stageWidth, Math.random() * Starling.current.nativeStage.stageHeight );
				}
			}
			
			numFrames++;
		}
	}
}