package  
{
	import fillbenchmark.FillBenchmark;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import starling.display.graphics.FastStroke;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import startupbenchmark.EmptyBenchmark;
	import tristripbenchmark.TriangleStripBenchmark;
	import trifanbenchmark.TriangleFanBenchmark;
	
	import boxbenchmark.BoxesShapeBenchmark;
	import strokebenchmark.StrokeBenchmark;
	import strokebenchmark.FastStrokeBenchmark;
	import strokegraphicsbenchmark.StrokeGraphicsBenchmark;
	
	import starling.text.TextField;
	import starling.core.Starling;
	import flash.text.TextField;
	
	public class BenchmarkMaster extends Sprite
	{
		protected var _benchmarks:Vector.<Benchmark>;
		
		protected var _currentBenchmark:Benchmark = null;
		protected var _currentBenchmarkIndex:int = -1;
	
		protected var _fastStroke:FastStroke;
		
		public function BenchmarkMaster() 
		{
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
			
			_benchmarks = new Vector.<Benchmark>();
			
			_benchmarks.push(new EmptyBenchmark());
			_benchmarks.push(new FastStrokeBenchmark());
			_benchmarks.push(new EmptyBenchmark());
			_benchmarks.push(new StrokeBenchmark());
			
			
			
			_benchmarks.push(new TriangleStripBenchmark());
			
			_benchmarks.push(new BoxesShapeBenchmark());
			_benchmarks.push(new StrokeGraphicsBenchmark());
						
			_benchmarks.push(new FillBenchmark());
			_benchmarks.push(new TriangleFanBenchmark());	 
			_benchmarks.push(new EmptyBenchmark());
			
			
			
		}
		
		protected function onAdded ( e:Event ):void
		{	
			
			/*_fastStroke = new FastStroke();
			_fastStroke.clear();
			
			_fastStroke.setCapacity(10);
			_fastStroke.addVertex(100, 100, 1, 0xFF0000, 1);
			_fastStroke.addVertex(200, 100, 1, 0x0000FF, 1);
			_fastStroke.addVertex(250, 200, 1, 0x00FF00, 1);
			_fastStroke.addVertex(300, 200, 1, 0xFF0000, 1);
			_fastStroke.addVertex(400, 200, 1, 0xFF00FF, 1);
			_fastStroke.addVertex(100, 100, 1, 0x00FFFF, 1);
			
			addChild(_fastStroke); */
			
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
				addChildAt(_currentBenchmark, 0);
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