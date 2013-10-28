package starling.display 
{
	
	/**
	 * ...
	 * API-breaking class GraphicsLine, allowing for line thickness, color, alpha on line segments.
	 */
	public class GraphicsLine implements IGraphicsData 
	{
		protected var mThickness:Number = NaN;
		protected var mColor:int = 0;
		protected var mAlpha:Number = 1.0;
		
		public function GraphicsLine(thickness:Number = NaN, color:int = 0, alpha:Number = 1.0 ) 
		{
			mThickness = thickness;
			mColor = color;
			mAlpha = alpha;
		}
		
		public function get thickness() : Number
		{
			return mThickness;
		}
		
		public function get color() : int
		{
			return mColor;
		}
		
		public function get alpha() : Number
		{
			return mAlpha;
		}
		
	}

}