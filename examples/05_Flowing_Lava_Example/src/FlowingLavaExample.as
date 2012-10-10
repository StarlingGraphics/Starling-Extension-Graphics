package
{
	/*
	
		An example demonstrating an effect acheivable with an animated UV vertex shader.
		
		Assets used with kind permission of Tomislav Podhraški. Original tutorial here
		http://gamedev.tutsplus.com/tutorials/implementation/create-a-glowing-flowing-lava-river-using-bezier-curves-and-shaders/
		
	*/
	
	import flash.geom.Matrix;
	
	import starling.display.Shape;
	import starling.display.Sprite;
	import starling.display.graphics.Graphic;
	import starling.display.graphics.Stroke;
	import starling.display.shaders.vertex.AnimateUVVertexShader;
	import starling.display.shaders.vertex.RippleVertexShader;
	import starling.events.Event;
	import starling.textures.Texture;
	
	[SWF( width="600", height="400", frameRate="60" )]
	public class FlowingLavaExample extends Sprite
	{
		[Embed( source = "/assets/BanksTiled.png" )]
		private var BanksTiledBMP		:Class;
		[Embed( source = "/assets/FinalBackground.png" )]
		private var FinalBackgroundBMP		:Class;
		[Embed( source = "/assets/FinalRock.png" )]
		private var FinalRockBMP		:Class;
		[Embed( source = "/assets/LavaTiled.png" )]
		private var LavaTiledBMP		:Class;
		[Embed( source = "/assets/GlowTiled.png" )]
		private var GlowTiledBMP		:Class;
		
		private var lavaTexture			:Texture;
		private var banksTexture		:Texture;
		private var backgroundTexture	:Texture;
		private var rockTexture			:Texture;
		
		public function FlowingLavaExample()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		private function onAdded ( e:Event ):void
		{
			// Some styles
			var lavaThickness:Number = 90;
			var bankThickness:Number = lavaThickness*2.2;
			
			lavaTexture = Texture.fromBitmap( new LavaTiledBMP(), false );
			banksTexture = Texture.fromBitmap( new BanksTiledBMP(), false );
			backgroundTexture = Texture.fromBitmap( new FinalBackgroundBMP(), false );
			rockTexture = Texture.fromBitmap( new FinalRockBMP(), false );
			
			var w:Number = stage.stageWidth;
			var h:Number = stage.stageHeight;
			
			var shape:Shape = new Shape();
			addChild(shape);
			
			var m:Matrix = new Matrix();
			m.scale( w/backgroundTexture.width, h/backgroundTexture.height);
			shape.graphics.beginTextureFill( backgroundTexture, m );
			shape.graphics.drawRect(0,0,w,h);
			shape.graphics.endFill();
			
			var shader:AnimateUVVertexShader = new AnimateUVVertexShader();
			shader.uSpeed = 0.1;
			shader.vSpeed = 0.0;
			shape.graphics.lineTexture( lavaThickness, lavaTexture, shader );
			shape.graphics.moveTo( 150, 0 );
			shape.graphics.curveTo( 500, 100, 500, 300 );
			shape.graphics.curveTo( 500, 500, 700, 650 );
			
			shape.graphics.lineTexture( bankThickness, banksTexture );
			shape.graphics.moveTo( 150, 0 );
			shape.graphics.curveTo( 500, 100, 500, 300 );
			shape.graphics.curveTo( 500, 500, 700, 650 );
			shape.graphics.lineStyle(0);
			
			m.identity();
			m.scale( w/rockTexture.width, (h/rockTexture.height)*1.6);
			shape.graphics.beginTextureFill( rockTexture, m );
			shape.graphics.drawRect(0,0,w,h);
			shape.graphics.endFill();
		}
	}
}