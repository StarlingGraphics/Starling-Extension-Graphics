package starling.display
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	
	import starling.display.graphics.Fill;
	import starling.display.graphics.Graphic;
	import starling.display.graphics.NGon;
	import starling.display.graphics.Plane;
	import starling.display.graphics.RoundedRectangle;
	import starling.display.graphics.Stroke;
	import starling.display.materials.IMaterial;
	import starling.display.shaders.fragment.TextureFragmentShader;
	import starling.display.util.CurveUtil;
	import starling.textures.Texture;

	public class Graphics
	{
		// Shared texture fragment shader used across all graphics drawn via graphics API.
		private static var textureFragmentShader	:TextureFragmentShader = new TextureFragmentShader();
		public static const BEZIER_ERROR:Number = 0.75;
		private static const DEG_TO_RAD:Number = Math.PI / 180;
		
		private var _currentX				:Number;
		private var _currentY				:Number;
		private var _currentStroke			:Stroke;
		private var _currentFill			:Fill;
		
		private var _fillColor				:uint;
		private var _fillAlpha				:Number;
		private var _strokeThickness		:Number
		private var _strokeColor			:uint;
		private var _strokeAlpha			:Number;
		private var _strokeTexture			:Texture;
		private var _strokeMaterial			:IMaterial;
		
		private var _container				:DisplayObjectContainer;
		
		public function Graphics(displayObjectContainer:DisplayObjectContainer)
		{
			_container = displayObjectContainer;
		}
		
		public function clear():void
		{
			while ( _container.numChildren > 0 )
			{
				var child:DisplayObject = _container.getChildAt(0);
				child.dispose();
				if ( child is Graphic )
				{
					var graphic:Graphic = Graphic(child);
					if ( graphic.material )
					{
						graphic.material.dispose(true);
					}
				}
				_container.removeChildAt(0);
			}
			_currentX = NaN;
			_currentY = NaN;
			
			_fillColor 	= NaN;
			_fillAlpha 	= NaN;
			_currentFill= null;
			_currentStroke = null;
		}
		
		public function beginFill(color:uint, alpha:Number = 1.0):void
		{
			_fillColor = color;
			_fillAlpha = alpha;
			
			_currentFill = new Fill();
			_currentFill.material.alpha = _fillAlpha;
			_currentFill.material.color = color;
			_container.addChild(_currentFill);
		}
		
		/**
		 * Warning - this function will create a fresh texture for each bitmap.
		 * It is reccomended to use beginTextureFill to ensure texture re-use.
		 */
		public function beginBitmapFill(bitmap:BitmapData, uvMatrix:Matrix = null):void
		{
			_fillColor = 0xFFFFFF;
			_fillAlpha = 1;
			
			_currentFill = new Fill();
			_currentFill.material.fragmentShader = textureFragmentShader;
			var texture:Texture = Texture.fromBitmapData( bitmap, false );
			_currentFill.material.textures[0] = texture;
			
			var m:Matrix = new Matrix();
			m.scale(1/texture.width, 1/texture.height);
			if ( uvMatrix )
			{
				m.concat(uvMatrix);
			}
			_currentFill.uvMatrix = m;
			
			_container.addChild(_currentFill);
		}
		
		public function beginTextureFill( texture:Texture, uvMatrix:Matrix = null ):void
		{
			_fillColor = 0xFFFFFF;
			_fillAlpha = 1;
			
			_currentFill = new Fill();
			_currentFill.material.fragmentShader = textureFragmentShader;
			_currentFill.material.textures[0] = texture;
			
			var m:Matrix = new Matrix();
			m.scale(1/texture.width, 1/texture.height);
			if ( uvMatrix )
			{
				m.concat(uvMatrix);
			}
			_currentFill.uvMatrix = m;
			
			_container.addChild(_currentFill);
		}
		
		public function beginMaterialFill( material:IMaterial, uvMatrix:Matrix = null ):void
		{
			_fillColor = 0xFFFFFF;
			_fillAlpha = 1;
			
			_currentFill = new Fill();
			_currentFill.material = material;
			
			var m:Matrix;
			if ( uvMatrix )
			{
				m = uvMatrix.clone();
				m.invert();
			}
			else
			{
				m = new Matrix();
			}
			if ( material.textures.length > 0 )
			{
				m.scale(1/material.textures[0].width, 1/material.textures[0].height);
			}
			
			_currentFill.uvMatrix = m;
			
			_container.addChild(_currentFill);
		}
		
		public function endFill():void
		{
			if ( _currentFill && _currentFill.numVertices < 3 ) {
				_container.removeChild(_currentFill);
			}
			
			_fillColor 	= NaN;
			_fillAlpha 	= NaN;
			_currentFill= null;
		}
		
		public function drawCircle(x:Number, y:Number, radius:Number):void
		{
			drawEllipse(x, y, radius*2, radius*2);
		}
		
		public function drawEllipse(x:Number, y:Number, width:Number, height:Number):void
		{
			// Calculate num-sides based on a blend between circumference of width and circumference of height.
			// Should provide good results for ellipses with similar widths/heights.
			// Will look bad on very thin ellipses.
			var numSides:int = Math.PI * ((width*0.5) + (height*0.5)) * 0.25;
			numSides = numSides < 6 ? 6 : numSides;
			
			// Use an NGon primitive instead of fill to bypass triangulation.
			var cachedFill:Fill = _currentFill;
			if ( _currentFill )
			{
				var nGon:NGon = new NGon(width*0.5, numSides);
				nGon.x = x;
				nGon.y = y;
				nGon.scaleY = height/width;
				nGon.material = _currentFill.material;
				nGon.material.color = _fillColor;
				nGon.alpha = _fillAlpha;
				var m:Matrix = new Matrix();
				m.scale(width, height);
				if ( cachedFill.uvMatrix )
				{
					m.concat(cachedFill.uvMatrix);
				}
				nGon.uvMatrix = m;
				
				_container.addChild(nGon);
				_currentFill = null;
			}
			
			
			// Draw the stroke
			if ( isNaN(_strokeThickness) == false )
			{
				var halfWidth:Number = width*0.5;
				var halfHeight:Number = height*0.5;
				var anglePerSide:Number = (Math.PI * 2) / numSides;
				var a:Number = Math.cos(anglePerSide);
				var b:Number = Math.sin(anglePerSide);
				var s:Number = 0.0;
				var c:Number = 1.0;
				
				for ( var i:int = 0; i <= numSides; i++ )
				{
					var sx:Number = s * halfWidth + x;
					var sy:Number = -c * halfHeight + y;
					if ( i == 0 )
					{
						moveTo(sx,sy);
					}
					else
					{
						lineTo(sx,sy);
					}
					
					const ns:Number = b*c + a*s;
					const nc:Number = a*c - b*s;
					c = nc;
					s = ns;
				}
			}
			
			_currentFill = cachedFill;
		}
		
		
		public function drawRect(x:Number, y:Number, width:Number, height:Number):void
		{
			var storedFill:Fill;
			
			// Use a Plane primitive instead of fill to side-step triangulation.
			if ( _currentFill )
			{
				// Store fill to we can draw stroke without fill.
				storedFill = _currentFill;
				_currentFill = null;
				
				var plane:Plane = new Plane(width, height);
				plane.material = storedFill.material;
				
				var m:Matrix = new Matrix();
				m.scale(width, height);
				if ( storedFill.uvMatrix )
				{
					m.concat(storedFill.uvMatrix);
				}
				plane.uvMatrix = m;
				plane.x = x;
				plane.y = y;
				_container.addChild(plane);
				
			}
			
			// Draw stroke
			moveTo(x, y);
			lineTo(x + width, y);
			lineTo(x + width, y + height);
			lineTo(x, y + height);
			lineTo(x, y);
			_currentFill = storedFill;
		}
		
		public function drawRoundRect( x:Number, y:Number, width:Number, height:Number, radius:Number ):void
		{
			drawRoundRectComplex(x,y,width,height,radius,radius,radius,radius);
		}
		
		public function drawRoundRectComplex( x:Number, y:Number, width:Number, height:Number, topLeftRadius:Number, topRightRadius:Number, bottomLeftRadius:Number, bottomRightRadius:Number ):void
		{
			if ( !_currentFill && _strokeThickness <= 0 ) return;
			
			var storedFill:Fill;
			var roundedRect:RoundedRectangle = new RoundedRectangle( width, height, topLeftRadius, topRightRadius, bottomLeftRadius, bottomRightRadius );
			
			// Draw fill
			if ( _currentFill )
			{
				// Store fill to we can draw stroke without fill.
				storedFill = _currentFill;
				_currentFill = null;
				roundedRect.material = storedFill.material;
				
				var m:Matrix = new Matrix();
				m.scale(width, height);
				if ( storedFill.uvMatrix )
				{
					m.concat(storedFill.uvMatrix);
				}
				roundedRect.uvMatrix = m;
				roundedRect.x = x;
				roundedRect.y = y;
				_container.addChild(roundedRect);
			}
			_currentFill = storedFill;
			
			// Draw stroke
			if ( _strokeTexture ) 
			{
				beginTextureStroke();
			} 
			else if ( _strokeMaterial )
			{
				beginMaterialStroke();
			}
			else if ( _strokeThickness > 0 )
			{  	
				beginStroke();
			}
			if ( _currentStroke )
			{
				var strokePoints:Vector.<Number> = roundedRect.getStrokePoints();
				for ( var i:int = 0; i < strokePoints.length; i+=2 )
				{
					_currentStroke.addVertex( x+strokePoints[i],y+strokePoints[i+1], _strokeThickness, _strokeColor, _strokeAlpha, _strokeColor, _strokeAlpha );
				}
			}
		}
		
		public function lineStyle(thickness:Number = NaN, color:uint = 0, alpha:Number = 1.0):void
		{
			_strokeThickness		= thickness;
			_strokeColor			= color;
			_strokeAlpha			= alpha;
			_strokeTexture 			= null;
			_strokeMaterial			= null;
		}
		
		public function lineTexture(thickness:Number = NaN, texture:Texture = null):void
		{
			_strokeThickness		= thickness;
			_strokeColor			= 0xFFFFFF;
			_strokeAlpha			= 1;
			_strokeTexture 			= texture;
			_strokeMaterial			= null;
		}
		
		public function lineMaterial(thickness:Number = NaN, material:IMaterial = null):void
		{
			_strokeThickness		= thickness;
			_strokeColor			= 0xFFFFFF;
			_strokeAlpha			= 1;
			_strokeTexture			= null;
			_strokeMaterial			= material;
		}
		
		public function moveTo(x:Number, y:Number):void
		{
			if ( _strokeTexture ) 
			{
				beginTextureStroke();
			} 
			else if ( _strokeMaterial )
			{
				beginMaterialStroke();
			}
			else if ( _strokeThickness > 0 )
			{  	
				beginStroke();
			}
			
			if ( _currentStroke && _strokeThickness > 0 )
			{
				_currentStroke.addVertex( x, y, _strokeThickness );
			}
			
			if (_currentFill) 
			{
				_currentFill.addVertex( x, y );
			}
			
			_currentX = x;
			_currentY = y;
		}
		
		public function lineTo(x:Number, y:Number):void
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
			
			if ( isNaN(_currentX) )
			{
				moveTo(0,0);
			}
			
			if ( _currentStroke && _strokeThickness > 0 )
			{
				_currentStroke.addVertex( x, y, _strokeThickness );
			}
			
			if (_currentFill) 
			{
				_currentFill.addVertex( x, y );
			}
			_currentX = x;
			_currentY = y;
		}
		
		public function curveTo(cx:Number, cy:Number, a2x:Number, a2y:Number, error:Number = BEZIER_ERROR ):void
		{
			var startX:Number = _currentX;
			var startY:Number = _currentY;
			
			if ( isNaN(startX) )
			{
				startX = 0;
				startY = 0;
			}
			
			var points:Vector.<Number> = CurveUtil.quadraticCurve(startX, startY, cx, cy, a2x, a2y, error);
			
			var L:int = points.length;
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
					lineTo( x, y );
				}
			}
			
			_currentX = a2x;
			_currentY = a2y;
		}
		
		public function cubicCurveTo(c1x:Number, c1y:Number, c2x:Number, c2y:Number, a2x:Number, a2y:Number, error:Number = BEZIER_ERROR ):void
		{
			var startX:Number = _currentX;
			var startY:Number = _currentY;
			
			if ( isNaN(startX) )
			{
				startX = 0;
				startY = 0;
			}
			
			var points:Vector.<Number> = CurveUtil.cubicCurve(startX, startY, c1x, c1y, c2x, c2y, a2x, a2y, error);
			
			var L:int = points.length;
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
					lineTo( x, y );
				}
			}
			_currentX = a2x;
			_currentY = a2y;
		}
		
		////////////////////////////////////////
		// PRIVATE
		////////////////////////////////////////
		
		private function beginStroke():void
		{
			if ( _currentStroke && _currentStroke.numVertices < 2 ) {
				_container.removeChild(_currentStroke);
			}
			
			_currentStroke = new Stroke();
			_currentStroke.material.color = _strokeColor;
			_currentStroke.material.alpha = _strokeAlpha;
			_container.addChild(_currentStroke);
		}
		
		private function beginTextureStroke():void
		{
			if ( _currentStroke && _currentStroke.numVertices < 2 ) {
				_container.removeChild(_currentStroke);
			}
			
			_currentStroke = new Stroke();
			_currentStroke.material.fragmentShader = textureFragmentShader;
			_currentStroke.material.textures[0] = _strokeTexture;
			_currentStroke.material.color = _strokeColor;
			_currentStroke.material.alpha = _strokeAlpha;
			_container.addChild(_currentStroke);
		}
		
		private function beginMaterialStroke():void
		{
			if ( _currentStroke && _currentStroke.numVertices < 2 ) {
				_container.removeChild(_currentStroke);
			}
			_currentStroke = new Stroke();
			_currentStroke.material = _strokeMaterial;
			_container.addChild(_currentStroke);
		}
	}
}