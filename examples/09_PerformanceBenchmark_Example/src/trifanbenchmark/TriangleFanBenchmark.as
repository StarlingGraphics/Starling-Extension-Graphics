package trifanbenchmark 
{
	import starling.display.graphics.TriangleFan;
	
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.events.Event;

	public class TriangleFanBenchmark extends Benchmark 
	{
		protected var triFan			:TriangleFan;
		protected var startTime		:int;
		protected var numFrames:int = 0;
		protected var maxFrames :int = 480;
		protected var maxVerts:int = 500;
		protected var prevColor:uint;
		
		public function TriangleFanBenchmark() 
		{
			
		}
		
		override public function get benchmarkName() : String
		{
			return "TriangleFanBenchmark";
		}
		
		override public function startBenchmark() : void
		{
			triFan = new TriangleFan();
			
			addChild(triFan);
			
			prevColor = stage.color;
			stage.color = 0;
			
		}
		
		override public function endBenchmark() : void
		{
			stage.color = prevColor;
		}
		
		override public function isDone() : Boolean
		{
			return ( numFrames > maxFrames );
		}
		
		override public function updateBenchmark( ):void
		{
			triFan.clear();
				
			maxVerts = numFrames * 100;
			
			var trigFactor:Number = 0.001;
			
			var midX:Number = 500;
			var midY:Number = 400;
			triFan.addVertex(midX, midY, 0, 0, 1, 1, 1, 1);
			var g:Number = 0.5 * numFrames / maxFrames;
			var b:Number = 0.5 * numFrames / maxFrames;
			for ( var i:int = 0; i < maxVerts; i++ )
			{
				var vX:Number = midX + (400-i*0.008) * Math.cos(i * trigFactor);
				var vY:Number = midY + (400 - i * 0.008) * Math.sin(i * trigFactor);
				
				triFan.addVertex( vX, vY, 0, 0, i / maxVerts, g, b, 1); 
			}
			
			numFrames++;
			
		}
	}

}