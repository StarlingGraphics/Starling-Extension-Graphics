package  
{
	import starling.display.shaders.AbstractShader;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.utils.getTimer;

	/**
	 * ...
	 * @author Henrik Jonsson
	 */
	public class RippleAnimateUVVertexShader extends AbstractShader 
	{
		public var uSpeed	:Number = 1;
		public var vSpeed	:Number = 1;
		
		public function RippleAnimateUVVertexShader( uSpeed:Number = 1, vSpeed:Number = 1) 
		{
			this.uSpeed = uSpeed;
			this.vSpeed = vSpeed;
			
			var agal:String =
			"mul vt0, va0.x, vc4.y \n" +	// Calculate vert.x * frequency. Store in 0
			"add vt1, vc4.x, vt0 \n" + 		// Calculate phase + scaledX. Store in 1
			"sin vt2, vt1 \n" +
			"mul vt3, vt2, vc4.z \n" +
			"add vt4, va0.y, vt3 \n" +
			"mov vt5, va0 \n" +
			"mov vt5.y, vt4 \n" +
			
			"m44 op, vt5, vc0 \n" +			// Apply view matrix
			
			"mov v0, va1 \n" +				// Copy color to v0
			"sub vt0, va2, vc5 \n" +
			"mov v1, vt0 \n" +		
			//"mov v1, va2 \n"				// Copy UV to v1
			"sub vt0, va2, vc6 \n" +
			"mov v2, vt0 \n"		
			
			compileAGAL( Context3DProgramType.VERTEX, agal );
		}
		
		override public function setConstants( context:Context3D, firstRegister:int ):void
		{
			var phase:Number = getTimer()/200;
			var frequency:Number = 0.02;
			var amplitude:Number = 5;
			
			var uOffset:Number = -0.05 * Math.cos(phase*0.1)*phase * uSpeed;
			var vOffset:Number = -0.05 * Math.cos(phase*0.1)*phase * vSpeed;
			var uOffset2:Number = -0.1 * Math.sin(phase*0.1)* phase * uSpeed;
			var vOffset2:Number = -0.1 * Math.sin(phase*0.1) * phase * vSpeed;
			
			
			context.setProgramConstantsFromVector( Context3DProgramType.VERTEX, firstRegister, Vector.<Number>([ phase, frequency, amplitude, 1  ]) );
			context.setProgramConstantsFromVector( Context3DProgramType.VERTEX, firstRegister + 1, Vector.<Number>([ uOffset, vOffset, 0, 0  ]) );
			context.setProgramConstantsFromVector( Context3DProgramType.VERTEX, firstRegister+2, Vector.<Number>([ uOffset2, vOffset2, 0, 0  ]) );
		}
		
		
	}

}