&НаКлиенте
Перем Модуль_СервисныеФункции;

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	Отказ = Истина; // форма не предназначена для открытия
КонецПроцедуры

&НаКлиенте
Процедура мСцен_ПреобразоватьВДеревоСценарияНаКлиенте(Знач ТекстСценария,
		ДеревоСценария, мПараметры, ЭтоБуфер = Ложь) Экспорт

	ЗагрузитьБиблиотеки();
	
	ВремяНепрерывногоВвода = 5000;
	
	ИсключатьКомандуFocus = мПараметры.ИсключатьКомандуFocus;
	Исключать_xPath		= мПараметры.Исключать_xPath;
	
	ТребуетяОбвязкаПодключения = Истина;
	
	Если ЭтоБуфер=Истина Тогда
		ТребуетяОбвязкаПодключения = Ложь;
	Иначе
		ДеревоСценария.ПолучитьЭлементы().Очистить();
	КонецЕсли;
	
	ТекстСценария = УбратьНедопустимыеСимволыXML(ТекстСценария);
	// преобразуем текст в массив структур
	РезультатПреобразования = Модуль_СервисныеФункции.ОбработкаJSON(ТекстСценария);
	
	
	// Свяжем ввод символов в одно слово, если размер тайминга меньше 5000
	МассивУдаляемыхСтрок = новый Массив;
	ВводКлавишей = Неопределено;
	ПоследнийТайминг = 0;
	Для каждого стр из РезультатПреобразования Цикл
		
		Если стр.Свойство("command") И стр.command="keypress" Тогда
			
			Если ВводКлавишей=Неопределено Тогда
				ВводКлавишей = стр;
				ПоследнийТайминг = Число(стр.date_now);
			Иначе
				Если Число(стр.date_now)-ПоследнийТайминг<ВремяНепрерывногоВвода Тогда
					ПоследнийТайминг = Число(стр.date_now);
					ВводКлавишей.element_text = ВводКлавишей.element_text+стр.element_text;
					ВводКлавишей.key_code = ВводКлавишей.key_code+стр.key_code;
					ВводКлавишей.command="text";
					МассивУдаляемыхСтрок.Добавить(стр);
				Иначе 	
					ВводКлавишей=Неопределено;
				КонецЕсли;
			КонецЕсли;
			
		Иначе
			ВводКлавишей = Неопределено;
		КонецЕсли;
		
	КонецЦикла;
	
	Для каждого стр из МассивУдаляемыхСтрок Цикл
		РезультатПреобразования.Удалить(РезультатПреобразования.Найти(стр));	
	КонецЦикла;	
	
	ТаблицаДанныхСценария.Очистить();

	// перенесем в таблицу	
	Для каждого стр из РезультатПреобразования Цикл		
			
		стр_н = ТаблицаДанныхСценария.Добавить();
		element_title ="";
		Если стр.Свойство("element_title") Тогда
			стр_н.ЗаголовокОбъекта = стр.element_title;
			element_title = стр.element_title;
		КонецЕсли;
		Если стр.Свойство("element_name") И НЕ ЗначениеЗаполнено(стр_н.ЗаголовокОбъекта) Тогда
			стр_н.ЗаголовокОбъекта = стр.element_name;
		КонецЕсли;
		Если стр.Свойство("element_name") Тогда
			стр_н.ИмяОбъекта = стр.element_name;
		КонецЕсли;
		Если стр.Свойство("element_id") Тогда
			стр_н.ИдентификаторОбъекта = стр.element_id;
		КонецЕсли;
		Если стр.Свойство("element_class_name") Тогда
			стр_н.ИмяКлассаОбъекта = стр.element_class_name;
		КонецЕсли;
		Если стр.Свойство("element_text") Тогда
			стр_н.OutputText = стр.element_text;
		КонецЕсли;
		стр_н.Действие = ПреобразоватьНаименованиеДействия(стр.action);
		стр_н.Команда = стр.command;
		Если стр.Свойство("element_type") Тогда
			стр_н.ТипОбъекта = стр.element_type;
		КонецЕсли;
		element_description = "";
		Если стр.Свойство("element_description") Тогда
			element_description = стр.element_description;	
		КонецЕсли;
		
		Если ЗначениеЗаполнено(element_title) Тогда
			стр_н.Наименование = стр_н.Действие+ " """ +element_title + """";
		Иначе
			стр_н.Наименование = стр_н.Действие+ " """ +element_description + """";
		КонецЕсли;
		
		Если стр_н.Действие = "Команда" Тогда
			стр_н.Наименование = "Команда" + " """ +стр_н.Команда + """";
		КонецЕсли;
		стр_н.API = "Selenium";
		стр_н.UID = Строка(новый УникальныйИдентификатор());
		Если стр.Свойство("element_XPath") И НЕ Исключать_xPath=Истина Тогда
			стр_н.xPath = стр.element_XPath;
		Иначе
			стр_н.xPath = "";
		КонецЕсли;

		стр_н.ДанныеКартинки = мСцен_ПолучитьДанныеКартинки_НаКлиенте(новый Структура("Действие,ТипОбъекта", стр_н.Действие, ""));

	КонецЦикла;
	
 
	
	Если ТребуетяОбвязкаПодключения=Истина Тогда
		мСцен_GenerateClientConnectionScript(ДеревоСценария);
	КонецЕсли;
	
	
	// отправим в дерево
	ИмяОкна = новый Структура;
	ИмяОбъекта = новый Структура;
	ИмяОсновногоОкна = Новый Структура;
	ЭлементОсновноеОкно = Неопределено;
	ЭлементОкно = Неопределено;
	ЭлементОбъект = Неопределено;
	СбросОкна = Истина;
	Для каждого стр из ТаблицаДанныхСценария Цикл
		
		КлючОбъекта = новый Структура("Действие,Команда,ТипОбъекта,ИмяКлассаОбъекта,ИмяОбъекта,ЗаголовокОбъекта");
		ЗаполнитьЗначенияСвойств(КлючОбъекта,стр);		

		Если стр.Действие="НайтиОбъект" Тогда
			Если СбросОкна=Истина Тогда
				ИмяОкна = Новый Структура;
				ЭлементОкно = Неопределено;
			КонецЕсли;			
			Если НЕ СравнитьСтруктуры(ИмяОбъекта,КлючОбъекта) Тогда
				ИмяОбъекта = КлючОбъекта;
				ЭлементОбъект = ДеревоСценария.ПолучитьЭлементы().Добавить();
				ЗаполнитьЗначенияСвойств(ЭлементОбъект, стр);
				Продолжить;
			Иначе
				Продолжить;
			КонецЕсли;
		КонецЕсли;
		
		ЭлементКоманда = ЭлементОбъект.ПолучитьЭлементы().Добавить();
		ЗаполнитьЗначенияСвойств(ЭлементКоманда, стр,, "ТипОбъекта,ИмяКлассаОбъекта,xPath,ИдентификаторОбъекта,ЗаголовокОбъекта");
		
	КонецЦикла;
	
	// удалим фокус
	Если ИсключатьКомандуFocus = Истина Тогда

		МассивКУдалению = новый Массив(); //Массив к Удалению
		// получим объект и его команды
		Для каждого объект из ДеревоСценария.ПолучитьЭлементы() Цикл

			ЕстьДругиеКоманды = Ложь;
			ЕстьFocus = Ложь;

			Для каждого команда из объект.ПолучитьЭлементы() Цикл
				Если команда.Команда = "focus" Тогда
					МассивКУдалению.Добавить(новый Структура("Родитель,Ребенок",объект,команда));
					ЕстьFocus = Истина;
				Иначе
					ЕстьДругиеКоманды = Истина;
				КонецЕсли;
			КонецЦикла;
			Если ЕстьДругиеКоманды = Ложь И ЕстьFocus = Истина Тогда
				МассивКУдалению.Добавить(новый Структура("Родитель,Ребенок",ДеревоСценария,объект));
			КонецЕсли;

		КонецЦикла;

		Для каждого стр из МассивКУдалению Цикл
			стр.Родитель.ПолучитьЭлементы().Удалить(стр.Ребенок);
		КонецЦикла;
		
	КонецЕсли;
	
	
	Если ТребуетяОбвязкаПодключения=Истина Тогда
		мСцен_GenerateClientDisconnectionScript(ДеревоСценария);
	КонецЕсли;
	

КонецПроцедуры


&НаКлиенте
Функция СравнитьСтруктуры(Исходное,Сравниваемое)
	
	РезультатСравнения = Истина;
	
	Попытка
		Если Исходное.количество()<>Сравниваемое.Количество() Тогда
			РезультатСравнения = Ложь;
		Иначе
			Для каждого КлючИЗначение из Исходное Цикл
				Если КлючИЗначение.Значение <> Сравниваемое[КлючИЗначение.Ключ] Тогда
					РезультатСравнения = Ложь;
					Прервать;
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
		
	Исключение
		РезультатСравнения = Ложь;
	КонецПопытки;
	
	Возврат РезультатСравнения;
КонецФункции

&НаКлиенте
Функция ПреобразоватьНаименованиеДействия(Знач Наименование)
	
	Представление = Наименование;
	
	Если Наименование="find main window" Тогда
		Представление = "НайтиОсновноеОкно";
	ИначеЕсли Наименование="find window" Тогда
		Представление = "НайтиОкно";
	ИначеЕсли Наименование="find element" Тогда
		Представление = "НайтиОбъект";
	ИначеЕсли Наименование="command" Тогда
		Представление = "Команда";
	КонецЕсли;
	
	Возврат Представление;
	
КонецФункции

&НаСервереБезКонтекста
Функция мСцен_ПолучитьДанныеКартинки_НаКлиенте(Узел) Экспорт
	
	Действие = "";
	ТипОбъекта = "";

	
	Попытка
		Действие = Узел.Действие;
		ТипОбъекта = Узел.ТипОбъекта;
	Исключение
	КонецПопытки;
	
	
	// Картинка в поле Картинка
	Если Действие = "" ИЛИ Действие = "UnknownNode" ИЛИ Действие = "НеизвестныйУзел" Тогда
		ДанныеКартинки = 1;
		
	ИначеЕсли Действие = "НайтиОкно" ИЛИ Действие = "НайтиОсновноеОкно" Тогда
		ДанныеКартинки = 2;
		
	ИначеЕсли Действие = "НайтиФорму" Тогда
		ДанныеКартинки = 3;
		
	ИначеЕсли Действие = "Команда" И (ТипОбъекта ="FormButton" ИЛИ ТипОбъекта = "CommandInterfaceButton") Тогда
		ДанныеКартинки = 4;
		
	ИначеЕсли Действие = "НайтиОбъект" Тогда
		ДанныеКартинки = 5;
		
	ИначеЕсли Действие = "Условие" Тогда
		ДанныеКартинки = 6;
		
	ИначеЕсли Действие = "Команда" Тогда
		ДанныеКартинки = 7;
		
	ИначеЕсли Действие = "ПолучитьКомандныйИнтерфейс" Тогда
		ДанныеКартинки = 8;
		
	ИначеЕсли Действие = "GenerateClientConnectionScript" ИЛИ Действие = "ПодключитьТестируемоеПриложение" Тогда
		ДанныеКартинки = 9;
		
	ИначеЕсли Действие = "ЗакрытьТестируемоеПриложение" ИЛИ Действие = "GenerateClientDisconnectionScript" Тогда
		ДанныеКартинки = 10;
		
	ИначеЕсли Действие = "Комментарий" Тогда
		ДанныеКартинки = 11;
		
	ИначеЕсли Действие = "ВыполнитьПроизвольныйКодСервер" Тогда
		ДанныеКартинки = 12;
		
	ИначеЕсли Действие = "ВыполнитьПроизвольныйКодКлиент" Тогда
		ДанныеКартинки = 13;
		
	ИначеЕсли Действие = "Стоп" Тогда
		ДанныеКартинки = 14;
		
	ИначеЕсли Действие = "Пауза" Тогда
		ДанныеКартинки = 15;
		
	ИначеЕсли Действие = "СравнитьСПредставлениемДанных" Тогда
		ДанныеКартинки = 16;
		
	ИначеЕсли Действие = "ПолучитьПредставлениеДанных" Тогда
		ДанныеКартинки = 17;
		
	ИначеЕсли Действие = "ГотовыйБлокШагов" Тогда
		ДанныеКартинки = 18;
		
	ИначеЕсли Действие = "ТестовыйСлучай" Тогда
		ДанныеКартинки = 19;
		
	ИначеЕсли Действие = "ДилогВыбораФайла" Тогда
		ДанныеКартинки = 0;
		
	ИначеЕсли Действие = "Timer" ИЛИ Действие = "Таймер" Тогда
		ДанныеКартинки = 20;		
		
	ИначеЕсли Действие = "ИзПараметра1ВПараметр2" Тогда
		ДанныеКартинки = 21;
		
	ИначеЕсли Действие = "ПроверкаНаличияЭлемента" Тогда
		ДанныеКартинки = 22;
		
	ИначеЕсли Действие = "" Тогда
		ДанныеКартинки = 23;
		
	КонецЕсли;
	
	Возврат ДанныеКартинки;
	
КонецФункции

&НаСервере
Процедура мСцен_ПреобразоватьВДеревоСценарияНаСервере(ТекстСценария,
		ДеревоСценария, мПараметры, ЭтоБуфер = Ложь) Экспорт
КонецПроцедуры
	


&НаКлиенте
Процедура ЗагрузитьБиблиотеки()

	Если Модуль_СервисныеФункции = Неопределено Тогда
		Модуль_СервисныеФункции = ПолучитьФорму("ВнешняяОбработка.МенеджерСценарногоТеста.Форма.Модуль_СервисныеФункции");
	КонецЕсли;

КонецПроцедуры


#Область ДополнительныеКоманды

&НаКлиенте
Процедура мСцен_GenerateClientConnectionScript(РодительВетка)
	
	ТекущаяВетка = РодительВетка.ПолучитьЭлементы().Добавить();
	ТекущаяВетка.UID = строка(новый UUID());
	ТекущаяВетка.FUID = ТекущаяВетка.UID;
	ТекущаяВетка.Наименование = мСцен_ПолучитьНаименованиеПоТегу("ПодключитьТестируемоеПриложение");
    ТекущаяВетка.Действие = "ПодключитьТестируемоеПриложение";
	ТекущаяВетка.ДанныеКартинки = мСцен_ПолучитьДанныеКартинки_НаКлиенте(новый Структура("Действие,ТипОбъекта",ТекущаяВетка.Действие,""));
	ТекущаяВетка.API="Selenium";
	
КонецПроцедуры

&НаКлиенте
Процедура мСцен_GenerateClientDisconnectionScript(РодительВетка)
	
	ТекущаяВетка = РодительВетка.ПолучитьЭлементы().Добавить();
	ТекущаяВетка.UID = строка(новый UUID());
	ТекущаяВетка.FUID = ТекущаяВетка.UID;
	ТекущаяВетка.Наименование = мСцен_ПолучитьНаименованиеПоТегу("ЗакрытьТестируемоеПриложение");
    ТекущаяВетка.Действие = "ЗакрытьТестируемоеПриложение";
	ТекущаяВетка.ДанныеКартинки = мСцен_ПолучитьДанныеКартинки_НаКлиенте(новый Структура("Действие,ТипОбъекта",ТекущаяВетка.Действие,""));
	ТекущаяВетка.API="Selenium";
	
КонецПроцедуры

&НаКлиенте
Функция УбратьНедопустимыеСимволыXML(Знач Текст)
	
	мТекст = Текст;
	СпецСимволы = "\u0000,
	|\u0001,\u0002,
	|\u0003,\u0004,
	|\u0005,\u0006,
	|\u0007,\u0008,
	|\u000B,\u000C,
	|\u000E,\u000F,
	|\u0010,\u0011,
	|\u0012,\u0013,
	|\u0014,\u0015,
	|\u0016,\u0017,
	|\u0018,\u0019,
	|\u001A,\u001B,
	|\u001C,\u001D,
	|\u001E,\u001F,
	|\uFFFE,\uFFFF";
	
	СтрокаЗамены = "%20u0000,
	| %20u0001, %20u0002,
	| %20u0003, %20u0004,
	| %20u0005, %20u0006,
	| %20u0007, %20u0008,
	| %20u000B, %20u000C,
	| %20u000E, %20u000F,
	| %20u0010, %20u0011,
	| %20u0012, %20u0013,
	| %20u0014, %20u0015,
	| %20u0016, %20u0017,
	| %20u0018, %20u0019,
	| %20u001A, %20u001B,
	| %20u001C, %20u001D,
	| %20u001E, %20u001F,
	| %20uFFFE, %20uFFFF";
	
	МассивСпецСимволов = СтрРазделить(СтрЗаменить(СпецСимволы,Символы.ПС ,""),",",Ложь);
	МассивСпецСимволовЗамены = СтрРазделить(СтрЗаменить(СтрокаЗамены,Символы.ПС ,""),",",Ложь);
	
		
	Для ш=0 по МассивСпецСимволов.Количество()-1 Цикл
		мТекст = СтрЗаменить(мТекст,МассивСпецСимволов[ш],МассивСпецСимволовЗамены[ш]);
	КонецЦикла;
	
	Возврат мТекст;
КонецФункции


&НаСервереБезКонтекста
Функция мСцен_ПолучитьНаименованиеПоТегу(ИмяТега)
	
	Представление = ИмяТега;
	
	Если ИмяТега="ClientApplicationWindow" Тогда
		Представление = "Окно клиентского приложения";
	ИначеЕсли ИмяТега = "Form" Тогда
		Представление = "Форма";
	ИначеЕсли ИмяТега = "CommandInterface" Тогда
		Представление = "Командный интерфейс";		
	ИначеЕсли ИмяТега = "FormField" Тогда
		Представление = "Поле формы";		
	ИначеЕсли ИмяТега = "FormTable" Тогда
		Представление = "Таблица формы";		
	ИначеЕсли ИмяТега = "FormDecoration" Тогда
		Представление = "Декорация формы";		
	ИначеЕсли ИмяТега = "FormButton" Тогда
		Представление = "Кнопка формы";		
	ИначеЕсли ИмяТега = "FormGroup" Тогда
		Представление = "Группа формы";		
	ИначеЕсли ИмяТега = "CommandInterfaceButton" Тогда
		Представление = "Кнопка командный интерфейс";		
	ИначеЕсли ИмяТега = "CommandInterfaceGroup" Тогда
		Представление = "Группа командный интерфейс";
		
	// служебные мои
	ИначеЕсли ИмяТега = "ПодключитьТестируемоеПриложение" Тогда
		Представление = "Подключение к тестируемому приложению";
	// служебные мои
	ИначеЕсли ИмяТега = "ЗакрытьТестируемоеПриложение" Тогда
		Представление = "Отключиться от тестируемого приложения";
		
		
		
	//ИначеЕсли ИмяТега = "" Тогда
	//	Представление = "";		
	//ИначеЕсли ИмяТега = "" Тогда
	//	Представление = "";		
	//ИначеЕсли ИмяТега = "" Тогда
	//	Представление = "";		
	//ИначеЕсли ИмяТега = "" Тогда
	//	Представление = "";		
	//ИначеЕсли ИмяТега = "" Тогда
	//	Представление = "";		
	//ИначеЕсли ИмяТега = "" Тогда
	//	Представление = "";		
	//ИначеЕсли ИмяТега = "" Тогда
	//	Представление = "";		
	//ИначеЕсли ИмяТега = "" Тогда
	//	Представление = "";		
	Иначе
		Представление = "Неопознанный узел";
	КонецЕсли;
	
	Возврат Представление;
	
КонецФункции



#КонецОбласти