package starling.display.graphics
{
	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.textures.Texture;
	
	public class TriangleFan extends Graphic
	{
		private var numVertices		:int;
		
		public function TriangleFan()
		{
			vertices.push(0,0,0,1,1,1,1,0,0);
			numVertices++;
		}
		
		public function addVertex( 	x:Number, y:Number, u:Number = 0, v:Number = 0 ):void
		{
			vertices.push( x, y, 0, 1, 1, 1, 1, u, v );
			numVertices++;
			
			minBounds.x = x < minBounds.x ? x : minBounds.x;
			minBounds.y = y < minBounds.y ? y : minBounds.y;
			maxBounds.x = x > maxBounds.x ? x : maxBounds.x;
			maxBounds.y = y > maxBounds.y ? y : maxBounds.y;
			
			if ( numVertices > 2 )
			{
				indices.push( 0, numVertices-2, numVertices-1 );
			}
			
			isInvalid = true;
		}
		
		override protected function buildGeometry():void
		{
			
		}
	}
}