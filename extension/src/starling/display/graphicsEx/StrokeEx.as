package starling.display.graphicsEx
{
	import starling.textures.Texture;
	import starling.display.graphics.Stroke;
	import starling.display.graphics.StrokeVertex;
	
	public class StrokeEx extends Stroke
	{
		public function StrokeEx()
		{
			super();
		}
		
		// Added to support post processing 
		public function get strokeVertices() : Vector.<StrokeVertex>
		{
			return _line;
		}
		
		public function invalidate() : void
		{
			isInvalid = true;
		}
		
	}
		
}
