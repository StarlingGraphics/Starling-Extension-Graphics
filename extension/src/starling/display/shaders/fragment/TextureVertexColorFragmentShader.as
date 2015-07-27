package starling.display.shaders.fragment
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import starling.textures.Texture;
	import starling.core.RenderSupport;
	
	import starling.display.shaders.AbstractShader;
	
	/*
	* A pixel shader that multiplies a single texture with constants (the color transform) and vertex color
	*/
	public class TextureVertexColorFragmentShader extends AbstractShader
	{
		public function TextureVertexColorFragmentShader(texture:Texture = null, mipmapping:Boolean = false, repeat:Boolean = false, smoothing:String = "bilinear")
		{
			var shouldRepeat:Boolean = texture == null ? repeat : ( texture.repeat ? repeat : false);
			var textureFormat:String = texture != null ? texture.format : "";
			
			var flags:String = RenderSupport.getTextureLookupFlags(textureFormat, mipmapping, shouldRepeat, smoothing); 
						
			var agal:String = "tex ft1, v1, fs0 "; 
			agal += flags + "\n";
			agal += "mul ft2, v0, fc0 \n" +
					"mul oc, ft1, ft2";
			
			compileAGAL( Context3DProgramType.FRAGMENT, agal );
		}
	}
}