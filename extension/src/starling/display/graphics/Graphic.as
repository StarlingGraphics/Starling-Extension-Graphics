package starling.display.graphics
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
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
	import starling.display.shaders.fragment.TextureVertexColorFragmentShader;
	import starling.display.shaders.fragment.VertexColorFragmentShader;
	import starling.display.shaders.vertex.StandardVertexShader;
	import starling.errors.MissingContextError;
	import starling.textures.Texture;
	
	/**
	 * Abstract, do not instantiate directly
	 * Used as a base-class for all the drawing API sub-display objects (Like Fill and Stroke).
	 */
	public class Graphic extends DisplayObject
	{
		protected static var sHelperMatrix:Matrix = new Matrix();
		protected static var defaultVertexShader	:StandardVertexShader;
		protected static var defaultFragmentShader	:VertexColorFragmentShader;
		
		protected var _material		:IMaterial;
		protected var vertexBuffer	:VertexBuffer3D;
		protected var indexBuffer	:IndexBuffer3D;
		
		protected var _numVertices	:int;
		
		// Filled-out with min/max vertex positions
		// during addVertex(). Used during getBounds().
		protected var minBounds			:Point;
		protected var maxBounds			:Point;
		
		public function Graphic()
		{
			if ( defaultVertexShader == null )
			{
				defaultVertexShader = new StandardVertexShader();
				defaultFragmentShader = new VertexColorFragmentShader();
			}
			_material = new StandardMaterial( defaultVertexShader, defaultFragmentShader );
			minBounds = new Point();
			maxBounds = new Point();
		}
		
		override public function dispose():void
		{
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
		}
		
		public function set material( value:IMaterial ):void
		{
			_material = value;
		}
		
		public function get material():IMaterial
		{
			return _material;
		}
		
		public function get numVertices():int
		{
			return _numVertices;
		}
		
		override public function getBounds(targetSpace:DisplayObject, resultRect:Rectangle=null):Rectangle
		{
			if (resultRect == null) resultRect = new Rectangle();
			
			if ( _numVertices == 0 )
			{
				resultRect.x = resultRect.y = resultRect.width = resultRect.height = 0;
				return resultRect;
			}
			
			if (targetSpace == this) // optimization
			{
				resultRect.x = minBounds.x;
				resultRect.y = minBounds.y;
				resultRect.right = maxBounds.x;
				resultRect.bottom = maxBounds.y;
				return resultRect;
			}
			
			getTransformationMatrix(targetSpace, sHelperMatrix);
			
			var TL:Point = sHelperMatrix.transformPoint(minBounds.clone());
			var BR:Point = sHelperMatrix.transformPoint(maxBounds.clone());
			resultRect.x = TL.x;
			resultRect.y = TL.y;
			resultRect.right = BR.x;
			resultRect.bottom = BR.y;
			
			return resultRect;
		}
		
		override public function render( renderSupport:RenderSupport, alpha:Number ):void
		{
			// always call this method when you write custom rendering code!
			// it causes all previously batched quads/images to render.
			renderSupport.finishQuadBatch();
			
			var context:Context3D = Starling.context;
			if (context == null) throw new MissingContextError();
			
			RenderSupport.setBlendFactors(false, this.blendMode == BlendMode.AUTO ? renderSupport.blendMode : this.blendMode);
			_material.alpha = alpha;
			_material.drawTriangles( Starling.context, renderSupport.mvpMatrix3D, vertexBuffer, indexBuffer );
			
			context.setTextureAt(0, null);
			context.setTextureAt(1, null);
			context.setVertexBufferAt(0, null);
			context.setVertexBufferAt(1, null);
			context.setVertexBufferAt(2, null);
		}
	}
}