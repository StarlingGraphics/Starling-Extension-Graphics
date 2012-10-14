package starling.display
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import starling.core.RenderSupport;
	
	public class Shape extends DisplayObjectContainer
	{
		public var graphics			:Graphics;
		
		public function Shape( showProfiling:Boolean = false )
		{
			graphics = new Graphics(this, showProfiling);
		}
		
		override public function getBounds(targetSpace:DisplayObject, resultRect:Rectangle=null):Rectangle
        {
            return new Rectangle();
        }
	}
}