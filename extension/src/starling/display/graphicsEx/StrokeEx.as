package starling.display.graphicsEx
{
	import flash.geom.Point;
	import flash.display.GraphicsStroke;
	import starling.display.util.StrokeExEvaluationData;
	import starling.textures.Texture;
	import starling.display.graphics.Stroke;
	import starling.display.graphics.StrokeVertex;
	
	public class StrokeEx extends Stroke
	{
		protected var _lineLength:Number = 0;
		
		static protected var sHelperPoint1:Point = new Point();
		static protected var sHelperPoint2:Point = new Point();
		static protected var sHelperPoint3:Point = new Point();
		
		public function StrokeEx()
		{
			super();
		}
		
		// Added to support post processing 
		public function get strokeVertices() : Vector.<StrokeVertex>
		{
			return _line;
		}
		
		override public function clearForReuse() : void
		{
			super.clearForReuse();
			_lineLength = 0;
		}
		
		override public function clear() : void
		{
			super.clear();
			_lineLength = 0;
		}
		
		public function invalidate() : void
		{
			if ( buffersInvalid == false )
				setGeometryInvalid();
			
		}
		
		public function strokeLength() : Number
		{
			if ( _lineLength == 0 )
			{
				if ( _line == null || _line.length < 2 )
					return 0;
				else
					return calcStrokeLength();
			}
			else 
				return _lineLength;
		}
		
		protected function calcStrokeLength() : Number
		{
			if ( _line == null || _line.length < 2 )
				_lineLength = 0;
			else
			{
				var i:int = 1;
				var prevVertex:StrokeVertex = _line[0];
				var thisVertex:StrokeVertex = null;
				
				for ( i = 1 ; i < _numVertices; ++i )
				{
					thisVertex = _line[i];
					
					var dx:Number = thisVertex.x - prevVertex.x;
					var dy:Number = thisVertex.y - prevVertex.y;
					var d:Number = Math.sqrt(dx * dx + dy * dy);
					_lineLength += d;
					prevVertex = thisVertex;
				}
			}
			return _lineLength;
		}
		
		
		public function evaluateGraphPoints(xValue:Number, positionArray:Vector.<Point>, tangentArray:Vector.<Point> = null, normalArray:Vector.<Point> = null  ) : Boolean
		{
			var dx:Number;
			var dy:Number;
			
			var prevVertex:StrokeVertex = _line[0];
			var thisVertex:StrokeVertex = null;
			var invD:Number ;
			
			for ( var i:int = 1; i < _numVertices; ++i )
			{
				thisVertex = _line[i];
				prevVertex = _line[i - 1];
				if ( thisVertex.degenerate )
					continue;
					
				if (( prevVertex.x < xValue && thisVertex.x >= xValue) ||  ( thisVertex.x < xValue && prevVertex.x >= xValue))
				{
					
					dx = thisVertex.x - prevVertex.x;
					dy = thisVertex.y - prevVertex.y;
					
					var lerp:Number = (( xValue - prevVertex.x  ) / (thisVertex.x - prevVertex.x));
					sHelperPoint1.x = xValue;
					sHelperPoint1.y = prevVertex.y + dy  * lerp;
					positionArray.push(sHelperPoint1.clone());
					
					if ( tangentArray )
					{
						invD = 1.0 / Math.sqrt(dx * dx + dy * dy);	
						sHelperPoint2.x = dx * invD;
						sHelperPoint2.y = dy * invD;
						tangentArray.push(sHelperPoint2.clone());
						if ( normalArray )
						{
							sHelperPoint3.x = -sHelperPoint2.y;
							sHelperPoint3.y =  sHelperPoint2.x;
							normalArray.push(sHelperPoint3.clone());
						}
					}
					else if ( normalArray )
					{
						invD = 1.0 / Math.sqrt(dx * dx + dy * dy);	
						sHelperPoint3.x = -dy * invD;
						sHelperPoint3.y =  dx * invD;
						normalArray.push(sHelperPoint3.clone());
					}
				}
			}
			return positionArray.length > 0;
		}
		
		
		public function evaluateGraphPoint(xValue:Number, position:Point, evaluationData:StrokeExEvaluationData = null, tangent:Point = null, normal:Point = null  ) : Boolean
		{
			if ( evaluationData && evaluationData.internalStroke != this)
			{
				throw new Error("StrokeEx: evaluateGraphPoint method called with evaluationData pointing to wrong stroke" );
			}
				
			var dx:Number;
			var dy:Number;
			
			var prevVertex:StrokeVertex = _line[0];
			var thisVertex:StrokeVertex = null;
			var invD:Number ;
			var startIndex:int = 1;
			
			if ( evaluationData && evaluationData.internalStartVertSearchIndex > 0 )
			{
				if ( xValue >= evaluationData.internalLastX )
					startIndex = evaluationData.internalStartVertSearchIndex; // Go forward
			}
				
			for ( var i:int = startIndex; i < _numVertices; ++i )
			{
				thisVertex = _line[i];
				prevVertex = _line[i - 1];
				if ( thisVertex.degenerate )
					continue;
				
				if (( prevVertex.x < xValue && thisVertex.x >= xValue) ||  ( thisVertex.x < xValue && prevVertex.x >= xValue))
				{
					dx = thisVertex.x - prevVertex.x;
					dy = thisVertex.y - prevVertex.y;
						
					var lerp:Number = (( xValue - prevVertex.x  ) / (thisVertex.x - prevVertex.x));
					position.x = xValue;
					position.y = prevVertex.y + dy  * lerp;
					
				
					if ( tangent )
					{
						invD = 1.0 / Math.sqrt(dx * dx + dy * dy);	
						tangent.x = dx * invD;
						tangent.y = dy * invD;
						if ( normal )
						{
							normal.x = -tangent.y;
							normal.y =  tangent.x;
						}
					}
					else if ( normal )
					{
						invD = 1.0 / Math.sqrt(dx * dx + dy * dy);	
						normal.x = -dy * invD;
						normal.y =  dx * invD;
					}
					if ( evaluationData )
					{
						evaluationData.internalLastX = xValue;
						evaluationData.internalStartVertSearchIndex = i - 1; // Set prev index as last vertex
					}
					return true;
				}
			}
				
			return false;
		}
		
		public function evaluate(t:Number, position:Point, evaluationData:StrokeExEvaluationData = null, tangent:Point = null, normal:Point = null ) : Boolean
		{
			if ( t < 0 || t > 1.0)
				return false;
				
			if ( evaluationData && evaluationData.internalStroke != this)
			{
				throw new Error("StrokeEx: evaluate method called with evaluationData pointing to wrong stroke" );
			}
			
			var lineTotalLength:Number = strokeLength();
			var querydistanceAlongLine:Number = t * lineTotalLength;
			var remainingUntilQueryDistance:Number = querydistanceAlongLine;
			
			var prevVertex:StrokeVertex = _line[0];
			var thisVertex:StrokeVertex = null;
			var accumulatedLength:Number = 0;	
			var startIndex:int = 1;
			var evaluateForward:Boolean = true;
			
			var debugNumLoops:int = 0;
			
			if ( evaluationData )
			{
				if ( evaluationData.internalStartVertSearchIndex >= 1 )
				{
					startIndex = evaluationData.internalStartVertSearchIndex;
					accumulatedLength = evaluationData.internalDistanceToPrevVert;
					accumulatedLength *= lineTotalLength / evaluationData.internalLastStrokeLength;
						
					remainingUntilQueryDistance -= evaluationData.internalDistanceToPrevVert;
				
					if ( t < evaluationData.internalLastT )
						evaluateForward = false;
				}
				evaluationData.internalLastStrokeLength = lineTotalLength;
			}
				
			var dx:Number;
			var dy:Number;
			var d:Number;
			var i:int;
			var dt:Number;
			var invD:Number;
			var oneMinusDT:Number;
			
			if ( evaluateForward )
			{
				for ( i = startIndex ; i < _numVertices; ++i )
				{
					thisVertex = _line[i];
					prevVertex = _line[i - 1];
				
					dx = thisVertex.x - prevVertex.x;
					dy = thisVertex.y - prevVertex.y;
					d  = Math.sqrt(dx * dx + dy * dy);
						
					if ( accumulatedLength + d > querydistanceAlongLine )
					{
						
						if ( d < 0.000001 )
							continue;

						invD = 1.0 / d;
						
						dt = remainingUntilQueryDistance * invD;
						oneMinusDT = (1.0 - dt);
						position.x = oneMinusDT * prevVertex.x + dt * thisVertex.x;
						position.y = oneMinusDT * prevVertex.y + dt * thisVertex.y;
						if ( evaluationData )
						{
							evaluationData.internalLastT = t;
							evaluationData.internalStartVertSearchIndex = i ;
							evaluationData.internalDistanceToPrevVert = accumulatedLength;
							evaluationData.distance = querydistanceAlongLine;
							evaluationData.thickness = oneMinusDT * prevVertex.thickness + dt * thisVertex.thickness; 
							evaluationData.r = oneMinusDT * prevVertex.r1 + dt * thisVertex.r1; 
							evaluationData.g = oneMinusDT * prevVertex.g1 + dt * thisVertex.g1; 
							evaluationData.b = oneMinusDT * prevVertex.b1 + dt * thisVertex.b1; 
							evaluationData.a = oneMinusDT * prevVertex.a1 + dt * thisVertex.a1; 
						}
						if ( tangent )
						{
							tangent.x = dx * invD;
							tangent.y = dy * invD;
							if ( normal )
							{
								normal.x = -tangent.y;
								normal.y =  tangent.x;
							}
						}
						else if ( normal )
						{
							normal.x = -dy * invD;
							normal.y =  dx * invD;
						}
						return true;
					}
					else
					{
						accumulatedLength += d;
						remainingUntilQueryDistance -= d;
					}
				}
			}
			else
			{
				for ( i = startIndex ; i > 0; --i )
				{
					thisVertex = _line[i];
					prevVertex = _line[i - 1];
				
					dx = thisVertex.x - prevVertex.x;
					dy = thisVertex.y - prevVertex.y;
					d  = Math.sqrt(dx * dx + dy * dy);
					
					if ( accumulatedLength < querydistanceAlongLine && accumulatedLength + d > querydistanceAlongLine )
					{
						if ( d < 0.000001 )
							continue;

						invD = 1.0 / d;
						
						dt = (querydistanceAlongLine - accumulatedLength ) * invD;
						oneMinusDT = (1.0 - dt);
						position.x = oneMinusDT * prevVertex.x + dt * thisVertex.x;
						position.y = oneMinusDT * prevVertex.y + dt * thisVertex.y;
						
						if ( evaluationData )
						{
							evaluationData.internalLastT = t;
							evaluationData.internalStartVertSearchIndex = i ;
							evaluationData.internalDistanceToPrevVert = accumulatedLength;
							evaluationData.distance = querydistanceAlongLine;
							evaluationData.thickness = oneMinusDT * prevVertex.thickness + dt * thisVertex.thickness; 
							evaluationData.r = oneMinusDT * prevVertex.r1 + dt * thisVertex.r1; 
							evaluationData.g = oneMinusDT * prevVertex.g1 + dt * thisVertex.g1; 
							evaluationData.b = oneMinusDT * prevVertex.b1 + dt * thisVertex.b1; 
							evaluationData.a = oneMinusDT * prevVertex.a1 + dt * thisVertex.a1; 
						}
						if ( tangent )
						{
							tangent.x = dx * invD;
							tangent.y = dy * invD;
							if ( normal )
							{
								normal.x = -tangent.y;
								normal.y =  tangent.x;
							}
						}
						else if ( normal )
						{
							normal.x = -dy * invD;
							normal.y =  dx * invD;
						}

						return true;
					}
					else
					{
						if ( i - 2 >= 0)
						{
							var prevPrevVertex:StrokeVertex = _line[i - 2];
							dx = prevVertex.x - prevPrevVertex.x;
							dy = prevVertex.y - prevPrevVertex.y;
							d  = Math.sqrt(dx * dx + dy * dy);
							accumulatedLength -= d;
						}
						else
							accumulatedLength = 0;
					}
				}
			}
			return false;
		}

		public static function blendStrokes(strokeA:StrokeEx, strokeB:StrokeEx, blendValue:Number, blendColor:Boolean, outputStroke:StrokeEx, minSamplePoints:int = -1) : void
		{
			var numPointsA:int = strokeA.numVertices;
			var numPointsB:int = strokeB.numVertices;
			var numPoints:int = Math.max(numPointsA, numPointsB);
			
			outputStroke.clearForReuse();
			var i:int;
			var oneMinusBlendValue:Number = (1.0 - blendValue);
			var newX:Number;
			var newY:Number;
			var newThickness:Number;
			var newR:int;
			var newG:int
			var newB:int;
			var newA : Number;
			
			if ( numPointsA == numPointsB )
			{
				for ( i = 0; i < numPoints; i++ )
				{
					newX = strokeA._line[i].x * oneMinusBlendValue + strokeB._line[i].x * blendValue;
					newY = strokeA._line[i].y * oneMinusBlendValue + strokeB._line[i].y * blendValue;
					newThickness = strokeA._line[i].thickness * oneMinusBlendValue + strokeB._line[i].thickness * blendValue;
					
					newR = strokeA._line[i].r1 * oneMinusBlendValue + strokeB._line[i].r1 * blendValue;
					newG = strokeA._line[i].g1 * oneMinusBlendValue + strokeB._line[i].g1 * blendValue;
					newB = strokeA._line[i].b1 * oneMinusBlendValue + strokeB._line[i].b1 * blendValue;
					newA = strokeA._line[i].a1 * oneMinusBlendValue + strokeB._line[i].a1 * blendValue;
					
					outputStroke.addVertex(newX, newY, newThickness, (newR << 16) + (newG << 8 ) + newB, newA, (newR << 16) + (newG << 8 ) + newB, newA);
				}
			}
			else
			{
				var evalContextA:StrokeExEvaluationData = new StrokeExEvaluationData(strokeA);
				var evalContextB:StrokeExEvaluationData = new StrokeExEvaluationData(strokeB);
				var t:Number = 0.0;
				
				if ( minSamplePoints > numPoints )
					numPoints = minSamplePoints;
				
				var invNumPoints:Number = 1.0 / numPoints;
				
				for ( i = 0; i <= numPoints; i++ )
				{
					strokeA.evaluate(t, sHelperPoint1, evalContextA);
					strokeB.evaluate(t, sHelperPoint2, evalContextB);
					
					newX = sHelperPoint1.x * oneMinusBlendValue + sHelperPoint2.x * blendValue;
					newY = sHelperPoint1.y * oneMinusBlendValue + sHelperPoint2.y * blendValue;
					newThickness = evalContextA.thickness * oneMinusBlendValue + evalContextB.thickness * blendValue;
					
					newR = 255 * (evalContextA.r * oneMinusBlendValue + evalContextB.r * blendValue);
					newG = 255 * (evalContextA.g * oneMinusBlendValue + evalContextB.g * blendValue);
					newB = 255 * (evalContextA.b * oneMinusBlendValue + evalContextB.b * blendValue);
					newA = evalContextA.a * oneMinusBlendValue + evalContextB.a * blendValue;
					outputStroke.addVertex(newX, newY, newThickness, (newR << 16) + (newG << 8 ) + newB, newA, (newR << 16) + (newG << 8 ) + newB, newA);
					t += invNumPoints;
				}
			}
		}
	}
		
}
