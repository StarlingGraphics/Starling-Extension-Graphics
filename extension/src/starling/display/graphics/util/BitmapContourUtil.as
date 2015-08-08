package starling.display.graphics.util 
{
	import flash.geom.Point;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import starling.display.graphics.Fill;
	import starling.display.graphics.Graphic;
	import starling.display.graphics.TriangleFan;
	import starling.utils.ArrayUtil;
	import starling.display.graphics.Stroke;
	import flash.utils.ByteArray;
	
	
	public class BitmapContourUtil 
	{
		public function BitmapContourUtil() 
		{
			
		}
		
		public static var trySortClockwise:Boolean = true;
		
		public static function createContourFromColorBitmap(inputBitmap:Bitmap, graphic:Object, excludeColor:uint = 0xFFFFFF, excludeDiff:int = 32, thickness:Number = 1, color:uint = 0xFFFFFF, alpha:Number = 1 ) : void
		{
			var pointArray:Vector.<Point> = scanCountoursColor(inputBitmap.bitmapData, excludeColor, excludeDiff);
			
			var sortedArray:Vector.<Point> = new Vector.<Point>(pointArray.length+1, true);
			sortPointArray(pointArray, sortedArray);
			
			populateGraphic(graphic, sortedArray, thickness, color, alpha);
		}
		
		public static function createContourFromAlphaBitmap(inputBitmap:Bitmap, graphic:Object, alphaThreshold:int = 0, thickness:Number = 1, color:uint = 0xFFFFFF, alpha:Number = 1 ) : void
		{
			var pointArray:Vector.<Point> = scanCountoursAlpha(inputBitmap.bitmapData, alphaThreshold);
			
			var sortedArray:Vector.<Point> = new Vector.<Point>(pointArray.length+1, true);
			sortPointArray(pointArray, sortedArray);
			
			populateGraphic(graphic, sortedArray, thickness, color, alpha);
		}

		protected static function populateGraphic(graphic:Object, sortedArray:Vector.<Point>, thickness:Number = 1, color:uint = 0xFFFFFF, alpha:Number = 1) : void
		{
			if ( graphic is Array )
			{
				var array:Array = graphic as Array;
				for ( var i : int = 0; i < array.length; i++ )
				{
					var gfx:Graphic = array[i];
					if ( gfx is Fill || gfx is Stroke || gfx is TriangleFan )
						populateGraphicData(gfx, sortedArray, thickness, color, alpha);
					else
						throw new Error("Wrong type sent to BitmapContourUtil. Only Fill, Stroke, TriangleFan and an Array of those types supported");
				}
			}
			else
			{
				if ( graphic is Fill || graphic is Stroke || graphic is TriangleFan )
					populateGraphicData(graphic as Graphic, sortedArray, thickness, color, alpha);
				else
					throw new Error("Wrong type sent to BitmapContourUtil. Only Fill, Stroke, TriangleFan and an Array of those types supported");
			}
		}
		
		private static function populateGraphicData(graphic:Graphic, sortedArray:Vector.<Point>, thickness:Number = 1, color:uint = 0xFFFFFF, alpha:Number = 1) : void
		{
			var i:int;
			var stroke:Stroke = graphic as Stroke;
			if ( stroke )
			{
				stroke.clear();
				for ( i = 0; i < sortedArray.length; i++ )
				{
					stroke.lineTo(sortedArray[i].x, sortedArray[i].y, thickness, color, alpha);
				}
			}
			var fill:Fill = graphic as Fill;
			if ( fill )
			{
				fill.clear();
				for ( i = 0; i < sortedArray.length; i++ )
				{
					fill.addVertex(sortedArray[i].x, sortedArray[i].y, color, alpha);
				}
			}
			var fan:TriangleFan = graphic as TriangleFan;
			if ( fan )
			{
				fan.clear();
				
				var minX:Number = Number.POSITIVE_INFINITY;
				var maxX:Number = Number.NEGATIVE_INFINITY;
				var minY:Number = Number.POSITIVE_INFINITY;
				var maxY:Number = Number.NEGATIVE_INFINITY;
				
				var r:int = ( color & 0xFF);
				var g:int = ( color >> 8 & 0xFF);
				var b:int = ( color >> 16 & 0xFF);
				
				for ( i = 0; i < sortedArray.length; i++ )
				{
					var x:Number = sortedArray[i].x;
					var y:Number = sortedArray[i].y;
					if ( x < minX ) minX = x;
					if ( x > maxX ) maxX = x;
					if ( y < minY ) minY = y;
					if ( y > maxY ) maxY = y;
				}
				var centerX:Number = minX + 0.5 * (maxX - minX);
				var centerY:Number = minY + 0.5 * (maxY - minY);
				
				fan.addVertex( centerX, centerY , 0, 0, r, g, b, alpha );
				for ( i = 0; i < sortedArray.length; i++ )
				{
					fan.addVertex(sortedArray[i].x, sortedArray[i].y, color, alpha);
				}
			}
			
		}

		
		private static function sortPointArray(pointArray:Vector.<Point>, sortedArray:Vector.<Point>) : void
		{
			var index:int = 0;
			var len:int = pointArray.length;
			var startSearchPoint:int = 0;
			var sortedIndex:int = 0;
			var startPoint:Point = pointArray[index];
			if ( trySortClockwise )
			{
				index = 1;
				startPoint = pointArray[index];
			}
				
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
				var numSteps:int = 30;
				if ( index < numSteps )
					startSearchPoint = 0;
				else
					startSearchPoint = index - numSteps;
			}
			
		}
		
		private static function scanCountoursAlpha(bitmapData:BitmapData, alphaThreshold:int = 0) : Vector.<Point>
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

		private static function scanCountoursColor(bitmapData:BitmapData, excludeColor:uint, excludeColorDiff:int = 10 ) : Vector.<Point>
		{
			var retval:Vector.<Point> = new Vector.<Point>();
			var pixels:ByteArray = bitmapData.getPixels(bitmapData.rect);
			pixels.position = 0;
			var bmdWidth:int = bitmapData.width;
			var bmdHeight:int = bitmapData.height;
			var excludeR:int = ( excludeColor & 0xFF);
			var excludeG:int = ( excludeColor >> 8 & 0xFF);
			var excludeB:int = ( excludeColor >> 16 & 0xFF);
			var threshholdR:int = excludeR + excludeColorDiff;
			var threshholdG:int = excludeG + excludeColorDiff;
			var threshholdB:int = excludeB + excludeColorDiff;
			var acceptUp:Boolean = true;
			if ( excludeR > 128 )
			{
				acceptUp = false;
				threshholdR = excludeR - excludeColorDiff;
				threshholdG = excludeG - excludeColorDiff;
				threshholdB = excludeB - excludeColorDiff;
			}
			
			for ( var y:int = 0; y < bmdHeight; y++ )
			{
				var isScanningPixels:Boolean = false;
				var lastXPos:int = 0;
				var firstXPos:int = 0;
				for ( var x:int = 0; x < bmdWidth; x++ )
				{
					var pixel:uint = pixels.readUnsignedInt();
					var r:int = ( pixel & 0xFF);
					var g:int = ( pixel >> 8 & 0xFF);
					var b:int = ( pixel >> 16 & 0xFF);
					if ( acceptUp )
					{
						if ( isScanningPixels && ( r > threshholdR || g > threshholdG || b > threshholdB ) )
						{
							lastXPos = x;
						}
						else if ( isScanningPixels == false && ( r > threshholdR || g > threshholdG || b > threshholdB ) )
						{
							isScanningPixels = true;
							firstXPos = x;
						}
					}
					else
					{
						if ( isScanningPixels && ( r < threshholdR || g < threshholdG || b < threshholdB ) )
						{
							lastXPos = x;
						}
						else if ( isScanningPixels == false && ( r < threshholdR || g < threshholdG || b < threshholdB ) )
						{
							isScanningPixels = true;
							firstXPos = x;
						}
					}
				}
				if ( isScanningPixels)
				{
					if ( firstXPos > 0 && lastXPos > firstXPos )
					{
						retval.push(new Point(firstXPos, y));
						retval.push(new Point(lastXPos, y));
					}
				}
			}
			return retval;
		}

	}

}
