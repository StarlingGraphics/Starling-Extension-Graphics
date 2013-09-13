package starling.display.graphicsEx
{
	import flash.geom.Point;

	import starling.display.Graphics;
	import starling.textures.Texture;
	import starling.display.materials.IMaterial;
	import starling.display.DisplayObjectContainer;
	import starling.display.util.CurveUtil;

	public class GraphicsEx extends Graphics
	{
		// Added to support dynamic stroke thickness and alpha between control points for the Extended Ex part of the API
		private var _strokeThicknessLast    :Number = NaN; // Used to keep track of last thickness
		private var _strokeAlphaLast		:Number = NaN; // Used to keep track of last alpha

		public function GraphicsEx(displayObjectContainer:DisplayObjectContainer)
		{
			super(displayObjectContainer);
		}

		override public function clear():void
		{
			super.clear();

			_strokeThicknessLast = NaN;
			_strokeAlphaLast = NaN;
		}

		/*
		 * Added code to expand the API. With interpolated thickness, you get
		 * a greater freedom in designing curves fitting your games.
		 * The "thickness" parameter should be interpreted as:
		 * "Interpolate to this "thickness" at the end of the segment"
		 * The segment will then go from "last thickness" as set by, for example,
		 * lineMaterialEx or previous call to curveToEx, to this new thickness.
		 *
		 */

		public function lineToEx(x:Number, y:Number, thickness:Number = -1, alpha:Number = -1):void
		{
			lineToExInternal(x, y, thickness, alpha);
			if ( thickness != -1 )
				_strokeThicknessLast = thickness;
			else
				_strokeThicknessLast = _strokeThickness;

			if ( alpha != -1 )
				_strokeAlphaLast = alpha;
			else
				_strokeAlphaLast = _strokeAlpha;


		}

		/*
		 * The reason for an lineToExInternal method is that the public method lineToEx
		 * needs to set _strokeThicknessLast, but when lineToExInternal is called from
		 * curveToEx, the _strokeThicknessLast variable should not be updated until
		 * after the full curveToEx call has been completed.
		 * So these had to be separated.
		 */
		protected function lineToExInternal(x:Number, y:Number, thickness:Number = -1, alpha:Number = -1):void
		{
			if (!_currentStroke && _strokeThickness > 0)
			{
				if (_strokeTexture)
				{
					beginTextureStroke();
				}
				else if ( _strokeMaterial )
				{
					beginMaterialStroke();
				}
				else
				{
					beginStroke();
				}
			}

			if ( _currentStroke && ( _strokeInterrupted || _currentStroke.numVertices == 0 ) && isNaN(_currentX) == false )
			{
				if ( thickness != -1 )
					_currentStroke.addVertex( _currentX, _currentY, _strokeThicknessLast, 0xFFFFFF, _strokeAlphaLast, 0xFFFFFF, _strokeAlphaLast );
				else
					_currentStroke.addVertex( _currentX, _currentY, _strokeThickness , 0xFFFFFF, _strokeAlphaLast, 0xFFFFFF, _strokeAlphaLast);

				_strokeInterrupted  = false;
			}

			if ( isNaN(_currentX) )
			{
				moveTo(0,0);
			}

			if ( _currentStroke && _strokeThickness > 0 )
			{
				if ( thickness != -1 )
				{
					_currentStroke.addVertex( x, y, thickness, 0xFFFFFF, alpha, 0xFFFFFF, alpha );
				}
				else
				{
					_currentStroke.addVertex( x, y, _strokeThickness, 0xFFFFFF, alpha, 0xFFFFFF, alpha );
				}
			}

			if (_currentFill)
			{
				_currentFill.addVertex( x, y );
			}
			_currentX = x;
			_currentY = y;
		}


		protected function drawPointsInternal(points:Vector.<Number>, param:GraphicsExData) : void
		{
			var lerp:Number;
			var t:Number;
			var a:Number;

			var targetThickness:Number = _strokeThickness;
			if ( param && param.endThickness > -1 )
				targetThickness = param.endThickness;

			var targetAlpha:Number = _strokeAlpha;
			if ( param && param.endAlpha > -1 )
				targetAlpha = param.endAlpha;

			var L:int = points.length;
			if ( L > 0 )
			{
				var invHalfL:Number = 1.0/(0.5*L);
				for ( var i:int = 0; i < L; i+=2 )
				{
					var x:Number = points[i];
					var y:Number = points[i+1];

					if ( i == 0 && isNaN(_currentX) )
					{
						moveTo( x, y );
					}
					else
					{
						lerp = Number(i>>1) * invHalfL;
						if ( param != null )
						{
							if ( param.thicknessCallback != null )
							{
								t = param.thicknessCallback(_strokeThicknessLast, targetThickness, lerp);

								a = _strokeAlphaLast * (1.0 - lerp) + targetAlpha * lerp;
								if ( param.alphaCallback != null )
									a = param.alphaCallback(_strokeAlphaLast, targetAlpha, lerp);

								lineToExInternal(x,y,t,a);
							}
							else if ( param.endThickness > -1 )
							{
								t = _strokeThicknessLast * (1.0 - lerp) + targetThickness * lerp;

								a = _strokeAlphaLast * (1.0 - lerp) + targetAlpha * lerp;

								if ( param.alphaCallback != null )
									a = param.alphaCallback(_strokeAlphaLast, targetAlpha, lerp);

								lineToExInternal(x,y,t,a);
							}
							else
							{
								a = _strokeAlphaLast * (1.0 - lerp) + targetAlpha * lerp;
								if ( param.alphaCallback != null )
									a = param.alphaCallback(_strokeAlphaLast, targetAlpha, lerp);

								lineToEx(x, y, targetThickness, a);
							}
						}
						else
							lineTo(x, y);
					}
				}
			}
			_strokeThicknessLast = targetThickness;
			_strokeAlphaLast = a;

		}


		public function curveToEx(cx:Number, cy:Number, a2x:Number, a2y:Number, param:GraphicsExData, error:Number = BEZIER_ERROR ):void
		{
			var startX:Number = _currentX;
			var startY:Number = _currentY;

			if ( isNaN(startX) )
			{
				startX = 0;
				startY = 0;
			}

			var points:Vector.<Number> = CurveUtil.quadraticCurve(startX, startY, cx, cy, a2x, a2y, error);

			drawPointsInternal(points, param);


			_currentX = a2x;
			_currentY = a2y;
		}

		public function cubicCurveToEx(c1x:Number, c1y:Number, c2x:Number, c2y:Number, a2x:Number, a2y:Number, param:GraphicsExData, error:Number = BEZIER_ERROR ):void
		{
			var startX:Number = _currentX;
			var startY:Number = _currentY;

			if ( isNaN(startX) )
			{
				startX = 0;
				startY = 0;
			}

			var points:Vector.<Number> = CurveUtil.cubicCurve(startX, startY, c1x, c1y, c2x, c2y, a2x, a2y, error);

			drawPointsInternal(points, param);

			_currentX = a2x;
			_currentY = a2y;
		}

		/**
		 * performs the natural cubic slipne transformation
		 * @param	controlPoints a Vector.<Point> of the control points
		 * @param	closed a boolean to tell wether the curve is opened or closed
		 * @param   steps - an int indicating the number of steps between control points
		 */

		public function naturalCubicSplineTo( controlPoints:Array, closed:Boolean, steps:int = 4, gfxDataVec:Vector.<GraphicsExData> = null) : void
		{
			var i:int = 0;
			var j:Number = 0;

			var numPoints:int = controlPoints.length;
			var xpoints:Vector.<Number> = new Vector.<Number>(numPoints, true);
			var ypoints:Vector.<Number> = new Vector.<Number>(numPoints, true);



			for ( i = 0; i < controlPoints.length; i++ )
			{
				xpoints[i] = controlPoints[ i ].x ;
				ypoints[i] = controlPoints[ i ].y ;
			}

			var X:Vector.<Cubic>;
			var Y:Vector.<Cubic>;

			if ( closed )
			{
				X = calcClosedNaturalCubic(	numPoints-1, xpoints );
				Y = calcClosedNaturalCubic(	numPoints-1, ypoints );
			}
			else
			{
				X = calcNaturalCubic(	numPoints - 1, xpoints );
				Y = calcNaturalCubic(	numPoints - 1, ypoints );
			}


			/* very crude technique - just break each segment up into _steps lines */
			var points:Vector.<Number> = new Vector.<Number>(2*steps, true);

			var invSteps:Number = 1.0 / steps;
			for ( i = 0; i < X.length; i++)
			{
				for ( j = 0; j < steps; j++)
				{
					var u:Number = j * invSteps;
					var valueX:Number = X[i].eval(u);
					var valueY:Number = Y[i].eval(u);
					points[j*2  ] = valueX;
					points[j*2+1] = valueY;
				}
				var gfxData:GraphicsExData = null;
				if ( gfxDataVec != null )
					gfxData = gfxDataVec[i];

				drawPointsInternal(points, gfxData);
			}

		}

		public function lineStyleEx(thickness:Number = NaN, color:uint = 0, alpha:Number = 1.0):void
		{
			_strokeThicknessLast = thickness;
			_strokeAlphaLast = alpha;

			_strokeThickness		= thickness;
			_strokeColor			= color;
			_strokeAlpha			= alpha;
			_strokeTexture 			= null;
			_strokeMaterial			= null;

			disposeCurrentStroke();
		}

		public function lineTextureEx(thickness:Number = NaN, texture:Texture = null, alpha:Number = 1.0):void
		{
			_strokeThicknessLast = thickness;
			_strokeAlphaLast = alpha;

			_strokeThickness		= thickness;
			_strokeColor			= 0xFFFFFF;
			_strokeAlpha			= 1;
			_strokeTexture 			= texture;
			_strokeMaterial			= null;

			disposeCurrentStroke();
		}

		public function lineMaterialEx(thickness:Number = NaN, material:IMaterial = null, alpha:Number = 1.0):void
		{
			_strokeThicknessLast = thickness;
			_strokeAlphaLast = alpha;

			_strokeThickness		= thickness;
			_strokeColor			= 0xFFFFFF;
			_strokeAlpha			= 1;
			_strokeTexture			= null;
			_strokeMaterial			= material;

			disposeCurrentStroke();
		}



		private function calcNaturalCubic( n:int, x:Vector.<Number> ) :Vector.<Cubic>
		{
			var i:int;
			var gamma:Vector.<Number> = new Vector.<Number>( n + 1 );;
			var delta:Vector.<Number> = new Vector.<Number>( n + 1 );
			var D:Vector.<Number> = new Vector.<Number>( n+1 );

			gamma[0] = 1.0/2.0;
			for ( i = 1; i < n; i++)
			{
				gamma[i] = 1 / (4 - gamma[i - 1]);
			}
			gamma[n] = 1 / (2 - gamma[n - 1]);

			delta[0] = 3 * (x[1] - x[0]) * gamma[0];


			for ( i = 1; i < n; i++)
			{
				delta[i] = (3 * (x[i + 1] - x[i - 1]) - delta[i - 1]) * gamma[i];
			}
			delta[n] = (3 * (x[n] - x[n - 1]) - delta[n - 1]) * gamma[n];


			D[n] = delta[n];

			for ( i = n - 1; i >= 0; i--)
			{

				D[i] = delta[i] - gamma[i] * D[i + 1];

			}

			/* now compute the coefficients of the cubics */
			var C:Vector.<Cubic> = new Vector.<Cubic>( n );

			for ( i = 0; i < n; i++)
			{
				C[i] = new Cubic(
						x[i],
						D[i],
						3 * (x[i + 1] - x[i]) - 2 * D[i] - D[i + 1],
						2 * (x[i] - x[i + 1]) + D[i] + D[i + 1]
				);
			}
			return C;
		}



		private function calcClosedNaturalCubic( n:int, x:Vector.<Number>):Vector.<Cubic>
		{

			var w:Vector.<Number> = new Vector.<Number>( n+1 );
			var v:Vector.<Number> = new Vector.<Number>( n+1 );
			var y:Vector.<Number> = new Vector.<Number>( n+1 );
			var D:Vector.<Number> = new Vector.<Number>( n+1 );
			var z:Number, F:Number, G:Number, H:Number;
			var k:int;

			w[1] = v[1] = z = 1 / 4;
			y[0] = z * 3 * (x[1] - x[n]);
			H = 4;
			F = 3 * (x[0] - x[n - 1]);
			G = 1;
			for ( k = 1; k < n; k++)
			{

				v[k + 1] = z = 1 / (4 - v[k]);
				w[k + 1] = -z * w[k];
				y[k] = z * (3 * (x[k + 1] - x[k - 1]) - y[k - 1]);
				H = H - G * w[k];
				F = F - G * y[k - 1];
				G = -v[k] * G;

			}
			H = H - (G + 1) * (v[n] + w[n]);
			y[n] = F - (G + 1) * y[n - 1];


			D[n] = y[n] / H;

			/* This equation is WRONG! in my copy of Spath */
			D[n - 1] = y[n - 1] - (v[n] + w[n]) * D[n];
			for ( k = n - 2; k >= 0; k--)
			{
				D[k] = y[k] - v[k + 1] * D[k + 1] - w[k + 1] * D[n];
			}


			/* now compute the coefficients of the cubics */
			var C:Vector.<Cubic> = new Vector.<Cubic>( n+1 );
			for ( k = 0; k < n; k++)
			{
				C[k] = new Cubic(
						x[k],
						D[k],
						3 * (x[k + 1] - x[k]) - 2 * D[k] - D[k + 1],
						2 * (x[k] - x[k + 1]) + D[k] + D[k + 1]
				);

			}
			C[n] = new Cubic(
					x[n],
					D[n],
					3 * (x[0] - x[n]) - 2 * D[n] - D[0],
					2 * (x[n] - x[0]) + D[n] + D[0]
			);
			return C;
		}


	}

}

class Cubic
{
	/** this class represents a cubic polynomial */
	private var a:Number,b:Number,c:Number,d:Number;         /* a + b*u + c*u^2 +d*u^3 */

	public function Cubic(a:Number, b:Number, c:Number, d:Number)
	{
		this.a = a;
		this.b = b;
		this.c = c;
		this.d = d;
	}

	/** evaluate cubic */
	public function eval( u:Number ):Number
	{

		return (((d * u) + c) * u + b) * u + a;

	}
}

