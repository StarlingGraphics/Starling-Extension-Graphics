package starling.display.graphicsEx 
{
	
	public class GraphicsExThicknessData 
	{
		
		// Parameters to control thickness along the segment
		public var startThickness:Number = -1;
		public var endThickness:Number = -1;
		public var thicknessCallback:Function = null; // Callback function not yet supported
		
		public function GraphicsExThicknessData(sThick:int, eThick:int, callback:Function = null ) 
		{
			startThickness = sThick;
			endThickness = eThick;
			thicknessCallback = callback;
		}

		public function clone() : GraphicsExThicknessData
		{
			var c:GraphicsExThicknessData = new GraphicsExThicknessData(startThickness, endThickness, thicknessCallback);
			
			return c;
		}
	}

}