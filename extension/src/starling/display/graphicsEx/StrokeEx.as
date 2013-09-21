package starling.display.graphicsEx
{
	import flash.display.GraphicsStroke;
	import starling.textures.Texture;
	import starling.display.graphics.Stroke;
	import starling.display.graphics.StrokeVertex;
	
	public class StrokeEx extends Stroke
	{
		protected var _lineLength:Number = 0;
		
		public function StrokeEx()
		{
			super();
		}
		
		// Added to support post processing 
		public function get strokeVertices() : Vector.<StrokeVertex>
		{
			return _line;
		}
		
		override public function clear() : void
		{
			super.clear();
			_lineLength = 0;
		}
		
		public function invalidate() : void
		{
			isInvalid = true;
		}
		
		public function strokeLength() : Number
		{
			if ( _lineLength == 0 )
			{
				if ( _line == null || _line.length < 2 )
					return 0;
				else
					return calcStrokeLength();
			}
			else 
				return _lineLength;
		}
		
		protected function calcStrokeLength() : Number
		{
			if ( _line == null || _line.length < 2 )
				_lineLength = 0;
			else
			{
				var i:int = 1;
				var prevVertex:StrokeVertex = _line[0];
				var thisVertex:StrokeVertex = null;
				
				for ( i = 1 ; i < _numVertices; ++i )
				{
					thisVertex = _line[i];
					
					var dx:Number = thisVertex.x - prevVertex.x;
					var dy:Number = thisVertex.y - prevVertex.y;
					var d:Number = Math.sqrt(dx * dx + dy * dy);
					_lineLength += d;
					prevVertex = thisVertex;
				}
			}
			return _lineLength;
		}
	}
		
}
