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
		public static const QUADRATIC_ERROR:Number = 0.75;
		private var _quadraticError:Number = QUADRATIC_ERROR;
		private var _quadA1:Point = new Point();
		private var _quadC:Point  = new Point();
		private var _quadA2:Point = new Point();
				
		public function quadratic( t:Number, a1:Number, c:Number, a2:Number ):Number {
			var oneMinusT:Number = (1.0 - t);
			return (oneMinusT*oneMinusT*a1) + (2.0*oneMinusT*t*c) + t*t*a2;
		}
		
		/* Subdivide until an error metric is hit.
		 * Uses depth first recursion, so that lineTo() can be called directory,
		 * and the calls will be in the currect order.
		 */
		private function subdivide( t0:Number, t1:Number, depth:int ):void
		{
			var quadX:Number = quadratic( (t0 + t1) * 0.5, _quadA1.x, _quadC.x, _quadA2.x );
			var quadY:Number = quadratic( (t0 + t1) * 0.5, _quadA1.y, _quadC.y, _quadA2.y );
			
			var x0:Number = quadratic( t0, _quadA1.x, _quadC.x, _quadA2.x );
			var y0:Number = quadratic( t0, _quadA1.y, _quadC.y, _quadA2.y );
			var x1:Number = quadratic( t1, _quadA1.x, _quadC.x, _quadA2.x );
			var y1:Number = quadratic( t1, _quadA1.y, _quadC.y, _quadA2.y );
			
			var midX:Number = ( x0 + x1 ) * 0.5;
			var midY:Number = ( y0 + y1 ) * 0.5;
			
			var dx:Number = quadX - midX;
			var dy:Number = quadY - midY;
			
			var error2:Number = dx * dx + dy * dy;
			
			if ( error2 > (_quadraticError*_quadraticError) ) {
				subdivide( t0, (t0 + t1)*0.5, depth+1 );	
				subdivide( (t0 + t1)*0.5, t1, depth+1 );	
			}
			else {
				++_subSteps;
				//trace( subSteps, depth, int(x1), int(y1), t1 )
				lineTo( x1, y1 );
			}
		}
		
		public function curveTo(cx:Number, cy:Number, a2x:Number, a2y:Number, error:Number = QUADRATIC_ERROR ):void
		{
			if ( isNaN(_currentX) )
			{
				moveTo(0,0);
			}
			
			_subSteps = 0;
			_quadraticError = error;
			
			_quadA1.setTo( _currentX, _currentY );
			_quadC.setTo( cx, cy );
			_quadA2.setTo( a2x, a2y );
			
			subdivide( 0.0, 0.5, 0 );
			subdivide( 0.5, 1.0, 0 );
			//trace( "subSteps", _subSteps );

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
		
		public function moveTo(x:Number, y:Number):void
		{
			if ( _currentStroke )
			{
				endStroke();
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