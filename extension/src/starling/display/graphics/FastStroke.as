package starling.display.graphics
{
	import flash.geom.Point;
	
	import starling.display.graphics.StrokeVertex;
	import starling.textures.Texture;
	import starling.core.Starling;
	import flash.display3D.Context3D;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import starling.core.RenderSupport;
	import starling.display.BlendMode;
	import starling.errors.MissingContextError;
		
	public class FastStroke extends Graphic
	{
		protected var _line			:Vector.<StrokeVertex>;
		
		protected var _lastX:Number;
		protected var _lastY:Number;
		protected var _lastR:Number;
		protected var _lastG:Number;
		protected var _lastB:Number;
		protected var _lastA:Number;
		protected var _lastThickness:Number;
		
		protected var _numControlPoints :int;
		protected var _capacity:int = -1;
		protected var _numVertIndex:int = 0;
		protected var _numVerts:int = 0;
		
		protected var _verticesBufferAllocLen:int = 0;
		protected var _indicesBufferAllocLen:int = 0;
		
		protected const INDEX_STRIDE_FOR_QUAD:int = 6;
		
		protected var _lostContext:Boolean = false;
		
		
		public function FastStroke()
		{
			clear();
		}
		
		public function setCapacity(capacity:int) : void
		{
			if ( capacity >_capacity )
			{
				clear();
				vertices = new Vector.<Number>(capacity * 18 * 2, true);
				indices = new Vector.<uint>((capacity ) * INDEX_STRIDE_FOR_QUAD * 2, true);
				_capacity = capacity;
			}
		}

		public function moveTo(x:Number, y:Number, thickness:Number = 1, color:uint = 0xFFFFFF, alpha:Number = 1 ) : void
		{
			setCurrentPosition(x, y);
			setCurrentColor(color, alpha);
			setCurrentThickness(thickness);
		}

		
		public function lineTo(x:Number, y:Number, thickness:Number = 1.0, color:uint = 0xFFFFFF, a:Number = 1.0  ):void
		{
			var r:Number = (color >> 16) / 255;
			var g:Number = ((color & 0x00FF00) >> 8) / 255;
			var b:Number = (color & 0x0000FF) / 255;
			
			var halfThickness:Number = (0.5 * thickness);
			
			var dx:Number = x - _lastX;
			var dy:Number = y - _lastY;
			var halfLastThickness:Number = _lastThickness * 0.5;
			if ( dy == 0 )
			{
				pushVerts(vertices,  _numControlPoints  , _lastX, _lastY+halfLastThickness, _lastX, _lastY-halfLastThickness, _lastR, _lastG, _lastB, _lastA );
				pushVerts(vertices,  _numControlPoints+1, x     , y+halfThickness, x, y-halfThickness, r, g, b, a);
			}
			else if ( dx == 0 )
			{
				pushVerts(vertices,  _numControlPoints  , _lastX + halfLastThickness, _lastY, _lastX - halfLastThickness, _lastY, _lastR, _lastG, _lastB, _lastA);
				pushVerts(vertices,  _numControlPoints+1, x+halfThickness, y, x-halfThickness, y, r, g, b, a);
			}
			else
			{
				var d:Number = Math.sqrt( dx * dx + dy * dy );
				
				var nx:Number = -dy / d;
				var ny:Number =  dx / d;
				
				var cnx:Number = nx;
				var cny:Number = ny;
				
				var cnInv:Number = (1 / Math.sqrt( cnx * cnx + cny * cny ));
				var c:Number =  cnInv * halfLastThickness;
				cnx = nx * c;
				cny = ny * c;
				
				var v1xPos:Number = _lastX + cnx;
				var v1yPos:Number = _lastY + cny;
				var v1xNeg:Number = _lastX - cnx;
				var v1yNeg:Number = _lastY - cny;
					
				pushVerts(vertices,  _numControlPoints, v1xPos, v1yPos, v1xNeg, v1yNeg, _lastR, _lastG, _lastB, _lastA);
					
				c =  cnInv * halfThickness;
				cnx = nx * c;
				cny = ny * c;
				
				v1xPos = x + cnx;
				v1yPos = y + cny;
				v1xNeg = x - cnx;
				v1yNeg = y - cny;
					
				pushVerts(vertices,  _numControlPoints+1, v1xPos, v1yPos, v1xNeg, v1yNeg, r, g, b, a);
			}
			
			_lastX = x;
			_lastY = y;
			_lastR = r;
			_lastG = g;
			_lastB = b;
			_lastA = a;
			_lastThickness = thickness;
			
			// This needs fixing, not accurate at the moment, since thickness is ignored here.
			minBounds.x = x < minBounds.x ? x : minBounds.x; 
			minBounds.y = y < minBounds.y ? y : minBounds.y;
			maxBounds.x = x > maxBounds.x ? x : maxBounds.x;
			
			maxBounds.y = y > maxBounds.y ? y : maxBounds.y;
			
			if ( _numControlPoints < (_capacity)*2 )
			{
				var i:int = _numControlPoints;
				var i2:int = (i << 1);
				
				var counter:int = i * INDEX_STRIDE_FOR_QUAD;
				indices[counter++] = i2;
				indices[counter++] = i2+2;
				indices[counter++] = i2+1;
				indices[counter++] = i2+1;
				indices[counter++] = i2+2;
				indices[counter++] = i2+3;
				
				_numVertIndex += INDEX_STRIDE_FOR_QUAD*2;	
			}
			
			_numControlPoints += 2;
			_numVerts += 18 * 2;
			
			if ( buffersInvalid == false )
				setGeometryInvalid();
		}
		
		
		override public function dispose():void
		{
			clear();
			vertices = new Vector.<Number>();
			indices = new Vector.<uint>();
			
			super.dispose();
			_capacity = -1;
		}

		public function clear():void
		{
			_numControlPoints = 0;
			_numVerts = 0;
			_numVertIndex = 0;
			_lastX = 0;
			_lastY = 0;
			_lastThickness = 1;
			_lastR = _lastG = _lastB = _lastA = 1.0
			
			setGeometryInvalid();
		}
		
		override protected function buildGeometry():void
		{
			
		}
		
		
		protected function setCurrentPosition(x:Number, y:Number) : void
		{
			_lastX = x;
			_lastY = y;
		}
		
		protected function setCurrentColor(color:uint, alpha:Number = 1 ) :void
		{
			_lastR =  (color >> 16) / 255;
			_lastG = ((color & 0x00FF00) >> 8) / 255;
			_lastB =  (color & 0x0000FF) / 255;
			_lastA = alpha;	
		}
		
		protected function setCurrentThickness(thickness:Number) : void
		{
			_lastThickness = thickness;
		}
		
		override protected function shapeHitTestLocalInternal( localX:Number, localY:Number ):Boolean
		{
			if ( _line == null ) return false;
			if ( _line.length < 2 ) return false;
			
			var numLines:int = _line.length;
			
			for ( var i: int = 1; i < numLines; i++ )
			{
				var v0:StrokeVertex = _line[i - 1];
				var v1:StrokeVertex = _line[i];
				
				var lineLengthSquared:Number = (v1.x - v0.x) * (v1.x - v0.x) + (v1.y - v0.y) * (v1.y - v0.y);
				
				var interpolation:Number = ( ( ( localX - v0.x ) * ( v1.x - v0.x ) ) + ( ( localY - v0.y ) * ( v1.y - v0.y ) ) )  /	( lineLengthSquared );
				if( interpolation < 0.0 || interpolation > 1.0 )
					continue;   // closest point does not fall within the line segment
					
				var intersectionX:Number = v0.x + interpolation * ( v1.x - v0.x );
				var intersectionY:Number = v0.y + interpolation * ( v1.y - v0.y );
				
				var distanceSquared:Number = (localX - intersectionX) * (localX - intersectionX) + (localY - intersectionY) * (localY - intersectionY);
				
				var intersectThickness:Number = (v0.thickness * (1.0 - interpolation) + v1.thickness * interpolation); // Support for varying thicknesses
				
				intersectThickness += _precisionHitTestDistance;
				
				if ( distanceSquared <= intersectThickness * intersectThickness)
					return true;
			}
				
			return false;
		}
		
		override public function validateNow():void
		{
			if ( geometryInvalid == false )
				return;
			
			
			if ( vertexBuffer && (buffersInvalid || uvsInvalid) )
			{
		//		vertexBuffer.dispose();
		//		indexBuffer.dispose();
			}
			
			if ( buffersInvalid || geometryInvalid )
			{
				buildGeometry();
				applyUVMatrix();
			}
			else if ( uvsInvalid )
			{
				applyUVMatrix();
			}
		}
		
		override public function render( renderSupport:RenderSupport, parentAlpha:Number ):void
		{
			validateNow();
			
			if ( indices.length < 3 ) return;
			
			var numIndices:int = _numVertIndex;
			if ( buffersInvalid || uvsInvalid )
			{
				// Upload vertex/index buffers.
				
				var numVertices:int = (_numControlPoints * 2);
				if ( numVertices > _verticesBufferAllocLen || _lostContext )
				{
					if ( vertexBuffer != null )
						vertexBuffer.dispose();
					vertexBuffer = Starling.context.createVertexBuffer( numVertices, VERTEX_STRIDE );
					_verticesBufferAllocLen = numVertices;					
				}
				
				vertexBuffer.uploadFromVector( vertices, 0, numVertices );
				
				if ( numIndices > _indicesBufferAllocLen || _lostContext )
				{
					if ( indexBuffer != null )
						indexBuffer.dispose();
					indexBuffer = Starling.context.createIndexBuffer( numIndices );
					_indicesBufferAllocLen = numIndices;
				}
				
				indexBuffer.uploadFromVector( indices, 0, numIndices );
				
				_lostContext = buffersInvalid = uvsInvalid = false;
			}
			
			
			// always call this method when you write custom rendering code!
			// it causes all previously batched quads/images to render.
			renderSupport.finishQuadBatch();
			renderSupport.raiseDrawCount();
			
			var context:Context3D = Starling.context;
			if (context == null) throw new MissingContextError();
			
			RenderSupport.setBlendFactors(material.premultipliedAlpha, this.blendMode == BlendMode.AUTO ? renderSupport.blendMode : this.blendMode);
			_material.drawTriangles( Starling.context, renderSupport.mvpMatrix3D, vertexBuffer, indexBuffer, parentAlpha*this.alpha, _numVertIndex / 3 );
			
			context.setTextureAt(0, null);
			context.setTextureAt(1, null);
			context.setVertexBufferAt(0, null);
			context.setVertexBufferAt(1, null);
			context.setVertexBufferAt(2, null);
		} 
	
		[inline]
		protected static function pushVerts(vertices:Vector.<Number>, _numControlPoints:Number, x1:Number, y1:Number, x2:Number, y2:Number, r:Number, g:Number, b:Number, a:Number) : void
		{
			var u:Number = 0; // Todo uv mapping in this case?
			var i:int = _numControlPoints * 18;
			vertices[i++] = x1;
			vertices[i++] = y1;
			vertices[i++] = 0;
			vertices[i++] = r;
			vertices[i++] = g;
			vertices[i++] = b;
			vertices[i++] = a;
			vertices[i++] = u;
			vertices[i++] = 0;
			
			vertices[i++] = x2;
			vertices[i++] = y2;
			vertices[i++] = 0;
			vertices[i++] = r;
			vertices[i++] = g;
			vertices[i++] = b;
			vertices[i++] = a;
			vertices[i++] = u;
			vertices[i++] = 1;
			
		}
		
		override protected function onGraphicLostContext() : void
		{
			_lostContext = true;
		}
		
	}
}
