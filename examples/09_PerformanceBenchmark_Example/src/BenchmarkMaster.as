package  
{
	import fillbenchmark.FillBenchmark;
	import starling.display.Sprite;
	import starling.events.Event;
	import startupbenchmark.EmptyBenchmark;
	import tristripbenchmark.TriangleStripBenchmark;
	
	import boxbenchmark.BoxesShapeBenchmark;
	import strokebenchmark.StrokeBenchmark;
	
	public class BenchmarkMaster extends Sprite
	{
		protected var _benchmarks:Vector.<Benchmark>;
		
		protected var _currentBenchmark:Benchmark = null;
		protected var _currentBenchmarkIndex:int = -1;
		
		public function BenchmarkMaster() 
		{
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
			_benchmarks = new Vector.<Benchmark>();
			_benchmarks.push(new EmptyBenchmark());
			_benchmarks.push(new StrokeBenchmark());
			_benchmarks.push(new BoxesShapeBenchmark());
			_benchmarks.push(new TriangleStripBenchmark());			
			_benchmarks.push(new FillBenchmark());
		}
		
		protected function onAdded ( e:Event ):void
		{		
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		protected function initBenchmark() : void
		{
			if ( _currentBenchmark != null )
			{
				_currentBenchmark.endBenchmark();
				removeChild(_currentBenchmark);
				_currentBenchmark = null;
			}
			_currentBenchmarkIndex++;
			if ( _currentBenchmarkIndex >= _benchmarks.length )
				return;
				
			_currentBenchmark = _benchmarks[_currentBenchmarkIndex];
			
			if ( _currentBenchmark != null )
			{
				addChild(_currentBenchmark);
				_currentBenchmark.startBenchmark();
			}
		}
		
		protected function enterFrameHandler( event:Event ):void
		{
			if ( _currentBenchmark == null || _currentBenchmark.isDone() )
			{
				initBenchmark();
			}
			if ( _currentBenchmark != null )
				_currentBenchmark.updateBenchmark();
			
			
		}
	}

}