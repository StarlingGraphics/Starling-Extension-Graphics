package starling.display 
{
	import starling.textures.Texture;
	import flash.geom.Matrix;
	
	/**
	 * ...
	 * @author Henrik Jonsson
	 */
	public class GraphicsTextureFill implements IGraphicsData 
	{
		protected var mTexture:Texture;
		protected var mMatrix:Matrix;
		
		public function GraphicsTextureFill(texture:Texture, matrix:Matrix = null ) 
		{
			mTexture = texture;
			mMatrix = matrix;
		}
		
		public function get texture() : Texture
		{
			return mTexture;
		}
		
		public function get matrix() : Matrix
		{
			return mMatrix;
		}
	}

}