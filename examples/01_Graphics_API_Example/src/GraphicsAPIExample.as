package
{
	import flash.display.Bitmap;
	import flash.geom.Matrix;
	import flash.system.System;
	import starling.core.Starling;
	import starling.display.Shape;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;
	
	public class GraphicsAPIExample extends Sprite
	{
		[Embed( source = "/assets/Rock.png" )]
		private var RockBMP			:Class;
		
		[Embed( source = "/assets/Checker.png" )]
		private var CheckerBMP		:Class;
		
		[Embed( source = "/assets/Marble.png" )]
		private var MarbleBMP		:Class;
		
		[Embed( source = "/assets/Grass.png" )]
		private var GrassBMP		:Class;
		
		// Display objects
		private var shape			:Shape;
		
		// Resources
		private var rockBMP			:Bitmap;
		private var grassBMP		:Bitmap;
		private var checkerBMP		:Bitmap;
		private var marbleBMP		:Bitmap;
		
		private var rockTexture		:Texture;
		private var grassTexture	:Texture;
		private var checkerTexture	:Texture;
		private var marbleTexture	:Texture;
		
		
		
		public function GraphicsAPIExample()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		private function onAdded ( e:Event ):void
		{
			shape = new Shape();
			addChild(shape);
			shape.x = 20;
			shape.y = 20;
			
			rockBMP = new RockBMP();
			grassBMP = new GrassBMP();
			checkerBMP = new CheckerBMP();
			marbleBMP = new MarbleBMP();
			
			rockTexture = Texture.fromBitmap( rockBMP, false );
			grassTexture = Texture.fromBitmap( grassBMP, false );
			checkerTexture = Texture.fromBitmap( checkerBMP, false );
			marbleTexture = Texture.fromBitmap( marbleBMP, false );
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private var runCount:int = 0;
		private function onEnterFrame():void
		{
			// Run and clear the example multiple times
			// to expose any potential memory leaks to Scout.
			shape.graphics.clear();
			runExample();
			System.gc();
			
			runCount++;
			if ( runCount == 30 )
			{
				//removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
		}
		
		private function runExample():void
		{
			// Rect drawn with drawRect()
			shape.graphics.beginFill(0x8dc63f);
			shape.graphics.drawRect(0, 0, 100, 100);
			shape.graphics.endFill();
			
			// Rect drawn with lineTo()
			shape.graphics.beginFill(0xc72046);
			shape.graphics.moveTo(110, 0);
			shape.graphics.lineTo(210, 0);
			shape.graphics.lineTo(210, 100);
			shape.graphics.lineTo(110, 100);
			shape.graphics.lineTo(110, 0);
			shape.graphics.endFill();
			
			// Rounded rect
			shape.graphics.lineStyle(2,0xFFFFFF);
			shape.graphics.beginFill(0x0957c0);
			shape.graphics.drawRoundRect( 220, 0, 100, 100, 20 );
			shape.graphics.endFill();
			shape.graphics.lineStyle();
			
			// Filled Circle
			shape.graphics.beginFill(0xfcc738);
			shape.graphics.drawCircle(380, 50, 50);
			shape.graphics.endFill();
			
			// Complex rounded rect
			shape.graphics.beginFill(0xff7b00);
			shape.graphics.drawRoundRectComplex( 0, 110, 430, 100, 0, 20, 40, 80 );
			shape.graphics.endFill();
			
			// Stroked ellipse
			shape.graphics.lineStyle(6, 0x00bff3);
			shape.graphics.drawEllipse(490, 105, 100, 200);
			
			// Multiple moveTo() test
			shape.graphics.lineStyle(2, 0xFFFFFF, 1);
			for ( var i:int = 0; i < 4; i++ )
			{
				shape.graphics.moveTo(0, 220+i*20);
				shape.graphics.lineTo(550, 220+i*20);
			}		
			
			// Textured fill
			shape.graphics.lineStyle(-1);
			shape.graphics.beginTextureFill(checkerTexture);
			shape.graphics.moveTo(0, 300);
			shape.graphics.lineTo(100, 400);
			shape.graphics.lineTo(0, 400);
			shape.graphics.lineTo(0, 300);
			shape.graphics.endFill();
			
			// Marble
			var uvMatrix:Matrix = new Matrix();
			uvMatrix.translate( -marbleTexture.width*0.5 + 150, -marbleTexture.height*0.5 + 364 );
			shape.graphics.beginTextureFill(marbleTexture, uvMatrix);
			shape.graphics.lineStyle(2, 0xFFFFFF, 1);
			shape.graphics.drawCircle(150, 364, 32);
			shape.graphics.endFill();
			
			// Rect drawn with textured fill and stroke
			shape.graphics.beginTextureFill(rockTexture);
			shape.graphics.lineTexture(20, grassTexture);
			shape.graphics.drawRect(0, 450, 550, 100);
			shape.graphics.endFill();
		}
	}
}














