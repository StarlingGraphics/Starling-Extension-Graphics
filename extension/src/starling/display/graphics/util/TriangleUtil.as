package starling.display.graphics.util 
{

	public class TriangleUtil 
	{
		
		public function TriangleUtil() 
		{
			
		}
		
		public static function isLeft(v0x:Number, v0y:Number, v1x:Number, v1y:Number, px:Number, py:Number):Boolean
		{
			return ((v1x - v0x) * (py - v0y) - (v1y - v0y) * (px - v0x)) < 0;
		}
		
		public static function isPointInTriangle(v0x:Number, v0y:Number, v1x:Number, v1y:Number, v2x:Number, v2y:Number, px:Number, py:Number ):Boolean
		{
			if ( isLeft( v2x, v2y, v0x, v0y, px, py ) ) return false;  // In practical tests, this seems to be the one returning false the most. Put it on top as faster early out.
			if ( isLeft( v0x, v0y, v1x, v1y, px, py ) ) return false;
			if ( isLeft( v1x, v1y, v2x, v2y, px, py ) ) return false;
			return true;
		}
	}

}