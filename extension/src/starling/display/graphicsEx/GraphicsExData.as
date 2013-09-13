package starling.display.graphicsEx 
{
	/**
	 * ...
	 * @author Henrik Jonsson
	 */
	public class GraphicsExData 
	{
		// Parameters to control thickness along the segment
		public var endThickness:Number = -1;
		public var thicknessCallback:Function = null;
	//	public var thicknessArray:Array = null; // The arrays are not yet supported
		
		// Parameters to control alpha along the segment
		public var endAlpha:Number = -1;
		public var alphaCallback:Function = null;
	//	public var alphaArray:Array = null; // The arrays are not yet supported
		
		public function GraphicsExData() 
		{
			
		}

		public function clone() : GraphicsExData
		{
			var c:GraphicsExData = new GraphicsExData();
			c.endThickness = endThickness;
			c.thicknessCallback = thicknessCallback;
			c.endAlpha = endAlpha;
			c.alphaCallback = alphaCallback;
			return c;
		}
	}

}