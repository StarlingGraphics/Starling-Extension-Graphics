package starling.display.graphics
{
	import starling.textures.Texture;
	
	public class Stroke extends Graphic
	{
		private var lines				:Vector.<Vector.<StrokeVertex>>;
		private var _currLine			:Vector.<StrokeVertex>;
		private var _numVertices		:int;
		
		public function Stroke()
		{
			clear();
		}
		
		public function get numVertices():int
		{
			return _numVertices;
		}
		
		override public function dispose():void
		{
			clear();
			lines = null;
			super.dispose();
		}

		public function clear():void
		{
			if(minBounds)
			{
				minBounds.x = minBounds.y = Number.POSITIVE_INFINITY; 
				maxBounds.x = maxBounds.y = Number.NEGATIVE_INFINITY;
			}
			
			if ( lines )
			{
				var L:int = lines.length;
				for ( var i:int = 0; i < L; i++ )
				{
					StrokeVertex.returnInstances(lines[i]);
				}
			}
			lines = new Vector.<Vector.<StrokeVertex>>();
			_currLine = null;
			_numVertices = 0;
			isInvalid = true;
		}
		
		public function addBreak():void
		{
			_currLine = null;
			_numVertices = 0;
		}
		
		public function addVertex( 	x:Number, y:Number, thickness:Number = 1,
									color0:uint = 0xFFFFFF,  alpha0:Number = 1,
									color1:uint = 0xFFFFFF, alpha1:Number = 1 ):void
		{
			if ( _currLine == null )
			{
				_currLine = lines[lines.length] = new Vector.<StrokeVertex>();
				_numVertices = 0;
			}
			
			var u:Number = 0;
			var textures:Vector.<Texture> = _material.textures;
			if ( _currLine.length > 0 && textures.length > 0 )
			{
				var prevVertex:StrokeVertex = _currLine[_currLine.length - 1];
				var dx:Number = x - prevVertex.x;
				var dy:Number = y - prevVertex.y;
				var d:Number = Math.sqrt(dx*dx+dy*dy);
				u = prevVertex.u + (d / textures[0].width);
			}
			
			var r0:Number = (color0 >> 16) / 255;
			var g0:Number = ((color0 & 0x00FF00) >> 8) / 255;
			var b0:Number = (color0 & 0x0000FF) / 255;
			var r1:Number = (color1 >> 16) / 255;
			var g1:Number = ((color1 & 0x00FF00) >> 8) / 255;
			var b1:Number = (color1 & 0x0000FF) / 255;
			
			var v:StrokeVertex = _currLine[_numVertices] = StrokeVertex.getInstance();
			v.x = x;
			v.y = y;
			v.r1 = r0;
			v.g1 = g0;
			v.b1 = b0;
			v.a1 = alpha0;
			v.r2 = r1;
			v.g2 = g1;
			v.b2 = b1;
			v.a2 = alpha1;
			v.u = u;
			v.v = 0;
			v.thickness = thickness;
			_numVertices++;
			
			if(x < minBounds.x) 
			{
				minBounds.x = x;
			}
			else if(x > maxBounds.x)
			{
				maxBounds.x = x;
			}
			
			if(y < minBounds.y)
			{
				minBounds.y = y;
			}
			else if(y > maxBounds.y)
			{
				maxBounds.y = y;
			}
			
			isInvalid = true;
		}
		
		override protected function buildGeometry():void
		{
			vertices = new Vector.<Number>();
			indices = new Vector.<uint>();
			var indexOffset:int = 0;
			var L:int = lines.length;
			const oneOverVertexStride:Number = 1/VERTEX_STRIDE;
			for ( var i:int = 0; i < L; i++ )
			{
				var oldVerticesLength:int = vertices.length;
				createPolyLine( lines[i], vertices, indices, indexOffset );
				indexOffset += (vertices.length-oldVerticesLength) * oneOverVertexStride;
			}
		}
		
		///////////////////////////////////
		// Static helper methods
		///////////////////////////////////
		[inline]
		private static function createPolyLine( vertices:Vector.<StrokeVertex>, 
												outputVertices:Vector.<Number>, 
												outputIndices:Vector.<uint>, 
												indexOffset:int ):void
		{
			
			var sqrt:Function = Math.sqrt;
			var sin:Function = Math.sin;
			const numVertices:int = vertices.length;
			const PI:Number = Math.PI;
			
			for ( var i:int = 0; i < numVertices; i++ )
			{
				var v1:StrokeVertex = vertices[i];
				var v0:StrokeVertex
				if ( i > 0 )
				{
					v0 = vertices[i - 1];
				}
				else
				{
					v0 = v1.clone();
				}
				var v2:StrokeVertex
				if ( i < numVertices-1 )
				{
					v2 = vertices[i + 1];
				}
				else
				{
					v2 = v1.clone();
				}
				
				var v0x:Number = v0.x;
				var v0y:Number = v0.y;
				var v1x:Number = v1.x;
				var v1y:Number = v1.y;
				var v2x:Number = v2.x;
				var v2y:Number = v2.y;
				
				var d0x:Number = v1x - v0x;
				var d0y:Number = v1y - v0y;
				var d1x:Number = v2x - v1x;
				var d1y:Number = v2y - v1y;
				
				if ( i == numVertices - 1 )
				{
					v2x += d0x;
					v2y += d0y;
					
					d1x = v2x - v1x;
					d1y = v2y - v1y;
				}
				
				if ( i == 0 )
				{
					v0x -= d1x;
					v0y -= d1y;
					
					d0x = v1x - v0x;
					d0y = v1y - v0y;
				}
				
				var d0:Number = sqrt( d0x*d0x + d0y*d0y );
				var d1:Number = sqrt( d1x*d1x + d1y*d1y );
				
				var elbowThickness:Number = v1.thickness*0.5;
				if ( i > 0 && i < numVertices-1 )
				{
					// Thanks to Tom Clapham for spotting this relationship.
					var dot:Number = (d0x*d1x+d0y*d1y) / (d0*d1);
					elbowThickness /= sin((PI-Math.acos(dot)) * 0.5);
					
					if ( elbowThickness > v1.thickness * 4 )
					{
						elbowThickness = v1.thickness * 4;
					}
					
					if ( isNaN( elbowThickness ) )
					{
						elbowThickness = v1.thickness*0.5;
					}
				}
				
				var n0x:Number = -d0y / d0;
				var n0y:Number =  d0x / d0;
				var n1x:Number = -d1y / d1;
				var n1y:Number =  d1x / d1;
				
				var cnx:Number = n0x + n1x;
				var cny:Number = n0y + n1y;
				var c:Number = (1/sqrt( cnx*cnx + cny*cny )) * elbowThickness;
				cnx *= c;
				cny *= c;
				
				outputVertices.push( v1x + cnx, v1y + cny, 0, v1.r2, v1.g2, v1.b2, v1.a2, v1.u, 1,
									 v1x - cnx, v1y - cny, 0, v1.r1, v1.g1, v1.b1, v1.a1, v1.u, 0 );
			
				
				if ( i < numVertices - 1 )
				{
					var i2:int = indexOffset + (i << 1);
					outputIndices.push(i2, i2 + 2, i2 + 1, i2 + 1, i2 + 2, i2 + 3);
				}
			}
		}
	}
}

internal class StrokeVertex
{
	public var x		:Number;
	public var y		:Number;
	public var u		:Number;
	public var v		:Number;
	public var r1		:Number;
	public var g1		:Number;
	public var b1		:Number;
	public var a1		:Number;
	public var r2		:Number;
	public var g2		:Number;
	public var b2		:Number;
	public var a2		:Number;
	public var thickness:Number;
	
	public function StrokeVertex()
	{
		
	}
	
	public function clone():StrokeVertex
	{
		var vertex:StrokeVertex = getInstance();
		vertex.x = x;
		vertex.y = y;
		vertex.r1 = r1;
		vertex.g1 = g1;
		vertex.b1 = b1;
		vertex.a1 = a1;
		vertex.u = u;
		vertex.v = v;
		return vertex;
	}
	
	private static var pool:Vector.<StrokeVertex> = new Vector.<StrokeVertex>();
	private static var poolLength:int = 0;
	
	public static function getInstance():StrokeVertex
	{
		if ( poolLength == 0 ) 
		{
			return new StrokeVertex();
		}
		poolLength--;
		return pool.pop();
	}
	
	public static function returnInstance( instance:StrokeVertex ):void
	{
		pool[poolLength] = instance;
		poolLength++;
	}
	
	public static function returnInstances( instances:Vector.<StrokeVertex> ):void
	{
		var L:int = instances.length;
		for ( var i:int = 0; i < L; i++ )
		{
			pool[poolLength] = instances[i];
			poolLength++;
		}
	}
}
