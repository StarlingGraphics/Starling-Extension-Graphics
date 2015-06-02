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
		
		public function GraphicsPolygon(vertices:Array=null, indices:Vector.<uint> = null) 
		{
			super(vertices);
			this.indices = indices.slice();
		}

		override public function triangulate(result:Vector.<uint>=null):Vector.<uint>
        {
        
            if (result == null) result = new <uint>[];
			var numIndices:int = indices.length;
			for ( var i:int = 0; i < numIndices; i++ )
				result[i] = indices[i];
			return result;
			
		}
		
		 /** Indicates if the polygon's line segments are not self-intersecting. */
        override public function get isSimple():Boolean
        {
			return true;
		}
	}

}