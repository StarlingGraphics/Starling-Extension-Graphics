package starling.display.graphics
{
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import starling.core.RenderSupport;
	import starling.textures.Texture;
	import starling.utils.MatrixUtil;

	public class Stroke extends Graphic
	{
		protected var _moved        :Boolean;
		protected var _moveX        :Number;
		protected var _moveY        :Number;
		protected var _moveThickness:Number;
		protected var _moveR0       :Number;
		protected var _moveG0       :Number;
		protected var _moveB0       :Number;
		protected var _moveR1       :Number;
		protected var _moveG1       :Number;
		protected var _moveB1       :Number;
		protected var _moveAlpha    :Number;
		protected var _prevX        :Number;
		protected var _prevY        :Number;
		protected var _prevThickness:Number;
		protected var _prevX2       :Number;
		protected var _prevY2       :Number;
		protected var _prevU        :Number;
		protected var _prevR0       :Number;
		protected var _prevG0       :Number;
		protected var _prevB0       :Number;
		protected var _prevR1       :Number;
		protected var _prevG1       :Number;
		protected var _prevB1       :Number;
		protected var _prevAlpha0   :Number;
		protected var _prevAlpha1   :Number;
		protected var _numVertices  :uint;
		protected var _numIndices   :uint;
		protected var _numInSegment :uint;

		private static const c_u8MaxDivisor:Number = 1.0/255.0;
		private static const c_halfPI:Number = Math.PI * 0.5;
		private static const c_quarterPI:Number = Math.PI * 0.25;
		protected static var sCollissionHelper:StrokeCollisionHelper = null;

		public function Stroke(initialVerts:uint = 0)
		{
			super(true);
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

		[Inline]
		private static function extractR(value:uint):Number {
			return (value >> 16) * c_u8MaxDivisor;
		}

		[Inline]
		private static function extractG(value:uint):Number {
			return ((value & 0x00FF00) >> 8) * c_u8MaxDivisor;
		}

		[Inline]
		private static function extractB(value:uint):Number {
			return (value & 0x0000FF) * c_u8MaxDivisor;
		}

		public function lineTo(	x:Number, y:Number, thickness:Number = 1, color:uint = 0xFFFFFF,  alpha:Number = 1) : void
		{
			if (_moved == true) {
				move(_moveX, _moveY, _moveThickness, _moveR0, _moveG0, _moveB0, _moveAlpha,
					_moveR1, _moveG1, _moveB1, _moveAlpha);
			}
			var r:Number = extractR(color);
			var g:Number = extractG(color);
			var b:Number = extractB(color);
			addVertexInternal(x, y, thickness, r, g, b, alpha, r, g, b, alpha);
			isInvalid = true;
		}

		public function lineToFast(	x:Number, y:Number, thickness:Number = 1, r:Number = 1, g:Number = 1, b:Number = 1,  alpha:Number = 1) : void
		{
			if (_moved == true) {
				move(_moveX, _moveY, _moveThickness, _moveR0, _moveG0, _moveB0, _moveAlpha,
					_moveR1, _moveG1, _moveB1, _moveAlpha);
			}
			addVertexInternal(x, y, thickness, r, g, b, alpha, r, g, b, alpha);
			isInvalid = true;
		}

		public function moveTo( x:Number, y:Number, thickness:Number = 1, color:uint = 0xFFFFFF, alpha:Number = 1.0 ) : void
		{
			var r0:Number = extractR(color);
			var g0:Number = extractG(color);
			var b0:Number = extractB(color);
			_moved = true;
			_moveX = x;
			_moveY = y;
			_moveThickness = thickness;
			_moveR0 = r0;
			_moveG0 = g0;
			_moveB0 = b0;
			_moveAlpha = alpha;
			isInvalid = true;
		}

		public function moveToFast( x:Number, y:Number, thickness:Number = 1, r:Number = 1, g:Number = 1, b:Number = 1, alpha:Number = 1 ) : void
		{
			_moved = true;
			_moveX = x;
			_moveY = y;
			_moveThickness = thickness;
			_moveR0 = r;
			_moveG0 = g;
			_moveB0 = b;
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
			var r0:Number = extractR(color0);
			var g0:Number = extractG(color0);
			var b0:Number = extractB(color0);
			var r1:Number = extractR(color1);
			var g1:Number = extractG(color1);
			var b1:Number = extractB(color1);
			if (_numInSegment == 0) {
				move(x, y, thickness, r0, b0, g0, alpha0, r1, b1, g1, alpha1);
			} else {
				addVertexInternal(x, y, thickness, r0, b0, g0, alpha0, r1, b1, g1, alpha1);
			}
			isInvalid = true;
		}

		[Inline]
		private final function move( x:Number, y:Number, thickness:Number = 1,
									 r0:Number = 1, g0:Number = 1, b0:Number = 1, alpha0:Number = 1,
									 r1:Number = 1, g1:Number = 1, b1:Number = 1, alpha1:Number = 1) :void
		{
			_prevX = x;
			_prevY = y;
			_prevR0 = r0;
			_prevG0 = g0;
			_prevB0 = b0;
			_prevR1 = r1;
			_prevG1 = g1;
			_prevB1 = b1;
			_prevAlpha0 = alpha0;
			_prevAlpha1 = alpha1;
			_prevThickness = thickness;
			_prevU = 0;
			_numInSegment = 0;
			_moved = false;
		}

		[Inline]
		private final function updateBounds( x:Number, y:Number ):void {
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

		[Inline]
		private final function adjustPoints( x:Number, y:Number, nX:Number, nY:Number, thickness:Number):void {
			nX *= thickness;
			nY *= thickness;
			var v1xPos:Number = x + nX;
			var v1yPos:Number = y + nY;
			var v1xNeg:Number = x - nX;
			var v1yNeg:Number = y - nY;

			var prevIdx:uint = _numVertices - Graphic.VERTEX_STRIDE * 2;
			vertices[prevIdx++] = v1xPos;
			vertices[prevIdx++] = v1yPos;
			prevIdx += Graphic.VERTEX_STRIDE - 2;
			vertices[prevIdx++] = v1xNeg;
			vertices[prevIdx++] = v1yNeg;
		}

		[Inline]
		private final function addPoints( x:Number, y:Number, nX:Number, nY:Number, thickness:Number,
									r0:Number, g0:Number, b0:Number, r1:Number, g1:Number,
									b1:Number, alpha0:Number, alpha1:Number, u:Number ):void {
			const c_u8MaxDivisor:Number = 1.0 / 255;
			nX *= thickness;
			nY *= thickness;
			var v1xPos:Number = x + nX;
			var v1yPos:Number = y + nY;
			var v1xNeg:Number = x - nX;
			var v1yNeg:Number = y - nY;


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

		[Inline]
		private final function addVertexInternal(x:Number, y:Number, thickness:Number = 1,
											r0:Number = 1, g0:Number = 1, b0:Number = 1, alpha0:Number = 1,
											r1:Number = 1, g1:Number = 1, b1:Number = 1, alpha1:Number = 1):void
		{
			updateBounds(x,y);
			var dX:Number = x - _prevX;
			var dY:Number = y - _prevY;
			var len:Number = Math.sqrt(dX * dX + dY * dY);

			var u:Number = 0;
			var textures:Vector.<Texture> = _material.textures;
			if ( textures.length > 0 )
			{
				u = (len / textures[0].width) + _prevU;
				_prevU = u;
			}

			dX /= len;
			dY /= len;
			var nX:Number = -dY;
			var nY:Number = dX;

			// If only 1 vertex is in the segment
			// add the first two points
			if (_numInSegment == 0) {
//				var mark1:Number = Telemetry.spanMarker;
				addPoints(_prevX, _prevY, nX, nY, _prevThickness * 0.5, _prevR0, _prevG0, _prevB0,
				          _prevR1, _prevG1, _prevB1, _prevAlpha0, _prevAlpha1, 0.0);
				_numInSegment++;
//				Telemetry.sendSpanMetric("mark1", mark1);
			}
			// If 2 vertices are already in the segment
			// adjust the two previous points to be elbowed
			else if (_numInSegment > 1)
			{
//				var mark2:Number = Telemetry.spanMarker;
				var dX2:Number = _prevX - _prevX2;
				var dY2:Number = _prevY - _prevY2;
				var len2:Number = Math.sqrt(dX2 * dX2 + dY2 * dY2);
				dX2 /= len2;
				dY2 /= len2;
				const nX2:Number = -dY2;
				const nY2:Number = dX2;
				var elbowThickness:Number = _prevThickness*0.5;

				// Expensive trigonometric functions removed thanks
				// to my mathematical-computing friend Matt:
				// https://github.com/summercat
				var dot:Number = (nX * nX2 + nY * nY2);
				var midX:Number = (nX + nX2);
				var midY:Number = (nY + nY2);
				var midLen:Number = Math.sqrt(midX*midX + midY*midY);
				midX /= midLen;
				midY /= midLen;
				var midDot:Number = (midX * nX + midY * nY);
				var cosHalf:Number = midDot;
				elbowThickness /= cosHalf;

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

//				adjustPoints(_prevX, _prevY, cnx, cny, elbowThickness);
				cnx *= elbowThickness;
				cny *= elbowThickness;
				var v1xPos:Number = _prevX + cnx;
				var v1yPos:Number = _prevY + cny;
				var v1xNeg:Number = _prevX - cnx;
				var v1yNeg:Number = _prevY - cny;
				
				var prevIdx:uint = _numVertices - Graphic.VERTEX_STRIDE * 2;
				vertices[prevIdx++] = v1xPos;
				vertices[prevIdx++] = v1yPos;
				prevIdx += Graphic.VERTEX_STRIDE - 2;
				vertices[prevIdx++] = v1xNeg;
				vertices[prevIdx++] = v1yNeg;
//				Telemetry.sendSpanMetric("mark2", mark2);
			}

//			var mark3:Number = Telemetry.spanMarker;
			// Add two vertices as if it is the end
//			addPoints(x, y, nX, nY, thickness * 0.5, r0, g0, b0, r1, g1, b1, alpha0, alpha1, u);
			const c_u8MaxDivisor:Number = 1.0 / 255;
			nX *= thickness;
			nY *= thickness;
			var v1xPos_:Number = x + nX;
			var v1yPos_:Number = y + nY;
			var v1xNeg_:Number = x - nX;
			var v1yNeg_:Number = y - nY;
			
			vertices[_numVertices++] = v1xPos_;
			vertices[_numVertices++] = v1yPos_;
			vertices[_numVertices++] = 0;
			vertices[_numVertices++] = r1;
			vertices[_numVertices++] = g1;
			vertices[_numVertices++] = b1;
			vertices[_numVertices++] = alpha1;
			vertices[_numVertices++] = u;
			vertices[_numVertices++] = 1;
			vertices[_numVertices++] = v1xNeg_;
			vertices[_numVertices++] = v1yNeg_;
			vertices[_numVertices++] = 0;
			vertices[_numVertices++] = r0;
			vertices[_numVertices++] = g0;
			vertices[_numVertices++] = b0;
			vertices[_numVertices++] = alpha0;
			vertices[_numVertices++] = u;
			vertices[_numVertices++] = 0;
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
			_prevThickness = thickness;
			_numInSegment++;
//			Telemetry.sendSpanMetric("mark3", mark3);
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
			renderInternal( renderSupport, parentAlpha, vertices, indices, _numIndices /3 );
		}

		[Inline]
		public final function getX(idx:uint):Number { return vertices[idx * VERTEX_STRIDE + VERTEX_X]; }
		[Inline]
		public final function getY(idx:uint):Number { return vertices[idx * VERTEX_STRIDE + VERTEX_Y]; }
		[Inline]
		public final function getZ(idx:uint):Number { return vertices[idx * VERTEX_STRIDE + VERTEX_Z]; }
		[Inline]
		public final function getR(idx:uint):Number { return vertices[idx * VERTEX_STRIDE + VERTEX_R]; }
		[Inline]
		public final function getG(idx:uint):Number { return vertices[idx * VERTEX_STRIDE + VERTEX_G]; }
		[Inline]
		public final function getB(idx:uint):Number { return vertices[idx * VERTEX_STRIDE + VERTEX_B]; }
		[Inline]
		public final function getA(idx:uint):Number { return vertices[idx * VERTEX_STRIDE + VERTEX_A]; }
		[Inline]
		public final function getU(idx:uint):Number { return vertices[idx * VERTEX_STRIDE + VERTEX_U]; }
		[Inline]
		public final function getV(idx:uint):Number { return vertices[idx * VERTEX_STRIDE + VERTEX_V]; }

		[Inline]
		public final function setX(idx:uint, value:Number):void { vertices[idx * VERTEX_STRIDE + VERTEX_X] = value; }
		[Inline]
		public final function setY(idx:uint, value:Number):void { vertices[idx * VERTEX_STRIDE + VERTEX_Y] = value; }
		[Inline]
		public final function setZ(idx:uint, value:Number):void { vertices[idx * VERTEX_STRIDE + VERTEX_Z] = value; }
		[Inline]
		public final function setR(idx:uint, value:Number):void { vertices[idx * VERTEX_STRIDE + VERTEX_R] = value; }
		[Inline]
		public final function setG(idx:uint, value:Number):void { vertices[idx * VERTEX_STRIDE + VERTEX_G] = value; }
		[Inline]
		public final function setB(idx:uint, value:Number):void { vertices[idx * VERTEX_STRIDE + VERTEX_B] = value; }
		[Inline]
		public final function setA(idx:uint, value:Number):void { vertices[idx * VERTEX_STRIDE + VERTEX_A] = value; }
		[Inline]
		public final function setU(idx:uint, value:Number):void { vertices[idx * VERTEX_STRIDE + VERTEX_U] = value; }
		[Inline]
		public final function setV(idx:uint, value:Number):void { vertices[idx * VERTEX_STRIDE + VERTEX_V] = value; }

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