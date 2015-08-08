package starling.display.util 
{
	import starling.display.graphicsEx.StrokeEx;
	
	public class StrokeExEvaluationData 
	{
		public var distance:Number; // Distance holds the distance along the curve that the 't' value represents. 
		public var thickness:Number;
		public var r:Number;
		public var g:Number;
		public var b:Number;
		public var a:Number;
		
		// These are internal values, that should not be accessed by API users. 
		public var internalLastT:Number;
		public var internalLastX:Number;
		public var internalStroke:StrokeEx;
		public var internalStartVertSearchIndex:int;
		public var internalDistanceToPrevVert:Number;	
		public var internalLastStrokeLength:Number;
		
		public function StrokeExEvaluationData(s:StrokeEx) 
		{
			reset(s);
		}
		
		public function reset(s:StrokeEx) : void
		{
			internalStroke = s;
			internalStartVertSearchIndex = -1;
			internalDistanceToPrevVert = internalLastT = -1;
			internalLastX = -1;
			internalLastStrokeLength = distance = 0;
		}
		
	}

}