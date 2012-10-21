package
{
	/*
	
		An example demonstrating an effect acheivable with an animated UV vertex shader.
		
		Assets used with kind permission of Tomislav Podhraški. Original tutorial here
		http://gamedev.tutsplus.com/tutorials/implementation/create-a-glowing-flowing-lava-river-using-bezier-curves-and-shaders/
		
	*/
	
	import starling.display.Image;
	import starling.display.Shape;
	import starling.display.Sprite;
	import starling.display.materials.StandardMaterial;
	import starling.display.shaders.fragment.TextureFragmentShader;
	import starling.display.shaders.vertex.AnimateUVVertexShader;
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
		
		public function FlowingLavaExample()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		private function onAdded ( e:Event ):void
		{
			// Some styles
			var lavaThickness:Number = 90;
			var bankThickness:Number = lavaThickness*2.2;
			
			var background:Image = new Image(Texture.fromBitmap(new FinalBackgroundBMP()));
			background.width = stage.stageWidth;
			background.height = stage.stageHeight;
			addChild(background);
			
			var shape:Shape = new Shape();
			addChild(shape);
			
			var lavaMaterial:StandardMaterial = new StandardMaterial(  );
			lavaMaterial.vertexShader = new AnimateUVVertexShader( 0.1, 0 );
			lavaMaterial.fragmentShader = new TextureFragmentShader();
			lavaMaterial.textures[0] = Texture.fromBitmap( new LavaTiledBMP(), false );
			shape.graphics.lineMaterial( lavaThickness, lavaMaterial );
			shape.graphics.moveTo( 150, 0 );
			shape.graphics.curveTo( 500, 100, 500, 300 );
			shape.graphics.curveTo( 500, 500, 700, 650 );
			
			var banksTexture:Texture = Texture.fromBitmap( new BanksTiledBMP(), false );
			shape.graphics.lineTexture( bankThickness, banksTexture );
			shape.graphics.moveTo( 150, 0 );
			shape.graphics.curveTo( 500, 100, 500, 300 );
			shape.graphics.curveTo( 500, 500, 700, 650 );
			shape.graphics.lineStyle(0);
			
			var foreground:Image = new Image(Texture.fromBitmap(new FinalRockBMP()));
			foreground.width = stage.stageWidth;
			foreground.height = stage.stageHeight*1.6;
			addChild(foreground);
		}
	}
}