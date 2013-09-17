package
{
	/*
	
		An example demonstrating an effect acheivable with an animated UV vertex shader.
		
		Assets used with kind permission of Tomislav Podhraški. Original tutorial here
		http://gamedev.tutsplus.com/tutorials/implementation/create-a-glowing-flowing-lava-river-using-bezier-curves-and-shaders/
		
	*/

	import flash.geom.Point;
	import starling.display.graphicsEx.GraphicsExColorData;
	import starling.display.graphicsEx.GraphicsExThicknessData;
	import starling.display.Image;
	import starling.display.graphicsEx.ShapeEx;
	import starling.display.shaders.fragment.VertexColorFragmentShader;
	import starling.display.Sprite;
	import starling.display.BlendMode;
	import starling.display.materials.StandardMaterial;
	import starling.display.shaders.fragment.TextureVertexColorFragmentShader;
	import starling.display.shaders.vertex.RippleVertexShader;
	import starling.events.Event;
	import starling.textures.Texture;

	
	public class NaturalSplineExample extends Sprite
	{
		[Embed( source = "/assets/GlowTiled.png" )]
		private var GlowTiledBMP		:Class;

		public function NaturalSplineExample()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}

		private function onAdded ( e:Event ):void
		{
			var lavaMaterial:StandardMaterial = new StandardMaterial(  );
			lavaMaterial.vertexShader = new RippleAnimateUVVertexShader( 0.125, 0  );
			lavaMaterial.fragmentShader = new TwoTextureVertexColorFragmentShader();
			lavaMaterial.textures[0] = Texture.fromBitmap( new GlowTiledBMP(), false );
			lavaMaterial.textures[1] = Texture.fromBitmap( new GlowTiledBMP(), false );
		
			var shape:ShapeEx = new ShapeEx();
			shape.blendMode = BlendMode.ADD;
			addChild(shape);

			shape.graphics.lineMaterial( 1, lavaMaterial);
			shape.graphics.moveTo( 900, 550 );
			
			var firstPoint:int = shape.graphics.currentLineIndex; // Grab first index point before we add anything
			var controlPoints:Array = [new Point(900, 550), new Point(700, 130), new Point(150, 180), new Point(200, 650), new Point(500, 650), new Point(700, 650)];
			shape.graphics.naturalCubicSplineTo(controlPoints, false, 100);
			var midPoint:int = shape.graphics.currentLineIndex/2; // Midpoint can be had by dividing length in half.
			var endPoint:int = shape.graphics.currentLineIndex-1; // End point is one off the current index.
			
			var colorData:GraphicsExColorData = new GraphicsExColorData(0xFF0000, 0xFFFFFF, 0.0, 1.0);
			var thicknessData:GraphicsExThicknessData = new GraphicsExThicknessData(1, 30);
			// run postProcess from start to midpoint, go from red to white, alpha 0 to 1, thickness 1 to 30 pixels
			shape.graphics.postProcess(firstPoint, midPoint, thicknessData, colorData );
		
			colorData = new GraphicsExColorData(0xDDDDFF, 0xDDFFFF, 1.0, 0.0, null, null);
			thicknessData = new GraphicsExThicknessData(30, 1);
			// run postProcess from midpoint to end, go from 0xDDDDFF to 0xDDFFFF, alpha 1 to 0, thickness 30 to 1 pixels
			shape.graphics.postProcess(midPoint, endPoint, thicknessData, colorData );
		}
		
	}
}