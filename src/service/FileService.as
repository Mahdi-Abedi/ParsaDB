package service
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import events.FileEvent;
	
	[Event(name="created", type="events.FileEvent")]
	[Event(name="removed", type="events.FileEvent")]
	
	public class FileService extends EventDispatcher
	{
		// ------- Singleton implementation -------
		
		private static var _instance:FileService;
		public static function getInstance():FileService
		{
			
			return _instance || (_instance = new FileService());
		}
		
		// ------- Constructor -------
		public function FileService()
		{
			if (_instance != null)
			{
				throw new Error("Singleton can only be accessed through Singleton.instance");
			}
			
			this.inti();
		}
		
		//--------------- Methods --------------
		private function inti():void
		{
			
		}
		
		public function create(file:File):void
		{
			if(file && !file.exists)
			{
				var fs:FileStream = new FileStream();
				fs.open(file,FileMode.WRITE);
				fs.addEventListener(Event.COMPLETE, 
					function():void{
						dispatchEvent( new FileEvent( FileEvent.CREATED , file ));
					}
				);
				fs.writeMultiByte("","UTF-8");
				fs.close();
			}
			
			
		}
		
		public function remove(file:File):void
		{
			if(file && file.exists)
			{
				file.deleteFile();
			}
		}
	}
}