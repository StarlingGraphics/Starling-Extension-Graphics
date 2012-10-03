package starling.display
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import starling.core.RenderSupport;
	import starling.display.DisplayObject;
	import starling.display.graphics.Fill;
	import starling.display.graphics.Stroke;
	import starling.display.materials.IMaterial;
	import starling.display.shaders.fragment.TextureVertexColorFragmentShader;
	import starling.textures.Texture;
	
	public class Shape extends DisplayObjectContainer
	{
		private var penPositionPrev	:Point;
		private var penPosition		:Point;
		
		private var penDown			:Boolean = false;
		private var currentFill		:Fill;
		private var currentStroke	:Stroke;
		
		private var showProfiling	:Boolean;
		
		public var graphics			:Graphics;
		
		public function Shape( showProfiling:Boolean = false )
		{
			this.showProfiling = showProfiling
			penPosition = new Point();
			penPositionPrev = new Point();
			
			graphics	= new Graphics(this, showProfiling);
		}
		
		override public function getBounds(targetSpace:DisplayObject, resultRect:Rectangle=null):Rectangle
        {
            return new Rectangle();
        }

		override public function render( renderSupport:RenderSupport, alpha:Number ):void
		{
			super.render(renderSupport, alpha);
		}
	}
}