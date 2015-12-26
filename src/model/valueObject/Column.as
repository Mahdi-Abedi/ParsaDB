package model.valueObject
{
	public class Column
	{
		public var table:Table;
		public var name:String;
		public var type:String;
		public var size:uint;
		public var precision:uint;
		public var defaultValue:uint;
		public var collate:uint;
		public var notNull:Boolean;
		public var onConflict:uint;
		public var primaryKey:Boolean;
		public var autoIncrement:Boolean;
		
		
		public function Column(name:String, type:String)
		{
			if(!name) throw new Error('Name is invalid.');
			if(!type) throw new Error('Type is invalid.');
			
			this.name = name;
			this.type = type;
		}
		
		public function destroy():void
		{
			this.table = null;
		}
	}
}