package starling.display.graphics.util 
{
	import flash.geom.Point;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import starling.utils.ArrayUtil;
	import starling.display.graphics.Stroke;
	
	public class BitmapContourUtil 
	{
		
		public function BitmapContourUtil() 
		{
			
		}

		public static function createContourFromBitmap(inputBitmap:Bitmap, stroke:Stroke, alphaThreshold:int = 0, thickness:Number = 1, color:uint = 0xFFFFFF, alpha:Number = 1 ) : void
		{
			var pointArray:Array = scanCountours(inputBitmap.bitmapData, alphaThreshold);
			var sortedArray:Array = new Array();
			sortPointArray(pointArray, 0, sortedArray, pointArray[0]);
			
			for ( var i:int = 0; i < sortedArray.length; i++ )
			{
				stroke.lineTo(sortedArray[i].x, sortedArray[i].y, thickness, color, alpha);
			}
		}
		
		private static function sortPointArray(pointArray:Array, index:int, sortedArray:Array, startPoint:Point) : void
		{
			var currentPt:Point = pointArray[index];
			sortedArray.push(currentPt);
			ArrayUtil.removeAt(pointArray, index);
			
			var len:int = pointArray.length;
			if ( len == 0 )
			{
				sortedArray.push(startPoint.clone());
				return;
			}
				
			var closestDistanceSq:Number = 6666666;
			var closestDistanceIndex:int = -1;
			
			for ( var i:int = 0; i < len; i++ )
			{
				var pt:Point = pointArray[i];
				var dx:Number = pt.x - currentPt.x;
				var dy:Number = pt.y - currentPt.y;
				var d:int = dx * dx + dy * dy;
				if ( d < closestDistanceSq )
				{
					closestDistanceSq = d;
					closestDistanceIndex = i;
				}
			}
			if ( closestDistanceIndex != -1 )
			{
				sortPointArray(pointArray, closestDistanceIndex, sortedArray, startPoint);
			}
			
		}
		
		private static function scanCountours(bitmapData:BitmapData, alphaThreshold:int = 0) : Array
		{
			var retval:Array = new Array();
			
			for ( var y:int = 0; y < bitmapData.height; y++ )
			{
				var isScanningPixels:Boolean = false;
				for ( var x:int = 0; x < bitmapData.width; x++ )
				{
					var a:int = (bitmapData.getPixel32(x, y) >> 24 & 0xFF);
					if ( isScanningPixels && a <= alphaThreshold )
					{
						isScanningPixels = false;
						
						retval.push(new Point(x, y));
						
					}
					else if ( isScanningPixels == false && a > alphaThreshold )
					{
						isScanningPixels = true;
						retval.push(new Point(x, y));
					}
				}
			}
			return retval;
		}
		
	}

}