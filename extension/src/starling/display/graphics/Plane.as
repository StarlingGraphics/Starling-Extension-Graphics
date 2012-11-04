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
		
		private var isInvalid		:Boolean;
		
		public function Plane( width:Number = 100, height:Number = 100, numVerticesX:uint = 2, numVerticesY:uint = 2 )
		{
			_width = width;
			_height = height;
			_numVerticesX = numVerticesX;
			_numVerticesY = numVerticesY;
			isInvalid = true;
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
			var segmentWidth:Number = _width / (_numVerticesX-1);
			var segmentHeight:Number = _height / (_numVerticesY-1);
			var halfWidth:Number = _width * 0.5;
			var halfHeight:Number = _height * 0.5;
			var uv:Point = new Point();
			for ( var i:int = 0; i < numVertices; i++ )
			{
				var column:int = i % _numVerticesX;
				var row:int = i / _numVerticesX;
				var x:Number = segmentWidth * column;
				var y:Number = segmentHeight * row;
				if ( _uvMatrix )
				{
					uv.x = x;
					uv.y = y;
					uv = _uvMatrix.transformPoint(uv);
				}
				else
				{
					uv.x = column / (_numVerticesX-1);
					uv.y = row / (_numVerticesY-1);
				}
				
				vertices.push( x, y, 0, 1, 1, 1, 1, uv.x, uv.y );
			}
			
			// Generate indices
			indices = new Vector.<uint>();
			var numQuads:int = (_numVerticesX-1) * (_numVerticesY-1);
			for ( i = 0; i < numQuads; i++ )
			{
				indices.push( i, i+1, i+_numVerticesX+1, i+_numVerticesX+1, i+_numVerticesX, i );
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