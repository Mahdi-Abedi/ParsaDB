package model.valueObject 
{
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	
	import events.DatabaseEvent;
	import events.FileEvent;
	import events.TableEvent;
	
	import model.TableModel;
	
	import service.FileService;
	import service.SQLService;
	
	/**
	 * <div style="
	 * direction:rtl; 
	 * text-align: justify;
	 * text-justify: inter-word;">
	 * [broadcast event] 
	 * زمانی که فایل پایگاه داده بر روی هار دیسک ساخته شود، این رویداد صدا زده می شود.
	 * </div> 
	 * 
	 * @eventType	events.DatabaseEvent.FILE_CREATED
	 */
	[Event(name="fileCreated", type="events.DatabaseEvent")]
	
	/**
	 * <div style="
	 * direction:rtl; 
	 * text-align: justify;
	 * text-justify: inter-word;">
	 * [broadcast event] 
	 * زمانی که فایل پایگاه داده از روی هار دیسک حذف شود، این رویداد صدا زده می شود.
	 * </div> 
	 * 
	 * @eventType	events.DatabaseEvent.FILE_REMOVED
	 */
	[Event(name="fileRemoved", type="events.DatabaseEvent")]
	
	/**
	 * <div style="
	 * direction:rtl; 
	 * text-align: justify;
	 * text-justify: inter-word;">
	 * زمانی که جدول جدیدی به پایگاه داده اضافه شود، این رویداد صدا زده می شود.
	 * </div> 
	 * 
	 * @eventType	events.DatabaseEvent.TABLE_ADDED
	 */
	[Event(name="tableAdded", type="events.DatabaseEvent")]
	
	/**
	 * <div style="
	 * direction:rtl; 
	 * text-align: justify;
	 * text-justify: inter-word;">
	 * زمانی که جدولی از پایگاه داده حذف شود، این رویداد صدا زده می شود.
	 * </div> 
	 * 
	 * @eventType	events.DatabaseEvent.TABLE_REMOVED
	 */
	[Event(name="tableRemoved", type="events.DatabaseEvent")]
	
	/**
	 * <div style="
	 * direction:rtl; 
	 * text-align: justify;
	 * text-justify: inter-word;">
	 * زمانی که تمامی اطلاعات از جدولی درون پایگاه داده حذف شود، این رویداد صدا زده می شود.
	 * </div> 
	 * 
	 * @eventType	events.DatabaseEvent.TABLE_EMPTIED
	 */
	[Event(name="tableEmptied", type="events.DatabaseEvent")]
	
	/**
	 * <div style="
	 * direction:rtl; 
	 * text-align: justify;
	 * text-justify: inter-word;">
	 * برای استفاده از این کتابخانه،
	 *  ابتدا باید یک نمونه از کلاس Database بسازید. بعد از ساختن نمونه از این کلاس می توانید جدول ها را به 
	 * آن اضافه کرده و سایر اعمال را دلخواه را انجام دهید. کلیه رویداد ها بصورت 
	 * غیرهمزمان صورت می گیرد و برای کنترل اتفاقات صورت گرفته
	 *  بر روی پایگاه داده ، باید از رویدادها استفاده کرده
	 *  و به آنها گوش دهید. 
	 * 
	 * </div>
	 * @langversion	3.0
	 * @playerversion	Air 2
	 */	
	public class Database extends EventDispatcher
	{
		
		private var fileService:FileService;
		private var sqlService:SQLService;
		private var _file:File;
		
		private var tableModel:TableModel;
			
		/**
		 * <div style="
		 * direction:rtl; 
		 * text-align: justify;
		 * text-justify: inter-word;">
		 * حداکثر تعداد اتصالی که نمونه SQLConnection برای اجرای جملات SELECT استفاده می کند. تعداد اتصال بیشتر به معنی 
		 * اجرای جملات همزمان بیشتر است که سرعت را افزایش می دهد ولی همچنین باعث افزایش استفاده از حافظه و پردازنده هم
 		 * می شود. 
		 * 
		 * </div>
		 * 
		 * @default مقدار پیش فرض آن 5 است.
		 * @langversion	3.0
	 	 * @playerversion	Air 2
		 */		
		public var maxPoolSize:int = 5;
		
		
		/**
		 * <div style="
		 * direction:rtl; 
		 * text-align: justify;
		 * text-justify: inter-word;">
		 * کلیدی که برای کدگذاری اطلاعات در پایگاه داده استفاده می شود.
		 * </div>
		 * 
		 * @default مقدار پیش فرض آن null است.
		 * @langversion	3.0
	 	 * @playerversion	Air 2
		 */	
		public var encryptionKey:ByteArray = null;
		
		/**
		 * <div style="
		 * direction:rtl; 
		 * text-align: justify;
		 * text-justify: inter-word;">
		 * فایلی که پایگاه داده از آن برای ذخیره سازی اطلاعات استفاده می کند.
		 * </div>
		 * 
		 * langversion	3.0
	 	 * @playerversion	Air 2
		 */		
		public function get file():File
		{
			return _file;
		}

		/**
		 * <div style="
		 * direction:rtl; 
		 * text-align: justify;
		 * text-justify: inter-word;">
		 * نام فایل پایگاه داده ای که در حال استفاده استفاده است. نام شامل پسوند فایل نمی شود.
		 * 
		 * </div>
		 * 
		 * langversion	3.0
	 	 * @playerversion	Air 2
		 */
		public function get name():String
		{
			return this.file ? this.file.name.substring(0, this.file.name.lastIndexOf('.')) : '';
		}
		
		/**
		 * <div style="
		 * direction:rtl; 
		 * text-align: justify;
		 * text-justify: inter-word;">
		 * محیط ایجاد پایگاه داده را فراهم می کند. با نمونه سازی از این کلاس هیچ فایل ساخته نمی شود و در زمان استفاده از متد createFile یا addTable فایل ارسال شده به سازنده، در صورت وجود نداشتن، ساخته می شود.
		 * </div>
		 * @param databaseFile
		 *  <div style="
		 * direction:rtl; 
		 * text-align: justify;
		 * text-justify: inter-word;">
		 * فایلی که پایگاه داده از آن برای ذخیره سازی اطلاعات استفاده می کند.
		 * </div>
		 * 
		 * @langversion	3.0
		 * @playerversion	Air 2
		 */
		public function Database(databaseFile:File)
		{
			this._file = databaseFile;
			
			this.init();
		}
		
		/**
		 * <div style="
		 * direction:rtl; 
		 * text-align: justify;
		 * text-justify: inter-word;">
		 * تمامی مقداردهی های اولیه در این متد صورت می گیرد.
		 * </div>
		 * 
		 * @langversion	3.0
		 * @playerversion	Air 2
		 */		
		private function init():void
		{
			
			
			this.fileService = FileService.getInstance();
			this.sqlService = SQLService.getInstance();
			
			this.tableModel = new TableModel(this);
		}
		/**
		 * <div style="
		 * direction:rtl; 
		 * text-align: justify;
		 * text-justify: inter-word;">
		 * فایل پایگاه داده را در صورتی که وجود نداشته باشد، ایجاد می کند.
		 * </div>
		 * 
		 * @langversion	3.0
		 * @playerversion	Air 2
		 */		
		public function createFile():void
		{
			this.fileService.addEventListener(FileEvent.CREATED, 
				function():void{
					fileService.removeEventListener(FileEvent.CREATED, arguments.callee);
					dispatchEvent(new DatabaseEvent(DatabaseEvent.FILE_CREATED));
				}
			);
			this.fileService.create(this.file);
		}		
		
		/**
		 * <div style="
		 * direction:rtl; 
		 * text-align: justify;
		 * text-justify: inter-word;">
		 * فایل پایگاه داده را در صورتی که وجود داشته باشد، حذف می کند. توجه داشته باشید که در حین انجام عملیات بر روی پایگاه داده، حذف کردن فایل آن موجب بروز خطا می شود.
		 * </div>
		 * 
		 * @langversion	3.0
		 * @playerversion	Air 2
		 */
		public function removeFile():void
		{
			this.fileService.addEventListener(FileEvent.REMOVED, 
				function():void{
					fileService.removeEventListener(FileEvent.REMOVED, arguments.callee);
					dispatchEvent(new DatabaseEvent(DatabaseEvent.FILE_REMOVED));
				}
			);
			
			this.sqlService.close( function():void{});
			fileService.remove(file);
				
			
		}
		
		/**
		 * <div style="
		 * direction:rtl; 
		 * text-align: justify;
		 * text-justify: inter-word;">
		 * فایل پایگاه داده را حذف و سپس دوباره می سازد.
		 * </div> 
		 * 
		 * @langversion	3.0
		 * @playerversion	Air 2
		 */		
		public function recreateFile():void
		{
			this.removeFile();
			this.createFile();
		}
		
		/**
		 * <div style="
		 * direction:rtl; 
		 * text-align: justify;
		 * text-justify: inter-word;">
		 * جدول جدیدی در پایگاه داده ایجاد می کند. در صورتی که فایل پایگاه داده را نساخته باشید، این متد این کار را بصورت خودکار انجام می دهد.
		 * </div>
		 * 
		 * @param name
		 * <div style="
		 * direction:rtl; 
		 * text-align: justify;
		 * text-justify: inter-word;">
		 * نام جدولی که قرار هست ایجاد شود.
		 * </div>
		 * 
		 * @langversion	3.0
		 * @playerversion	Air 2
		 */		
		public function createTable(name:String):void
		{
			if(this.name)
			{
				this.addTable( new Table(name) );
			}
		}
		/**
		 * <div style="
		 * direction:rtl; 
		 * text-align: justify;
		 * text-justify: inter-word;">
		 * جدول جدیدی در پایگاه داده ایجاد می کند. در صورتی که فایل پایگاه داده را نساخته باشید، این متد این کار را بصورت خودکار انجام می دهد.
		 * </div>
		 * 
		 * @param table
		 * <div style="
		 * direction:rtl; 
		 * text-align: justify;
		 * text-justify: inter-word;">
		 * جدولی که قرار هست در پایگاه داده ساخته شود.
		 * </div>
		 * 
		 * @langversion	3.0
		 * @playerversion	Air 2
		 */		
		public function addTable(table:Table):void
		{
			if(table)
			{
				table.addEventListener(TableEvent.CREATED, 
					function():void{
						table.removeEventListener(TableEvent.CREATED, arguments.callee);
						
						dispatchEvent( new DatabaseEvent(DatabaseEvent.TABLE_ADDED, table))
					});
				
				table.database = this;
				tableModel.add(table);
				this.sqlService.addTable(table);
			}
		}
		
		/**
		 * <div style="
		 * direction:rtl; 
		 * text-align: justify;
		 * text-justify: inter-word;">
		 * لیست جدول های داده شده را در پایگاه داده ایجاد می کند. در صورتی که فایل پایگاه داده را نساخته باشید، این متد این کار را بصورت خودکار انجام می دهد.
		 * </div>
		 * 
		 * @param tables
		 * <div style="
		 * direction:rtl; 
		 * text-align: justify;
		 * text-justify: inter-word;">
		 * لیست جدول هایی که قرار هست در پایگاه داده ساخته شوند.
		 * </div>
		 * 
		 * @langversion	3.0
		 * @playerversion	Air 2
		 */	
		public function addTableList(...tables):void
		{
			for (var i:int = 0, len:int = tables.length ; i < len; i++) 
			{
				this.addTable(tables[i]);
			}
			
		}
		/**
		 * <div style="
		 * direction:rtl; 
		 * text-align: justify;
		 * text-justify: inter-word;">
		 * جدول مورد نظر را از پایگاه داده حذف می کند.
		 * </div>
		 *  
		 * @param table
		 * <div style="
		 * direction:rtl; 
		 * text-align: justify;
		 * text-justify: inter-word;">
		 * جدولی که باید از پایگاه داده حذف شود.
		 * </div>
		 * 
		 * @langversion	3.0
		 * @playerversion	Air 2
		 */	
		public function removeTable(table:Table):void
		{
			if(table && this.tableModel.has(table))
			{
				table.addEventListener(TableEvent.REMOVED, 
					function():void{
						tableModel.remove(table);
						table.removeEventListener(TableEvent.REMOVED, arguments.callee);
						
						dispatchEvent( new DatabaseEvent(DatabaseEvent.TABLE_REMOVED, table));
					});
				this.sqlService.deleteTable(table);
			}
		}
		
		/**
		 * <div style="
		 * direction:rtl; 
		 * text-align: justify;
		 * text-justify: inter-word;">
		 * جدول مورد نظر را در اختیار شما قرار می دهد.
		 * </div>
		 *  
		 * @param name
		 * <div style="
		 * direction:rtl; 
		 * text-align: justify;
		 * text-justify: inter-word;">
		 * نام جدولی که می خواهید آن را از پایگاه داده دریافت کنید.
		 * </div>
		 * 
		 * @return 
		 * <div style="
		 * direction:rtl; 
		 * text-align: justify;
		 * text-justify: inter-word;">
		 * شی جدولی که تقاضای آن را داشته اید. در صورت وجود نداشتن جدول نقدار null باز گردانده می شود.
		 * </div>
		 * 
		 * @langversion	3.0
		 * @playerversion	Air 2
		 */
		 	
		public function getTable(name:String):Table
		{
			return this.tableModel.getByName(name);
		}
		
		/**
		 * <div style="
		 * direction:rtl; 
		 * text-align: justify;
		 * text-justify: inter-word;">
		 * لیست تمامی جداول موجود در پایگاه داده را در اختیار شما قرار می دهد.
		 * </div>
		 * 
		 * @return 
		 * <div style="
		 * direction:rtl; 
		 * text-align: justify;
		 * text-justify: inter-word;">
		 * آرایه ای از جداول موجود در پایگاه داده را باز می گرداند. در صورت نبودن جدول در پایگاه داده طول آرایه برابر صفر خواهد بود.
		 * </div>
		 * 
		 * @langversion	3.0
		 * @playerversion	Air 2
		 */
		public function getAllTables():Array
		{
			return this.tableModel.getList();
		}
		/**
		 * <div style="
		 * direction:rtl; 
		 * text-align: justify;
		 * text-justify: inter-word;">
		 * تمامی اطلاعات موجود در جدول را به طور کلی حذف می کند. توجه داشته باشید که این متد ساختار جدول را تغییر نمی دهد، مثلا ستون های داخل جدول را حذف نمی کند.
		 * </div>
		 * 
		 * @param table
		 * <div style="
		 * direction:rtl; 
		 * text-align: justify;
		 * text-justify: inter-word;">
		 * نام جدولی که قرار هست اطلاعات داخل آن حذف شود.
		 * </div>
		 * 
		 * @langversion	3.0
		 * @playerversion	Air 2
		 */	
		public function emptyTable(table:Table):void
		{
			if(table && this.tableModel.has(table) )
			{
				table.addEventListener(TableEvent.EMPTIED, 
					function():void{
						table.removeEventListener(TableEvent.EMPTIED, arguments.callee);
						
						dispatchEvent( new DatabaseEvent(DatabaseEvent.TABLE_EMPTIED, table))
					});
				
				table.empty();
			}
		}
		
		override public function toString():String
		{
			return "[" + this.name + "]";
		}
		
	}
}