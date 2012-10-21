package starling.display.graphics
{
	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.textures.Texture;
	
	public class TriangleFan extends Graphic
	{
		private static const VERTEX_STRIDE	:int = 9;
		
		private var vertices		:Vector.<Number>;
		private var _numVertices	:int;
		private var indices			:Vector.<uint>;
		
		public function TriangleFan()
		{
			vertices = new Vector.<Number>();
			indices = new Vector.<uint>();
		}
		
		public function addVertex( 	x:Number, y:Number, color:uint = 0xFFFFFF, alpha:Number = 1, u:Number = 0, v:Number = 0 ):void
		{
			if ( vertexBuffer )
			{
				vertexBuffer.dispose();
				vertexBuffer = null;
			}
			
			if ( indexBuffer )
			{
				indexBuffer.dispose();
				indexBuffer = null;
			}
			
			var r:Number = (color >> 16) / 255;
			var g:Number = ((color & 0x00FF00) >> 8) / 255;
			var b:Number = (color & 0x0000FF) / 255;
			
			vertices.push( x, y, 0, r, g, b, alpha, u, v );
			_numVertices++;
			
			if ( _numVertices < 3 )
			{
				indices.push( _numVertices-1 );
			}
			else
			{
				indices.push( 0, _numVertices - 2, _numVertices - 1 );
			}
			
			minBounds.x = x < minBounds.x ? x : minBounds.x;
			minBounds.y = y < minBounds.y ? y : minBounds.y;
			maxBounds.x = x > maxBounds.x ? x : maxBounds.x;
			maxBounds.y = y > maxBounds.y ? y : maxBounds.y;
		}
		
		override public function render( renderSupport:RenderSupport, alpha:Number ):void
		{
			if ( _numVertices < 3 ) return;
			
			if ( vertexBuffer == null )
			{
				vertexBuffer = Starling.context.createVertexBuffer( _numVertices, VERTEX_STRIDE );
				vertexBuffer.uploadFromVector( vertices, 0, _numVertices )
				indexBuffer = Starling.context.createIndexBuffer( indices.length );
				indexBuffer.uploadFromVector( indices, 0, indices.length );
			}
			
			super.render( renderSupport, alpha );
		}
	}
}