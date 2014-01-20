package strokebenchmark
{
	import flash.utils.getTimer;
	
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.display.graphics.Stroke;
	import starling.events.Event;
	
	public class StrokeBenchmark extends Benchmark
	{
		private var stroke			:Stroke;
		private var startTime		:int;
		private var numFrames:int = 0;
		
		public function StrokeBenchmark()
		{
			
		}
		
		override public function startBenchmark() : void
		{
			stroke = new Stroke();
			addChild(stroke);
			
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
	
			stroke.clear();
			
			
			for ( var i:int = 0; i < 100; i++ )
			{
				var L:int = 200;
				
				if ( numFrames < 240 )
					L = 20;
				for ( var j:int = 0; j < L; j++ )
				{
					stroke.addVertex( Math.random() * Starling.current.nativeStage.stageWidth, Math.random() * Starling.current.nativeStage.stageHeight, 1, Math.random() * 0xFFFFFF, 1, Math.random() * 0xFFFFFF, 1 );
				}
			}
			
			numFrames++;
		}
	}
}