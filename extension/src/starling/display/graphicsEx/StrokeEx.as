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
		static protected var sHelperPoint:Point = new Point();
		static protected var sHelperTangentPoint:Point = new Point();
		static protected var sHelperNormalPoint:Point = new Point();
		
		public function StrokeEx()
		{
			super();
		}
		
		// Added to support post processing 
		public function get strokeVertices() : Vector.<StrokeVertex>
		{
			return _line;
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
					sHelperPoint.x = xValue;
					sHelperPoint.y = prevVertex.y + dy  * lerp;
					positionArray.push(sHelperPoint.clone());
					
					if ( tangentArray )
					{
						invD = 1.0 / Math.sqrt(dx * dx + dy * dy);	
						sHelperTangentPoint.x = dx * invD;
						sHelperTangentPoint.y = dy * invD;
						tangentArray.push(sHelperTangentPoint.clone());
						if ( normalArray )
						{
							sHelperNormalPoint.x = -sHelperTangentPoint.y;
							sHelperNormalPoint.y =  sHelperTangentPoint.x;
							normalArray.push(sHelperNormalPoint.clone());
						}
					}
					else if ( normalArray )
					{
						invD = 1.0 / Math.sqrt(dx * dx + dy * dy);	
						sHelperNormalPoint.x = -dy * invD;
						sHelperNormalPoint.y =  dx * invD;
						normalArray.push(sHelperNormalPoint.clone());
					}
				}
			}
			return positionArray.length > 0;
		}
		
		
		public function evaluateGraphPoint(xValue:Number, position:Point, tangent:Point = null, normal:Point = null  ) : Boolean
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
			
			if ( evaluationData && evaluationData.internalStartVertSearchIndex >= 1 )
			{
				startIndex = evaluationData.internalStartVertSearchIndex;
				accumulatedLength = evaluationData.internalDistanceToPrevVert;
				remainingUntilQueryDistance -= evaluationData.internalDistanceToPrevVert;
				
				if ( t < evaluationData.internalLastT )
					evaluateForward = false;
			}
				
			var dx:Number;
			var dy:Number;
			var d:Number;
			var i:int;
			var dt:Number;
			var invD:Number;
			
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
						position.x = (1.0-dt) * prevVertex.x + dt * thisVertex.x;
						position.y = (1.0 - dt) * prevVertex.y + dt * thisVertex.y;
						if ( evaluationData )
						{
							evaluationData.internalLastT = t;
							evaluationData.internalStartVertSearchIndex = i ;
							evaluationData.internalDistanceToPrevVert = accumulatedLength;
							evaluationData.distance = querydistanceAlongLine;
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
						position.x = (1.0 - dt) * prevVertex.x + dt * thisVertex.x;
						position.y = (1.0 - dt) * prevVertex.y + dt * thisVertex.y;
						
						if ( evaluationData )
						{
							evaluationData.internalLastT = t;
							evaluationData.internalStartVertSearchIndex = i ;
							evaluationData.internalDistanceToPrevVert = accumulatedLength;
							evaluationData.distance = querydistanceAlongLine;
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

	}
		
}
