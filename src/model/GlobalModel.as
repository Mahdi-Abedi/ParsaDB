package model
{

	public class GlobalModel
	{	
		// ------- Singleton implementation -------
		
		private static var _instance:GlobalModel;
		public static function getInstance():GlobalModel
		{
			return _instance || (_instance = new GlobalModel());
		}
		
		// ------- Constructor -------
		public function GlobalModel()
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
	}
}