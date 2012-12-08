package
{
	import flash.events.MouseEvent;
	
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.display.graphics.NGon;
	import starling.display.graphics.Plane;
	import starling.display.graphics.RoundedRectangle;
	import starling.display.materials.StandardMaterial;
	import starling.display.materials.TextureMaterial;
	import starling.display.shaders.fragment.TextureFragmentShader;
	import starling.display.shaders.fragment.VertexColorFragmentShader;
	import starling.display.shaders.vertex.StandardVertexShader;
	import starling.events.Event;
	import starling.textures.Texture;
	
	public class PrimitivesExample extends Sprite
	{
		[Embed( source = "/assets/Checker.png" )]
		private var CheckerBMP		:Class;
		
		private var nGonC		:NGon;
		
		public function PrimitivesExample()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		private function onAdded ( e:Event ):void
		{
			var plane:Plane = new Plane(100,100,2,2);
			plane.material.color = 0x3399FF;
			plane.x = 10;
			plane.y = 10;
			addChild(plane);
			
			var nGonA:NGon = new NGon(50, 10);
			nGonA.x = 200;
			nGonA.y = 60;
			nGonA.material.color = 0x0066CC;
			addChild(nGonA);
			
			var nGonB:NGon = new NGon(50, 5, 40);
			nGonB.x = 400;
			nGonB.y = 60;
			nGonB.material.color = 0xFF9900;
			addChild(nGonB);
			
			nGonC = new NGon(100, 50, 50, -5, 356);
			nGonC.x = 340;
			nGonC.y = 200;
			nGonC.material = new StandardMaterial( new StandardVertexShader(), new TextureFragmentShader() );
			nGonC.material.textures[0] = Texture.fromBitmap( new CheckerBMP() );
			nGonC.material.color = 0x9900FF;
			addChild(nGonC);
			
			var roundedRect:RoundedRectangle = new RoundedRectangle(200, 100, 10, 20, 30, 40);
			roundedRect.material = new TextureMaterial( Texture.fromBitmap( new CheckerBMP() ) );
			roundedRect.x = 20;
			roundedRect.y = 140;
			addChild(roundedRect);
			
			Starling.current.nativeStage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}

		private function onMouseMove(event:MouseEvent):void
		{
			nGonC.startAngle = (event.stageY / stage.stageHeight) * 360;
			nGonC.endAngle = (event.stageX / stage.stageWidth) * 360;
		}
	}
}