package behaviours
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import starling.display.Shape;

	public class BounceBehaviour
	{
		public var shape:Shape;
		public var velocity:Point;
		public var boundsRect:Rectangle;
		public var gravity:Number = 3;
		
		public function BounceBehaviour()
		{
		}
		
		public function step():void
		{			
			shape.x += velocity.x;
			shape.y += velocity.y;				
			velocity.y += gravity;
			
			if (shape.x > boundsRect.right) {
				velocity.x *= -1;
				shape.x = boundsRect.right;
			}
			else if (shape.x < boundsRect.left) {
				velocity.x *= -1;
				shape.x = boundsRect.left;
			}
			
			if (shape.y > boundsRect.bottom) {
				velocity.y *= -0.8;
				shape.y = boundsRect.bottom;
				
				if (Math.random() > 0.5) {
					velocity.y -= Math.random() * 12;
				}
			}
			else if (shape.y < boundsRect.top) {
				velocity.y = 0;
				shape.y = boundsRect.top;
			}
		}		
	}
}