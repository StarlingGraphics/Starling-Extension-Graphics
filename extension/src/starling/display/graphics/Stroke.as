package starling.display.graphics
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import starling.core.RenderSupport;
	import starling.display.graphics.StrokeVertex;
	import starling.display.graphics.util.TriangleUtil;
	import starling.textures.Texture;
	import starling.utils.MatrixUtil;

	public class Stroke extends Graphic
	{
		protected var _moved        :Boolean;
		protected var _moveX        :Number;
		protected var _moveY        :Number;
		protected var _moveThickness:Number;
		protected var _moveColor    :Number;
		protected var _moveAlpha    :Number;
		protected var _prevX        :Number;
		protected var _prevY        :Number;
		protected var _prevThickness:Number;
		protected var _prevX2       :Number;
		protected var _prevY2       :Number;
		protected var _prevU        :Number;
		protected var _prevColor0   :uint;
		protected var _prevColor1   :uint;
		protected var _prevAlpha0   :uint;
		protected var _prevAlpha1   :uint;
		protected var _numVertices  :uint;
		protected var _numIndices   :uint;
		protected var _numInSegment :uint;

		protected static var sCollissionHelper:StrokeCollisionHelper = null;

		public function Stroke(initialVerts:uint = 0)
		{
			vertices = new Vector.<Number>(initialVerts * (Graphic.VERTEX_STRIDE * 2));
			indices = new Vector.<uint>((initialVerts > 0) ? ((initialVerts-1) * 6) : 0);
			clear();
		}

		// Legacy function - effectly the number of points in the line
		// not the amount of vertices used to build the solid line shape.
		public function get numVertices():uint
		{
			return _numVertices / (Graphic.VERTEX_STRIDE * 2);
		}

		override public function dispose():void
		{
			clear();
			super.dispose();
		}

		public function clear():void
		{
			if(minBounds)
			{
				minBounds.x = minBounds.y = Number.POSITIVE_INFINITY;
				maxBounds.x = maxBounds.y = Number.NEGATIVE_INFINITY;
			}

			_numVertices = 0;
			_numIndices = 0;
			_numInSegment = 0;
			_moved = true;
			isInvalid = true;
			setGeometryInvalid();
		}

		public function lineTo(	x:Number, y:Number, thickness:Number = 1, color:uint = 0xFFFFFF,  alpha:Number = 1) : void
		{
			if (_moved == true) {
				_moved = false;
				addVertexInternal(_moveX, _moveY, _moveThickness, _moveColor, _moveAlpha, _moveColor, _moveAlpha, true);
			}
			addVertexInternal(x, y, thickness, color, alpha, color, alpha);
			isInvalid = true;
		}

		public function moveTo( x:Number, y:Number, thickness:Number = 1, color:uint = 0xFFFFFF, alpha:Number = 1.0 ) : void
		{
			_moved = true;
			_moveX = x;
			_moveY = y;
			_moveThickness = thickness;
			_moveColor = color;
			_moveAlpha = alpha;
			isInvalid = true;
		}

		public function modifyVertexPosition(index:int, x:Number, y:Number) : void
		{
			setX(index, x);
			setY(index, y);
			isInvalid = true;
		}
		
		public function fromBounds(boundingBox:Rectangle, thickness:int = 1) : void
		{
			clear();
			addVertex(boundingBox.x, boundingBox.y, thickness);
			addVertex(boundingBox.x+boundingBox.width, boundingBox.y, thickness);
			addVertex(boundingBox.x+boundingBox.width, boundingBox.y+boundingBox.height, thickness);
			addVertex(boundingBox.x, boundingBox.y+boundingBox.height, thickness);
			addVertex(boundingBox.x, boundingBox.y, thickness);
		}

	//	[Deprecated(replacement="starling.display.graphics.Stroke.lineTo()")]
		public function addVertex( 	x:Number, y:Number, thickness:Number = 1,
									color0:uint = 0xFFFFFF,  alpha0:Number = 1,
									color1:uint = 0xFFFFFF, alpha1:Number = 1 ):void
		{
			addVertexInternal(x, y, thickness, color0, alpha0, color1, alpha1);
			_moved = false;
			isInvalid = true;
		}

		protected function updateBounds( x:Number, y:Number ):void {
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

			if ( maxBounds.x == Number.NEGATIVE_INFINITY )
				maxBounds.x = x;
			if ( maxBounds.y == Number.NEGATIVE_INFINITY )
				maxBounds.y = y;
		}

		private function adjustPoints( x:Number, y:Number, nX:Number, nY:Number, thickness:Number):void {
			nX *= thickness;
			nY *= thickness;
			var v1xPos:Number = x + nX;
			var v1yPos:Number = y + nY;
			var v1xNeg:Number = x - nX;
			var v1yNeg:Number = y - nY;

			var prevIndices:uint = _numVertices - Graphic.VERTEX_STRIDE * 2;
			vertices[prevIndices++] = v1xPos;
			vertices[prevIndices++] = v1yPos;
			prevIndices += Graphic.VERTEX_STRIDE - 2;
			vertices[prevIndices++] = v1xNeg;
			vertices[prevIndices++] = v1yNeg;
		}

		private function addPoints( x:Number, y:Number, nX:Number, nY:Number, thickness:Number,
									col0:uint, col1:uint, alpha0:Number, alpha1:Number, u:Number ):void {
			nX *= thickness;
			nY *= thickness;
			var v1xPos:Number = x + nX;
			var v1yPos:Number = y + nY;
			var v1xNeg:Number = x - nX;
			var v1yNeg:Number = y - nY;

			var r0:Number = (col0 >> 16) / 255;
			var g0:Number = ((col0 & 0x00FF00) >> 8) / 255;
			var b0:Number = (col0 & 0x0000FF) / 255;
			var r1:Number = (col1 >> 16) / 255;
			var g1:Number = ((col1 & 0x00FF00) >> 8) / 255;
			var b1:Number = (col1 & 0x0000FF) / 255;

			vertices[_numVertices++] = v1xPos;
			vertices[_numVertices++] = v1yPos;
			vertices[_numVertices++] = 0;
			vertices[_numVertices++] = r1;
			vertices[_numVertices++] = g1;
			vertices[_numVertices++] = b1;
			vertices[_numVertices++] = alpha1;
			vertices[_numVertices++] = u;
			vertices[_numVertices++] = 1;
			vertices[_numVertices++] = v1xNeg;
			vertices[_numVertices++] = v1yNeg;
			vertices[_numVertices++] = 0;
			vertices[_numVertices++] = r0;
			vertices[_numVertices++] = g0;
			vertices[_numVertices++] = b0;
			vertices[_numVertices++] = alpha0;
			vertices[_numVertices++] = u;
			vertices[_numVertices++] = 0;
		}

		protected function addVertexInternal(	x:Number, y:Number, thickness:Number = 1,
									color0:uint = 0xFFFFFF,  alpha0:Number = 1,
									color1:uint = 0xFFFFFF, alpha1:Number = 1,
									start:Boolean = false):void
		{
			if (start) {
				_prevX = x;
				_prevY = y;
				_prevColor0 = color0;
				_prevColor1 = color1;
				_prevAlpha0 = alpha0;
				_prevAlpha1 = alpha1;
				_prevThickness = thickness;
				_prevU = 0;
				_numInSegment = 0;
				return;
			}
			updateBounds(x,y);
			var u:Number = 0;
			var v:Number = 0;
			var textures:Vector.<Texture> = _material.textures;
			if ( textures.length > 0 )
			{
				var dx:Number = x - _prevX;
				var dy:Number = y - _prevY;
				var d:Number = Math.sqrt(dx*dx+dy*dy);
				u = (d / textures[0].width) + _prevU;
			}


			var dX:Number = x - _prevX;
			var dY:Number = y - _prevY;
			var len:Number = Math.sqrt(dX * dX + dY * dY);
			var invLen:Number = 1.0 / len;
			dX *= invLen;
			dY *= invLen;
			const nX:Number = -dY;
			const nY:Number = dX;

			// If only 1 vertex is in the segment
			// add the first two points
			if (_numInSegment == 0) {
				addPoints(_prevX, _prevY, nX, nY, _prevThickness * 0.5, _prevColor0, _prevColor1, _prevAlpha0, _prevAlpha1, 0.0);
				_numInSegment++;
			}
			// If 2 vertices are already in the segment
			// adjust the two previous points to be elbowed
			else if (_numInSegment > 1)
			{
				var dX2:Number = _prevX - _prevX2;
				var dY2:Number = _prevY - _prevY2;
				var len2:Number = Math.sqrt(dX2 * dX2 + dY2 * dY2);
				var invLen2:Number = 1.0 / len2;
				dX2 *= invLen2;
				dY2 *= invLen2;
				const nX2:Number = -dY2;
				const nY2:Number = dX2;
				var elbowThickness:Number = _prevThickness*0.5;
				
				// For future reference, dot product has this equality:
				// vA.vB = |vA||vB|cos(theta) 
				// where theta is the angle betwen vectors vA and vB.
				var dot:Number = (nX * nX2 + nY * nY2);
				var arcCosDot:Number = Math.acos(dot);
				elbowThickness /= Math.sin( (Math.PI-arcCosDot) * 0.5);
				
				if ( elbowThickness > _prevThickness * 4 )
				{
					elbowThickness = _prevThickness * 4;
				}
				
				if ( elbowThickness != elbowThickness ) // faster NaN comparison
				{
					elbowThickness = _prevThickness*0.5;
				}
				
				var cnx:Number = nX2 + nX;
				var cny:Number = nY2 + nY;
				var c:Number = (1/Math.sqrt( cnx*cnx + cny*cny ));
				cnx *= c;
				cny *= c;
				
				adjustPoints(_prevX, _prevY, cnx, cny, elbowThickness);
			}

			// Add two vertices as if it is the end
			addPoints(x, y, nX, nY, thickness * 0.5, color0, color1, alpha0, alpha1, u);
			_numInSegment++;

			// Add indices
			var i2:int = _numVertices / Graphic.VERTEX_STRIDE - 4;
			indices[_numIndices++] = i2;
			indices[_numIndices++] = i2+2;
			indices[_numIndices++] = i2+1;
			indices[_numIndices++] = i2+1;
			indices[_numIndices++] = i2+2;
			indices[_numIndices++] = i2+3;
			_prevX2 = _prevX;
			_prevY2 = _prevY;
			_prevX = x;
			_prevY = y;
			_prevU = u;
			_prevThickness = thickness;
			_numInSegment++;
		}

		public function getVertexPosition(index:int, prealloc:Point = null):Point
		{
			var point:Point = prealloc;
			if ( point == null )
				point = new Point();

			var vertIndex:uint = index * 2;
			point.x = (getX(vertIndex) + getX(vertIndex + 1)) * 0.5;
			point.y = (getY(vertIndex) + getY(vertIndex + 1)) * 0.5;
			return point;
		}

		///////////////////////////////////
		// Static helper methods
		///////////////////////////////////
		[inline]
		protected static function createPolyLinePreAlloc( _line:Vector.<StrokeVertex>,
												lines:Vector.<uint>,
												numLines:uint,
												vertices:Vector.<Number>,
												indices:Vector.<uint>
		):void
		{
			const numVertices:int = _line.length;
			const PI:Number = Math.PI;
			var vertCounter:int = 0;
			var indiciesCounter:int = 0;
			var lastD0:Number = 0;
			var lastD1:Number = 0;
			var idx:uint = 0;
			var treatAsFirst:Boolean;
			var treatAsLast:Boolean;

			var i:int = 0;
			for (var j:uint = 0; j < numLines; j++) {
				var lineVerts:uint = lines[j];
				for (var k:uint = 0; k < lineVerts; k++) {
					idx = i;
					treatAsFirst = (k == 0);
					treatAsLast = (k == lineVerts - 1)
					var treatAsRegular:Boolean = treatAsFirst == false && treatAsLast == false;

					var idx0:uint = treatAsFirst ? idx : ( idx - 1 );
					var idx2:uint = treatAsLast ? idx : ( idx + 1 );

					var v0:StrokeVertex = _line[idx0];
					var v1:StrokeVertex = _line[idx];
					var v2:StrokeVertex = _line[idx2];

					var vThickness:Number = v1.thickness;

					var v0x:Number = v0.x;
					var v0y:Number = v0.y;
					var v1x:Number = v1.x;
					var v1y:Number = v1.y;
					var v2x:Number = v2.x;
					var v2y:Number = v2.y;

					// Line segments before and after
					var d0x:Number = v1x - v0x;
					var d0y:Number = v1y - v0y;
					var d1x:Number = v2x - v1x;
					var d1y:Number = v2y - v1y;

					if ( treatAsRegular == false )
					{
						// Extend first and last points
						if ( treatAsLast )
						{
							v2x += d0x;
							v2y += d0y;
							d1x = v2x - v1x;
							d1y = v2y - v1y;
						}
						if ( treatAsFirst )
						{
							v0x -= d1x;
							v0y -= d1y;
							d0x = v1x - v0x;
							d0y = v1y - v0y;;
						}
					}

					var d0:Number = Math.sqrt( d0x*d0x + d0y*d0y );
					var d1:Number = Math.sqrt( d1x*d1x + d1y*d1y );

					var elbowThickness:Number = vThickness*0.5;
					if ( !(treatAsFirst || treatAsLast) ) {
						if ( d0 == 0 )
							d0 = lastD0;
						else
							lastD0 = d0;

						if ( d1 == 0 )
							d1 = lastD1;
						else
							lastD1 = d1;

						// Thanks to Tom Clapham for spotting this relationship.
						var dot:Number = (d0x * d1x + d0y * d1y) / (d0 * d1);
						var arcCosDot:Number = Math.acos(dot);
						elbowThickness /= Math.sin( (PI-arcCosDot) * 0.5);

						if ( elbowThickness > vThickness * 4 )
						{
							elbowThickness = vThickness * 4;
						}

						if ( elbowThickness != elbowThickness ) // faster NaN comparison
						{
							elbowThickness = vThickness*0.5;
						}
					}

					var n0x:Number = -d0y / d0;
					var n0y:Number =  d0x / d0;
					var n1x:Number = -d1y / d1;
					var n1y:Number =  d1x / d1;

					var cnx:Number = n0x + n1x;
					var cny:Number = n0y + n1y;

					var c:Number = (1/Math.sqrt( cnx*cnx + cny*cny )) * elbowThickness;
					cnx *= c;
					cny *= c;

					var v1xPos:Number = v1x + cnx;
					var v1yPos:Number = v1y + cny;
					var v1xNeg:Number = v1x - cnx;
					var v1yNeg:Number = v1y - cny;

					vertices[vertCounter++] = v1xPos;
					vertices[vertCounter++] = v1yPos;
					vertices[vertCounter++] = 0;
					vertices[vertCounter++] = v1.r2;
					vertices[vertCounter++] = v1.g2;
					vertices[vertCounter++] = v1.b2;
					vertices[vertCounter++] = v1.a2;
					vertices[vertCounter++] = v1.u;
					vertices[vertCounter++] = 1;
					vertices[vertCounter++] = v1xNeg;
					vertices[vertCounter++] = v1yNeg;
					vertices[vertCounter++] = 0;
					vertices[vertCounter++] = v1.r1;
					vertices[vertCounter++] = v1.g1;
					vertices[vertCounter++] = v1.b1;
					vertices[vertCounter++] = v1.a1;
					vertices[vertCounter++] = v1.u;
					vertices[vertCounter++] = 0;

					if ( k < lineVerts - 1 )
					{
						var i2:int = (i << 1);
						indices[indiciesCounter++] = i2;
						indices[indiciesCounter++] = i2+2;
						indices[indiciesCounter++] = i2+1;
						indices[indiciesCounter++] = i2+1;
						indices[indiciesCounter++] = i2+2;
						indices[indiciesCounter++] = i2+3;
					}

					i++;
				}
			}
		}

		// Now dynamically making geometry during the update cycle in
		// a sensible fashion, drastically reducing CPU and memory load
		// and moving processing out of the render phase.
		override protected function buildGeometry():void {
		}

		override protected function shapeHitTestLocalInternal( localX:Number, localY:Number ):Boolean
		{
			return false;
//
//			if ( _line == null ) return false;
//			if ( _line.length < 2 ) return false;
//
//			var numLines:int = _line.length;
//
//			for ( var i: int = 1; i < numLines; i++ )
//			{
//				var v0:StrokeVertex = _line[i - 1];
//				var v1:StrokeVertex = _line[i];
//
//				var lineLengthSquared:Number = (v1.x - v0.x) * (v1.x - v0.x) + (v1.y - v0.y) * (v1.y - v0.y);
//
//				var interpolation:Number = ( ( ( localX - v0.x ) * ( v1.x - v0.x ) ) + ( ( localY - v0.y ) * ( v1.y - v0.y ) ) )  /	( lineLengthSquared );
//				if( interpolation < 0.0 || interpolation > 1.0 )
//					continue;   // closest point does not fall within the line segment
//
//				var intersectionX:Number = v0.x + interpolation * ( v1.x - v0.x );
//				var intersectionY:Number = v0.y + interpolation * ( v1.y - v0.y );
//
//				var distanceSquared:Number = (localX - intersectionX) * (localX - intersectionX) + (localY - intersectionY) * (localY - intersectionY);
//
//				var intersectThickness:Number = (v0.thickness * (1.0 - interpolation) + v1.thickness * interpolation); // Support for varying thicknesses
//
//				intersectThickness += _precisionHitTestDistance;
//
//				if ( distanceSquared <= intersectThickness * intersectThickness)
//					return true;
//			}
//
//			return false;
		}

		/** Transforms a point from the local coordinate system to parent coordinates.
         *  If you pass a 'resultPoint', the result will be stored in this point instead of
         *  creating a new object. */
        public function localToParent(localPoint:Point, resultPoint:Point=null):Point
        {
            return MatrixUtil.transformCoords(transformationMatrix, localPoint.x, localPoint.y, resultPoint);
        }

		public static function strokeCollideTest(s1:Stroke, s2:Stroke, intersectPoint:Point, staticLenIntersectPoints:Vector.<Point> = null ) : Boolean
		{
			return false;
//			
//			if ( s1 == null || s2 == null ||  s1._line == null || s1._line == null )
//				return false;
//
//			if ( sCollissionHelper == null )
//				sCollissionHelper  = new StrokeCollisionHelper();
//			sCollissionHelper.testIntersectPoint.x = 0;
//			sCollissionHelper.testIntersectPoint.y = 0;
//			intersectPoint.x = 0;
//			intersectPoint.y = 0;
//			var hasSameParent:Boolean = false;
//			if ( s1.parent == s2.parent )
//				hasSameParent = true;
//
//			s1.getBounds(hasSameParent ? s1.parent: s1.stage, sCollissionHelper.bounds1);
//			s2.getBounds(hasSameParent ? s2.parent: s2.stage, sCollissionHelper.bounds2);
//			if ( sCollissionHelper.bounds1.intersects(sCollissionHelper.bounds2) == false )
//				return false;
//
//			if ( intersectPoint == null )
//				intersectPoint = new Point();
//			var numLinesS1:int = s1._line.length;
//			var numLinesS2:int = s2._line.length;
//			var hasHit:Boolean = false;
//
//			if ( sCollissionHelper.s2v0Vector == null || sCollissionHelper.s2v0Vector.length < numLinesS2 )
//			{
//				sCollissionHelper.s2v0Vector = new Vector.<Point>(numLinesS2, true);
//				sCollissionHelper.s2v1Vector = new Vector.<Point>(numLinesS2, true);
//			}
//
//			var pointCounter:int = 0;
//			var maxPointCounter:int = 0;
//			if ( staticLenIntersectPoints != null )
//				maxPointCounter = staticLenIntersectPoints.length;
//
//			for ( var i: int = 1; i < numLinesS1; i++ )
//			{
//				var s1v0:StrokeVertex = s1._line[i - 1];
//				var s1v1:StrokeVertex = s1._line[i];
//
//				sCollissionHelper.localPT1.setTo(s1v0.x, s1v0.y);
//				sCollissionHelper.localPT2.setTo(s1v1.x, s1v1.y);
//				if ( hasSameParent )
//				{
//					s1.localToParent(sCollissionHelper.localPT1, sCollissionHelper.globalPT1);
//					s1.localToParent(sCollissionHelper.localPT2, sCollissionHelper.globalPT2);
//				}
//				else
//				{
//					s1.localToGlobal(sCollissionHelper.localPT1, sCollissionHelper.globalPT1);
//					s1.localToGlobal(sCollissionHelper.localPT2, sCollissionHelper.globalPT2);
//				}
//
//				for	( var j: int = 1; j < numLinesS2; j++ )
//				{
//					var s2v0:StrokeVertex = s2._line[j - 1];
//					var s2v1:StrokeVertex = s2._line[j];
//
//					if ( i == 1 )
//					{ // when we do the first loop through this set, we can cache all global points in s2v0Vector and s2v1Vector, to avoid slow localToGlobals on next loop passes
//						sCollissionHelper.localPT3.setTo(s2v0.x, s2v0.y);
//						sCollissionHelper.localPT4.setTo(s2v1.x, s2v1.y);
//
//						if ( hasSameParent )
//						{
//							s2.localToParent(sCollissionHelper.localPT3, sCollissionHelper.globalPT3);
//							s2.localToParent(sCollissionHelper.localPT4, sCollissionHelper.globalPT4);
//						}
//						else
//						{
//							s2.localToGlobal(sCollissionHelper.localPT3, sCollissionHelper.globalPT3);
//							s2.localToGlobal(sCollissionHelper.localPT4, sCollissionHelper.globalPT4);
//						}
//
//						if ( sCollissionHelper.s2v0Vector[j] == null )
//						{
//							sCollissionHelper.s2v0Vector[j] = new Point(sCollissionHelper.globalPT3.x, sCollissionHelper.globalPT3.y);
//							sCollissionHelper.s2v1Vector[j] = new Point(sCollissionHelper.globalPT4.x, sCollissionHelper.globalPT4.y);
//						}
//						else
//						{
//							sCollissionHelper.s2v0Vector[j].x = sCollissionHelper.globalPT3.x;
//							sCollissionHelper.s2v0Vector[j].y = sCollissionHelper.globalPT3.y;
//							sCollissionHelper.s2v1Vector[j].x = sCollissionHelper.globalPT4.x;
//							sCollissionHelper.s2v1Vector[j].y = sCollissionHelper.globalPT4.y;
//						}
//					}
//					else
//					{
//						sCollissionHelper.globalPT3.x = sCollissionHelper.s2v0Vector[j].x;
//						sCollissionHelper.globalPT3.y = sCollissionHelper.s2v0Vector[j].y;
//
//						sCollissionHelper.globalPT4.x = sCollissionHelper.s2v1Vector[j].x;
//						sCollissionHelper.globalPT4.y = sCollissionHelper.s2v1Vector[j].y;
//					}
//
//					if ( TriangleUtil.lineIntersectLine(sCollissionHelper.globalPT1.x, sCollissionHelper.globalPT1.y, sCollissionHelper.globalPT2.x, sCollissionHelper.globalPT2.y, sCollissionHelper.globalPT3.x, sCollissionHelper.globalPT3.y, sCollissionHelper.globalPT4.x, sCollissionHelper.globalPT4.y, sCollissionHelper.testIntersectPoint) )
//					{
//						if ( staticLenIntersectPoints != null && pointCounter < (maxPointCounter-1) )
//						{
//							if ( hasSameParent )
//								s1.parent.localToGlobal(sCollissionHelper.testIntersectPoint, staticLenIntersectPoints[pointCounter])
//							else
//							{
//								staticLenIntersectPoints[pointCounter].x = sCollissionHelper.testIntersectPoint.x;
//								staticLenIntersectPoints[pointCounter].y = sCollissionHelper.testIntersectPoint.y;
//							}
//							pointCounter++;
//							staticLenIntersectPoints[pointCounter].x = NaN;
//							staticLenIntersectPoints[pointCounter].y = NaN;
//						}
//
//						if ( sCollissionHelper.testIntersectPoint.length > intersectPoint.length )
//						{
//							if ( hasSameParent )
//								s1.parent.localToGlobal(sCollissionHelper.testIntersectPoint, intersectPoint);
//							else
//							{
//								intersectPoint.x = sCollissionHelper.testIntersectPoint.x;
//								intersectPoint.y = sCollissionHelper.testIntersectPoint.y;
//							}
//
//						}
//						hasHit = true;
//					}
//				}
//			}
//
//			return hasHit;
		}

		override public function render(renderSupport:RenderSupport, parentAlpha:Number):void {
			validateNow();
			renderInternal( renderSupport, parentAlpha, vertices, _numVertices / (Graphic.VERTEX_STRIDE), indices, _numIndices );
		}

		[inline]
		public function getX(idx:uint):Number { return vertices[idx * VERTEX_STRIDE + VERTEX_X]; }
		[inline]
		public function getY(idx:uint):Number { return vertices[idx * VERTEX_STRIDE + VERTEX_Y]; }
		[inline]
		public function getZ(idx:uint):Number { return vertices[idx * VERTEX_STRIDE + VERTEX_Z]; }
		[inline]
		public function getR(idx:uint):Number { return vertices[idx * VERTEX_STRIDE + VERTEX_R]; }
		[inline]
		public function getG(idx:uint):Number { return vertices[idx * VERTEX_STRIDE + VERTEX_G]; }
		[inline]
		public function getB(idx:uint):Number { return vertices[idx * VERTEX_STRIDE + VERTEX_B]; }
		[inline]
		public function getA(idx:uint):Number { return vertices[idx * VERTEX_STRIDE + VERTEX_A]; }
		[inline]
		public function getU(idx:uint):Number { return vertices[idx * VERTEX_STRIDE + VERTEX_U]; }
		[inline]
		public function getV(idx:uint):Number { return vertices[idx * VERTEX_STRIDE + VERTEX_V]; }

		[inline]
		public function setX(idx:uint, value:Number):void { vertices[idx * VERTEX_STRIDE + VERTEX_X] = value; }
		[inline]
		public function setY(idx:uint, value:Number):void { vertices[idx * VERTEX_STRIDE + VERTEX_Y] = value; }
		[inline]
		public function setZ(idx:uint, value:Number):void { vertices[idx * VERTEX_STRIDE + VERTEX_Z] = value; }
		[inline]
		public function setR(idx:uint, value:Number):void { vertices[idx * VERTEX_STRIDE + VERTEX_R] = value; }
		[inline]
		public function setG(idx:uint, value:Number):void { vertices[idx * VERTEX_STRIDE + VERTEX_G] = value; }
		[inline]
		public function setB(idx:uint, value:Number):void { vertices[idx * VERTEX_STRIDE + VERTEX_B] = value; }
		[inline]
		public function setA(idx:uint, value:Number):void { vertices[idx * VERTEX_STRIDE + VERTEX_A] = value; }
		[inline]
		public function setU(idx:uint, value:Number):void { vertices[idx * VERTEX_STRIDE + VERTEX_U] = value; }
		[inline]
		public function setV(idx:uint, value:Number):void { vertices[idx * VERTEX_STRIDE + VERTEX_V] = value; }

	}
}

import flash.geom.Point;
import flash.geom.Rectangle;

class StrokeCollisionHelper
{
	public var localPT1:Point = new Point();
	public var localPT2:Point = new Point();
	public var localPT3:Point = new Point();
	public var localPT4:Point = new Point();
	public var globalPT1:Point = new Point();
	public var globalPT2:Point = new Point();
	public var globalPT3:Point = new Point();
	public var globalPT4:Point = new Point();
	public var bounds1:Rectangle = new Rectangle();
	public var bounds2:Rectangle = new Rectangle();

	public var testIntersectPoint:Point = new Point();
	public var s1v0Vector:Vector.<Point> = null;
	public var s1v1Vector:Vector.<Point>= null;
	public var s2v0Vector:Vector.<Point>= null;
	public var s2v1Vector:Vector.<Point>= null;
}