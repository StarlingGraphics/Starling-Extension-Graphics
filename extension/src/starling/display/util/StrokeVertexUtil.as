package starling.display.util 
{
	import starling.display.graphics.StrokeVertex;
	
	public class StrokeVertexUtil 
	{

        /** Removes the value at the specified index from the 'StrokeVertex'-Vector. Pass a negative
         *  index to specify a position relative to the end of the vector. */
        public static function removeStrokeVertexAt(vector:Vector.<StrokeVertex>, index:int):StrokeVertex
        {
            var i:int;
            var length:uint = vector.length;

            if (index < 0) index += length;
            if (index < 0) index = 0; else if (index >= length) index = length - 1;

            var value:StrokeVertex = vector[index];

            for (i = index+1; i < length; ++i)
                vector[i-1] = vector[i];

            vector.length = length - 1;
            return value;
        }
	}
}