
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	РедактироватьКонструктором = Истина;
	ИдентификаторКонструктора = "TaskLoadReportsOnly";
	ИдентификаторКонструктораУниверсальный = "Universal";
	МенеджерОтчетов = Справочники.ТестируемыеКлиенты.ТекущийКлиент1С;
	
	// Открыта форма редактирования
	Если ЗначениеЗаполнено(Параметры.Задание) Тогда		
		Задание = Параметры.Задание;
	Иначе
		СоздаватьИскатьДействияАвтоматически = Истина;
	КонецЕсли;
	
	Если Параметры.Свойство("ОбъектыНазначения") Тогда
		Если ТипЗнч(Параметры.ОбъектыНазначения) = Тип("Массив")
			И Параметры.ОбъектыНазначения.Количество()>0 Тогда			
			Задание = Параметры.ОбъектыНазначения[0];
		КонецЕсли;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Задание) Тогда
		НайтиПараметрыПоЗаданию();
	Иначе
		Если НЕ ЗначениеЗаполнено(ФорматФайлаОтчета) Тогда
			ФорматФайлаОтчета = "JUnit";
		КонецЕсли;		
		НайтиШаблоныДействия();
	КонецЕсли;
	
	Элементы.ГруппаДействия.ТолькоПросмотр = СоздаватьИскатьДействияАвтоматически;

КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	Элементы.СтраницыОбработки.ОтображениеСтраниц=ОтображениеСтраницФормы.Нет;
	ОтработатьПеремещениеПоСтраницам();
	//ОтображениеПредупрежденияТестируемогоКлиента();
	Если НЕ ЗначениеЗаполнено(ФорматФайлаОтчета) Тогда
		ФорматФайлаОтчета = "JUnit";
	КонецЕсли;
КонецПроцедуры


#Область ЗагрузкаПараметровЗадания

&НаСервере
Процедура НайтиПараметрыПоЗаданию()
	
	Перем Выборка, Запрос, КлючПоискаШаблона, РезультатЗапроса;
	
	Элементы.СоздатьНовоеЗадание.Заголовок = "Применить изменения";
	Запрос = новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	Задания.Наименование,
	|	Задания.ID,
	|	Задания.Автор,
	|	Задания.ГруппаЗадания,
	|	Задания.Ответственный,
	|	Задания.ИдентификаторКонструктора,
	|	Задания.Родитель
	|ИЗ
	|	Справочник.Задания КАК Задания
	|ГДЕ
	|	Задания.Ссылка = &Ссылка";
	Запрос.УстановитьПараметр("Ссылка",Задание);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если РезультатЗапроса.Пустой() Тогда
		
		ВызватьИсключение "Ошибка редактирования запроса в конструкторе...";
		
	КонецЕсли;
	
	Выборка = РезультатЗапроса.Выбрать();
	Выборка.Следующий();
	
	Наименование = Выборка.Наименование;
	TaskID = Выборка.ID; 
	Ответственный = Выборка.Ответственный;
	ГруппаЗадания = Выборка.ГруппаЗадания;
	Родитель =  Выборка.Родитель;
	
	// СоздаватьИскатьДействияАвтоматически
	СоздаватьИскатьДействияАвтоматически = ПолучитьЗначениеПараметраПоРегистру(Задание,"СоздаватьИскатьДействияАвтоматически");
	Элементы.ГруппаДействия.ТолькоПросмотр = СоздаватьИскатьДействияАвтоматически;		
	
	// ФорматФайлаОтчета
	ФорматФайлаОтчета = ПолучитьЗначениеПараметраПоРегистру(Задание,Справочники.ИменаПеременных.ФорматФайлаОтчета);
	Если НЕ ЗначениеЗаполнено(ФорматФайлаОтчета) Тогда
		ФорматФайлаОтчета = "JUnit";
	КонецЕсли;
	
	// менеджер отчетов
	мМенеджерОтчетов = ПолучитьЗначениеПараметраПоРегистру(Задание,Справочники.ИменаПеременных.МенеджерОтчетов);
	Если ЗначениеЗаполнено(мМенеджерОтчетов) Тогда
		МенеджерОтчетов = мМенеджерОтчетов;
	КонецЕсли;
	
	// тестируемый клиент
	ТестируемыйКлиент = ПолучитьЗначениеПараметраПоРегистру(Задание,Справочники.ИменаПеременных.ТестируемыйКлиент);
	
	// Путь к файлу теста
	ПутьКФайлуТеста = ПолучитьЗначениеПараметраПоРегистру(Задание,"%ПутьКФайлуТеста%",Ложь);
	
	НайтиШаблоныДействия();

КонецПроцедуры

&НаСервере
Процедура НайтиШаблоныДействия()
	
	Перем КлючПоискаШаблона;
	
	
	КлючПоискаШаблона = ПолучитьКлючПоискаШаблона("ШаблонЗагрузкиЛога"); 
	ШаблонКомандыЗагрузкиЛога = НайтиШаблонКоманды(ИдентификаторКонструктораУниверсальный,ПолучитьТекстШаблонаКомандыЗагрузкиОтчетаВыполнени(ФорматФайлаОтчета),КлючПоискаШаблона);
	
	КлючПоискаШаблона = ПолучитьКлючПоискаШаблона("ЗагрузитьЛог");
	ДействиеЗагрузкиЛога = НайтиДействиеЗадания(ИдентификаторКонструктораУниверсальный,КлючПоискаШаблона);

КонецПроцедуры

&НаСервере
Функция  ПолучитьЗначениеПараметраПоРегистру(Знач Владелец, Знач ИмяПеременной,Знач ЭтоПараметрНастройки=Истина)
	
	ЗначениеПараметра = Неопределено;
	
	// параметр СоздаватьИскатьАвтоматически
	Запрос = новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	ПеременныеЗаданий.ЗначениеПеременной КАК Значение
	|ИЗ
	|	РегистрСведений.ПеременныеЗаданий КАК ПеременныеЗаданий
	|ГДЕ
	|	ПеременныеЗаданий.Задание = &Задание
	|	И ПеременныеЗаданий.ИмяПеременной = &ИмяПеременной
	|	И ПеременныеЗаданий.ЭтоПараметрНастройки = &ЭтоПараметрНастройки";
	Запрос.УстановитьПараметр("Задание",Владелец);
	Запрос.УстановитьПараметр("ИмяПеременной",ИмяПеременной);
	Запрос.УстановитьПараметр("ЭтоПараметрНастройки",ЭтоПараметрНастройки);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Выборка.Следующий() Тогда
		ЗначениеПараметра = Выборка.Значение;
	КонецЕсли;

	Возврат ЗначениеПараметра;
	
КонецФункции

#КонецОбласти

#Область ДействиеЗадания

&НаСервереБезКонтекста
Функция СоздатьДействиеЗадания(Знач ИдентификаторКонструктора, Знач Наименование, Знач КлючПоиска, Знач ШаблонКоманды, Знач МаксВремяОжидания=600)
	
	ДействиеСсылка = Справочники.ДействияЗаданий.ПустаяСсылка();
	
	ДействиеОбъект = Справочники.ДействияЗаданий.СоздатьЭлемент();
	ДействиеОбъект.Наименование 				= Наименование;
	ДействиеОбъект.ИдентификаторКонструктора 	= ИдентификаторКонструктора;
	ДействиеОбъект.РедактироватьКонструктором	= Истина;
	Если   Найти(КлючПоиска,"ЗагрузитьЛог") Тогда
		ДействиеОбъект.ТипДействия					= Перечисления.ТипыДействийЗаданий.ЗапуститьПриложение;
		ДействиеОбъект.ШаблонКоманды				= ШаблонКоманды;
		ДействиеОбъект.ИспользоватьШаблонКоманды    = Истина;
	Иначе
		ВызватьИсключение "Не известное задание по шаблону!";
	КонецЕсли;                                               	
	ДействиеОбъект.Автор						= Пользователи.ТекущийПользователь();
	
	Попытка
		ДействиеОбъект.Записать();
		ДействиеСсылка = ДействиеОбъект.Ссылка;
	Исключение
		ТекстОшибки = ОписаниеОшибки();
		Сообщить(ОписаниеОшибки());
		ЗаписьЖурналаРегистрации("СозатьДействиеЗадания",УровеньЖурналаРегистрации.Ошибка,Неопределено,Неопределено,ТекстОшибки);
	КонецПопытки;
	
	Возврат ДействиеСсылка;
КонецФункции

&НаСервереБезКонтекста
Функция НайтиДействиеЗадания(Знач ИдентификаторКонструктора, Знач КлючПоиска)
	
	ДействиеСсылка = Справочники.ШаблоныКоманд.ПустаяСсылка();
	
	Запрос = новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	Т.Ссылка КАК Ссылка,
	|	0 КАК Порядок
	|ИЗ
	|	РегистрСведений.ПеременныеЗаданий КАК ПеременныеЗаданий
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ДействияЗаданий КАК Т
	|		ПО ПеременныеЗаданий.Задание = Т.Ссылка
	|			И (ПеременныеЗаданий.НомерАргумента = 0)
	|			И (ПеременныеЗаданий.Ключ = НЕОПРЕДЕЛЕНО)
	|			И (ПеременныеЗаданий.ИмяПеременной = &ИмяПеременной)
	|			И (ПеременныеЗаданий.ЗначениеПеременной = &КлючПоиска)
	|ГДЕ
	|	Т.ИдентификаторКонструктора = &ИдентификаторКонструктора
	|	И Т.ПометкаУдаления = ЛОЖЬ
	|
	|УПОРЯДОЧИТЬ ПО
	|	Порядок";
	Запрос.УстановитьПараметр("ИдентификаторКонструктора",ИдентификаторКонструктора);
	Запрос.УстановитьПараметр("ИмяПеременной",Справочники.ИменаПеременных.КлючПоиска);
	Запрос.УстановитьПараметр("КлючПоиска",КлючПоиска);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если НЕ РезультатЗапроса.Пустой() Тогда
		Выборка = РезультатЗапроса.Выбрать();
		Если Выборка.Следующий() Тогда
			ДействиеСсылка = Выборка.Ссылка;
		КонецЕсли;
	КонецЕсли;	
	
	Возврат ДействиеСсылка;
КонецФункции

#КонецОбласти

#Область ШаблонКоманды

&НаСервере
Функция ПолучитьКлючПоискаШаблона(Знач Действие="")
	Ключ = "";
	Если Действие="ЗагрузитьЛог" ИЛИ Действие="ШаблонЗагрузкиЛога" Тогда
		Ключ = "GIT/"+ФорматФайлаОтчета+?(ЗначениеЗаполнено(Действие),"/"+Действие,"");
	КонецЕсли;
	
	Возврат Ключ;
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьТекстШаблонаКомандыЗагрузкиОтчетаВыполнени(ФорматФайлаОтчета)
	Возврат """%ПутьКИсполняемомуФайлу1С%"" %СтрокаСоединенияМенеджер% /UseHwLicenses- /DisableStartupMessages 
	| /Execute ""%ПутьККаталогуGIT%\PluginsUI\"+?(ФорматФайлаОтчета="Allure","ЗагрузкаAllureЛогаТеста.epf","ЗагрузкаJUnitЛогаТеста.epf")+"""  
	| /C""
	| TestLogUI %ПутьККаталогуОтчетовВыполненияТестов%\report-%НомерПроверки%_%Тест%.xml 
	| TestNumberUI %НомерПроверки%
	| TestAssemblyUI %НомерСборки%
	| TestClientIdUI %ИдентификаторКлиента% 
	| TestCloseUI
	| TestDeleteLogUI 
	|"" ";
КонецФункции

&НаСервереБезКонтекста
Функция НайтиШаблонКоманды(Знач ИдентификаторКонструктора,Знач ТекстШаблона="",Знач КлючПоиска="")
	
	ШаблонСсылка = Справочники.ШаблоныКоманд.ПустаяСсылка();
	
	Запрос = новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	Т.Ссылка КАК Ссылка,
	|	0 КАК Порядок
	|ИЗ
	|	РегистрСведений.ПеременныеЗаданий КАК ПеременныеЗаданий
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ШаблоныКоманд КАК Т
	|		ПО ПеременныеЗаданий.Задание = Т.Ссылка
	|			И (ПеременныеЗаданий.НомерАргумента = 0)
	|			И (ПеременныеЗаданий.Ключ = НЕОПРЕДЕЛЕНО)
	|			И (ПеременныеЗаданий.ИмяПеременной = &ИмяПеременной)
	|			И (ПеременныеЗаданий.ЗначениеПеременной = &КлючПоиска)
	|ГДЕ
	|	Т.ИдентификаторКонструктора = &ИдентификаторКонструктора
	|	И Т.ПометкаУдаления = ЛОЖЬ
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	Т.Ссылка,
	|	1
	|ИЗ
	|	Справочник.ШаблоныКоманд КАК Т
	|ГДЕ
	|	Т.ПометкаУдаления = ЛОЖЬ
	|	И (ВЫРАЗИТЬ(Т.ТекстШаблона КАК СТРОКА(1000))) = (ВЫРАЗИТЬ(&ТекстШаблона КАК СТРОКА(1000)))
	|
	|УПОРЯДОЧИТЬ ПО
	|	Порядок";
	Запрос.УстановитьПараметр("ИдентификаторКонструктора",ИдентификаторКонструктора);
	Запрос.УстановитьПараметр("ИмяПеременной",Справочники.ИменаПеременных.КлючПоиска);
	Запрос.УстановитьПараметр("КлючПоиска",КлючПоиска);
	Запрос.УстановитьПараметр("ТекстШаблона",ТекстШаблона);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если НЕ РезультатЗапроса.Пустой() Тогда
		Выборка = РезультатЗапроса.Выбрать();
		Если Выборка.Следующий() Тогда
			ШаблонСсылка = Выборка.Ссылка;
		КонецЕсли;
	КонецЕсли;	
	
	Возврат ШаблонСсылка;
КонецФункции

&НаСервереБезКонтекста
Функция СоздатьШаблонКоманды(Знач ИдентификаторКонструктора, Знач Наименование, Знач КлючПоиска, Знач ТекстШаблона)
	
	ШаблонСсылка = Справочники.ШаблоныКоманд.ПустаяСсылка();
	
	ШаблонОбъект = Справочники.ШаблоныКоманд.СоздатьЭлемент();
	ШаблонОбъект.Наименование 				= Наименование;
	ШаблонОбъект.ИдентификаторКонструктора 	= ИдентификаторКонструктора;
	ШаблонОбъект.ТекстШаблона 				= ТекстШаблона;
	ШаблонОбъект.РедактироватьКонструктором = Истина;
	
	Попытка
		ШаблонОбъект.Записать();
		ШаблонСсылка = ШаблонОбъект.Ссылка;
	Исключение
		ТекстОшибки = ОписаниеОшибки();
		Сообщить(ОписаниеОшибки());
		ЗаписьЖурналаРегистрации("СозатьШаблонКоманды",УровеньЖурналаРегистрации.Ошибка,Неопределено,Неопределено,ТекстОшибки);
	КонецПопытки;
	
	Возврат ШаблонСсылка;
КонецФункции

#КонецОбласти

#Область Навигация

&НаКлиенте
Процедура Вперед(Команда)
	Если Элементы.СтраницыОбработки.ТекущаяСтраница=Элементы.СтраницаИнициализация Тогда
		
		// условие переключения на следующий шаг
		Если НЕ ПроверитьНаличиеПодобноегоЗадания(Наименование,TaskID,Задание) Тогда
			Элементы.СтраницыОбработки.ТекущаяСтраница=Элементы.СтраницаСоставЗадания;
		КонецЕсли;
		
	ИначеЕсли Элементы.СтраницыОбработки.ТекущаяСтраница=Элементы.СтраницаСоставЗадания Тогда
		
		ОбобщениеHTML = СформироватьОписаниеСоздаваемогоЗдания();
		Элементы.СтраницыОбработки.ТекущаяСтраница=Элементы.СтраницаИтого;
		
	ИначеЕсли Элементы.СтраницыОбработки.ТекущаяСтраница=Элементы.СтраницаИтого Тогда
		
	КонецЕсли;
	
	ОтработатьПеремещениеПоСтраницам();
КонецПроцедуры

&НаКлиенте
Процедура Назад(Команда)
	
	// назад без проверок
	Если Элементы.СтраницыОбработки.ТекущаяСтраница=Элементы.СтраницаИнициализация Тогда
	ИначеЕсли Элементы.СтраницыОбработки.ТекущаяСтраница=Элементы.СтраницаСоставЗадания Тогда
		Элементы.СтраницыОбработки.ТекущаяСтраница=Элементы.СтраницаИнициализация;
	ИначеЕсли Элементы.СтраницыОбработки.ТекущаяСтраница=Элементы.СтраницаИтого Тогда
		Элементы.СтраницыОбработки.ТекущаяСтраница=Элементы.СтраницаСоставЗадания;
	КонецЕсли;	
	
	ОтработатьПеремещениеПоСтраницам();
КонецПроцедуры

&НаКлиенте
Процедура ОтработатьПеремещениеПоСтраницам()
	
	Если Элементы.СтраницыОбработки.ТекущаяСтраница=Элементы.СтраницаИнициализация Тогда
		Элементы.Назад.Видимость = Ложь;
		Элементы.Вперед.Видимость = Истина;
		Элементы.СоздатьНовоеЗадание.Видимость = Ложь;
	ИначеЕсли Элементы.СтраницыОбработки.ТекущаяСтраница=Элементы.СтраницаСоставЗадания Тогда
		Элементы.Назад.Видимость = Истина;
		Элементы.Вперед.Видимость = Истина;
		Элементы.СоздатьНовоеЗадание.Видимость = Ложь;
	ИначеЕсли Элементы.СтраницыОбработки.ТекущаяСтраница=Элементы.СтраницаИтого Тогда
		Элементы.Назад.Видимость = Истина;
		Элементы.Вперед.Видимость = Ложь;
		Элементы.СоздатьНовоеЗадание.Видимость = Истина;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СозданиеЗадания

&НаКлиенте
Процедура СоздатьНовоеЗадание(Команда)
	Если СоздатьНовоеЗаданиеНаСервере()=Истина Тогда
		ЭтаФорма.Закрыть();
	КонецЕсли;
КонецПроцедуры

&НаСервере
Функция СоздатьНовоеЗаданиеНаСервере()
	
	Отказ = Ложь;	
	ЗаданиеОбъект = Неопределено;
	
	// созададим действия
	
	Попытка
		
		НачатьТранзакцию(); 		
		
		// шаблон
		Если СоздаватьИскатьДействияАвтоматически=Истина И НЕ ЗначениеЗаполнено(ШаблонКомандыЗагрузкиЛога) Тогда
			КлючПоискаШаблона = ПолучитьКлючПоискаШаблона("ШаблонЗагрузкиЛога"); 
			ШаблонКомандыЗагрузкиЛога = НайтиШаблонКоманды(ИдентификаторКонструктораУниверсальный,ПолучитьТекстШаблонаКомандыЗагрузкиОтчетаВыполнени(ФорматФайлаОтчета),КлючПоискаШаблона);
			Если НЕ ЗначениеЗаполнено(ШаблонКомандыЗагрузкиЛога) Тогда
				ШаблонКомандыЗагрузкиЛога = СоздатьШаблонКоманды(ИдентификаторКонструктораУниверсальный,"Шаблон команды загрузка отчета выполнения формат '"+ФорматФайлаОтчета+"'",КлючПоискаШаблона,ПолучитьТекстШаблонаКомандыЗагрузкиОтчетаВыполнени(ФорматФайлаОтчета));
				СоздатьОбновитьПараметр(ШаблонКомандыЗагрузкиЛога,Справочники.ИменаПеременных.КлючПоиска,КлючПоискаШаблона);
				// если не удалось создать, тогда отказ
				Если НЕ ЗначениеЗаполнено(ШаблонКомандыЗагрузкиЛога) Тогда
					Отказ = Истина;
					Возврат НЕ Отказ;
				КонецЕсли;
			КонецЕсли;		
		КонецЕсли;
		
		
		// действия
		Если СоздаватьИскатьДействияАвтоматически=Истина И НЕ ЗначениеЗаполнено(ДействиеЗагрузкиЛога) Тогда
			КлючПоискаШаблона = ПолучитьКлючПоискаШаблона("ЗагрузитьЛог");
			ДействиеЗагрузкиЛога = СоздатьДействиеЗадания(ИдентификаторКонструктораУниверсальный,"Загрузить отчет выполнения теста формат '"+ФорматФайлаОтчета+"'",КлючПоискаШаблона,ШаблонКомандыЗагрузкиЛога);
			СоздатьОбновитьПараметр(ДействиеЗагрузкиЛога,Справочники.ИменаПеременных.КлючПоиска,КлючПоискаШаблона);
			Если НЕ ЗначениеЗаполнено(ДействиеЗагрузкиЛога) Тогда
				Отказ = Истина;
				Возврат НЕ Отказ;
			КонецЕсли;
		КонецЕсли;	
		
		
		// Создаем/ обновляем задание
		Если ЗначениеЗаполнено(Задание) Тогда
			ЗаданиеОбъект = Задание.ПолучитьОбъект();
		Иначе
			ЗаданиеОбъект = Справочники.Задания.СоздатьЭлемент();
		КонецЕсли;	
		
		ЗаданиеОбъект.Наименование = Наименование;
		ЗаданиеОбъект.ID = TaskID;
		ЗаданиеОбъект.Родитель = Родитель;
		ЗаданиеОбъект.ГруппаЗадания = ГруппаЗадания;
		ЗаданиеОбъект.РедактироватьКонструктором = РедактироватьКонструктором;
		ЗаданиеОбъект.ИдентификаторКонструктора = ИдентификаторКонструктора;
		ЗаданиеОбъект.Ответственный = Ответственный;
		Если НЕ ЗначениеЗаполнено(ЗаданиеОбъект.Автор) Тогда
			ЗаданиеОбъект.Автор = Пользователи.ТекущийПользователь();
		КонецЕсли;
		
		Попытка
			ЗаданиеОбъект.Записать();
			Задание = ЗаданиеОбъект.Ссылка;
		Исключение
			ОтменитьТранзакцию();
			Отказ = Истина;
			Сообщить(ОписаниеОшибки());		
			Возврат НЕ Отказ;
		КонецПопытки;
		
		
		// обновляем регистр состав
		НаборЗаписей = РегистрыСведений.СоставЗаданий.СоздатьНаборЗаписей();
		НаборЗаписей.Отбор.Задание.Установить(Задание);
		
		ПорядокВыполнения = 1;
		
		НоваяЗапись = НаборЗаписей.Добавить();
		НоваяЗапись.Задание = Задание;
		НоваяЗапись.ПорядокВыполнения = ПорядокВыполнения;
		НоваяЗапись.Действие = ДействиеЗагрузкиЛога;
		ПорядокВыполнения = ПорядокВыполнения +1;
		
		Если ЗначениеЗаполнено(ДействиеЗакрытьПриложение) Тогда
			НоваяЗапись = НаборЗаписей.Добавить();
			НоваяЗапись.Задание = Задание;
			НоваяЗапись.ПорядокВыполнения = ПорядокВыполнения;
			НоваяЗапись.Действие = ДействиеЗакрытьПриложение;
			ПорядокВыполнения = ПорядокВыполнения +1;  		
		КонецЕсли;
		
		НаборЗаписей.Записать();
		
		// создаем необходимые переменные
		СоздатьОбновитьПараметр(Задание,"СоздаватьИскатьДействияАвтоматически",СоздаватьИскатьДействияАвтоматически);
		СоздатьОбновитьПараметр(Задание,Справочники.ИменаПеременных.ФорматФайлаОтчета,ФорматФайлаОтчета);
		СоздатьОбновитьПараметр(Задание,"%ПутьКФайлуТеста%",ПутьКФайлуТеста,Ложь);
		СоздатьОбновитьПараметр(Задание,"%НомерПроверки%",0,Ложь);  		
			
		// Менеджер Отчетов
		СоздатьОбновитьПараметр(Задание,Справочники.ИменаПеременных.МенеджерОтчетов,МенеджерОтчетов);
		СоздатьОбновитьПараметр(Задание,"%СтрокаСоединенияМенеджер%",МенеджерОтчетов,Истина,Неопределено,"","СтрокаСоединения");
		
		// Тестируемый Клиент
		Если ЗначениеЗаполнено(ТестируемыйКлиент) Тогда			
			СоздатьОбновитьПараметр(Задание,Справочники.ИменаПеременных.ТестируемыйКлиент,ТестируемыйКлиент);
			СоздатьОбновитьПараметр(Задание,"%ИдентификаторКлиента%",ТестируемыйКлиент,Ложь,Неопределено,"ID");			
		КонецЕсли;   		
		
		ЗафиксироватьТранзакцию();
		
	Исключение
		ОтменитьТранзакцию();
		ТекстОшибки = ОписаниеОшибки();
		ЗаписьЖурналаРегистрации("ScenarioUITaskTestBuilder",УровеньЖурналаРегистрации.Ошибка,Неопределено,Неопределено,ТекстОшибки);
		Сообщить(ТекстОшибки);
	КонецПопытки; 	
	
	Возврат НЕ Отказ;

КонецФункции

&НаСервереБезКонтекста
Функция ПроверитьНаличиеПодобноегоЗадания(Знач Наименование,Знач TaskID,Знач Задание)   	
	
	Если НЕ ЗначениеЗаполнено(Наименование) Тогда
		Сообщить("Укажите наименование нового задания!");
		Возврат Истина;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(TaskID) Тогда
		Сообщить("Укажите идентификатор нового задания!");
		Возврат Истина;
	КонецЕсли;
	
	// проверим, есть ли такое задание
	Запрос = новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	Задания.Ссылка,
	|	Задания.ID,
	|	Задания.Наименование
	|ИЗ
	|	Справочник.Задания КАК Задания
	|ГДЕ
	|	(Задания.Наименование = &Наименование
	|			ИЛИ Задания.ID = &TaskID)
	|	И НЕ Задания.Ссылка = &Задание";
	
	Запрос.УстановитьПараметр("Наименование",Наименование);
	Запрос.УстановитьПараметр("TaskID",TaskID);
	Запрос.УстановитьПараметр("Задание",Задание);

	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если РезультатЗапроса.Пустой() Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		
		Сообщить("Уже существет задание с подобным именем или идентификатором. Измените вводимые данные! Наименование - " +Выборка.Наименование+" Идентификатор - "+Выборка.TaskID);
		
	КонецЦикла;
	
	
	Возврат Истина;
	
	
КонецФункции

&НаКлиенте
Функция СформироватьОписаниеСоздаваемогоЗдания()
	
	Html = "<html><head></head><body>";
	Html = Html + "<h3>Свойства задания</h3>";
	Html = Html + "<b>Наименование:</b>  <span color='blue'>"+Наименование+"</span></br>";
	Html = Html + "<b>Идентификатор задания:</b> <span color='blue'>"+TaskID+"</span></br>";
	Html = Html + "Ответственный: "+?(ЗначениеЗаполнено(Ответственный),Ответственный,"---")+"</br>";
	Html = Html + "Родитель: "+?(ЗначениеЗаполнено(Родитель),Родитель,"---")+"</br>";
	Html = Html + "ГруппаЗадания: "+?(ЗначениеЗаполнено(ГруппаЗадания),ГруппаЗадания,"---")+"</br>";
	Html = Html + "<h3>Структура действий</h3>";
	Html = Html + "<b>Действие загрузки лога:</b> <span color='blue'>"+ДействиеЗагрузкиЛога+"</b></br>";
	Html = Html+"</body></html>";
	
	Возврат Html;
	
КонецФункции

&НаКлиенте
Процедура ЗаданиеПриИзменении(Элемент)
	НайтиПараметрыПоЗаданию();
КонецПроцедуры

&НаСервереБезКонтекста
Процедура СоздатьОбновитьПараметр(Знач Владелец,Знач ИмяПеременной,Знач ЗначениеПеременной, Знач ЭтоПараметрНастройки=Истина, Знач Ключ=Неопределено, Знач ИмяРеквизита="",Знач ИмяФункции="")
	
	МенеджерЗаписи = РегистрыСведений.ПеременныеЗаданий.СоздатьМенеджерЗаписи();
	
	МенеджерЗаписи.Задание = Владелец;	
	МенеджерЗаписи.ИмяПеременной = ИмяПеременной;
	МенеджерЗаписи.НомерАргумента = 0;
	МенеджерЗаписи.Ключ = Ключ;
	МенеджерЗаписи.ЗначениеПеременной = ЗначениеПеременной;
	МенеджерЗаписи.ЭтоПараметрНастройки = ЭтоПараметрНастройки;
	МенеджерЗаписи.ИмяРеквизита = ИмяРеквизита;
	Если ЗначениеЗаполнено(ИмяФункции) Тогда
		МенеджерЗаписи.ИмяФункции = ИмяФункции;
		МенеджерЗаписи.ИспользоватьФункцию = Истина;
	КонецЕсли;
	
	МенеджерЗаписи.Записать(Истина);
	
КонецПроцедуры

#КонецОбласти

#Область События

&НаКлиенте
Процедура СоздаватьИскатьДействияАвтоматическиПриИзменении(Элемент)
	Элементы.ГруппаДействия.ТолькоПросмотр = СоздаватьИскатьДействияАвтоматически;
КонецПроцедуры

&НаКлиенте
Процедура НаименованиеПриИзменении(Элемент)
	Если НЕ ЗначениеЗаполнено(TaskID) Тогда
		TaskID = СценарноеТестированиеКлиентСервер.СформироватьАвтоматическиИдентификаторТеста(Наименование);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПутьКФайлуТестаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	Диалог = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие); 
	Диалог.Заголовок = "Выберите файл отчета"; 
	Если ЗначениеЗаполнено(ПутьКФайлуТеста) Тогда
		Диалог.Каталог = ОбщегоНазначенияКлиентСервер.ПолучитьКаталогПоПутиФайла(ПутьКФайлуТеста);
	КонецЕсли;
	Диалог.ПолноеИмяФайла = ""; 
	Фильтр = "XML-файл (*.xml)|*.xml"; 
	Диалог.Фильтр = Фильтр; 
	Диалог.МножественныйВыбор = Ложь; 
	ВыборФайлаОткрытияФайла = новый ОписаниеОповещения("ВыборФайлаОткрытияФайла",ЭтотОбъект,новый Структура("ИмяЭлемента","ПутьКФайлуТеста"));
	Диалог.Показать(ВыборФайлаОткрытияФайла);

КонецПроцедуры

&НаКлиенте
Процедура ВыборФайлаОткрытияФайла(ВыбранныеФайлы, ДополнительныеПараметры) Экспорт
	
	Если ВыбранныеФайлы <> Неопределено И ВыбранныеФайлы.Количество() > 0 Тогда
		ИмяЭлемента = ДополнительныеПараметры.ИмяЭлемента;
		ЭтаФорма[ИмяЭлемента] = ВыбранныеФайлы[0]; 
	КонецЕсли; 
	
КонецПроцедуры

#КонецОбласти