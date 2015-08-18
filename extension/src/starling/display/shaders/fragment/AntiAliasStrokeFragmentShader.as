package starling.display.shaders.fragment 
{
	import starling.display.shaders.AbstractShader;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3D;
	
	
	public class AntiAliasStrokeFragmentShader extends AbstractShader 
	{
		public static const BOTH_SIDES_FADE:int = 1;
		public static const OUTSIDE_FADE:int = 2;
		public static const CIRCULAR_FADE:int = 3;
		
		public var strokeType:int = 1;
		public var midAreaBoost:Number = 1.0;
		
		public function AntiAliasStrokeFragmentShader(type:int = 1, midAreaBoost:Number = 1.0) 
		{
			this.strokeType = type;
			this.midAreaBoost = midAreaBoost;
			
			var agalBothSides:String = 
				"mov ft2 v0 \n" + // copy color values over verted into ft2
				"mov ft0 v1.yyyy \n" + // copy v position from UVs 
				"sub ft0 fc1.yyyy ft0 \n" + // Create 1-v from constants
				"mul ft0 ft0 fc1.xxxx \n" + // Multiply the new value with PI from constants, we want a value between 0 and 3.1415. PI comes from fc.y
				"sin ft2.wwww ft0 \n" + // Take sine of this value, creating a ramp from 0 to 1 back to 0 again
				"mul ft2.wwww ft2.wwww fc1.zzzz \n" + // Multiply with the midAreaBoost value
				"sat ft2.wwww ft2.wwww \n" + // clamp alpha between 0 and 1
				"mul ft1 fc0, v0 \n" +  // Multiply the material color in fc0 with the vertex color value
				"mul oc, ft1, ft2.wwww n"; // Multiply the color result above with sine ramp value in alpha channel
			
			var agalCircularFade:String = 
				"mov ft2 v0 \n" + // copy color values over verted into ft2
				"mov ft4 v0 \n" + // copy color values over verted into ft2
				"mov ft0 v1.yyyy \n" + // copy v position from UVs 
				"mov ft3 v1.xxxx \n" + // copy u position from UVs 
				"sub ft0 fc1.yyyy ft0 \n" + // Create 1-v from constants
				"sub ft3 fc1.yyyy ft3 \n" + // Create 1-v from constants
				"mul ft0 ft0 fc1.xxxx \n" + // Multiply the new value with PI from constants, we want a value between 0 and 3.1415. PI comes from fc.y
				"mul ft3 ft3 fc1.xxxx \n" + // Multiply the new value with PI from constants, we want a value between 0 and 3.1415. PI comes from fc.y
				"sin ft2.wwww ft0 \n" + // Take sine of this value, creating a ramp from 0 to 1 back to 0 again
				"sin ft4.wwww ft3 \n" + // Take sine of this value, creating a ramp from 0 to 1 back to 0 again
				"mul ft2.wwww ft2.wwww fc1.zzzz \n" + // Multiply with the midAreaBoost value
				"mul ft4.wwww ft4.wwww fc1.zzzz \n" + // Multiply with the midAreaBoost value
				"sat ft2.wwww ft2.wwww \n" + // clamp alpha between 0 and 1
				"sat ft4.wwww ft4.wwww \n" + // clamp alpha between 0 and 1
				"mul ft2.wwww ft2.wwww ft4.wwww \n" + 
				"mul ft1 fc0, v0 \n" +  // Multiply the material color in fc0 with the vertex color value
				"mul oc, ft1, ft2.wwww n"; // Multiply the color result above with sine ramp value in alpha channel
			
				
			var agalOutside:String = 
				"mov ft2 v0 \n" + // copy color values over verted into ft2
				"mov ft0 v1.yyyy \n" + // copy v position from UVs 
				"mul ft0 ft0 fc1.xxxx \n" + // Multiply the new value with PI from constants, we want a value between 0 and 3.1415. PI comes from fc.y
				"sin ft2.wwww ft0 \n" + // Take sine of this value, creating a ramp from 0 to 1 back to 0 again
				"mul ft2.wwww ft2.wwww fc1.zzzz \n" + // Multiply with the midAreaBoost value
				"sat ft2.wwww ft2.wwww \n" + // clamp alpha between 0 and 1
				"mul ft1 fc0, v0 \n" +  // Multiply the material color in fc0 with the vertex color value
				"mul oc, ft1, ft2.wwww n"; // Multiply the color result above with sine ramp value in alpha channel
			
			if ( strokeType == BOTH_SIDES_FADE )
				compileAGAL( Context3DProgramType.FRAGMENT, agalBothSides );		
			else if ( strokeType == CIRCULAR_FADE )
				compileAGAL( Context3DProgramType.FRAGMENT, agalCircularFade);
			else
				compileAGAL( Context3DProgramType.FRAGMENT, agalOutside );
		}
		override public function setConstants( context:Context3D, firstRegister:int ):void
		{
			var scaleValue:Number = Math.PI;
			
			if ( strokeType == OUTSIDE_FADE )
				scaleValue = Math.PI * 0.5;
			
			
			context.setProgramConstantsFromVector( Context3DProgramType.FRAGMENT, firstRegister, Vector.<Number>([ scaleValue, 1, midAreaBoost, 1]) );
		}
		
		
	}

}