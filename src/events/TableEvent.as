package events
{
	import flash.events.Event;
	
	public class TableEvent extends Event
	{
		public static const CREATED:String = 'created';
		public static const REMOVED:String = 'removed';
		public static const EMPTIED:String = 'emptied';
		public static const ROW_ADDED:String = 'rowAdded';
		public static const ROWS_LIST_ADDED:String = 'rowsListAdded';
		public static const ROW_REMOVED:String = 'rowRemoved';
		public static const ROWS_RECIVED:String = 'rowsRecived';
		public static const DESTROYED:String = 'destroyed';
		
		public var data:Array = null;
		
		public function TableEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			var e:TableEvent = new TableEvent(this.type, this.bubbles, this.cancelable);
			
			return e;
		}
	}
}