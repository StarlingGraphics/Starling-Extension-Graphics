package
{
	import starling.display.Shape;
	import starling.display.Sprite;
	import starling.display.graphics.NGon;
	import starling.events.Event;
	
	public class NGonTest extends Sprite
	{	
		private var shape:Shape;
		
		public function NGonTest()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		private function onAdded ( e:Event ):void
		{
			addNGon(200, 150, false, 0, 335, 0x00ff00);
			addNGon(200, 150, false, 0, 336, 0xff0000); // Losing shape when endAngle == 336
			addNGon(200, 150, false, 0, 337, 0x0000ff);
			
			addNGon(600, 150, false, -11, 0, 0x00ff00);
			addNGon(600, 150, false, -12, 0, 0xff0000); // Losing shape in startAngle == -12
			addNGon(600, 150, false, -13, 0, 0x0000ff);
			
			addNGon(200, 450, true, 0, 335, 0x00ff00);
			addNGon(200, 450, true, 0, 336, 0xff0000); // Losing shape when endAngle == 336
			addNGon(200, 450, true, 0, 337, 0x0000ff);
			
			addNGon(600, 450, true, -11, 0, 0x00ff00);
			addNGon(600, 450, true, -12, 0, 0xff0000); // Losing shape in startAngle == -12
			addNGon(600, 450, true, -13, 0, 0x0000ff);
		}
		
		private function addNGon(x:Number, y:Number, isArc:Boolean, startAngle:Number, endAngle:Number, color:uint):void
		{
			var shape:NGon = new NGon(120, 60, isArc ? 60 : 0, startAngle, endAngle);
			shape.color = color;
			shape.x = x;
			shape.y = y;
			shape.alpha = 0.2;
			addChild(shape);
		}
	}
}