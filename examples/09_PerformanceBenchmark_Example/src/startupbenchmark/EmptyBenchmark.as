package startupbenchmark 
{
	import starling.display.Image;
	import starling.textures.Texture;
	import starling.core.Starling;
	
	public class EmptyBenchmark extends Benchmark 
	{
		
		protected var _numFrames:int = 0;
		
		[Embed( source = "starling_bird.png" )]
		protected var StarlingBird		:Class;
		protected var birdImage:Image;
		
		public function EmptyBenchmark() 
		{
			
		}
		
		
		override public function get benchmarkName() : String
		{
			return "EmptyBenchmark";
		}
		
		
		override public function isDone() : Boolean
		{
			return (_numFrames > 120 );
		}
		
		override public function startBenchmark() : void
		{
			birdImage = new Image( Texture.fromBitmap(new StarlingBird));
			
			birdImage.x = (Starling.current.nativeStage.stageWidth - birdImage.width) / 2;
			birdImage.y = (Starling.current.nativeStage.stageHeight - birdImage.height) / 2 - 60;
			
			addChild(birdImage);
		}
		
		override public function updateBenchmark() : void
		{
			_numFrames++;
		}
		
		override public function endBenchmark() : void
		{
			removeChild(birdImage);
		}
			
	}

}