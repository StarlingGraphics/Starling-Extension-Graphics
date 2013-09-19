package starling.display.graphicsEx 
{
	
	public class GraphicsExColorData 
	{
		// Parameters to control alpha and color along the segment
		public var endAlpha:Number = 1.0;
		public var endRed:int = 0xFF;
		public var endGreen:int = 0xFF;
		public var endBlue:int = 0xFF;
		
		public var startAlpha:Number = 1.0;
		public var startRed:int = 0xFF;
		public var startGreen:int = 0xFF;
		public var startBlue:int = 0xFF;
		
		public var colorCallback:Function = null; // Color callback not yet supported
		public var alphaCallback:Function = null; // Alpha callback not yet supported
		
		
		public function GraphicsExColorData(startColor:uint = 0xFFFFFF, endColor:uint = 0xFFFFFF, sAlpha:Number = 1.0, eAlpha:Number = 1.0, colorFunc:Function = null, alphaFunc:Function = null) 
		{
			endAlpha = eAlpha;
			endRed = (( endColor >> 16 ) & 0xFF);
			endGreen = ( (endColor >> 8) & 0xFF );
			endBlue  = ( endColor & 0xFF );
			
			startAlpha = sAlpha;
			
			startRed = (( startColor >> 16 ) & 0xFF);
			startGreen = ( (startColor >> 8) & 0xFF );
			startBlue  = ( startColor & 0xFF );
			
			colorCallback = colorFunc;
			alphaCallback = alphaFunc;
			
		}

		public function clone() : GraphicsExColorData
		{
			var c:GraphicsExColorData = new GraphicsExColorData();
		
			c.endAlpha = endAlpha;
			c.endRed = endRed;
			c.endGreen = endGreen;
			c.endBlue = endBlue;
			
			c.startAlpha = startAlpha;
			c.startRed = startRed;
			c.startGreen = startGreen;
			c.startBlue = startBlue;
			
			c.alphaCallback = alphaCallback;
			
			c.colorCallback = colorCallback;
			
			return c;
		}
	}

}