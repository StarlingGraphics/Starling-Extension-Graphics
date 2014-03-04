package  
{
	import starling.display.Sprite;
	
	public class Benchmark  extends Sprite
	{
		private var timings:Array;
		
		public function Benchmark() 
		{
			timings = new Array;
		}
		
		public function isDone() : Boolean
		{
			return true;
		}
		
		public function startBenchmark() : void
		{
			
		}
		
		public function updateBenchmark() : void
		{
			
		}
		
		public function endBenchmark() : void
		{
			
		}
		
		public function get benchmarkName() : String
		{
			return "Benchmark Base Class";
		}
		
		public function addTiming(duration:uint):void 
		{
			timings.push(duration);
		}
		
		public function getNumCalls():uint 
		{
			return timings.length;
		}
		
		public function getAverageDuration():Number
		{
			var scale:Number = 1.0 / Number(timings.length);
			var avg:Number = 0.0;
			for (var i:uint = 0; i < timings.length; i++) 
			{
				avg += timings[i] * scale;
			}
			return avg;
		}
	}
}