package model
{
	import model.valueObject.Command;

	public class CommandModel
	{
		private var commandList:Array;
		//--------------- Getter / Setter -------------------
		public function get currentCommand():Command
		{
			return this.commandList[0] ? this.commandList[0] : null;
		}
		
		public function get isEmpty():Boolean
		{
			return !(this.commandList && this.commandList.length);
		}
		
		
		// ------- Singleton implementation -------
		
		private static var _instance:CommandModel;
		public static function getInstance():CommandModel
		{
			if (_instance == null)
			{
				_instance = new CommandModel();
			}
			
			return _instance || (_instance = new CommandModel());
		}
		
		// ------- Constructor -------
		public function CommandModel()
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
			this.commandList = new Array();
		}
		
		public function push(...commands):void
		{
			if(commands && commands.length && this.commandList)
			{
				for (var i:int = 0, len:int = commands.length ; i < len; i++) 
				{
					this.commandList.push(commands[i]);
					
				}
				
			}
		}
		
		public function fetch():Command
		{
			if(!this.isEmpty)
			{
				return this.commandList.splice(0,1)[0] ;
			}
			
			return null;
		}
	}
}