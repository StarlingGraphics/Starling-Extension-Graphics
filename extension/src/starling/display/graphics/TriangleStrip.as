package starling.display.graphics
{
	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.textures.Texture;
	
	public class TriangleStrip extends Graphic
	{
		private var numVertices		:int;
		
		public function TriangleStrip()
		{
			
		}
		
		public function addVertex( 	x:Number, y:Number, 
									u:Number = 0, v:Number = 0, 
									r:Number = 1, g:Number = 1, b:Number = 1, a:Number = 1 ):void
		{
			vertices.push( x, y, 0, r, g, b, a, u, v );
			numVertices++;
			
			minBounds.x = x < minBounds.x ? x : minBounds.x;
			minBounds.y = y < minBounds.y ? y : minBounds.y;
			maxBounds.x = x > maxBounds.x ? x : maxBounds.x;
			maxBounds.y = y > maxBounds.y ? y : maxBounds.y;
			
			if ( numVertices > 2 )
			{
				indices.push( numVertices-3, numVertices-2, numVertices-1 );
			}
			
			setGeometryInvalid();
		}
		
		override protected function buildGeometry():void
		{
			
		}
	}
}