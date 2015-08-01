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
		
		public function evaluate(t:Number, position:Point, evaluationData:StrokeExEvaluationData = null, tangent:Point = null, normal:Point = null ) : Boolean
		{
			if ( t < 0 || t > 1.0)
				return false;
				
			if ( evaluationData && evaluationData.stroke != this)
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
			
			if ( evaluationData && evaluationData.startVertSearchIndex >= 1 )
			{
				startIndex = evaluationData.startVertSearchIndex;
				accumulatedLength = evaluationData.distanceToPrevVert;
				remainingUntilQueryDistance -= evaluationData.distanceToPrevVert;
				
				if ( t < evaluationData.lastT )
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
							evaluationData.lastT = t;
							evaluationData.startVertSearchIndex = i ;
							evaluationData.distanceToPrevVert = accumulatedLength;
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
							evaluationData.lastT = t;
							evaluationData.startVertSearchIndex = i ;
							evaluationData.distanceToPrevVert = accumulatedLength;
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
