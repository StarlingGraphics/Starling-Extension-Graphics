package
{
	import flash.utils.getTimer;
	
	import starling.core.RenderSupport;
	import starling.display.Sprite;

	public class Benchmark  extends Sprite
	{
		private var timings:Array;
		private var renderTimings:Array;

		public function Benchmark()
		{
			timings = new Array;
			renderTimings = new Array;
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

		private function getAverageTimings(array:Array):Number {
			var scale:Number = 1.0 / Number(array.length);
			var avg:Number = 0.0;
			for (var i:uint = 0; i < array.length; i++)
			{
				avg += array[i] * scale;
			}
			return avg;
		}

		public function getAverageUpdateDuration():Number
		{
			return getAverageTimings(timings);
		}

		public function getAverageRenderDuration():Number
		{
			return getAverageTimings(renderTimings);
		}

		override public function render(support:RenderSupport, parentAlpha:Number):void
		{
			var start:int = getTimer();
			super.render(support, parentAlpha);
			renderTimings.push(getTimer() - start);
		}
	}
}