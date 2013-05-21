package starling.display.materials
{
	import flash.display3D.Context3D;
	import flash.display3D.Program3D;
	import flash.utils.Dictionary;
	
	import starling.display.shaders.IShader;

	internal class Program3DCache
	{
		private static var uid							:int = 0;
		private static var uidByShaderTable				:Dictionary = new Dictionary(true);
		private static var programByUIDTable			:Object = {};
		private static var uidByProgramTable			:Dictionary = new Dictionary(false);
		private static var numReferencesByProgramTable	:Dictionary = new Dictionary();
		
		public static function getProgram3D( context:Context3D, vertexShader:IShader, fragmentShader:IShader ):Program3D
		{
			var vertexShaderUID:int = uidByShaderTable[vertexShader];
			if ( vertexShaderUID == 0 )
			{
				vertexShaderUID = uidByShaderTable[vertexShader] = ++uid;
			}
			
			var fragmentShaderUID:int = uidByShaderTable[fragmentShader];
			if ( fragmentShaderUID == 0 )
			{
				fragmentShaderUID = uidByShaderTable[fragmentShader] = ++uid;
			}
			
			var program3DUID:String = vertexShaderUID + "_" + fragmentShaderUID;
			
			var program3D:Program3D = programByUIDTable[program3DUID];
			if ( program3D == null )
			{
				program3D = programByUIDTable[program3DUID] = context.createProgram();
				uidByProgramTable[program3D] = program3DUID;
				program3D.upload( vertexShader.opCode, fragmentShader.opCode );
				numReferencesByProgramTable[program3D] = 0;
			}
			
			numReferencesByProgramTable[program3D]++;
			
			return program3D;
		}
		
		public static function releaseProgram3D( program3D:Program3D ):void
		{
			if ( numReferencesByProgramTable[program3D] == null )
			{
				throw( new Error( "Program3D is not in cache" ) );
				return;
			}
			
			var numReferences:int = numReferencesByProgramTable[program3D];
			numReferences--;
			
			if ( numReferences == 0 )
			{
				program3D.dispose();
				delete numReferencesByProgramTable[program3D];
				var program3DUID:String = uidByProgramTable[program3D];
				delete programByUIDTable[program3DUID];
				delete uidByProgramTable[program3D];
				return;
			}
			
			numReferencesByProgramTable[program3D] = numReferences;
		}
	}
}