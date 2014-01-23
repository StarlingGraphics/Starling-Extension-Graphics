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
		
		private var startTime		:int;
		private var numFrames:int = 0;
				
		private var randomArray:Vector.<Number>;
		private var currentRandom:int;
		private var maxRandom:int = 101797;
		
		public function StrokeBenchmark( )
		{
			
		}
		
		override public function startBenchmark() : void
		{
			stroke = new Stroke();
			addChild(stroke);
			stage.color = 0xFFFFFF;
			
			randomArray = new Vector.<Number>(maxRandom, true);
			for ( var i:int = 0; i < maxRandom; i++ )
				randomArray[i] = Math.random();
			currentRandom = 0;
		}
		
		override public function endBenchmark() : void
		{
			stroke.dispose();
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
	
			var L:int = 200;
				
			if ( numFrames < 240 )
				L = 20;
			var numVerts:int = L * 100 + Math.random() * 50;
			
			stroke.clear();
			
			var Width:int = Starling.current.nativeStage.stageWidth;
			var Height:int = Starling.current.nativeStage.stageHeight;
			var xVal:Number;
			var yVal:Number;
			var color1:int ;
			var color2:int;
			var i:int;
			var j:int;
			
			for ( i = 0; i < numVerts; i++ )
			{
				if ( currentRandom + 4 > maxRandom )
					currentRandom = 0;
					
				xVal = Width * randomArray[currentRandom++];
				yVal = Height * randomArray[currentRandom++];
				color1 = randomArray[currentRandom++] * 0xFFFFFF;
				color2 = randomArray[currentRandom++] * 0xFFFFFF;
					
				stroke.addVertex( xVal, yVal, 1, color1, 1, color2 , 1);
			}
			numFrames++;
		}
	}
}