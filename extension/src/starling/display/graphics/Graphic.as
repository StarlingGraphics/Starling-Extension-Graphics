package starling.display.graphics
{
	import flash.display3D.Context3D;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.DisplayObject;
	import starling.display.materials.IMaterial;
	import starling.display.materials.StandardMaterial;
	import starling.display.shaders.fragment.VertexColorFragmentShader;
	import starling.display.shaders.vertex.StandardVertexShader;
	import starling.errors.AbstractMethodError;
	import starling.errors.MissingContextError;
	import starling.events.Event;
	
	/**
	 * Abstract, do not instantiate directly
	 * Used as a base-class for all the drawing API sub-display objects (Like Fill and Stroke).
	 */
	public class Graphic extends DisplayObject
	{
		protected static const VERTEX_STRIDE		:int = 9;
		protected static var sHelperMatrix			:Matrix = new Matrix();
		protected static var defaultVertexShader	:StandardVertexShader;
		protected static var defaultFragmentShader	:VertexColorFragmentShader;
		
		protected var _material		:IMaterial;
		private var vertexBuffer	:VertexBuffer3D;
		private var indexBuffer		:IndexBuffer3D;
		protected var vertices		:Vector.<Number>;
		protected var indices		:Vector.<uint>;
		protected var _uvMatrix		:Matrix;
		protected var isInvalid		:Boolean = false;
		protected var uvsInvalid	:Boolean = false;
		
		// Filled-out with min/max vertex positions
		// during addVertex(). Used during getBounds().
		protected var minBounds			:Point;
		protected var maxBounds			:Point;
		
		public function Graphic()
		{
			indices = new Vector.<uint>();
			vertices = new Vector.<Number>();
			
			if ( defaultVertexShader == null )
			{
				defaultVertexShader = new StandardVertexShader();
				defaultFragmentShader = new VertexColorFragmentShader();
			}
			_material = new StandardMaterial( defaultVertexShader, defaultFragmentShader );
			minBounds = new Point();
			maxBounds = new Point();
			
			Starling.current.addEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
		}
		
		private function onContextCreated( event:Event ):void
		{
			isInvalid = true;
			uvsInvalid = true;
			_material.dispose();
		}
		
		override public function dispose():void
		{
			Starling.current.removeEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
			super.dispose();
			
			if ( vertexBuffer )
			{
				vertexBuffer.dispose();
				vertexBuffer = null;
			}
			
			if ( indexBuffer )
			{
				indexBuffer.dispose();
				indexBuffer = null;
			}
			
			if ( material )
			{
				material.dispose();
				material = null;
			}
			
			vertices = null;
			indices = null;
			_uvMatrix = null;
			minBounds = null;
			maxBounds = null;
		}
		
		public function set material( value:IMaterial ):void
		{
			_material = value;
		}
		
		public function get material():IMaterial
		{
			return _material;
		}
		
		public function get uvMatrix():Matrix
		{
			return _uvMatrix;
		}
		
		public function set uvMatrix(value:Matrix):void
		{
			_uvMatrix = value;
			uvsInvalid = true;
		}
		
		public function shapeHitTest( stageX:Number, stageY:Number ):Boolean
		{
			var pt:Point = globalToLocal(new Point(stageX,stageY));
			return pt.x >= minBounds.x && pt.x <= maxBounds.x && pt.y >= minBounds.y && pt.y <= maxBounds.y;
		}
		
		override public function getBounds(targetSpace:DisplayObject, resultRect:Rectangle=null):Rectangle
		{
			if (resultRect == null) resultRect = new Rectangle();
			
			if (targetSpace == this) // optimization
			{
				resultRect.x = minBounds.x;
				resultRect.y = minBounds.y;
				resultRect.right = maxBounds.x;
				resultRect.bottom = maxBounds.y;
				return resultRect;
			}
			
			getTransformationMatrix(targetSpace, sHelperMatrix);
			var m:Matrix = sHelperMatrix;
			
			var tr:Point = new Point( minBounds.x + (maxBounds.x-minBounds.x), minBounds.y )
			var bl:Point = new Point( minBounds.x, minBounds.y + (maxBounds.y-minBounds.y) )
			
			var TL:Point = sHelperMatrix.transformPoint(minBounds.clone());
			tr = sHelperMatrix.transformPoint(tr);
			var BR:Point = sHelperMatrix.transformPoint(maxBounds.clone());
			bl = sHelperMatrix.transformPoint(bl);
				
			resultRect.x = Math.min(TL.x, BR.x, tr.x, bl.x);
			resultRect.y = Math.min(TL.y, BR.y, tr.y, bl.y);
			resultRect.right = Math.max(TL.x, BR.x, tr.x, bl.x);
			resultRect.bottom = Math.max(TL.y, BR.y, tr.y, bl.y);
			
			return resultRect;
		}
		
		protected function buildGeometry():void
		{
			throw( new AbstractMethodError() );
		}
		
		protected function applyUVMatrix():void
		{
			if ( !vertices ) return;
			if ( !_uvMatrix ) return;
			
			var uv:Point = new Point();
			for ( var i:int = 0; i < vertices.length; i += VERTEX_STRIDE )
			{
				uv.x = vertices[i+7];
				uv.y = vertices[i+8];
				uv = _uvMatrix.transformPoint(uv);
				vertices[i+7] = uv.x;
				vertices[i+8] = uv.y;
			}
		}
		
		protected function validateNow():void
		{
			if ( vertexBuffer && (isInvalid || uvsInvalid) )
			{
				vertexBuffer.dispose();
				indexBuffer.dispose();
			}
			
			if ( isInvalid )
			{
				buildGeometry();
				applyUVMatrix();
			}
			else if ( uvsInvalid )
			{
				applyUVMatrix();
			}
		}
		
		override public function render( renderSupport:RenderSupport, parentAlpha:Number ):void
		{
			validateNow();
			
			if ( indices.length < 3 ) return;
			
			if ( isInvalid || uvsInvalid )
			{
				// Upload vertex/index buffers.
				var numVertices:int = vertices.length / VERTEX_STRIDE;
				vertexBuffer = Starling.context.createVertexBuffer( numVertices, VERTEX_STRIDE );
				vertexBuffer.uploadFromVector( vertices, 0, numVertices )
				indexBuffer = Starling.context.createIndexBuffer( indices.length );
				indexBuffer.uploadFromVector( indices, 0, indices.length );
				
				isInvalid = uvsInvalid = false;
			}
			
			
			// always call this method when you write custom rendering code!
			// it causes all previously batched quads/images to render.
			renderSupport.finishQuadBatch();
			
			var context:Context3D = Starling.context;
			if (context == null) throw new MissingContextError();
			
			RenderSupport.setBlendFactors(false, this.blendMode == BlendMode.AUTO ? renderSupport.blendMode : this.blendMode);
			_material.drawTriangles( Starling.context, renderSupport.mvpMatrix3D, vertexBuffer, indexBuffer, parentAlpha*this.alpha );
			
			context.setTextureAt(0, null);
			context.setTextureAt(1, null);
			context.setVertexBufferAt(0, null);
			context.setVertexBufferAt(1, null);
			context.setVertexBufferAt(2, null);
		}
	}
}