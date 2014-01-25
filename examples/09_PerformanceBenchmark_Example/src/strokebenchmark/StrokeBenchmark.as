package strokebenchmark
{
	import flash.utils.getTimer;
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.display.graphics.Stroke;
	import starling.events.Event;
	
	public class StrokeBenchmark extends Benchmark
	{
		private var stroke			:Stroke = null;
		
		private var allStrokes:Vector.<Stroke>;
		
		private var startTime		:int;
		private var numFrames:int = 0;
				
		private var randomArray:Vector.<Number>;
		private var currentRandom:int;
		private var maxRandom:int = 101797;
		
		public function StrokeBenchmark( )
		{
			
		}
		
		
		override public function get benchmarkName() : String
		{
			return "StrokeBenchmark";
		}
		
		
		override public function startBenchmark() : void
		{
			allStrokes = new Vector.<Stroke>();
			var i:int = 0;
			for ( i = 0; i < 5 ; i++ )
			{
				stroke = new Stroke();
				allStrokes.push(stroke);
				addChild(stroke);
			}
		
			stage.color = 0xFFFFFF;
			
			randomArray = new Vector.<Number>(maxRandom, true);
			for ( i = 0; i < maxRandom; i++ )
				randomArray[i] = Math.random();
			currentRandom = 0;
			
			
		}
		
		override public function endBenchmark() : void
		{
			for ( var si:int = 0;  si < allStrokes.length; si++ )
			{
				stroke = allStrokes[si];
				stroke.dispose();
			}
			stage.color = 0xFFFFFF;
			randomArray = null;
		}
		
		override public function isDone() : Boolean
		{
			return ( numFrames > 480 );
		}
		
		override public function updateBenchmark( ):void
		{
			const STAGE_HEIGHT:Number = Starling.current.nativeStage.stageHeight;
			const STAGE_WIDTH:Number = Starling.current.nativeStage.stageWidth;
	
			var L:int = 200;
			if ( numFrames < 240 )
				L = 20;
			var numVerts:int = L * 50 + Math.random() * 50;
			var numCalls:int = 0;
			for ( var si:int = 0;  si < allStrokes.length; si++ )
			{
				stroke = allStrokes[si];
				stroke.clear();
				for ( var i:int = 0; i < numVerts; i++ )
				{
					if ( currentRandom + 4 > maxRandom )
						currentRandom = 0;
					
					var xVal:Number = STAGE_WIDTH * randomArray[currentRandom++];
					var yVal:Number = STAGE_HEIGHT * randomArray[currentRandom++];
					var color1:uint = randomArray[currentRandom++] * 0xFFFFFF;
					var color2:uint = randomArray[currentRandom++] * 0xFFFFFF;
					
					stroke.addVertex( xVal, yVal, 1, color1, 1, color2, 1);
					numCalls++;
				}
			}
		//	trace("NumCalls: " + numCalls);
			numFrames++;
		}
	}
}