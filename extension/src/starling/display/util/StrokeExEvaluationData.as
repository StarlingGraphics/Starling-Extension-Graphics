package starling.display.util 
{
	import starling.display.graphicsEx.StrokeEx;
	
	public class StrokeExEvaluationData 
	{
		public var lastT:Number;
		public var stroke:StrokeEx;
		public var startVertSearchIndex:int;
		public var distanceToPrevVert:Number;	
		
		public function StrokeExEvaluationData(s:StrokeEx) 
		{
			reset(s);
		}
		
		public function reset(s:StrokeEx) : void
		{
			stroke = s;
			startVertSearchIndex = -1;
			distanceToPrevVert = lastT = -1;
		}
		
	}

}