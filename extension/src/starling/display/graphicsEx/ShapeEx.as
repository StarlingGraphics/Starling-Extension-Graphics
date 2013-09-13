package starling.display.graphicsEx
{
	import starling.display.Graphics;
	import starling.display.DisplayObjectContainer;
	
	public class ShapeEx extends DisplayObjectContainer
	{
		private var _graphics :GraphicsEx;
		
		public function ShapeEx()
		{
			_graphics = new GraphicsEx(this);
		}
		
		public function get graphics():GraphicsEx
		{
			return _graphics;
		}
	}
}