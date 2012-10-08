package starling.display
{
	import flash.display.Bitmap;
	import flash.geom.Matrix;
	
	import starling.display.graphics.Fill;
	import starling.display.graphics.Stroke;
	import starling.display.materials.StandardMaterial;
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
		
		public function lineStyle(thickness:Number = NaN, color:uint = 0, alpha:Number = 1.0):void//, pixelHinting:Boolean = false, scaleMode:String = "normal", caps:String = null, joints:String = null, miterLimit:Number = 3):void
		{
			_strokeThickness		= thickness;
			_strokeColor			= color;
			_strokeAlpha			= alpha;
			_currentStrokeTexture 	= null;
		}
		
		public function lineTexture(thickness:Number = NaN, texture:Texture = null):void//, pixelHinting:Boolean = false, scaleMode:String = "normal", caps:String = null, joints:String = null, miterLimit:Number = 3):void
		{
			_strokeThickness		= thickness;
			_strokeColor			= NaN;
			_strokeAlpha			= NaN;
			_currentStrokeTexture 	= texture;
		}
		
		public function lineTo(x:Number, y:Number):void
		{
			if (!_currentStroke) {
				if (_currentStrokeTexture) {
					beginTextureStroke();
				} else {
					beginStroke();
				}
			}
			
			if (_currentStrokeIsBitmapStroke) {
				_currentStroke.addVertex( x, y, _strokeThickness);
			} else {
				_currentStroke.addVertex( x, y, _strokeThickness, _strokeColor, _strokeAlpha, _strokeColor );
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
		
		private static const STEPS:int = 8;
		private var subSteps:int = 0;
		private static const ERROR:Number = 0.1;
				
		public function quadratic( t:Number, a1:Number, c:Number, a2:Number ):Number {
			var oneMinusT:Number = (1.0 - t);
			return oneMinusT * oneMinusT * a1 + 2.0 * oneMinusT * t * c + t * t * a2;
		}
		
		private function subdivide( t0:Number, t1:Number, depth:int, a1x:Number, a1y:Number, cx:Number, cy:Number, a2x:Number, a2y:Number ):void
		{
			var quadX:Number = quadratic( (t0 + t1) * 0.5, a1x, cx, a2x );
			var quadY:Number = quadratic( (t0 + t1) * 0.5, a1y, cy, a2y );
			
			var x0:Number = quadratic( t0, a1x, cx, a2x );
			var y0:Number = quadratic( t0, a1y, cy, a2y );
			var x1:Number = quadratic( t1, a1x, cx, a2x );
			var y1:Number = quadratic( t1, a1y, cy, a2y );
			var midX:Number = ( x0 + x1 ) * 0.5;
			var midY:Number = ( y0 + y1 ) * 0.5;
			
			var dx:Number = quadX - midX;
			var dy:Number = quadY - midY;
			
			var error2:Number = dx * dx + dy * dy;
			
			if ( depth < 2 ) { //error2 > (ERROR*ERROR) ) {
				subdivide( t0, (t0 + t1) * 0.5, depth+1, a1x, a1y, cx, cy, a2x, a2y );	
				subdivide( (t0 + t1) * 0.5, t1, depth+1, a1x, a1y, cx, cy, a2x, a2y );	
			}
			else {
				++subSteps;
				trace( subSteps, depth, x1, y1 )
				lineTo( x1, y1 );
			}
		}
		
		public function curveTo(cx:Number, cy:Number, a2x:Number, a2y:Number):void
		{
			/*
			subSteps = 0;
			subdivide( 0.0, 0.5, 0, _currentX, _currentY, cx, cy, a2x, a2y );
			subdivide( 0.5, 1.0, 0, _currentX, _currentY, cx, cy, a2x, a2y );
			trace( "subSteps", subSteps );
			*/

			var a1x:Number = _currentX;
			var a1y:Number = _currentY;
			
			for ( var j:int = 1; j <= STEPS; ++j ) {
				var t:Number = Number(j) / Number(STEPS);
				var oneMinusT:Number = (1.0 - t);
				var bx:Number = (oneMinusT*oneMinusT*a1x) + (2.0*oneMinusT*t*cx) + (t*t*a2x);
				var by:Number = (oneMinusT*oneMinusT*a1y) + (2.0*oneMinusT*t*cy) + (t*t*a2y);
				
				lineTo( bx, by );
			}			
			
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
		
		private function beginTextureStroke():Stroke
		{
			_currentStrokeIsBitmapStroke = true;
			
			if ( _currentStroke && _currentStroke.numVertices < 2 ) {
				_container.removeChild(_currentStroke);
			}
			
			_currentStroke = new Stroke();
			_currentStroke.material.fragmentShader = new TextureVertexColorFragmentShader();
			_currentStroke.material.textures[0] = _currentStrokeTexture;
			_container.addChild(_currentStroke);
			
			return _currentStroke;
		}
	}
}