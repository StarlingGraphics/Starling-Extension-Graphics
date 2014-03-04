// ActionScript file
package {
	public class TimeLog {
		public function TimeLog():void {
			timeIdx = 0;
			timeLog = new Array();
		}

		public function logTime(time:int):void {
			timeLog[timeIdx] = time;
			timeIdx++;
			if (timeIdx == cTimeLogCount) {
				var scale:Number = 1.0 / Number(timeIdx);
				var average:Number = 0.0;
				for (var i:uint = 0; i < cTimeLogCount; i++) {
					average += timeLog[i] * scale;
				}
				trace("Avg: " + average);
				timeIdx = 0;
			}
		}

		private var timeLog         :Array;
		private var timeIdx         :uint;
		static private const cTimeLogCount:uint = 60;
	}
}