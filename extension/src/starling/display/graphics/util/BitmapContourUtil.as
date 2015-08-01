package starling.display.graphics.util 
{
	import flash.geom.Point;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import starling.utils.ArrayUtil;
	import starling.display.graphics.Stroke;
	import flash.utils.ByteArray;
	
	public class BitmapContourUtil 
	{
		
		public function BitmapContourUtil() 
		{
			
		}

		public static function createContourFromBitmap(inputBitmap:Bitmap, stroke:Stroke, alphaThreshold:int = 0, thickness:Number = 1, color:uint = 0xFFFFFF, alpha:Number = 1 ) : void
		{
			var pointArray:Vector.<Point> = scanCountours(inputBitmap.bitmapData, alphaThreshold);
			var sortedArray:Vector.<Point> = new Vector.<Point>(pointArray.length+1, true);
			sortPointArray(pointArray, 0, sortedArray, pointArray[0]);
			
			for ( var i:int = 0; i < sortedArray.length; i++ )
			{
				stroke.lineTo(sortedArray[i].x, sortedArray[i].y, thickness, color, alpha);
			}

		}
		
		private static function sortPointArray(pointArray:Vector.<Point>, index:int, sortedArray:Vector.<Point>, startPoint:Point) : void
		{
			var len:int = pointArray.length;
			var startSearchPoint:int = 0;
			var sortedIndex:int = 0;
			while ( len > 0 )
			{
				var currentPt:Point = pointArray[index];
				sortedArray[sortedIndex++] = currentPt;
				
				pointArray.splice(index, 1);
				
				len = pointArray.length;
				if ( len == 0 )
				{
					sortedArray[sortedIndex] = startPoint;
					return;
				}
				
				var closestDistanceSq:Number = 6666666;
				var closestDistanceIndex:int = -1;				
				
				for ( var i:int = startSearchPoint; i < len; i++ )
				{
					var pt:Point = pointArray[i];
					var dx:Number = pt.x - currentPt.x;
					var dy:Number = pt.y - currentPt.y;
					var dx2:Number = dx * dx;
					var dy2:Number = dy * dy;
					if ( dx2 > closestDistanceSq && dy2 > closestDistanceSq)
						break;
					
					var d:Number = dx2 + dy2;
					if ( d < closestDistanceSq )
					{
						closestDistanceSq = d;
						closestDistanceIndex = i;
					}
				}
				
				index = closestDistanceIndex;
				var numSteps:int = 20;
				if ( index < numSteps )
					startSearchPoint = 0;
				else
					startSearchPoint = index - numSteps;
			}
			
		}
		
		private static function scanCountours(bitmapData:BitmapData, alphaThreshold:int = 0) : Vector.<Point>
		{
			var retval:Vector.<Point> = new Vector.<Point>();
			var pixels:ByteArray = bitmapData.getPixels(bitmapData.rect);
			pixels.position = 0;
			var bmdWidth:int = bitmapData.width;
			var bmdHeight:int = bitmapData.height;
			
			for ( var y:int = 0; y < bmdHeight; y++ )
			{
				var isScanningPixels:Boolean = false;
				for ( var x:int = 0; x < bmdWidth; x++ )
				{
					var pixel:uint = pixels.readUnsignedInt();
					var a:int = ( pixel >> 24 & 0xFF);
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
