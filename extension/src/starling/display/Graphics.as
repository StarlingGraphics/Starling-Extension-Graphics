package starling.display
{
	import flash.display.Bitmap;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import starling.display.graphics.Fill;
	import starling.display.graphics.Stroke;
	import starling.display.materials.StandardMaterial;
	import starling.display.shaders.IShader;
	import starling.display.shaders.fragment.TextureVertexColorFragmentShader;
	import starling.display.shaders.vertex.StandardVertexShader;
	import starling.textures.Texture;

	public class Graphics
	{
		private var _currentFillColor	:uint;
		private var _currentFillAlpha	:Number;
		private var _currentX			:Number;
		private var _currentY			:Number;
		
		private var _strokeThickness	:Number
		private var _strokeColor		:uint;
		private var _strokeAlpha		:Number;
		
		private var _currentStroke					:Stroke;
		private var _currentFill					:Fill;
		private var _currentFillIsBitmapFill		:Boolean;
		private var _currentStrokeIsBitmapStroke	:Boolean;
		private var _currentStrokeTexture			:Texture;
		private var _currentStrokeVertexShader		:IShader;
		
		private var _container			:DisplayObjectContainer;
		
		private var showProfiling		:Boolean;
		
		public function Graphics(displayObjectContainer:DisplayObjectContainer, showProfiling:Boolean = false)
		{
			_container = displayObjectContainer;
			this.showProfiling = showProfiling;
		}
		
		public function clear():void
		{
			while ( _container.numChildren > 0 )
			{
				var child:DisplayObject = _container.getChildAt(0);
				child.dispose();
				_container.removeChildAt(0);
			}
			_currentX = NaN;
			_currentY = NaN;
		}
		
		public function beginFill(color:uint, alpha:Number = 1.0):void
		{
			_currentFillColor = color;
			_currentFillAlpha = alpha;
			_currentFillIsBitmapFill = false;
			
			_currentFill = new Fill(showProfiling);
			_container.addChild(_currentFill);
		}

		public function beginBitmapFill(bitmap:Bitmap, matrix:Matrix = null, repeat:Boolean = true):void//, smooth:Boolean = false ) 
		{
			_currentFillColor = NaN;
			_currentFillAlpha = NaN;
			_currentFillIsBitmapFill = true;
			
			_currentFill = new Fill(showProfiling);
			_currentFill.material = new StandardMaterial( new StandardVertexShader(), new TextureVertexColorFragmentShader() );
			_currentFill.material.textures[0] = Texture.fromBitmap( bitmap, false );
			
			if ( matrix ) {
				_currentFill.uvMatrix = matrix;
			}
			
			_container.addChild(_currentFill);
		}		
		
		public function beginTextureFill( texture:Texture, matrix:Matrix = null ):Fill
		{
			_currentFillColor = NaN;
			_currentFillAlpha = NaN;
			_currentFillIsBitmapFill = true;
			
			_currentFill = new Fill(showProfiling);
			_currentFill.material.fragmentShader = new TextureVertexColorFragmentShader();
			_currentFill.material.textures[0] = texture;
			
			if ( matrix ) {
				_currentFill.uvMatrix = matrix;
			}
			
			_container.addChild(_currentFill);
			
			return _currentFill;
		}
		
		public function endFill():void
		{
			if ( _currentFill && _currentFill.numVertices < 3 ) {
				_container.removeChild(_currentFill);
			}
			
			_currentFillColor 	= NaN;
			_currentFillAlpha 	= NaN;
			_currentFill 		= null;
		}
		
		public function drawCircle(x:Number, y:Number, radius:Number):void
		{
			drawEllipse(x, y, radius, radius);
		}
		
		public function drawEllipse(x:Number, y:Number, width:Number, height:Number):void
		{
			var segmentSize:Number = 2;
			var angle:Number = 270;
			var startAngle:Number = angle;
			
			var xpos:Number = (Math.cos(deg2rad(startAngle)) * width) + x;
			var ypos:Number = (Math.sin(deg2rad(startAngle)) * height) + y;
			moveTo(xpos, ypos);
			
			while (angle - 360 < startAngle) 
			{
				angle += segmentSize;
				
				xpos = (Math.cos(deg2rad(angle)) * width) + x;
				ypos = (Math.sin(deg2rad(angle)) * height) + y;
				
				lineTo(xpos,ypos);
			}
		}
		private function deg2rad (deg:Number):Number {
			return deg * Math.PI / 180;
		}
		
		public function drawRect(x:Number, y:Number, width:Number, height:Number):void
		{
			moveTo(x, y);
			lineTo(x + width, y);
			lineTo(x + width, y + height);
			lineTo(x, y + height);
			lineTo(x, y);
		}
		
		public function lineStyle(thickness:Number = NaN, color:uint = 0, alpha:Number = 1.0, vertexShader:IShader = null):void//, pixelHinting:Boolean = false, scaleMode:String = "normal", caps:String = null, joints:String = null, miterLimit:Number = 3):void
		{
			_strokeThickness		= thickness;
			_strokeColor			= color;
			_strokeAlpha			= alpha;
			_currentStrokeTexture 	= null;
			_currentStrokeVertexShader = vertexShader;
		}
		
		public function lineTexture(thickness:Number = NaN, texture:Texture = null, vertexShader:IShader = null):void//, pixelHinting:Boolean = false, scaleMode:String = "normal", caps:String = null, joints:String = null, miterLimit:Number = 3):void
		{
			_strokeThickness			= thickness;
			_strokeColor				= NaN;
			_strokeAlpha				= NaN;
			_currentStrokeTexture 		= texture;
			_currentStrokeVertexShader = vertexShader;
		}
		
		public function lineTo(x:Number, y:Number):void
		{
			if (!_currentStroke && _strokeThickness > 0) 
			{
				if (_currentStrokeTexture) 
				{
					beginTextureStroke();
				} 
				else
				{
					beginStroke();
				}
			}
			
			if ( isNaN(_currentX) )
			{
				moveTo(0,0);
			}
			
			if ( _currentStroke )
			{
				if (_currentStrokeIsBitmapStroke) {
					_currentStroke.addVertex( x, y, _strokeThickness);
				} else {
					_currentStroke.addVertex( x, y, _strokeThickness, _strokeColor, _strokeAlpha, _strokeColor );
				}
			}
			
			if (_currentFill) {
				if (_currentFillIsBitmapFill) {
					_currentFill.addVertex(x, y);
				} else {
					_currentFill.addVertex(x, y, _currentFillColor, _currentFillAlpha );
				}
			}
			_currentX = x;
			_currentY = y;
		}
		
		// State variables for quadratic subdivision.
		private static const STEPS:int = 8;
		private var _subSteps:int = 0;
		public static const BEZIER_ERROR:Number = 0.75;
		private var _bezierError:Number = BEZIER_ERROR;
		
		// ax1, ay1, cx, cy, ax2, ay2 for quadratic, or
		// ax1, ay1, cx1, cy1, cx2, cy2, ax2, ay2 for cubic
		private var _terms:Vector.<Number> = new Vector.<Number>( 8, true );
				
		private function quadratic( t:Number, axis:int ):Number {
			var oneMinusT:Number = (1.0 - t);
			var a1:Number = _terms[0 + axis];
			var c:Number  = _terms[2 + axis];
			var a2:Number = _terms[4 + axis];
			return (oneMinusT*oneMinusT*a1) + (2.0*oneMinusT*t*c) + t*t*a2;
		}
		
		private function cubic( t:Number, axis:int ):Number {
			var oneMinusT:Number = (1.0 - t);
			
			var a1:Number = _terms[0 + axis];
			var c1:Number = _terms[2 + axis];
			var c2:Number = _terms[4 + axis];
			var a2:Number = _terms[6 + axis];
			return (oneMinusT*oneMinusT*oneMinusT*a1) + (3.0*oneMinusT*oneMinusT*t*c1) + (3.0*oneMinusT*t*t*c2) + t*t*t*a2;
		}

		/* Subdivide until an error metric is hit.
		 * Uses depth first recursion, so that lineTo() can be called directory,
		 * and the calls will be in the currect order.
		 */
		private function subdivide( t0:Number, t1:Number, depth:int, equation:Function ):void
		{
			var quadX:Number = equation( (t0 + t1) * 0.5, 0 );
			var quadY:Number = equation( (t0 + t1) * 0.5, 1 );
			
			var x0:Number = equation( t0, 0 );
			var y0:Number = equation( t0, 1 );
			var x1:Number = equation( t1, 0 );
			var y1:Number = equation( t1, 1 );
			
			var midX:Number = ( x0 + x1 ) * 0.5;
			var midY:Number = ( y0 + y1 ) * 0.5;
			
			var dx:Number = quadX - midX;
			var dy:Number = quadY - midY;
			
			var error2:Number = dx * dx + dy * dy;
			
			if ( error2 > (_bezierError*_bezierError) ) {
				subdivide( t0, (t0 + t1)*0.5, depth+1, equation );	
				subdivide( (t0 + t1)*0.5, t1, depth+1, equation );	
			}
			else {
				++_subSteps;
				//trace( subSteps, depth, int(x1), int(y1), t1 )
				lineTo( x1, y1 );
			}
		}
		
		public function curveTo(cx:Number, cy:Number, a2x:Number, a2y:Number, error:Number = BEZIER_ERROR ):void
		{
			if ( isNaN(_currentX) )
			{
				moveTo(0,0);
			}
			
			_subSteps = 0;
			_bezierError = error;
			
			_terms[0] = _currentX;
			_terms[1] = _currentY;
			_terms[2] = cx;
			_terms[3] = cy;
			_terms[4] = a2x;
			_terms[5] = a2y;
			
			subdivide( 0.0, 0.5, 0, quadratic );
			subdivide( 0.5, 1.0, 0, quadratic );
			//trace( "quadratic subSteps", _subSteps );

			/* 
			// Straight subdivision. Useful for testing.
			var a1x:Number = _currentX;
			var a1y:Number = _currentY;
			
			for ( var j:int = 1; j <= STEPS; ++j ) {
				var t:Number = Number(j) / Number(STEPS);
				var oneMinusT:Number = (1.0 - t);
				var bx:Number = (oneMinusT*oneMinusT*a1x) + (2.0*oneMinusT*t*cx) + (t*t*a2x);
				var by:Number = (oneMinusT*oneMinusT*a1y) + (2.0*oneMinusT*t*cy) + (t*t*a2y);
				
				lineTo( bx, by );
			}			
			*/
			
			_currentX = a2x;
			_currentY = a2y;
		}
		
		public function cubicCurveTo(c1x:Number, c1y:Number, c2x:Number, c2y:Number, a2x:Number, a2y:Number, error:Number = BEZIER_ERROR ):void
		{
			if ( isNaN(_currentX) )
			{
				moveTo(0,0);
			}
			
			_subSteps = 0;
			_bezierError = error;
			
			_terms[0] = _currentX;
			_terms[1] = _currentY;
			_terms[2] = c1x;
			_terms[3] = c1y;
			_terms[4] = c2x;
			_terms[5] = c2y;
			_terms[6] = a2x;
			_terms[7] = a2y;
			
			subdivide( 0.0, 0.5, 0, cubic );
			subdivide( 0.5, 1.0, 0, cubic );
			//trace( "cubic subSteps", _subSteps );

			_currentX = a2x;
			_currentY = a2y;
		}

		
		public function moveTo(x:Number, y:Number):void
		{
			if (_currentStrokeTexture) {
				beginTextureStroke();
			} else {  	
				beginStroke();  	
			}
			
			if (_currentStrokeIsBitmapStroke) {
				_currentStroke.addVertex( x, y, _strokeThickness);  	
			} else {
				_currentStroke.addVertex( x, y, _strokeThickness, _strokeColor, _strokeAlpha, _strokeColor );
			}
//			if ( _currentStroke )
//			{
//				endStroke();
//			}
			
			if (_currentFill) {
				if (_currentFillIsBitmapFill) {
					_currentFill.addVertex(x, y);
				} else {
					_currentFill.addVertex(x, y, _currentFillColor, _currentFillAlpha );
				}
			}
			_currentX = x;
			_currentY = y;
		}
		
		private function beginStroke():void
		{
			_currentStrokeIsBitmapStroke = false;
			
			if ( _currentStroke && _currentStroke.numVertices < 2 ) {
				_container.removeChild(_currentStroke);
			}
			
			_currentStroke = new Stroke();
			_container.addChild(_currentStroke);
		}
		
		private function endStroke():void
		{
			_currentStroke = null;
		}
		
		private function beginTextureStroke():Stroke
		{
			_currentStrokeIsBitmapStroke = true;
			
			if ( _currentStroke && _currentStroke.numVertices < 2 ) {
				_container.removeChild(_currentStroke);
			}
			
			_currentStroke = new Stroke();
			if ( _currentStrokeVertexShader )
			{
				_currentStroke.material.vertexShader = _currentStrokeVertexShader;
			}
			_currentStroke.material.fragmentShader = new TextureVertexColorFragmentShader();
			_currentStroke.material.textures[0] = _currentStrokeTexture;
			_container.addChild(_currentStroke);
			
			return _currentStroke;
		}
	}
}