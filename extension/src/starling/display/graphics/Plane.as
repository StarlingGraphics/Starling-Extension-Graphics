package starling.display.graphics
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.display.DisplayObject;

	public class Plane extends Graphic
	{
		private static const VERTEX_STRIDE	:int = 9;
		
		private var vertices		:Vector.<Number>;
		private var indices			:Vector.<uint>
		private var _width			:Number;
		private var _height			:Number;
		private var _numVerticesX	:uint;
		private var _numVerticesY	:uint;
		private var _uvMatrix		:Matrix;
		private var _vertexFunction	:Function;
		
		private var isInvalid		:Boolean;
		
		public function Plane( width:Number = 100, height:Number = 100, numVerticesX:uint = 2, numVerticesY:uint = 2 )
		{
			_width = width;
			_height = height;
			_numVerticesX = numVerticesX;
			_numVerticesY = numVerticesY;
			_vertexFunction = defaultVertexFunction;
			isInvalid = true;
		}
		
		public static function defaultVertexFunction( column:int, row:int, width:Number, height:Number, numVerticesX:int, numVerticesY:int, output:Vector.<Number>, uvMatrix:Matrix = null ):void
		{
			var segmentWidth:Number = width / (numVerticesX-1);
			var segmentHeight:Number = height / (numVerticesY-1);
			
			var x:Number = segmentWidth * column;
			var y:Number = segmentHeight * row;
			
			var uv:Point = new Point();
			if ( uvMatrix )
			{
				uv.x = x;
				uv.y = y;
				uv = uvMatrix.transformPoint(uv);
			}
			else
			{
				uv.x = column / (numVerticesX-1);
				uv.y = row / (numVerticesY-1);
			}
			
			output.push( x,y,0,1,1,1,1,uv.x,uv.y );
		}
		
		public function set vertexFunction( value:Function ):void
		{
			if ( value == null )
			{
				throw( new Error( "Value must not be null" ) );
				return;
			}
			_vertexFunction = value;
			isInvalid = true;
		}
		
		public function get vertexFunction():Function
		{
			return _vertexFunction
		}
		
		public function get uvMatrix():Matrix
		{
			return _uvMatrix;
		}

		public function set uvMatrix(value:Matrix):void
		{
			_uvMatrix = value;
			isInvalid = true;
		}

		public function validate():void
		{
			if ( vertexBuffer )
			{
				vertexBuffer.dispose();
				indexBuffer.dispose();
			}
			
			// Generate vertices
			var numVertices:int = _numVerticesX * _numVerticesY;
			vertices = new Vector.<Number>();
			for ( var i:int = 0; i < numVertices; i++ )
			{
				var column:int = i % _numVerticesX;
				var row:int = i / _numVerticesX;
				_vertexFunction( column, row, _width, _height, _numVerticesX, _numVerticesY, vertices, _uvMatrix );
			}
			
			// Generate indices
			indices = new Vector.<uint>();
			var qn:int = 0; //quad number
			for (var n:int = 0; n <_numVerticesX-1; n++) //create quads out of the vertices
			{               
				for (var m:int = 0; m <_numVerticesY - 1; m++)
				{
					
					indices.push(qn, qn + 1, qn + _numVerticesX ); //upper face
					indices.push(qn + _numVerticesX, qn + _numVerticesX  + 1, qn+1); //lower face
					
					qn++; //jumps to next quad
				}
				qn++; // jumps to next row
			}
			
			// Upload vertex/index buffers.
			vertexBuffer = Starling.context.createVertexBuffer( numVertices, VERTEX_STRIDE );
			vertexBuffer.uploadFromVector( vertices, 0, numVertices )
			indexBuffer = Starling.context.createIndexBuffer( indices.length );
			indexBuffer.uploadFromVector( indices, 0, indices.length );
		}
		
		public override function getBounds(targetSpace:DisplayObject, resultRect:Rectangle=null):Rectangle
		{
			minBounds.x = 0;
			minBounds.y = 0;
			maxBounds.x = _width;
			maxBounds.y = _height;
			return super.getBounds(targetSpace, resultRect);
		}
		
		override public function render( renderSupport:RenderSupport, alpha:Number ):void
		{
			if ( isInvalid )
			{
				validate();
				isInvalid = false;
			}
			
			super.render( renderSupport, alpha );
		}
	}
}