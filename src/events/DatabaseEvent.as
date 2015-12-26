package events
{
	import flash.events.Event;
	
	import model.valueObject.Table;
	
	public class DatabaseEvent extends Event
	{
		public static const FILE_CREATED:String = 'fileCreated';
		public static const FILE_REMOVED:String = 'fileRemoved';
		public static const TABLE_ADDED:String = 'tableAdded';
		public static const TABLE_REMOVED:String = 'tableRemoved';
		public static const TABLE_EMPTIED:String = 'tableEmptied';
		
		public var table:Table;
		
		public function DatabaseEvent(type:String, table:Table = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.table = table;
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			var e:DatabaseEvent = new DatabaseEvent(this.type, this.table, this.bubbles, this.cancelable);
			
			return e;
		}
	}
}