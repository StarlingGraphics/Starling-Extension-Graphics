package strokebenchmark
{
	import flash.system.System;
	import flash.utils.getTimer;

	import starling.core.Starling;
	import starling.display.graphics.Stroke;

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
				stroke = new Stroke(200 * 50 + 50);
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
				L = 10;
			var numVerts:int = L * 50 + 50;//Math.random() * 50;
			var startTime:int = getTimer();
			for ( var si:int = 0;  si < allStrokes.length; si++ )
			{
				stroke = allStrokes[si];
				stroke.clear();
				stroke.moveToFast(100, 100);
				for ( var i:int = 0; i < numVerts; i++ )
				{
					if ( currentRandom + 5 > maxRandom )
						currentRandom = 0;

					var xVal:Number = STAGE_WIDTH * randomArray[currentRandom++];
					var yVal:Number = STAGE_HEIGHT * randomArray[currentRandom++];
					var r0:Number = randomArray[currentRandom++];
					var g0:Number = randomArray[currentRandom++];
					var b0:Number = randomArray[currentRandom++];

					stroke.lineToFast( xVal, yVal, 1, r0, g0, b0, 1);
				}
			}
			addTiming(getTimer() - startTime);
			numFrames++;
		}
	}
}