package starling.display.geom 
{
	import starling.geom.Polygon;
	
	/**
	 * ...
	 * @author IonSwitz
	 */
	public class GraphicsPolygon extends Polygon 
	{
		protected var indices : Vector.<uint>;
		
		public var lastVertexIndex:int = -1;
		public var lastIndexIndex:int = -1;
	//	protected var lastTriangulatedIndex:int = -1;
		
		public function GraphicsPolygon(vertices:Array=null, gfxIndices:Vector.<uint> = null) 
		{
			super(vertices);
			if ( vertices )
			{
				lastVertexIndex = vertices.length -1;
			}
			
			if ( gfxIndices )
			{
				indices = gfxIndices.slice();
				lastIndexIndex = indices.length;
			}
			else
				indices = new Vector.<uint>();
			
			
		}

		public function append(vertices:Array, gfxIndices:Vector.<uint> ) : void
		{
			var i:int;
			var num:int = vertices.length;
			if ( num == 0 )
				return;
			
			if ( lastVertexIndex == -1 ) 
				lastVertexIndex = 0;	
				
			for ( i = 0; i < num; i++)
			{
				addVertices(vertices[i]);
			}
			lastVertexIndex += num/2;
			
			var startIndex:int = lastIndexIndex == -1 ? 0 : lastIndexIndex;
			num = gfxIndices.length;
			for ( i = startIndex; i < num; i++ )
			{
				indices.push(gfxIndices[i]);
			}
			
			lastIndexIndex = indices.length;
			 
		}
		
		
		override public function triangulate(result:Vector.<uint>=null):Vector.<uint>
        {
            if (result == null) result = new <uint>[];
			var numIndices:int = indices.length;
			
	//		var startIndex:int = lastTriangulatedIndex <= 0 ? 0: lastTriangulatedIndex;
			for ( var i:int = 0; i < numIndices; i++ )
				result.push(indices[i]);
			
	//		lastTriangulatedIndex = numIndices - 1;
			
			return result;
		}
		
		 /** Indicates if the polygon's line segments are not self-intersecting. */
        override public function get isSimple():Boolean
        {
			return true;
		}
	}

}