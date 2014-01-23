package  
{
	import fillbenchmark.FillBenchmark;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import startupbenchmark.EmptyBenchmark;
	import tristripbenchmark.TriangleStripBenchmark;
	import trifanbenchmark.TriangleFanBenchmark;
	
	import boxbenchmark.BoxesShapeBenchmark;
	import strokebenchmark.StrokeBenchmark;
	import strokegraphicsbenchmark.StrokeGraphicsBenchmark;
	
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
			_benchmarks.push(new StrokeGraphicsBenchmark());
			_benchmarks.push(new TriangleStripBenchmark());			
			_benchmarks.push(new FillBenchmark());
			_benchmarks.push(new TriangleFanBenchmark());	 
			_benchmarks.push(new EmptyBenchmark());
		}
		
		protected function onAdded ( e:Event ):void
		{		
			addEventListener(EnterFrameEvent.ENTER_FRAME, enterFrameHandler);
		}
		
		protected function initBenchmark() : Boolean
		{
			_currentBenchmarkIndex++;
			
			if ( _currentBenchmarkIndex >= _benchmarks.length )
				return false;
			
			if ( _currentBenchmark != null )
			{
				_currentBenchmark.endBenchmark();
				removeChild(_currentBenchmark);
				_currentBenchmark = null;
			}
				
			_currentBenchmark = _benchmarks[_currentBenchmarkIndex];
			
			if ( _currentBenchmark != null )
			{
				addChild(_currentBenchmark);
				_currentBenchmark.startBenchmark();
			}
			return true;
		}
		
		protected function enterFrameHandler( event:EnterFrameEvent ):void
		{
			if ( _currentBenchmark == null || _currentBenchmark.isDone() )
			{
				if ( initBenchmark() == false )
				{
					removeEventListener(EnterFrameEvent.ENTER_FRAME, enterFrameHandler); // We are done
					return;
				}
			}

			if ( _currentBenchmark != null )
				_currentBenchmark.updateBenchmark();
			
			
		}
	}

}