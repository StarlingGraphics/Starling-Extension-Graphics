package
{
	import boxbenchmark.BoxesShapeBenchmark;
	
	import fillbenchmark.FillBenchmark;
	
	import starling.core.Starling;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.display.graphics.FastStroke;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.utils.HAlign;
	
	import startupbenchmark.EmptyBenchmark;
	
	import strokebenchmark.FastStrokeBenchmark;
	import strokebenchmark.StrokeBenchmark;
	
	import strokegraphicsbenchmark.StrokeGraphicsBenchmark;
	
	import trifanbenchmark.TriangleFanBenchmark;
	
	import tristripbenchmark.TriangleStripBenchmark;

	public class BenchmarkMaster extends Sprite
	{
		protected var _benchmarks:Vector.<Benchmark>;

		protected var _currentBenchmark:Benchmark = null;
		protected var _currentBenchmarkIndex:int = -1;

		protected var _textField:TextField;
		protected var _results:Vector.<TextField>;

		public function BenchmarkMaster()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAdded);

			_benchmarks = new Vector.<Benchmark>();

//			_benchmarks.push(new EmptyBenchmark());
			_benchmarks.push(new FastStrokeBenchmark());
			_benchmarks.push(new StrokeBenchmark());
			_benchmarks.push(new StrokeGraphicsBenchmark());

//			_benchmarks.push(new TriangleStripBenchmark());
//			_benchmarks.push(new TriangleFanBenchmark());

//			_benchmarks.push(new BoxesShapeBenchmark());
//			_benchmarks.push(new FillBenchmark());
		}

		protected function onAdded ( e:Event ):void
		{
			addEventListener(EnterFrameEvent.ENTER_FRAME, enterFrameHandler);

			var quad:Quad = new Quad(300, 30, 0);
			quad.alpha = 0.75;
			quad.y = 0;
			quad.x = stage.stageWidth - 300;
			addChild(quad);

			_textField = new TextField(300, 30, "", "Verdana", 20, 0xFF0000);
			addChild(_textField);
			_textField.y = 0;
			_textField.x = stage.stageWidth - 300;
			
			_results = new Vector.<TextField>;

		}

		protected function initBenchmark() : Boolean
		{
			_currentBenchmarkIndex++;

			if ( _currentBenchmark != null )
			{
				_currentBenchmark.endBenchmark();
				removeChild(_currentBenchmark);
				_currentBenchmark = null;
			}

			if ( _currentBenchmarkIndex >= _benchmarks.length )
			{
				return false;
			}

			_currentBenchmark = _benchmarks[_currentBenchmarkIndex];

			if ( _currentBenchmark != null )
			{
				addChildAt(_currentBenchmark, 0);
				_textField.text = _currentBenchmark.benchmarkName;
				_currentBenchmark.startBenchmark();
			}
			return true;
		}

		private function addResultText( text:String, yLoc:Number ):void
		{
			var textField:TextField = new TextField(stage.stageWidth, 30, text, "Verdana", 16, 0xFF0000);
			textField.x = 0;
			textField.y = yLoc;
			textField.hAlign = HAlign.CENTER;
			_results.push(textField);
			addChild(textField);
			
		}

		protected function enterFrameHandler( event:EnterFrameEvent ):void
		{
			if ( _currentBenchmark == null || _currentBenchmark.isDone() )
			{
				if ( initBenchmark() == false )
				{
					var yLoc:Number = 30.0;
					addResultText("Average CPU times (Lower is better)", yLoc);
					yLoc += 30.0;
					for each (var benchmark:Benchmark in _benchmarks)
					{
						var numCalls:uint = benchmark.getNumCalls();
						if (numCalls > 0) {
							var average:Number = benchmark.getAverageUpdateDuration();
							var renderAverage:Number = benchmark.getAverageRenderDuration();
							average = int(average * 100)/100;
							renderAverage = int(renderAverage * 100)/100;
							var text:String = benchmark.benchmarkName + ": " + average + " Render: " + renderAverage;
							addResultText(text, yLoc);
							yLoc += 30.0;
						}
					}

					removeEventListener(EnterFrameEvent.ENTER_FRAME, enterFrameHandler); // We are done
					return;
				}
			}

			if ( _currentBenchmark != null )
				_currentBenchmark.updateBenchmark();

		}
	}

}