package starling.display.graphics
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import starling.core.RenderSupport;
	import starling.display.graphics.util.TriangleUtil;
	import starling.textures.Texture;
	import starling.utils.MatrixUtil;

	// NB: The action script compiler 2.0 is still in adolescence,
	//     so code needs to be manual inlines inlined until the new
	//     compiler becomes optimised.
	//
	//     This will mean there is deliberate duplication of code
	//     for performance reasons.  Please take care with any
	//     changes you make.  Manual inlines have been highlighted.

	public class Stroke extends Graphic
	{
		protected var _moved        :Boolean;
		protected var _moveX        :Number;
		protected var _moveY        :Number;
		protected var _moveThickness:Number;
		protected var _moveR       :Number;
		protected var _moveG       :Number;
		protected var _moveB       :Number;
		protected var _moveAlpha    :Number;
		protected var _prevX        :Number;
		protected var _prevY        :Number;
		protected var _prevThickness:Number;
		protected var _prevX2       :Number;
		protected var _prevY2       :Number;
		protected var _prevU        :Number;
		protected var _prevR       :Number;
		protected var _prevG       :Number;
		protected var _prevB       :Number;
		protected var _prevAlpha   :Number;
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
			_moved = false;
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
			var r:Number = extractR(color);
			var g:Number = extractG(color);
			var b:Number = extractB(color);
			lineToFast(x, y, thickness, r, g, b, alpha);
		}

		public function moveTo( x:Number, y:Number, thickness:Number = 1, color:uint = 0xFFFFFF, alpha:Number = 1.0 ) : void
		{
			var r:Number = extractR(color);
			var g:Number = extractG(color);
			var b:Number = extractB(color);
			moveToFast(x, y, thickness, r, g, b, alpha);
		}

		public static var numMoves:uint = 0;
		public function moveToFast( x:Number, y:Number, thickness:Number = 1, r:Number = 1, g:Number = 1, b:Number = 1, alpha:Number = 1 ) : void
		{
			numMoves++;
			_moved = true;
			_moveX = x;
			_moveY = y;
			_moveThickness = thickness;
			_moveR = r;
			_moveG = g;
			_moveB = b;
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
			moveTo(boundingBox.x, boundingBox.y, thickness);
			lineTo(boundingBox.x+boundingBox.width, boundingBox.y, thickness);
			lineTo(boundingBox.x+boundingBox.width, boundingBox.y+boundingBox.height, thickness);
			lineTo(boundingBox.x, boundingBox.y+boundingBox.height, thickness);
			lineTo(boundingBox.x, boundingBox.y, thickness);
		}

		[Inline]
		private final function move( x:Number, y:Number, thickness:Number = 1,
									 r:Number = 1, g:Number = 1, b:Number = 1, alpha:Number = 1) :void
		{
			_prevX = x;
			_prevY = y;
			_prevR = r;
			_prevG = g;
			_prevB = b;
			_prevAlpha = alpha;
			_prevThickness = thickness;
			_prevU = 0;
			_numInSegment = 0;
			_moved = false;
		}

		[Inline]
		private final function addPoints( x:Number, y:Number, nX:Number, nY:Number, thickness:Number,
									r:Number, g:Number, b:Number, alpha:Number, u:Number ):void {
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
			vertices[_numVertices++] = r;
			vertices[_numVertices++] = g;
			vertices[_numVertices++] = b;
			vertices[_numVertices++] = alpha;
			vertices[_numVertices++] = u;
			vertices[_numVertices++] = 1;
			vertices[_numVertices++] = v1xNeg;
			vertices[_numVertices++] = v1yNeg;
			vertices[_numVertices++] = 0;
			vertices[_numVertices++] = r;
			vertices[_numVertices++] = g;
			vertices[_numVertices++] = b;
			vertices[_numVertices++] = alpha;
			vertices[_numVertices++] = u;
			vertices[_numVertices++] = 0;
		}

		public static var numLines:uint = 0;
		public function lineToFast(	x:Number, y:Number, thickness:Number = 1, r:Number = 1, 
									g:Number = 1, b:Number = 1,  alpha:Number = 1) : void
		{
			numLines++;
			if (_moved == true) {
				move(_moveX, _moveY, _moveThickness, _moveR, _moveG, _moveB, _moveAlpha);
			} else if (_numInSegment == 0) {
				moveToFast(x, y, thickness, r, g, b, alpha);
				return;
			}

			// This could be made more accurate by taking the final vertices into account.
			// Ideally it could be computed lazily, so that the cost can be avoided if
			// unneeded by the client software.
			if(x < minBounds.x) {
				minBounds.x = x;
			} else if(x > maxBounds.x) {
				maxBounds.x = x;
			}

			if(y < minBounds.y) {
				minBounds.y = y;
			} else if(y > maxBounds.y) {
				maxBounds.y = y;
			}

			if ( maxBounds.x == Number.NEGATIVE_INFINITY )
				maxBounds.x = x;
			if ( maxBounds.y == Number.NEGATIVE_INFINITY )
				maxBounds.y = y;

			var dX:Number = x - _prevX;
			var dY:Number = y - _prevY;
			// Manual inline: calculate normal
			var len:Number = Math.sqrt(dX * dX + dY * dY);
			dX /= len;
			dY /= len;
			var nOX:Number = -dY;
			var nOY:Number = dX;

			var u:Number = 0;
			var textures:Vector.<Texture> = _material.textures;
			if ( textures.length > 0 )
			{
				u = (len / textures[0].width) + _prevU;
				_prevU = u;
			}


			// If only 1 vertex is in the segment
			// add the first two points
			if (_numInSegment == 0) {
				addPoints(_prevX, _prevY, nOX, nOY, _prevThickness * 0.5,
						  _prevR, _prevG, _prevB, _prevAlpha, 0.0);
				_numInSegment++;
			}
			// If 2 vertices are already in the segment
			// adjust the two previous points to be elbowed
			else if (_numInSegment > 1)
			{
				// Manual inline: elbow()
				var dX2:Number = _prevX - _prevX2;
				var dY2:Number = _prevY - _prevY2;
				// Manual inline: calculate normal
				var len2:Number = Math.sqrt(dX2 * dX2 + dY2 * dY2);
				dX2 /= len2;
				dY2 /= len2;
				const nIX:Number = -dY2;
				const nIY:Number = dX2;
				var elbowThickness:Number = _prevThickness*0.5;

				var dot:Number = (nOX * nIX + nOY * nIY);
				var midX:Number = (nOX + nIX);
				var midY:Number = (nOY + nIY);
				// Manual inline: calculate normal
				var midLen:Number = Math.sqrt(midX*midX + midY*midY);
				midX /= midLen;
				midY /= midLen;

				var midDot:Number = (midX * nOX + midY * nOY);
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

				// Manual inline: calculate normal
				var cnx:Number = nIX + nOX;
				var cny:Number = nIY + nOY;
				var c:Number = (1/Math.sqrt( cnx*cnx + cny*cny ));
				cnx *= c;
				cny *= c;

				// Manual inline: adjustPoints(..)
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
			}

			// Add two vertices as if it is the end
			// Manual inline: addPoints(..)
			const c_u8MaxDivisor:Number = 1.0 / 255;
			nOX *= thickness;
			nOY *= thickness;
			var v1xPos_:Number = x + nOX;
			var v1yPos_:Number = y + nOY;
			var v1xNeg_:Number = x - nOX;
			var v1yNeg_:Number = y - nOY;

			vertices[_numVertices++] = v1xPos_;
			vertices[_numVertices++] = v1yPos_;
			vertices[_numVertices++] = 0;
			vertices[_numVertices++] = r;
			vertices[_numVertices++] = g;
			vertices[_numVertices++] = b;
			vertices[_numVertices++] = alpha;
			vertices[_numVertices++] = u;
			vertices[_numVertices++] = 1;
			vertices[_numVertices++] = v1xNeg_;
			vertices[_numVertices++] = v1yNeg_;
			vertices[_numVertices++] = 0;
			vertices[_numVertices++] = r;
			vertices[_numVertices++] = g;
			vertices[_numVertices++] = b;
			vertices[_numVertices++] = alpha;
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
			isInvalid = true;
		}

		// Makes a final line to the beginning of the segment and
		// creates a miter join.
		public function close():void {
			if (_numInSegment < 3) return;
			lineToFast(_moveX, _moveY, _moveThickness, _moveR, _moveG, _moveB, _moveAlpha);
			var firstIdx2:uint = Graphic.VERTEX_STRIDE;
			var prevIdx:uint = _numVertices - Graphic.VERTEX_STRIDE * 2;
			var prevIdx2:uint = prevIdx + Graphic.VERTEX_STRIDE;
			var dIX:Number = _prevX - _prevX2;
			var dIY:Number = _prevY - _prevY2;
			var len2:Number = Math.sqrt(dIX * dIX + dIY * dIY);
			dIX /= len2;
			dIY /= len2;
			const nIX:Number = -dIY;
			const nIY:Number = dIX;
			var x1:Number = vertices[0];
			var y1:Number = vertices[1];
			var x2:Number = vertices[Graphic.VERTEX_STRIDE * 2];
			var y2:Number = vertices[Graphic.VERTEX_STRIDE * 2 +1];
			var dOX:Number = x2 - x1;
			var dOY:Number = y2 - y1;
			var len:Number = Math.sqrt(dOX * dOX + dOY * dOY);
			dOX /= len;
			dOY /= len;
			const nOX:Number = -dOY;
			const nOY:Number = dOX;
			elbow(nIX, nIY, nOX, nOY, prevIdx);
			vertices[0] = vertices[prevIdx];
			vertices[1] = vertices[prevIdx+1];
			vertices[firstIdx2 + 0] = vertices[prevIdx2];
			vertices[firstIdx2 + 1] = vertices[prevIdx2+1];
		}

		private function elbow(nIX:Number, nIY:Number, nOX:Number, nOY:Number, idx:uint):void {
			var elbowThickness:Number = _prevThickness*0.5;

			// Expensive trigonometric functions removed thanks
			// to my mathematical-computing friend Matt:
			// https://github.com/summercat
			var dot:Number = (nOX * nIX + nOY * nIY);
			var midX:Number = (nOX + nIX);
			var midY:Number = (nOY + nIY);
			var midLen:Number = Math.sqrt(midX*midX + midY*midY);
			midX /= midLen;
			midY /= midLen;
			var midDot:Number = (midX * nOX + midY * nOY);
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

			var cnx:Number = nIX + nOX;
			var cny:Number = nIY + nOY;
			var c:Number = (1/Math.sqrt( cnx*cnx + cny*cny ));
			cnx *= c;
			cny *= c;

			cnx *= elbowThickness;
			cny *= elbowThickness;
			var v1xPos:Number = _prevX + cnx;
			var v1yPos:Number = _prevY + cny;
			var v1xNeg:Number = _prevX - cnx;
			var v1yNeg:Number = _prevY - cny;

			vertices[idx++] = v1xPos;
			vertices[idx++] = v1yPos;
			idx += Graphic.VERTEX_STRIDE - 2;
			vertices[idx++] = v1xNeg;
			vertices[idx++] = v1yNeg;
		}

		// Now dynamically making geometry during the update cycle in
		// a sensible fashion, drastically reducing CPU and memory load
		// and moving processing out of the render phase.
		override protected function buildGeometry():void {
		}

		private function getPointThickness(pointIdx:int):Number
		{
			var thickness:Number;
			var vertIndex:uint = pointIdx * 2;
			var dX:Number = getX(vertIndex) - getX(vertIndex + 1);
			var dY:Number = getY(vertIndex) - getY(vertIndex + 1);
			return Math.sqrt(dX*dX + dY*dY) * 0.5;
		}

		private function getPointPosition(pointIdx:int, prealloc:Point = null):Point
		{
			var point:Point = prealloc;
			if ( point == null )
				point = new Point();

			var vertIndex:uint = pointIdx * 2;
			point.x = (getX(vertIndex) + getX(vertIndex + 1)) * 0.5;
			point.y = (getY(vertIndex) + getY(vertIndex + 1)) * 0.5;
			return point;
		}

		// Ideally this should be part of a separate physics system rather
		// than coupled with the graphics implementation.
		// Function supplied for completeness but not optimal.
		override protected function shapeHitTestLocalInternal( localX:Number, localY:Number ):Boolean
		{
			var numLines:int = numVertices / Graphic.VERTEX_STRIDE * 2;
			if ( numLines < 2 ) return false;

			var v0:Point = new Point();
			var v1:Point = new Point();
			for ( var i: int = 1; i < numLines; i++ )
			{
				getPointPosition((i - 1), v0);
				getPointPosition(i, v1);
				var v0T:Number = getPointThickness(i-1);
				var v1T:Number = getPointThickness(i-1);

				var lineLengthSquared:Number = (v1.x - v0.x) * (v1.x - v0.x) + (v1.y - v0.y) * (v1.y - v0.y);

				var interpolation:Number = ( ( ( localX - v0.x ) * ( v1.x - v0.x ) ) + ( ( localY - v0.y ) * ( v1.y - v0.y ) ) )  /	( lineLengthSquared );
				if( interpolation < 0.0 || interpolation > 1.0 )
					continue;   // closest point does not fall within the line segment

				var intersectionX:Number = v0.x + interpolation * ( v1.x - v0.x );
				var intersectionY:Number = v0.y + interpolation * ( v1.y - v0.y );

				var distanceSquared:Number = (localX - intersectionX) * (localX - intersectionX) + (localY - intersectionY) * (localY - intersectionY);

				var intersectThickness:Number = (v0T * (1.0 - interpolation) + v1T * interpolation); // Support for varying thicknesses

				intersectThickness += _precisionHitTestDistance;

				if ( distanceSquared <= intersectThickness * intersectThickness)
					return true;
			}

			return false;
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

			if ( s1 == null || s2 == null ||  s1.numVertices == 0 || s1.numVertices == 0 )
				return false;

			if ( sCollissionHelper == null )
				sCollissionHelper  = new StrokeCollisionHelper();
			sCollissionHelper.testIntersectPoint.x = 0;
			sCollissionHelper.testIntersectPoint.y = 0;
			intersectPoint.x = 0;
			intersectPoint.y = 0;
			var hasSameParent:Boolean = false;
			if ( s1.parent == s2.parent )
				hasSameParent = true;

			s1.getBounds(hasSameParent ? s1.parent: s1.stage, sCollissionHelper.bounds1);
			s2.getBounds(hasSameParent ? s2.parent: s2.stage, sCollissionHelper.bounds2);
			if ( sCollissionHelper.bounds1.intersects(sCollissionHelper.bounds2) == false )
				return false;

			if ( intersectPoint == null )
				intersectPoint = new Point();
			var numLinesS1:int = s1.numVertices / Graphic.VERTEX_STRIDE;
			var numLinesS2:int = s2.numVertices / Graphic.VERTEX_STRIDE;
			var hasHit:Boolean = false;

			if ( sCollissionHelper.s2v0Vector == null || sCollissionHelper.s2v0Vector.length < numLinesS2 )
			{
				sCollissionHelper.s2v0Vector = new Vector.<Point>(numLinesS2, true);
				sCollissionHelper.s2v1Vector = new Vector.<Point>(numLinesS2, true);
			}

			var pointCounter:int = 0;
			var maxPointCounter:int = 0;
			if ( staticLenIntersectPoints != null )
				maxPointCounter = staticLenIntersectPoints.length;

			for ( var i: int = 1; i < numLinesS1; i++ )
			{
				var s1v0:Point = s1.getPointPosition(i - 1);
				var s1v1:Point = s1.getPointPosition(i);

				sCollissionHelper.localPT1.setTo(s1v0.x, s1v0.y);
				sCollissionHelper.localPT2.setTo(s1v1.x, s1v1.y);
				if ( hasSameParent )
				{
					s1.localToParent(sCollissionHelper.localPT1, sCollissionHelper.globalPT1);
					s1.localToParent(sCollissionHelper.localPT2, sCollissionHelper.globalPT2);
				}
				else
				{
					s1.localToGlobal(sCollissionHelper.localPT1, sCollissionHelper.globalPT1);
					s1.localToGlobal(sCollissionHelper.localPT2, sCollissionHelper.globalPT2);
				}

				for	( var j: int = 1; j < numLinesS2; j++ )
				{
					var s2v0:Point = s2.getPointPosition(j - 1);
					var s2v1:Point = s2.getPointPosition(j);

					if ( i == 1 )
					{ // when we do the first loop through this set, we can cache all global points in s2v0Vector and s2v1Vector, to avoid slow localToGlobals on next loop passes
						sCollissionHelper.localPT3.setTo(s2v0.x, s2v0.y);
						sCollissionHelper.localPT4.setTo(s2v1.x, s2v1.y);

						if ( hasSameParent )
						{
							s2.localToParent(sCollissionHelper.localPT3, sCollissionHelper.globalPT3);
							s2.localToParent(sCollissionHelper.localPT4, sCollissionHelper.globalPT4);
						}
						else
						{
							s2.localToGlobal(sCollissionHelper.localPT3, sCollissionHelper.globalPT3);
							s2.localToGlobal(sCollissionHelper.localPT4, sCollissionHelper.globalPT4);
						}

						if ( sCollissionHelper.s2v0Vector[j] == null )
						{
							sCollissionHelper.s2v0Vector[j] = new Point(sCollissionHelper.globalPT3.x, sCollissionHelper.globalPT3.y);
							sCollissionHelper.s2v1Vector[j] = new Point(sCollissionHelper.globalPT4.x, sCollissionHelper.globalPT4.y);
						}
						else
						{
							sCollissionHelper.s2v0Vector[j].x = sCollissionHelper.globalPT3.x;
							sCollissionHelper.s2v0Vector[j].y = sCollissionHelper.globalPT3.y;
							sCollissionHelper.s2v1Vector[j].x = sCollissionHelper.globalPT4.x;
							sCollissionHelper.s2v1Vector[j].y = sCollissionHelper.globalPT4.y;
						}
					}
					else
					{
						sCollissionHelper.globalPT3.x = sCollissionHelper.s2v0Vector[j].x;
						sCollissionHelper.globalPT3.y = sCollissionHelper.s2v0Vector[j].y;

						sCollissionHelper.globalPT4.x = sCollissionHelper.s2v1Vector[j].x;
						sCollissionHelper.globalPT4.y = sCollissionHelper.s2v1Vector[j].y;
					}

					if ( TriangleUtil.lineIntersectLine(sCollissionHelper.globalPT1.x, sCollissionHelper.globalPT1.y, sCollissionHelper.globalPT2.x, sCollissionHelper.globalPT2.y, sCollissionHelper.globalPT3.x, sCollissionHelper.globalPT3.y, sCollissionHelper.globalPT4.x, sCollissionHelper.globalPT4.y, sCollissionHelper.testIntersectPoint) )
					{
						if ( staticLenIntersectPoints != null && pointCounter < (maxPointCounter-1) )
						{
							if ( hasSameParent )
								s1.parent.localToGlobal(sCollissionHelper.testIntersectPoint, staticLenIntersectPoints[pointCounter])
							else
							{
								staticLenIntersectPoints[pointCounter].x = sCollissionHelper.testIntersectPoint.x;
								staticLenIntersectPoints[pointCounter].y = sCollissionHelper.testIntersectPoint.y;
							}
							pointCounter++;
							staticLenIntersectPoints[pointCounter].x = NaN;
							staticLenIntersectPoints[pointCounter].y = NaN;
						}

						if ( sCollissionHelper.testIntersectPoint.length > intersectPoint.length )
						{
							if ( hasSameParent )
								s1.parent.localToGlobal(sCollissionHelper.testIntersectPoint, intersectPoint);
							else
							{
								intersectPoint.x = sCollissionHelper.testIntersectPoint.x;
								intersectPoint.y = sCollissionHelper.testIntersectPoint.y;
							}

						}
						hasHit = true;
					}
				}
			}

			return hasHit;
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