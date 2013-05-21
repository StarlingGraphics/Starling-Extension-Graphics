package starling.display.graphics
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	public class Fill extends Graphic
	{
		public static const VERTEX_STRIDE	:int = 9;
		
		private var fillVertices	:VertexList;
		private var _numVertices	:int;
		
		public function Fill()
		{
			clear();
			
			_uvMatrix = new Matrix();
			_uvMatrix.scale(1/256, 1/256);
		}
		
		public function get numVertices():int
		{
			return _numVertices;
		}

		public function clear():void
		{
			indices = new Vector.<uint>();
			vertices = new Vector.<Number>();
			if(minBounds)
			{
				minBounds.x = minBounds.y = 0; 
				maxBounds.x = maxBounds.y = 0;
			}
			
			_numVertices = 0;
			VertexList.dispose(fillVertices);
			fillVertices = null;
			isInvalid = true;
		}
		
		override public function dispose():void
		{
			clear();
			fillVertices = null;
			super.dispose();
		}
		
		public function addVertex( x:Number, y:Number, color:uint = 0xFFFFFF, alpha:Number = 1 ):void
		{
			var r:Number = (color >> 16) / 255;
			var g:Number = ((color & 0x00FF00) >> 8) / 255;
			var b:Number = (color & 0x0000FF) / 255;
			
			var vertex:Vector.<Number> = Vector.<Number>( [ x, y, 0, r, g, b, alpha, x, y ]);
			var node:VertexList = VertexList.getNode();
			if ( _numVertices == 0 )
			{
				fillVertices = node;
				node.head = node;
				node.prev = node;
			}
			
			node.next = fillVertices.head;
			node.prev = fillVertices.head.prev;
			node.prev.next = node;
			node.next.prev = node;
			node.index = _numVertices;
			node.vertex = vertex;
			
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
			
			_numVertices++;
			
			isInvalid = true;
		}
		
		override protected function buildGeometry():void
		{
			if ( _numVertices < 3) return;
			
			vertices = new Vector.<Number>();
			indices = new Vector.<uint>();
			
			triangulate(fillVertices, _numVertices, vertices, indices);
		}
		
		override public function shapeHitTest( stageX:Number, stageY:Number ):Boolean
		{
			if ( vertices == null ) return false;
			if ( numVertices < 3 ) return false;
			
			var pt:Point = globalToLocal(new Point(stageX,stageY));
			var wn:int = windingNumberAroundPoint(fillVertices, pt.x, pt.y);
			if ( isClockWise(fillVertices) )
			{
				return  wn != 0;
			}
			return wn == 0;
		}
		
		/**
		 * Takes a list of arbitrary vertices. It will first decompose this list into
		 * non intersecting polygons, via convertToSimple. Then it uses an ear-clipping
		 * algorithm to decompose the polygons into triangles.
		 * @param vertices
		 * @param _numVertices
		 * @return 
		 * 
		 */		
		private static function triangulate( vertices:VertexList, _numVertices:int, outputVertices:Vector.<Number>, outputIndices:Vector.<uint> ):void
		{
			vertices = VertexList.clone(vertices);
			var openList:Vector.<VertexList> = convertToSimple(vertices);
			flatten(openList, outputVertices);
			
			while ( openList.length > 0 )
			{
				var currentList:VertexList = openList.pop();
				
				if ( isClockWise(currentList) == false )
				{
					VertexList.reverse(currentList);
				}
				
				var iter:int = 0;
				var flag:Boolean = false;
				var currentNode:VertexList = currentList.head;
				while ( true )
				{
					if ( iter > _numVertices*3 ) break;
					iter++;
					
					var n0:VertexList = currentNode.prev;
					var n1:VertexList = currentNode;
					var n2:VertexList = currentNode.next;
					
					// If vertex list is 3 long.
					if ( n2.next == n0 )
					{
						//trace( "making triangle : " + n0.index + ", " + n1.index + ", " + n2.index );
						outputIndices.push( n0.index, n1.index, n2.index );
						VertexList.releaseNode( n0 );
						VertexList.releaseNode( n1 );
						VertexList.releaseNode( n2 );
						break;
					}
					
					var v0x:Number = n0.vertex[0];
					var v0y:Number = n0.vertex[1];
					var v1x:Number = n1.vertex[0];
					var v1y:Number = n1.vertex[1];
					var v2x:Number = n2.vertex[0];
					var v2y:Number = n2.vertex[1];
					
					// Ignore vertex if not reflect
					//trace( "testing triangle : " + n0.index + ", " + n1.index + ", " + n2.index );
					if ( isReflex( v0x, v0y, v1x, v1y, v2x, v2y ) == false )
					{
						//trace("index is not reflex. Skipping. " + n1.index);
						currentNode = currentNode.next;
						continue;
					}
					
					// Check to see if building a triangle from these 3 vertices
					// would intersect with any other edges.
					var startNode:VertexList = n2.next;
					var n:VertexList = startNode;
					var found:Boolean = false;
					while ( n != n0 )
					{
						//trace("Testing if point is in triangle : " + n.index);
						if ( isPointInTriangle(v0x, v0y, v1x, v1y, v2x, v2y, n.vertex[0], n.vertex[1]) )
						{
							found = true;
							break;
						}
						n = n.next;
					}
					if ( found )
					{
						//trace("Point found in triangle. Skipping");
						currentNode = currentNode.next;
						continue;
					}
					
					// Build triangle and remove vertex from list
					//trace( "making triangle : " + n0.index + ", " + n1.index + ", " + n2.index );
					outputIndices.push( n0.index, n1.index, n2.index );
					
					//trace( "removing vertex : " + n1.index );
					if ( n1 == n1.head )
					{
						n1.vertex = n2.vertex;
						n1.next = n2.next;
						n1.index = n2.index;
						n1.next.prev = n1;
						VertexList.releaseNode( n2 );
					}
					else
					{
						n0.next = n2;
						n2.prev = n0;
						VertexList.releaseNode( n1 );
					}
					
					currentNode = n0;
				}
				
				VertexList.dispose(currentList);
			}
		}
		
		/**
		 * Decomposes a list of arbitrarily positioned vertices that may form self-intersecting
		 * polygons, into a list of non-intersecting polygons. This is then used as input
		 * for the triangulator. 
		 * @param vertexList
		 * @return 
		 */		
		private static function convertToSimple( vertexList:VertexList ):Vector.<VertexList>
		{
			var output:Vector.<VertexList> = new Vector.<VertexList>();
			var outputLength:int = 0;
			
			var openList:Vector.<VertexList> = new Vector.<VertexList>();
			openList.push(vertexList);
			
			while ( openList.length > 0 )
			{
				var currentList:VertexList = openList.pop();
				
				var headA:VertexList = currentList.head;
				var nodeA:VertexList = headA;
				var isSimple:Boolean = true;
				
				if ( nodeA.next == nodeA || nodeA.next.next == nodeA || nodeA.next.next.next == nodeA )
				{
					output[outputLength++] = headA;
					continue;
				}
				
				do
				{
					var nodeB:VertexList = nodeA.next.next;
					do
					{
						var isect:Vector.<Number> = intersection( nodeA, nodeA.next, nodeB, nodeB.next );
						
						if ( isect != null )
						{
							isSimple = false;
							
							var temp:VertexList = nodeA.next;
							
							var isectNodeA:VertexList = VertexList.getNode();
							isectNodeA.vertex = isect;
							isectNodeA.prev = nodeA;
							isectNodeA.next = nodeB.next;
							isectNodeA.next.prev = isectNodeA;
							isectNodeA.head = headA;
							nodeA.next = isectNodeA;
							
							var headB:VertexList = nodeB;
							var isectNodeB:VertexList = VertexList.getNode();
							isectNodeB.vertex = isect;
							isectNodeB.prev = nodeB;
							isectNodeB.next = temp;
							isectNodeB.next.prev = isectNodeB;
							isectNodeB.head = headB;
							nodeB.next = isectNodeB;
							do
							{
								nodeB.head = headB;
								nodeB = nodeB.next;
							}
							while ( nodeB != headB )
							
							openList.push( headA, headB );
							
							break;
						}
						nodeB = nodeB.next;
					}
					while ( nodeB != nodeA.prev && isSimple )
					
					nodeA = nodeA.next;
				}
				while ( nodeA != headA && isSimple)
				
				if ( isSimple )
				{
					output[outputLength++] = headA;
				}
			}
			
			return output;
		}
		
		private static function flatten( vertexLists:Vector.<VertexList>, output:Vector.<Number> ):void
		{
			var L:int = vertexLists.length;
			var index:int = 0;
			for ( var i:int = 0; i < L; i++ )
			{
				var vertexList:VertexList = vertexLists[i];
				var node:VertexList = vertexList.head;
				do
				{
					node.index = index++;
					output.push(node.vertex[0], node.vertex[1], node.vertex[2], node.vertex[3], node.vertex[4], node.vertex[5], node.vertex[6], node.vertex[7], node.vertex[8]);
					node = node.next;
				}
				while ( node != node.head )
			}
		}
		
		private static function windingNumberAroundPoint( vertexList:VertexList, x:Number, y:Number ):int
		{
			var wn:int = 0;
			var node:VertexList = vertexList.head;
			do
			{
				var v0y:Number = node.vertex[1];
				var v1y:Number = node.next.vertex[1];
				if ( (y > v0y && y < v1y) || (y > v1y && y < v0y)  )
				{
					var v0x:Number = node.vertex[0];
					var v1x:Number = node.next.vertex[0];
					
					var isUp:Boolean = v1y < y;
					if ( isUp )
					{
						//wn += isLeft( v0x, v0y, v1x, v1y, x, y ) ? 1 : 0;
						// Inline version of above
						wn += ((v1x - v0x) * (y - v0y) - (v1y - v0y) * (x - v0x)) < 0 ? 1 : 0
					}
					else
					{
						//wn += isLeft( v0x, v0y, v1x, v1y, x, y ) ? 0 : -1
						// Inline version of above
						wn += ((v1x - v0x) * (y - v0y) - (v1y - v0y) * (x - v0x)) < 0 ? 0 : -1;
					}
				}
				
				node = node.next;
			}
			while ( node != vertexList.head )
			return wn;
		}
		
		public static function isClockWise( vertexList:VertexList ):Boolean
		{
			var wn:Number = 0;
			var node:VertexList = vertexList.head;
			do
			{
				wn += (node.next.vertex[0]-node.vertex[0]) * (node.next.vertex[1]+node.vertex[1]);
				node = node.next;
			}
			while ( node != vertexList.head )
			
			return wn <= 0;
		}
		
		private static function windingNumber( vertexList:VertexList ):int
		{
			var wn:int = 0;
			var node:VertexList = vertexList.head;
			do
			{
				//wn += isLeft( node.vertex[0], node.vertex[1], node.next.vertex[0], node.next.vertex[1], node.next.next.vertex[0], node.next.next.vertex[1] ) ? -1 : 1;
				
				// Inline version of above
				wn += ((node.next.vertex[0] - node.vertex[0]) * (node.next.next.vertex[1] - node.vertex[1]) - (node.next.next.vertex[0] - node.vertex[0]) * (node.next.vertex[1] - node.vertex[1])) < 0 ? -1 : 1;
				
				node = node.next;
			}
			while ( node != vertexList.head )
			
			return wn;
		}
		
		private static function isLeft(v0x:Number, v0y:Number, v1x:Number, v1y:Number, px:Number, py:Number):Boolean
		{
			return ((v1x - v0x) * (py - v0y) - (v1y - v0y) * (px - v0x)) < 0;
		}
		
		private static function isPointInTriangle(v0x:Number, v0y:Number, v1x:Number, v1y:Number, v2x:Number, v2y:Number, px:Number, py:Number ):Boolean
		{
			//if ( isLeft( v0x, v0y, v1x, v1y, px, py ) ) return false;
			//if ( isLeft( v1x, v1y, v2x, v2y, px, py ) ) return false;
			//if ( isLeft( v2x, v2y, v0x, v0y, px, py ) ) return false;
			
			// Inline version of above
			if ( ((v1x - v0x) * (py - v0y) - (px - v0x) * (v1y - v0y)) < 0 ) return false;
			if ( ((v2x - v1x) * (py - v1y) - (px - v1x) * (v2y - v1y)) < 0 ) return false;
			if ( ((v0x - v2x) * (py - v2y) - (px - v2x) * (v0y - v2y)) < 0 ) return false;
			
			return true;
		}
		
		private static function isReflex( v0x:Number, v0y:Number, v1x:Number, v1y:Number, v2x:Number, v2y:Number ):Boolean
		{
			//if ( isLeft( v0x, v0y, v1x, v1y, v2x, v2y ) ) return false;
			//if ( isLeft( v1x, v1y, v2x, v2y, v0x, v0y ) ) return false;
			
			// Inline version of above
			if ( ((v1x - v0x) * (v2y - v0y) - (v2x - v0x) * (v1y - v0y)) < 0 ) return false;
			if ( ((v2x - v1x) * (v0y - v1y) - (v0x - v1x) * (v2y - v1y)) < 0 ) return false;
			
			return true;
		}
		
		private static const EPSILON:Number = 0.0000001
		static private function intersection( a0:VertexList, a1:VertexList, b0:VertexList, b1:VertexList ):Vector.<Number>
		{
			var ux:Number = (a1.vertex[0]) - (a0.vertex[0]);
			var uy:Number = (a1.vertex[1]) - (a0.vertex[1]);
			
			var vx:Number = (b1.vertex[0]) - (b0.vertex[0]);
			var vy:Number = (b1.vertex[1]) - (b0.vertex[1]);
			
			var wx:Number = (a0.vertex[0]) - (b0.vertex[0]);
			var wy:Number = (a0.vertex[1]) - (b0.vertex[1]);
			
			var D:Number = ux * vy - uy * vx
			if ((D < 0 ? -D : D) < EPSILON) return null
			
			var t:Number = (vx * wy - vy * wx) / D
			if (t < 0 || t > 1) return null
			var t2:Number = (ux * wy - uy * wx) / D
			if (t2 < 0 || t2 > 1) return null
			
			var vertexA:Vector.<Number> = a0.vertex;
			var vertexB:Vector.<Number> = a1.vertex;
			
			return Vector.<Number>( [ 	vertexA[0] + t * (vertexB[0] - vertexA[0]),
				vertexA[1] + t * (vertexB[1] - vertexA[1]),
				0,
				vertexA[3] + t * (vertexB[3] - vertexA[3]),
				vertexA[4] + t * (vertexB[4] - vertexA[4]),
				vertexA[5] + t * (vertexB[5] - vertexA[5]),
				vertexA[6] + t * (vertexB[6] - vertexA[6]),
				vertexA[7] + t * (vertexB[7] - vertexA[7]),
				vertexA[8] + t * (vertexB[8] - vertexA[8]) ] );
		}
	}
}
