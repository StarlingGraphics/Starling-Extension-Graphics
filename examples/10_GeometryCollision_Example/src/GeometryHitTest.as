package
{
	
	import flash.display.Shape;
	import starling.display.graphics.Graphic;
	import starling.display.graphics.NGon;
	import starling.display.graphics.TriangleFan;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	import starling.display.graphicsEx.StrokeEx;
	import starling.events.TouchEvent;
	
	import starling.core.Starling;
	import starling.display.graphicsEx.ShapeEx;
	
	import starling.display.graphics.Stroke;
	
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class GeometryHitTest extends Sprite
	{
		private var shape1			:ShapeEx;
		private var shape2			:ShapeEx;
		private var shape3			:ShapeEx;
		private var shape4			:ShapeEx;
		
		private var shape5			:ShapeEx;
		
		private var shape6			:ShapeEx;
		private var shape7			:ShapeEx;
	
		
		private var starStroke1: Stroke;
		private var starStroke2: Stroke;
		private var starStroke3: Stroke;
		
		private var largeCircle:Stroke;
		private var smallCircle:Stroke;
		
		private var startTime		:int;
		private var pt:Point = new Point();
		private var normalAtPoint:Point = new Point();
		
		private var gravitation:Number = 0.13;
		private var speed:Point = new Point();
		
		
		private var ptVector:Vector.<Point>;
		
		public function GeometryHitTest()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		private function onAdded ( e:Event ):void
		{
			ptVector = new Vector.<Point>(100, true);
			for ( var i:int = 0; i < 100; i++ )
				ptVector[i] = new Point();
				
			shape1 = new ShapeEx();
			shape1.graphics.precisionHitTest = true;
			createStarShape(shape1);
			addChild(shape1);
			shape1.alignPivot();
			shape1.x = 250;
			shape1.y = 300;
			
			shape2 = new ShapeEx();
			shape2.graphics.precisionHitTest = true;
			createStarShape(shape2);
			addChild(shape2);
			shape2.alignPivot();
			shape2.x = 410;
			shape2.y = 410;
			
			
			shape3 = new ShapeEx();
			shape3.graphics.precisionHitTest = true;
			createStarShape(shape3);
			addChild(shape3);
			shape3.alignPivot();
			shape3.x = 450;
			shape3.y = 190;
			
			
			shape4 = new ShapeEx();
			shape4.graphics.precisionHitTest = true;
			createOddShape(shape4);
			addChild(shape4);
			shape4.alignPivot();
			shape4.x = 160;
			shape4.y = 60;
			
			shape6 = new ShapeEx();
			shape6.graphics.precisionHitTest = true;
			shape6.graphics.lineStyle(1, 0);
			shape6.graphics.drawEllipse(0, 0, 400, 300);
			shape6.graphics.drawRect(-0, -0, 300, 300);
			shape6.x = 800;
			shape6.y = 400;
		
			
			addChild(shape6);
			
			shape1.addEventListener(TouchEvent.TOUCH, onShape1Touch);
			shape2.addEventListener(TouchEvent.TOUCH, onShape2Touch);
			shape3.addEventListener(TouchEvent.TOUCH, onShape3Touch);
			shape4.addEventListener(TouchEvent.TOUCH, onShape4Touch);
			
			startTime = getTimer();
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
	
		}
		
		private  function extractStrokes() : void
		{
			var i:int;
			for (i = 0; i < shape1.numChildren; i++ )
				if ( shape1.getChildAt(i) is Stroke )
					starStroke1 = Stroke(shape1.getChildAt(i));

			for (i = 0; i < shape2.numChildren; i++ )
				if ( shape2.getChildAt(i) is Stroke )
					starStroke2 = Stroke(shape2.getChildAt(i));						
			for (i = 0; i < shape3.numChildren; i++ )
				if ( shape3.getChildAt(i) is Stroke )
					starStroke3 = Stroke(shape3.getChildAt(i));		
				
			for (i = 0; i < shape6.numChildren; i++ )
				if ( shape6.getChildAt(i) is Stroke )
					largeCircle = Stroke(shape6.getChildAt(i));		
						
		}
		
		private var numFrames:int = 0;
		private function enterFrameHandler( event:Event ):void
		{
			numFrames++;
			
			shape1.rotation -= 0.007;
			shape2.rotation -= 0.01;
			shape3.rotation += 0.02;
			shape4.rotation -= 0.006;
			shape6.rotation += 0.003;
			shape6.x = 700 + 100 * Math.sin(getTimer() / 1000 );
			shape6.y = 400 + 100 * Math.cos(getTimer() / 1000 );
			
			var i:int = 0;
			if ( starStroke1 == null )
			{
				extractStrokes();
			}
			else
			{
				var hitPoint:Graphic;
					
				if ( Stroke.strokeCollideTest(starStroke1, starStroke2, pt, ptVector))
				{
					for ( i = 0; i < ptVector.length; i++ )
					{
						if ( ptVector[i].x == ptVector[i].x ) 
							drawBall(hitPoint, ptVector[i], 0xFF0000);
						else break;
					}
				}
				if ( Stroke.strokeCollideTest(starStroke1, starStroke3, pt, ptVector))
				{
					for ( i = 0; i < ptVector.length; i++ )
					{
						if ( ptVector[i].x == ptVector[i].x ) 
							drawBall(hitPoint, ptVector[i], 0x0000FF);
						else break;
					}
				}
					
				if ( Stroke.strokeCollideTest(starStroke2, starStroke3, pt, ptVector))
				{
					for ( i = 0; i < ptVector.length; i++ )
					{
						if ( ptVector[i].x == ptVector[i].x ) 
							drawBall(hitPoint, ptVector[i], 0x00FF00);
						else break;
					}
				}
				if ( Stroke.strokeCollideTest(largeCircle, starStroke3, pt, ptVector))
				{
					for ( i = 0; i < ptVector.length; i++ )
					{
						if ( ptVector[i].x == ptVector[i].x ) 
							drawBall(hitPoint, ptVector[i], 0x00FFFF);
						else break;
					}
				}
				
				if ( Stroke.strokeCollideTest(largeCircle, starStroke2, pt, ptVector))
				{
					for ( i = 0; i < ptVector.length; i++ )
					{
						if ( ptVector[i].x == ptVector[i].x ) 
							drawBall(hitPoint, ptVector[i], 0xFFFF00);
						else break;
					}
				}
				if ( Stroke.strokeCollideTest(largeCircle, starStroke1, pt, ptVector))
				{
					for ( i = 0; i < ptVector.length; i++ )
					{
						if ( ptVector[i].x == ptVector[i].x ) 
							drawBall(hitPoint, ptVector[i], 0xFF00FF);
						else break;
					}
				}
				
			}
		}
		
		private function drawBall(hitPoint:Graphic, pt:Point, color:uint) : void
		{
			
			hitPoint  = new NGon(5);
			hitPoint.x = pt.x;
			hitPoint.y = pt.y;
			addChild(hitPoint);
			Starling.juggler.delayCall(disposeGraphic, 0.5, hitPoint);
			NGon(hitPoint).color = color;
		}
		
		
		private function disposeGraphic(g:Graphic) : void
		{
			removeChild(g);
			g.dispose();
		}
		
		
		private function onShape1Touch(event:TouchEvent) : void
		{
			trace("Shape1 touch");
			addBall(event);
		}
		
		private function onShape2Touch(event:TouchEvent) : void 
		{
			trace("Shape2 touch");
			addBall(event);
		}
		
		private function onShape3Touch(event:TouchEvent) : void 
		{
			trace("Shape3 touch");
			addBall(event);
		}

		private function onShape4Touch(event:TouchEvent) : void 
		{
			trace("Shape4 touch");
			addBall(event);
		}
		
		private function addBall(event:TouchEvent) : void
		{
			if ( event != null && event.touches != null && event.touches.length > 0 )
			{
				var hitPoint:NGon = new NGon(3);
				hitPoint.x = event.touches[0].globalX;
				hitPoint.y = event.touches[0].globalY;
				addChild(hitPoint);
				Starling.juggler.delayCall(disposeGraphic, 0.5, hitPoint);
				hitPoint.color = Math.random() * 0xFFFFFF;
			}
		}
		

		private function createStarShape(shape:ShapeEx) : void
		{
			shape.graphics.clear();
			
			// star code copied from http://www.adobe.com/devnet/flash/quickstart/drawing_commands_as3.html
			// define the line style
			shape.graphics.lineStyle(2,0x000000);
 		//	shape.graphics.beginFill(0x339999);//set the color 
			shape.graphics.beginFill(0x666699);//set the color 
 			var star_commands:Vector.<int> = new Vector.<int>(); 
			// use  the Vector array push() method to add moveTo() and lineTo() values
			// 1 moveTo command followed by lineTo commands
			star_commands.push(1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2);
			// establish a new Vector object for the data parameter
			var star_coord:Vector.<Number> = new Vector.<Number>();
			// use the Vector array push() method to add a set of coordinate pairs
			star_coord.push(0,0, 75,50, 100,0, 125,50, 200,0, 150,75, 200,100, 150,125, 200,200, 125,150, 100,200, 75,150, 0,200, 50,125, 0,100, 50,75, 0,0); 
		
			shape.graphics.drawPath(star_commands, star_coord);
			
		}
		
		private function createCircleShape(shape:ShapeEx) : void
		{
			shape.graphics.clear();
			shape.graphics.lineStyle(2,0x000000);
 			shape.graphics.beginFill(0xAA3300);//set the color 
			shape.graphics.drawCircle(0,0, 50);
			
		}
		
		private function createOddShape(shape:ShapeEx) : void
		{
			shape.graphics.clear();
		//	shape.graphics.lineStyle(2,0x000000);
 			shape.graphics.beginFill(0x3333AA);//set the color 
			shape.graphics.moveTo(0, 0);
			shape.graphics.lineTo(100, 0);
			shape.graphics.lineTo(100, 90);
			shape.graphics.lineTo(0, 90);
			shape.graphics.lineTo(0, 70);
			shape.graphics.lineTo(30, 70);
			shape.graphics.lineTo(30, 30);
			shape.graphics.lineTo(0, 30);
			shape.graphics.lineTo(0, 0);
			
			
			
		}
	}
}