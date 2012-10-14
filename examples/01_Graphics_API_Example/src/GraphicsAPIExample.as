package
{
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import starling.display.Shape;
	import starling.display.Sprite;
	import starling.display.graphics.Fill;
	import starling.display.graphics.Stroke;
	import starling.display.materials.StandardMaterial;
	import starling.display.shaders.fragment.TextureVertexColorFragmentShader;
	import starling.display.shaders.vertex.StandardVertexShader;
	import starling.events.Event;
	import starling.textures.Texture;
	
	public class GraphicsAPIExample extends Sprite
	{
		[Embed( source = "/assets/Rock2.png" )]
		private var RockBMP			:Class;
		
		[Embed( source = "/assets/Checker.png" )]
		private var CheckerBMP		:Class;
		
		[Embed( source = "/assets/marble_80x80.png" )]
		private var MarbleBMP		:Class;
		
		[Embed( source = "/assets/Grass.png" )]
		private var GrassBMP		:Class;
		
		public function GraphicsAPIExample()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		private function onAdded ( e:Event ):void
		{
			var top:int = 0;
			var left:int = 0;
			var right:int = 100;
			var bottom:int = 100;
			
			var fillColor:uint = 0x08acff;
			var fillAlpha:Number = 1;
			var strokeColor:int = 0xc07732;
			var strokeAlpha:Number = 1;
			var strokeThickness:int = 3;
			
			
			// Rect drawn with drawRect()
			var shape:Shape = new Shape();
			addChild(shape);
			
			shape.x = 100;
			shape.y = 100;
			
			shape.graphics.beginFill(fillColor, fillAlpha);
			shape.graphics.lineStyle(strokeThickness, strokeColor, strokeAlpha);
			shape.graphics.drawRect(top, left, right, bottom);
			shape.graphics.endFill();
			
			
			// Rect drawn with lineTo()
			shape = new Shape();
			addChild(shape);
			
			shape.x = 300;
			shape.y = 100;
			
			shape.graphics.beginFill(fillColor, 0.2);
			shape.graphics.lineStyle(5, 0xFF0000, strokeAlpha);
			shape.graphics.moveTo(left, top);
			shape.graphics.lineTo(right, top);
			shape.graphics.lineTo(right, bottom);
			shape.graphics.lineTo(left, bottom);
			shape.graphics.lineTo(left, top);
			
			shape.graphics.endFill();
			
			
			// Filled Circle
			shape = new Shape();
			addChild(shape);
			
			shape.x = 150;
			shape.y = 300;
			
			shape.graphics.beginFill(fillColor, 0.2);
			shape.graphics.lineStyle(5, 0x00FF00, strokeAlpha);
			shape.graphics.drawCircle(0, 0, 50);
			shape.graphics.endFill();
			
			
			// Line Ellipse
			shape = new Shape();
			addChild(shape);
			
			shape.x = 350;
			shape.y = 300;
			
			shape.graphics.lineStyle(3, 0x0000FF, strokeAlpha);
			shape.graphics.drawEllipse(0, 0, 75, 50);
			
			
			// 2 Triangles in one Shape
			shape = new Shape();
			addChild(shape);
			
			shape.x = 500;
			shape.y = 100;
			
			shape.graphics.beginFill(fillColor, 0.2);
			shape.graphics.lineStyle(2, 0xFF0000, 0.5);
			shape.graphics.moveTo(left, top);
			shape.graphics.lineTo(right, bottom);
			shape.graphics.lineTo(left, bottom);
			shape.graphics.lineTo(left, top);
			
			shape.graphics.endFill();
			
			var xOffset:uint = 140;
			shape.graphics.beginFill(fillColor, 0.2);
			shape.graphics.lineStyle(2, 0xFF0000, 0.5);
			shape.graphics.moveTo(left + xOffset, top);
			shape.graphics.lineTo(right + xOffset, bottom);
			shape.graphics.lineTo(left + xOffset, bottom);
			shape.graphics.lineTo(left + xOffset, top);
			
			shape.graphics.endFill();
			
			
			// Multiple moveTo() test
			shape = new Shape();
			addChild(shape);
			
			shape.x = 500;
			shape.y = 250;
			
			shape.graphics.lineStyle(2, 0x000000, 0.5);
			shape.graphics.lineTo(100, 0);
			shape.graphics.moveTo(0,30);
			shape.graphics.lineTo(100, 30);
			shape.graphics.moveTo(0,60);
			shape.graphics.lineTo(100, 60);		
			
			// Triangle with CheckerBMP
			shape = new Shape();
			addChild(shape);
			
			var m:Matrix = new Matrix();
			m.translate(0, 0);
			
			shape.x = 100;
			shape.y = 400;
			
			shape.graphics.beginBitmapFill(new CheckerBMP(), m);
			shape.graphics.lineStyle(2, 0xFF0000, 0.5);
			shape.graphics.moveTo(left, top);
			shape.graphics.lineTo(right, bottom);
			shape.graphics.lineTo(left, bottom);
			shape.graphics.lineTo(left, top);
			shape.graphics.endFill();
			
			
			// Marble
			shape = new Shape();
			addChild(shape);
			
			shape.x = 350;
			shape.y = 450;
			
			m = new Matrix();
			m.translate(-25, -25);
			shape.graphics.beginBitmapFill(new MarbleBMP(), m, false);
			shape.graphics.lineStyle(2, 0xFF0000, strokeAlpha);
			shape.graphics.drawCircle(0, 0, 25);
			shape.graphics.endFill();
			
			
			// Rect drawn with textured fill and stroke
			shape = new Shape();
			addChild(shape);
			
			m = new Matrix();
			m.translate(0, 0);
			
			shape.x = 500;
			shape.y = 400;
			
			var rockTexture:Texture = Texture.fromBitmap( new RockBMP(), false );
			var grassTexture:Texture = Texture.fromBitmap( new GrassBMP(), false );
			
			shape.graphics.beginTextureFill(rockTexture, m);
			shape.graphics.lineTexture(20, grassTexture);
			shape.graphics.drawRect(top, left, right, bottom);
			shape.graphics.endFill();
			
		}
	}
}














