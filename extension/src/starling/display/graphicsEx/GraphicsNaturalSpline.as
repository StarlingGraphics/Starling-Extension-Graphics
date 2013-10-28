package starling.display.graphicsEx 
{
	import starling.display.GraphicsPathCommands;
	import starling.display.IGraphicsData;
	
	/**
	 * ...
	 * Making the spline usable for GraphicsPath as well
	 */
	
	public class GraphicsNaturalSpline implements IGraphicsData 
	{
		protected var mControlPoints:Array;
		protected var mClosed:Boolean;
		protected var mSteps:int;
		
		public function GraphicsNaturalSpline(controlPoints:Array = null, closed:Boolean = false, steps:int = 4) 
		{
			mControlPoints = controlPoints;
			mClosed = closed ;
			mSteps = steps;
			if ( mControlPoints == null )
				mControlPoints = [];
		}
		
		public function get controlPoints() : Array
		{
			return mControlPoints;
		}
		
		public function get closed() :Boolean
		{
			return mClosed;
		}
		
		public function get steps() : int
		{
			return mSteps;
		}
		
	}

}