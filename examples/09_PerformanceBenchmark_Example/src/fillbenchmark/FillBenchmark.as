package fillbenchmark 
{
	import flash.utils.getTimer;
	
	import starling.core.Starling;
	import starling.display.Shape;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;
	
	public class FillBenchmark extends Benchmark 
	{
		protected var shape:starling.display.Shape;
		protected var numFrames:int = 0;
		protected var maxVerts:int = 500;
		
		[Embed( source = "Checker.png" )]
		protected var CheckerBMP		:Class;
		
		protected var checkerTexture:Texture;
		
		public function FillBenchmark() 
		{
			
		}
		
		override public function get benchmarkName() : String
		{
			return "FillBenchmark";
		}
		
		
		override public function startBenchmark() : void
		{
			shape = new Shape();
			
			checkerTexture = Texture.fromBitmap(new CheckerBMP);
			
			addChild(shape);
			
		}
		
		override public function endBenchmark() : void
		{
			
		}
		
		override public function isDone() : Boolean
		{
			return ( numFrames > 480 );
		}
		
		override public function updateBenchmark( ):void
		{
			shape.graphics.clear();
			
			var startTime:int = getTimer();
			if ( numFrames < 240 )
			{
				shape.graphics.beginTextureFill( checkerTexture , null, 0x36E44A, Math.random());
			}
			else
			{
				maxVerts = 2000;
				shape.graphics.beginTextureFill( checkerTexture , null, 0xE436DA, Math.random());
			}	
			
			for ( var i:int = 0; i < maxVerts; i++ )
			{
				shape.graphics.lineTo( Math.random() * Starling.current.nativeStage.stageWidth, Math.random() * Starling.current.nativeStage.stageHeight );
			}
			
			shape.graphics.endFill();
			addTiming(getTimer() - startTime);
			
			numFrames++;
			
		}
	}

}