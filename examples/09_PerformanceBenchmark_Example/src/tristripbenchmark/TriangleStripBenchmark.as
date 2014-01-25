package tristripbenchmark
{
	import flash.utils.getTimer;
	import starling.display.graphics.TriangleStrip;
	
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.display.graphics.TriangleStrip;
	import starling.events.Event;
	
	public class TriangleStripBenchmark extends Benchmark
	{
		private var triStrip			:TriangleStrip;
		private var startTime		:int;
		private var numFrames:int = 0;
		private var randomArray:Vector.<Number>;
		private var currentRandom:int;
		private var maxRandom:int = 101797;
		public function TriangleStripBenchmark()
		{
			
		}
		
		override public function get benchmarkName() : String
		{
			return "TriangleStripBenchmark";
		}
		
		override public function startBenchmark() : void
		{
			triStrip = new TriangleStrip();
			addChild(triStrip);
			randomArray = new Vector.<Number>(maxRandom, true);
			for ( var i:int = 0; i < maxRandom; i++ )
				randomArray[i] = Math.random();
			currentRandom = 0;
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
			const STAGE_WIDTH:Number =  Starling.current.nativeStage.stageWidth;
			
			triStrip.clear();
			
			var lastX:Number = 0;
			var lastY:Number = 0;
			
			var loops:Number = 50.0;
			
			for ( var i:int = 0; i < loops; i++ )
			{
				var L:int = 200;
				
				lastY += STAGE_HEIGHT / loops;
				
				if ( numFrames < 240 )
					L = 20;
				
				lastX = 0;
				
				for ( var j:int = 0; j < L; j++ )
				{
					if ( currentRandom + 12 > maxRandom )
						currentRandom = 0;
					
					triStrip.addVertex( lastX, lastY, 0, 0, randomArray[currentRandom++] , randomArray[currentRandom++], randomArray[currentRandom++], 1 );
					triStrip.addVertex( lastX, lastY + STAGE_HEIGHT / loops, 0, 0, randomArray[currentRandom++] , randomArray[currentRandom++], randomArray[currentRandom++], 1 );
					triStrip.addVertex( lastX + STAGE_WIDTH / L, lastY , 0, 0, randomArray[currentRandom++] , randomArray[currentRandom++], randomArray[currentRandom++], 1 );
					triStrip.addVertex( lastX + STAGE_WIDTH / L, lastY+ STAGE_HEIGHT / loops , 0, 0, randomArray[currentRandom++], randomArray[currentRandom++], randomArray[currentRandom++], 1 );

					lastX += STAGE_WIDTH / L; 
				}
				
				triStrip.addVertex(lastX + STAGE_WIDTH / L, lastY + STAGE_HEIGHT / loops , 0, 0, 1, 1, 1, 0) 
				triStrip.addVertex(0, lastY+ STAGE_HEIGHT / loops , 0, 0, 1, 1, 1, 0) 
			}
			
			numFrames++;
		}
	}
}