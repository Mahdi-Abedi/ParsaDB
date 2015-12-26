package model.valueObject
{
	public class Command
	{
		public var sql:String = '';
		public var type:uint;
		public var resultHandler:Function;
		public var errorHandler:Function;
		public var progressHandler:Function;
		public function Command(sql:String = '', type:uint = 0, completeHandler:Function = null, errorHandler:Function = null)
		{
			this.sql = sql;
			this.type = type;
			this.resultHandler = completeHandler;
			this.errorHandler = errorHandler;
		}
	}
}