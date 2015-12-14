package starling.display.graphicsEx
{
	import flash.geom.Point;
	import starling.display.geom.GraphicsPolygon;
	import starling.display.graphics.Graphic;
	import starling.display.graphics.Stroke;
	import starling.display.graphics.StrokeVertex;
	import starling.display.IGraphicsData;
	import flash.display.GraphicsPath;
	import flash.display.IGraphicsData;
	import flash.display.IGraphicsFill;
	import flash.display.GraphicsSolidFill;
	import flash.display.GraphicsGradientFill;
	import flash.display.GraphicsPath;
	import starling.textures.GradientTexture;
	
	import starling.display.GraphicsPath;
	import starling.display.GraphicsPathCommands;
	import starling.display.IGraphicsData;
	
	
	import starling.display.Graphics;
	import starling.textures.Texture;
	import starling.display.materials.IMaterial;
	import starling.display.DisplayObjectContainer;
	import starling.display.util.CurveUtil;
	import starling.display.graphics.Fill;

	public class GraphicsEx extends Graphics
	{
		protected var _currentStrokeEx:StrokeEx;
		protected var _strokeCullDistance:Number;
		public function GraphicsEx(displayObjectContainer:DisplayObjectContainer, strokeCullDistance:Number = 0)
		{
			_strokeCullDistance = strokeCullDistance;
			
			super(displayObjectContainer);
		}

		override protected function endStroke() : void
		{
			super.endStroke();
			
			_currentStrokeEx = null;
		}
		
		public function get currentLineIndex() : int
		{
			if ( _currentStroke != null )
				return _currentStroke.numVertices;
			else
				return 0;
		}

		public function currentLineLength() : Number
		{
			if ( _currentStrokeEx )
				return _currentStrokeEx.strokeLength();
			else
				return 0;
		}
		
		public function currentStroke() : StrokeEx
		{
			return _currentStrokeEx;
		}
		
		public function drawGraphicsData(graphicsData:Vector.<flash.display.IGraphicsData>):void
		{
			var i:int = 0;
			var vectorLength:int = graphicsData.length;
			for ( i = 0; i < vectorLength; i++ )
			{
				var gfxData:flash.display.IGraphicsData = graphicsData[i];
				handleGraphicsDataType(gfxData);
			}
		}
		
		protected function handleGraphicsDataType(gfxData:flash.display.IGraphicsData ) : void
		{
			if ( gfxData is flash.display.GraphicsPath ) 
			{
				var gfxPath:flash.display.GraphicsPath = gfxData as flash.display.GraphicsPath;
				if ( gfxPath != null )
				{
					var cmds:Vector.<int> = gfxPath.commands as Vector.<int>;
					var data:Vector.<Number> = gfxPath.data as Vector.<Number>;
					var winding:String = gfxPath.winding as String;
					if ( cmds != null && data != null && winding != null )
						drawPath(cmds, data, winding);
				}
			}
			else if ( gfxData is flash.display.GraphicsEndFill )
				endFill();
		//	else if ( gfxData is flash.display.GraphicsBitmapFill ) // TODO - With the righteous removal of GraphicsBitmapFill, how do we solve this? /IonSwitz
		//		beginBitmapFill(flash.display.GraphicsBitmapFill(gfxData).bitmapData, flash.display.GraphicsBitmapFill(gfxData).matrix);
			else if ( gfxData is flash.display.GraphicsSolidFill )
				beginFill(flash.display.GraphicsSolidFill(gfxData).color, flash.display.GraphicsSolidFill(gfxData).alpha );
			else if ( gfxData is flash.display.GraphicsGradientFill )
			{
				var gradientFill:flash.display.GraphicsGradientFill = gfxData as flash.display.GraphicsGradientFill;
				var gradTexture:Texture = GradientTexture.create(128, 128, gradientFill.type, gradientFill.colors, gradientFill.alphas, gradientFill.ratios, gradientFill.matrix, gradientFill.spreadMethod, gradientFill.interpolationMethod, gradientFill.focalPointRatio);
				beginTextureFill(gradTexture);
			}
			else if ( gfxData is flash.display.GraphicsStroke )
			{
				var solidFill:flash.display.GraphicsSolidFill = flash.display.GraphicsStroke(gfxData).fill as flash.display.GraphicsSolidFill;
				var bitmapFill:flash.display.GraphicsBitmapFill = flash.display.GraphicsStroke(gfxData).fill as flash.display.GraphicsBitmapFill;
				var strokeGradientFill:flash.display.GraphicsGradientFill = flash.display.GraphicsStroke(gfxData).fill as flash.display.GraphicsGradientFill;
				if (  solidFill != null )
					lineStyle(flash.display.GraphicsStroke(gfxData).thickness, solidFill.color, solidFill.alpha); 
				else if ( bitmapFill != null )
					lineTexture(flash.display.GraphicsStroke(gfxData).thickness, Texture.fromBitmapData( bitmapFill.bitmapData, false ))
				else if ( strokeGradientFill )
				{
					var strokeGradTexture:Texture = GradientTexture.create(128, 128, strokeGradientFill.type, strokeGradientFill.colors, strokeGradientFill.alphas, strokeGradientFill.ratios, strokeGradientFill.matrix, strokeGradientFill.spreadMethod, strokeGradientFill.interpolationMethod, strokeGradientFill.focalPointRatio);
					lineTexture(flash.display.GraphicsStroke(gfxData).thickness, strokeGradTexture);
				}
			}
		}
		
		public function drawGraphicsDataEx(graphicsData:Vector.<starling.display.IGraphicsData>):void
		{
			var i:int = 0;
			var vectorLength:int = graphicsData.length;
			for ( i = 0; i < vectorLength; i++ )
			{
				var gfxData:starling.display.IGraphicsData = graphicsData[i];
				handleGraphicsDataTypeEx(gfxData);
			}
		}
		
		protected function handleGraphicsDataTypeEx(gfxData:starling.display.IGraphicsData ) : void
		{
			if ( gfxData is GraphicsNaturalSpline )
				naturalCubicSplineTo(GraphicsNaturalSpline(gfxData).controlPoints, GraphicsNaturalSpline(gfxData).closed, GraphicsNaturalSpline(gfxData).steps);
			else if ( gfxData is starling.display.GraphicsPath ) 
				drawPath(starling.display.GraphicsPath(gfxData).commands, starling.display.GraphicsPath(gfxData).data, starling.display.GraphicsPath(gfxData).winding);
			else if ( gfxData is starling.display.GraphicsEndFill )
				endFill();
			else if ( gfxData is starling.display.GraphicsTextureFill )
				beginTextureFill(starling.display.GraphicsTextureFill(gfxData).texture, starling.display.GraphicsTextureFill(gfxData).matrix);
		//	else if ( gfxData is starling.display.GraphicsBitmapFill ) // TODO - With the righteous removal of GraphicsBitmapFill, how do we solve this? /IonSwitz
		//		beginBitmapFill(starling.display.GraphicsBitmapFill(gfxData).bitmapData, starling.display.GraphicsBitmapFill(gfxData).matrix);
			else if ( gfxData is starling.display.GraphicsMaterialFill ) 
				beginMaterialFill(starling.display.GraphicsMaterialFill(gfxData).material, starling.display.GraphicsMaterialFill(gfxData).matrix);
			else if ( gfxData is starling.display.GraphicsLine )
				lineStyle(starling.display.GraphicsLine(gfxData).thickness, starling.display.GraphicsLine(gfxData).color, starling.display.GraphicsLine(gfxData).alpha); // This isn't part of the proper Flash API. 
			
		}

		protected function drawCommandInternal( command:int, data:Vector.<Number>, dataCounter:int, winding:String ):int
		{
			if ( command == GraphicsPathCommands.NO_OP )
			{
				return 0;
			}
			else if ( command == GraphicsPathCommands.MOVE_TO )
			{
				moveTo( data[dataCounter], data[dataCounter + 1] );
				return 2;
			}
			else if ( command == GraphicsPathCommands.LINE_TO )
			{
				lineTo( data[dataCounter], data[dataCounter + 1] );
				return 2;
			}
			else if ( command == GraphicsPathCommands.CURVE_TO )
			{
				curveTo(data[dataCounter], data[dataCounter + 1], data[dataCounter + 2], data[dataCounter + 3] );
				return 4;
			}
			else if ( command == GraphicsPathCommands.CUBIC_CURVE_TO )
			{
				cubicCurveTo( data[dataCounter], data[dataCounter + 1], data[dataCounter + 2], data[dataCounter + 3], data[dataCounter + 4], data[dataCounter + 5] );
				return 6;
			}
			else if ( command == GraphicsPathCommands.WIDE_MOVE_TO )
			{
				moveTo( data[dataCounter + 2 ], data[dataCounter + 3] ); 
				return 4;
			}
			else if ( command == GraphicsPathCommands.WIDE_LINE_TO )
			{
				lineTo( data[dataCounter + 2], data[dataCounter + 3] );
				return 4;
			}
			
			return 0;
		}

		public function drawPath(commands:Vector.<int>, data:Vector.<Number>, winding:String = "evenOdd"):void
		{
			var i:int = 0;
			var commandLength:int = commands.length;
			var dataCounter : int = 0;
			for ( i = 0; i < commandLength; i++ )
			{
				var cmd:int = commands[i];
				dataCounter += drawCommandInternal(cmd, data, dataCounter, winding);
			}
		}
		

		
		/**
		 * performs the natural cubic slipne transformation
		 * @param	controlPoints a Vector.<Point> of the control points
		 * @param	closed a boolean to tell wether the curve is opened or closed
		 * @param   steps - an int indicating the number of steps between control points
		 */

		public function naturalCubicSplineTo( controlPoints:Array, closed:Boolean, steps:int = 4) : void
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
				
				drawPointsInternal(points);
			}
		}

		public function postProcess(startIndex:int, endIndex:int, thicknessData:GraphicsExThicknessData = null, colorData:GraphicsExColorData = null ) : Boolean
		{
			if ( _currentStrokeEx == null)
				return false;
			
			var verts:Vector.<StrokeVertex> = _currentStrokeEx.strokeVertices;
			var totalVerts:int = _currentStrokeEx.numVertices;						
			if ( startIndex >= totalVerts || startIndex < 0 )
				return false;
			if ( endIndex >= totalVerts || endIndex < 0 )
				return false;	
			if ( startIndex == endIndex )
				return false;
			
			var numVerts:int = endIndex - startIndex;
			if ( colorData )
			{
				if ( thicknessData )
				{
					postProcessThicknessColorInternal(numVerts, startIndex, endIndex, verts, thicknessData, colorData);
				}
				else
				{
					postProcessColorInternal(numVerts, startIndex, endIndex, verts, colorData);
				}
			}
			else
			{
				if ( thicknessData )
				{
					postProcessThicknessInternal(numVerts, startIndex, endIndex, verts, thicknessData);
				}
			}
			_currentStrokeEx.invalidate();
			return true;
		}
		
		private function postProcessThicknessColorInternal(numVerts:int, startIndex:int, endIndex:int, verts:Vector.<StrokeVertex> , thicknessData:GraphicsExThicknessData, colorData:GraphicsExColorData ):void 
		{
			var invNumVerts:Number = 1.0 / Number(numVerts);
			var lerp:Number = 0;	
			var inv255:Number = 1.0 / 255.0;
			
			var t:Number; // thickness
			var r:Number;
			var g:Number;
			var b:Number;
			var a:Number;
			var i:Number;
			
			for ( i= startIndex; i <= endIndex ; ++i )
			{
				t= (thicknessData.startThickness * (1.0 - lerp)) + thicknessData.endThickness * lerp;
				
				r= inv255 * ((colorData.startRed * (1.0 - lerp)) + colorData.endRed * lerp);
				g= inv255 * ((colorData.startGreen * (1.0 - lerp)) + colorData.endGreen * lerp);
				b= inv255 * ((colorData.startBlue * (1.0 - lerp)) + colorData.endBlue* lerp);
				a= ((colorData.startAlpha * (1.0 - lerp)) + colorData.endAlpha* lerp);
				
				verts[i].thickness = t;
				
				verts[i].r1 = r;
				verts[i].r2 = r;
				verts[i].g1 = g;
				verts[i].g2 = g;
				verts[i].b1 = b;
				verts[i].b2 = b;
				verts[i].a1 = a;
				verts[i].a2 = a;
				
				lerp += invNumVerts;
			}
		}

		private function postProcessColorInternal(numVerts:int, startIndex:int, endIndex:int, verts:Vector.<StrokeVertex> , colorData:GraphicsExColorData ):void 
		{
			var invNumVerts:Number = 1.0 / Number(numVerts);
			var lerp:Number = 0;	
			var inv255:Number = 1.0 / 255.0;
		
			var r:Number;
			var g:Number;
			var b:Number;
			var a:Number;
			
			var i:Number;
			
			for ( i= startIndex; i <= endIndex ; ++i )
			{
				r= inv255 * ((colorData.startRed * (1.0 - lerp)) + colorData.endRed * lerp);
				g= inv255 * ((colorData.startGreen * (1.0 - lerp)) + colorData.endGreen * lerp);
				b= inv255 * ((colorData.startBlue * (1.0 - lerp)) + colorData.endBlue* lerp);
				a= ((colorData.startAlpha * (1.0 - lerp)) + colorData.endAlpha* lerp);
				
				verts[i].r1 = r;
				verts[i].r2 = r;
				verts[i].g1 = g;
				verts[i].g2 = g;
				verts[i].b1 = b;
				verts[i].b2 = b;
				verts[i].a1 = a;
				verts[i].a2 = a;
				
				lerp += invNumVerts;
			}
		}

		protected function postProcessThicknessInternal(numVerts:int, startIndex:int, endIndex:int, verts:Vector.<StrokeVertex> , thicknessData:GraphicsExThicknessData ):void 
		{
			var invNumVerts:Number = 1.0 / Number(numVerts);
			var lerp:Number = 0;	
			var inv255:Number = 1.0 / 255.0;
			
			var t:Number; // thickness
			var i:Number;
			
			for ( i= startIndex; i <= endIndex ; ++i )
			{
				t = (thicknessData.startThickness * (1.0 - lerp)) + thicknessData.endThickness * lerp;
				verts[i].thickness = t;
				lerp += invNumVerts;
			}
		}
		
		override protected function getStrokeInstance():Stroke
		{// Created to be able to extend class with different strokes for different folks.
			_currentStrokeEx = new StrokeEx();
			_currentStrokeEx.setPointCullDistance(_strokeCullDistance);
			return _currentStrokeEx as Stroke;
		}
		
		protected function drawPointsInternal(points:Vector.<Number>) : void
		{
			var L:int = points.length;
			if ( L > 0 )
			{
				var invHalfL:Number = 1.0/(0.5*L);
				for ( var i:int = 0; i < L; i+=2 )
				{
					var x:Number = points[i];
					var y:Number = points[i+1];

					if ( i == 0 && (_penPosX != _penPosX) ) // Alledgedly the fastest way to do "isNaN(x)". All comparisons with NaN yields false
					{
						moveTo( x, y );
					}
					else
					{
						lineTo(x, y);
					}
				}
			}
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
		
		public function exportStrokesToPolygons() : Vector.<GraphicsPolygon>
		{
			var retval:Vector.<GraphicsPolygon> = new Vector.<GraphicsPolygon>();
			for ( var i:int = 0; i < _container.numChildren; i++)
			{
				if ( _container.getChildAt(i) is Stroke )
					retval.push((Stroke(_container.getChildAt(i))).exportToPolygon());
			}
			
			return retval;
		}
		
		public function exportFillsToPolygons() : Vector.<GraphicsPolygon>
		{
			var retval:Vector.<GraphicsPolygon> = new Vector.<GraphicsPolygon>();
			for ( var i:int = 0; i < _container.numChildren; i++)
			{
				if ( _container.getChildAt(i) is Fill)
					retval.push((Fill(_container.getChildAt(i))).exportToPolygon());
			}
			
			return retval;
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

