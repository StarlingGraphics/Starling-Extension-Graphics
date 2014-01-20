package startupbenchmark 
{
	/**
	 * ...
	 * @author Henrik Jonsson
	 */
	public class EmptyBenchmark extends Benchmark 
	{
		
		protected var _numFrames:int = 0;
		
		public function EmptyBenchmark() 
		{
			
		}
		
		override public function isDone() : Boolean
		{
			return (_numFrames > 60 );
		}
		
		override public function startBenchmark() : void
		{
			
		}
		
		override public function updateBenchmark() : void
		{
			_numFrames++;
		}
		
		override public function endBenchmark() : void
		{
			
		}
			
	}

}