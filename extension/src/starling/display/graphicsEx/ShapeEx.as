package starling.display.graphicsEx
{
	import starling.display.Graphics;
	import starling.display.DisplayObjectContainer;
	
	public class ShapeEx extends DisplayObjectContainer
	{
		private var _graphics :GraphicsEx;
		
		public function ShapeEx(strokeCullDistance:Number = 0)
		{
			_graphics = new GraphicsEx(this, strokeCullDistance);
		}
		
		public function get graphics():GraphicsEx
		{
			return _graphics;
		}
	}
}