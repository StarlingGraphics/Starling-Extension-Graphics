package starling.display 
{
	/**
	 * ...
	 * An implementation of flash.graphics.GraphicsPath
	 */
	public class GraphicsPath implements IGraphicsData
	{
		protected var mCommands:Vector.<int>;
		protected var mData:Vector.<Number>;
		protected var mWinding:String; 
		
		public function GraphicsPath(commands:Vector.<int> = null, data:Vector.<Number> = null, winding:String = "evenOdd") 
		{
			mCommands = commands;
			mData = data;
			mWinding = winding;
			
			if ( mCommands == null )
				mCommands = new Vector.<int>();
			if ( mData == null )
				mData = new Vector.<Number>();				
		}
		
		public function get data() : Vector.<Number>
		{
			return mData;
		}
		
		public function get commands() : Vector.<int>
		{
			return mCommands;
		}
		
		public function get winding() : String
		{
			return mWinding;
		}
		
		public function set winding(value:String) : void
		{
			mWinding = value;
		} 
		
		public function curveTo(controlX:Number, controlY:Number, anchorX:Number, anchorY:Number):void
		{
			mCommands.push(GraphicsPathCommands.CURVE_TO);
			mData.push(controlX, controlY, anchorX, anchorY);
		}
		
		public function lineTo(x:Number, y:Number):void
		{
			mCommands.push(GraphicsPathCommands.LINE_TO);
			mData.push(x, y);
		}
		
		public function moveTo(x:Number, y:Number):void
		{
			mCommands.push(GraphicsPathCommands.MOVE_TO);
			mData.push(x, y);
		}
		
		public function wideLineTo(x:Number, y:Number):void
		{
			mCommands.push(GraphicsPathCommands.WIDE_LINE_TO);
			mData.push(x, y);
		}
		
		public function wideMoveTo(x:Number, y:Number):void
		{
			mCommands.push(GraphicsPathCommands.WIDE_MOVE_TO);
			mData.push(x, y);
		}
		
	}

}