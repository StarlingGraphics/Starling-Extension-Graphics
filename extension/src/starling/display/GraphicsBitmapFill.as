package starling.display 
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	/**
	 * ...
	 *  Trivial implementation of GraphicsBitmapFill.
	 *  Which I realize that we shouldn't really use, since the Texture sent to Starling will
	 *  be recreated on every use. Added the class anyway for completeness sake.
	 */
	public class GraphicsBitmapFill implements IGraphicsData 
	{
		
		protected var mBitmapData:BitmapData;
		protected var mMatrix:Matrix;
		
		public function GraphicsBitmapFill(bitmapData:BitmapData, matrix:Matrix = null ) 
		{
			mBitmapData = bitmapData;
			mMatrix = matrix;
		}
		
		public function get bitmapData() : BitmapData
		{
			return mBitmapData;
		}
		
		public function get matrix() : Matrix
		{
			return mMatrix;
		}
	}

}