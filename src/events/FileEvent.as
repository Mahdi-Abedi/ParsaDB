package events
{
	import flash.events.Event;
	import flash.filesystem.File;
	
	public class FileEvent extends Event
	{
		public static const CREATED:String = 'created';
		public static const REMOVED:String = 'removed';
		
		public var file:File;
		public function FileEvent(type:String, file:File, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.file = file;
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			var e:FileEvent = new FileEvent(this.type, this.file, this.bubbles, this.cancelable);
			
			return e;
		}
	}
}