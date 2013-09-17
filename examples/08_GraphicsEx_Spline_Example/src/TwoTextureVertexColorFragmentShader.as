package  
{
		import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.textures.Texture;
	
	import starling.display.shaders.AbstractShader;
	
	/**
	 * ...
	 * @author Henrik Jonsson
	 */
	public class TwoTextureVertexColorFragmentShader extends AbstractShader 
	{
		public function TwoTextureVertexColorFragmentShader()
		{
			var agal:String =
			"tex ft1, v1, fs0 <2d, repeat, linear> \n" +
			"tex ft2, v2, fs1 <2d, repeat, linear> \n" +
			"mul ft3, v0, fc0 \n" +
			"add ft4, ft1, ft2\n" +
			"mul oc, ft4, ft3\n";
			
			compileAGAL( Context3DProgramType.FRAGMENT, agal );
		}
	}

}