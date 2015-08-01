package starling.display.graphics
{
	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.textures.Texture;
	import starling.display.graphics.util.TriangleUtil;
	
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
			
			if ( buffersInvalid == false )
				setGeometryInvalid();
		}
		
		public function clear():void
		{
			vertices.length = 0;
			indices.length = 0;
			numVertices =  0;
			setGeometryInvalid();
		}
		
		override protected function shapeHitTestLocalInternal( localX:Number, localY:Number ):Boolean
		{
			var numIndices:int = indices.length;
			if ( numIndices < 2 )
				return false;
				
			for ( var i:int = 2; i < numIndices; i+=3 )
			{ // slower version - should be complete though. For all triangles, check if point is in triangle
				var i0:int = indices[(i - 2)];
				var i1:int = indices[(i - 1)];
				var i2:int = indices[(i - 0)];
				
				var v0x:Number = vertices[VERTEX_STRIDE * i0 + 0];
				var v0y:Number = vertices[VERTEX_STRIDE * i0 + 1];
				var v1x:Number = vertices[VERTEX_STRIDE * i1 + 0];
				var v1y:Number = vertices[VERTEX_STRIDE * i1 + 1];
				var v2x:Number = vertices[VERTEX_STRIDE * i2 + 0];
				var v2y:Number = vertices[VERTEX_STRIDE * i2 + 1];
				if ( TriangleUtil.isPointInTriangleBarycentric(v0x, v0y, v1x, v1y, v2x, v2y, localX, localY) )
					return true;
				if ( _precisionHitTestDistance > 0 )
				{
					if ( TriangleUtil.isPointOnLine(v0x, v0y, v1x, v1y, localX, localY, _precisionHitTestDistance) )
						return true;
					if ( TriangleUtil.isPointOnLine(v0x, v0y, v2x, v2y, localX, localY, _precisionHitTestDistance) )
						return true;
					if ( TriangleUtil.isPointOnLine(v1x, v1y, v2x, v2y, localX, localY, _precisionHitTestDistance) )
						return true;
				}
			}
			return false;
		}
		
		override protected function buildGeometry():void
		{
			
		}
	}
}
