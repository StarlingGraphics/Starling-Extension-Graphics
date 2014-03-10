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
		private var randomArray:Vector.<Number>;
		private var currentRandom:int;
		private var maxRandom:int = 101797;
		public function StrokeGraphicsBenchmark()
		{
			
		}
		
		override public function get benchmarkName() : String
		{
			return "StrokeGraphicsBenchmark";
		}
		
		override public function startBenchmark() : void
		{
			shape = new Shape();
			addChild(shape );
			randomArray = new Vector.<Number>(maxRandom, true);
			for ( var i:int = 0; i < maxRandom; i++ )
				randomArray[i] = Math.random();
			currentRandom = 0;
			
			stage.color = 0x000000;
		}
		
		override public function endBenchmark() : void
		{
			stage.color = 0xFFFFFF;
		}
		
		override public function isDone() : Boolean
		{
			return ( numFrames > 480 );
		}
		
		override public function updateBenchmark( ):void
		{
			const STAGE_HEIGHT:Number = Starling.current.nativeStage.stageHeight;
			const STAGE_WIDTH:Number = Starling.current.nativeStage.stageWidth;
	
			shape.graphics.clear();
			shape.graphics.lineStyle( 1, 0xFFFFFF );
			var L:int = 80;
				
			if ( numFrames < 240 )
				L = 10;

			var numVerts:int = L * 50 + Math.random() * 50;
			var startTime:int = getTimer();
			for ( var i:int = 0; i < 5; i++ )
			{
				shape.graphics.lineStyle( 1, 0xFFFFFF * Math.random() );
				
				shape.graphics.moveTo( Math.random() * Starling.current.nativeStage.stageWidth, Math.random() * Starling.current.nativeStage.stageHeight );
				for ( var j:int = 0; j < numVerts; j++ )
				{
					if ( currentRandom + 2 > maxRandom )
						currentRandom = 0;
				
					var xVal:Number = STAGE_WIDTH * randomArray[currentRandom++];
					var yVal:Number = STAGE_HEIGHT * randomArray[currentRandom++];
					
					shape.graphics.lineTo( xVal, yVal);
				}
			}
			addTiming(getTimer() - startTime);
			
			numFrames++;
		}
	}
}