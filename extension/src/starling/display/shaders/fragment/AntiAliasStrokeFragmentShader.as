package starling.display.shaders.fragment 
{
	import starling.display.shaders.AbstractShader;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3D;
	
	
	public class AntiAliasStrokeFragmentShader extends AbstractShader 
	{
		
		public function AntiAliasStrokeFragmentShader() 
		{
			var agal:String = 
				"mov ft2 v0 \n" + // copy color values over verted into ft2
				"mov ft0 v1.yyyy \n" + // copy v position from UVs 
				"sub ft0 fc0.yyyy ft0 \n" + // Create 1-v from constants
				"mul ft0 ft0 ft0\n" + // Then square that inverted value. This gives a nice curve to the alpha fade
				"mul ft0 ft0 fc1.xxxx \n" + // Multiply the new value with PI from constants, we want a value between 0 and 3.1415. PI comes from fc.y
				"sin ft2.wwww ft0 \n" + // Take sine of this value, creating a ramp from 0 to 1 back to 0 again
				"mul ft1 fc0, v0 \n" +  // Multiply the material color in fc0 with the vertex color value
				"mul oc, ft1, ft2.wwww n"; // Multiply the color result above with sine ramp value in alpha channel
			
			
			compileAGAL( Context3DProgramType.FRAGMENT, agal );		
		}
		override public function setConstants( context:Context3D, firstRegister:int ):void
		{
			var pi:Number = Math.PI;
			context.setProgramConstantsFromVector( Context3DProgramType.FRAGMENT, firstRegister, Vector.<Number>([ pi, 1, 1, 1]) );
		}
	}

}