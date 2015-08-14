package starling.display.graphics.util 
{
	import flash.display3D.Context3D;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Point;
	import flash.geom.Matrix3D;
	import starling.display.graphics.Graphic;
	import starling.display.materials.IMaterial;
	import starling.core.RenderSupport;
	import starling.display.BlendMode;
	import starling.core.Starling;
	
	public class RenderIntervalGraphicDrawHelper implements IGraphicDrawHelper
	{
		protected var _renderIntervals:Vector.<Point> = null;
		protected var _colorVector:Vector.<uint> = null;
		protected var _alphaVector:Vector.<Number> = null;
		protected var _blendModeVector:Array = null;
		protected var _numVerts:int = 0;
		
		public function RenderIntervalGraphicDrawHelper() 
		{

		}
		
		public function initialize(numVerts:int) : void
		{
			_numVerts = numVerts;
		}
		
		public function addRenderInterval(startT:Number, endT:Number, color:uint, alpha:Number = 1, blendMode:String = "auto") : void
		{
			if ( _numVerts == 0)
				return;
				
			var numVerts:int = _numVerts;
			var dt:Number = 1.0 / numVerts;
				
			var newStartIndex:int = startT * numVerts;
			var newEndIndex:int = endT * numVerts;
			if ( newEndIndex >= numVerts -1 )
				newEndIndex = numVerts -2;
				
			if ( _renderIntervals == null )
			{
				_renderIntervals = new Vector.<Point>();
				_colorVector = new Vector.<uint>();
				_blendModeVector = new Array();
				_alphaVector = new Vector.<Number>();
			}
			_renderIntervals.push(new Point(newStartIndex, newEndIndex));
			_colorVector.push(color);
			_blendModeVector.push(blendMode);
			_alphaVector.push(alpha);
			
			if ( endT * numVerts > numVerts )
			{
				newStartIndex = (startT * numVerts) % numVerts;
				
				newEndIndex = (endT * numVerts) % numVerts;
				if ( newEndIndex >= numVerts -1 )
					newEndIndex = numVerts -2;
				if ( newStartIndex > newEndIndex )
					newStartIndex = 0;
					
				_renderIntervals.push(new Point(newStartIndex, newEndIndex));
				_colorVector.push(color);
				_blendModeVector.push(blendMode);
				_alphaVector.push(alpha);
			}
			
		}
		
		public function clearRenderIntervals() : void
		{
			_renderIntervals = null;
			_colorVector = null;
			_blendModeVector = null;
		}
		
		public function onDrawTriangles(material:IMaterial, renderSupport:RenderSupport,  vertexBuffer:VertexBuffer3D, indexBuffer:IndexBuffer3D, alpha:Number = 1) : void
		{
			var numTriangles:int = -1;
			var startIndex:int = 0;
			var origColor:uint = material.color;
			
			if ( _renderIntervals && _renderIntervals.length > 0 )
			{
				for ( var i:int = 0; i < _renderIntervals.length; i++ )
				{
					var startEnd:Point = _renderIntervals[i];
					numTriangles = (startEnd.y - startEnd.x );
					startIndex = 3 * startEnd.x;
					material.color = _colorVector[i];
					var blendMode:String = _blendModeVector[i] == "auto" ? renderSupport.blendMode : _blendModeVector[i];
					RenderSupport.setBlendFactors(material.premultipliedAlpha, String(blendMode));
					
					material.drawTrianglesEx( Starling.context, renderSupport.mvpMatrix3D, vertexBuffer, indexBuffer, alpha * _alphaVector[i], numTriangles, startIndex);
					renderSupport.raiseDrawCount();
				}
			}
			material.color = origColor;
		}	
	}

}