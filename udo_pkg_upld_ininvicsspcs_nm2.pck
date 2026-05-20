create or replace package UDO_PKG_UPLD_ININVICSSPCS_NM2
is

  /* Создание тела xml */
  procedure XML_MAKE
  (
    NCOMPANY        in number,                  -- Организация
    DBEG            in date default sysdate - 31,           -- начало периода
    DEND            in date default sysdate,                -- конец периода
    bXML            out BLOB
  );

  /* Точка старта выгрузки отчетов */
  procedure START_OUT_MAKE
  (
    NCOMPANY         in number,         -- Организация
    NPROCESS         in number,         -- ID Процесса
    DBEG             in date default sysdate - 31,           -- начало периода
    DEND             in date default sysdate                -- конец периода
  );

  /* Запуск Формирование выгрузки через WEB API */
  procedure START_WEBAPI_OUT_MAKE
  (
    NCOMPANY         in number,                             -- Организация
    DBEG             in date default sysdate - 62,           -- начало периода
    DEND             in date default sysdate,               -- конец периода
    SPATTERN_DIR     in varchar2                            -- Каталог размещения файлов для выгрузки
  );

end UDO_PKG_UPLD_ININVICSSPCS_NM2;
/

create or replace package body UDO_PKG_UPLD_ININVICSSPCS_NM2
is
  SOPTIONS_CHR_LT           constant char(1) := CHR(60);          -- Символ открытия тэга
  SOPTIONS_CHR_GT           constant char(1) := CHR(62);          -- Символ закрытия тэга
  SOPTIONS_CHR_LT_TO        constant char(4) := /*'&lt;'--*/ CHR(38) || 'lt;'; -- Замена символа открытия тэга
  SOPTIONS_CHR_GT_TO        constant char(4) := /*'&gt;'--*/ CHR(38) || 'gt;'; -- Замена символа закрытия тэга
  SOPTIONS_CHR_X0A          constant char(6) := '&#x0a;';             -- Замена символа Символа переход строки

  /* Создание элемента Шапки книги с атрибутами XML */
  function NODEROW_MAKE
  (
    iCURSOR1        in integer
  )return           PKG_XMAKE.tNODE
  is
    --tATRIB          PKG_XMAKE.tATTRIBUTES;
    XROW            PKG_XMAKE.tNODE;
    XCELL1          PKG_XMAKE.tNODE;
    XCELL2          PKG_XMAKE.tNODE;
    XCELL           PKG_XMAKE.tNODE;


  begin

    /* Заголовок Таблицы */
    XCELL1 := PKG_XMAKE.CONCAT(iCURSOR1,
    PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Index','2')
                                                           ),
                                      PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                 Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                      ),
                                                                                 PKG_XMAKE.VALUE(iCURSOR1,'Номер накладной (поставщика)')
                                                                                )
                                                     )
                     ),
    PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',
                                      PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                 Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                      ),
                                                                                 PKG_XMAKE.VALUE(iCURSOR1,'Дата накладной (поставщика)')
                                                                                )
                                                     )
                     ),
    PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',
                                      PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                 Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                      ),
                                                                                 PKG_XMAKE.VALUE(iCURSOR1,'Номер СФ поставщика')
                                                                                )
                                                     )
                     ),
    PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',
                                      PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                 Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                      ),
                                                                                 PKG_XMAKE.VALUE(iCURSOR1,'Дата СФ поставщика')
                                                                                )
                                                     )
                     ),
    PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',
                                  PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                 Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                      ),
                                                                                 PKG_XMAKE.VALUE(iCURSOR1,'Номер накладной (в Парус)')
                                                                                )
                                                     )
                     ),
    PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',
                                  PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                 Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                      ),
                                                                                 PKG_XMAKE.VALUE(iCURSOR1,'Дата накладной (в Парус)')
                                                                                )
                                                     )
                     ),
    PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',
                                  PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                 Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                      ),
                                                                                 PKG_XMAKE.VALUE(iCURSOR1,'Номер приходного ордера (в Парус)')
                                                                                )
                                                     )
                     ),
    PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',
                                  PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                 Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                      ),
                                                                                 PKG_XMAKE.VALUE(iCURSOR1,'Дата приходного ордера (в Парус)')
                                                                                )
                                                     )
                     ),
    PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',
                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                 Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                      ),
                                                                                 PKG_XMAKE.VALUE(iCURSOR1,'Серия')
                                                                                )
                                                     )
                     ),
    PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',
                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                 Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                      ),
                                                                                 PKG_XMAKE.VALUE(iCURSOR1,'Наименование номенклатуры Поставщика (Не внутреннее Модуля)')
                                                                                )
                                                     )
                     ),
    PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',
                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                 Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                      ),
                                                                                 PKG_XMAKE.VALUE(iCURSOR1,'Номер номенклатуры Парус')
                                                                                )
                                                     )
                     ),
    PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',
                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                 Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                      ),
                                                                                 PKG_XMAKE.VALUE(iCURSOR1,'Наименование номенклатуры в Парус')
                                                                                )
                                                     )
                     ),
    PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',
                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                 Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                      ),
                                                                                 PKG_XMAKE.VALUE(iCURSOR1,'Код единицы измерения')
                                                                                )
                                                     )
                     ),              
    PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',
                                      PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                 Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                      ),
                                                                                 PKG_XMAKE.VALUE(iCURSOR1,'Количество')
                                                                                )
                                                     )
                     )
  );
  XCELL2 := PKG_XMAKE.CONCAT(iCURSOR1,
    PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',
                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                 Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                      ),
                                                                                 PKG_XMAKE.VALUE(iCURSOR1,'Цена без НДС')
                                                                                )
                                                     )
                     ),
    PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',
                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                 Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                      ),
                                                                                 PKG_XMAKE.VALUE(iCURSOR1,'Сумма без НДС')
                                                                                )
                                                     )
                     ),
    PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',
                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                 Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                      ),
                                                                                 PKG_XMAKE.VALUE(iCURSOR1,'Сумма НДС')
                                                                                )
                                                     )
                     ),
    PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',
                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                 Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                      ),
                                                                                 PKG_XMAKE.VALUE(iCURSOR1,'Стоимость без НДС ВСЕГО по НАКЛАДНОЙ')
                                                                                )
                                                     )
                     ),
    PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',
                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                 Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                      ),
                                                                                 PKG_XMAKE.VALUE(iCURSOR1,'ГТД Номер')
                                                                                )
                                                     )
                     ),
    PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',
                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                 Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                      ),
                                                                                 PKG_XMAKE.VALUE(iCURSOR1,'ИНН поставщика')
                                                                                )
                                                     )
                     ),
    PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',
                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                 Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                      ),
                                                                                 PKG_XMAKE.VALUE(iCURSOR1,'КПП поставщика')
                                                                                )
                                                     )
                     ),
    PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',
                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                 Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                      ),
                                                                                 PKG_XMAKE.VALUE(iCURSOR1,'Наименование поставщика')
                                                                                )
                                                     )
                     ),
    PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',
                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                 Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                      ),
                                                                                 PKG_XMAKE.VALUE(iCURSOR1,'Номер счета договор')
                                                                                )
                                                     )
                     ),
    PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',
                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                 Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                      ),
                                                                                 PKG_XMAKE.VALUE(iCURSOR1,'Заказ номер')
                                                                                )
                                                     )
                     )                                                                                                          
                    );
    XCELL := PKG_XMAKE.CONCAT(iCURSOR1,XCELL1, XCELL2);                
    XROW    := PKG_XMAKE.CONCAT(iCURSOR1, XROW, PKG_XMAKE.ELEMENT(iCURSOR1,'Row',
                                                                           PKG_XMAKE.ATTRIBUTES(iCURSOR1,Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Index','2')),
                                                                           XCELL));
    return XROW;
  end NODEROW_MAKE;

  /* Создание элемента таблицы книги с атрибутами XML */
  function NODETBL_MAKE
  (
    iCURSOR1        in integer,
    XNODE           in PKG_XMAKE.tNODE -- Подчиненный узел
    --nMACOUNT        in number           -- Количество колонок Составы затрат ведомости(код)
  )return           PKG_XMAKE.tNODE     -- Узел Элеманта Таблицы
  is
    tATRIB          PKG_XMAKE.tATTRIBUTES;
    XTBL            PKG_XMAKE.tNODE;
    XCOLUM1          PKG_XMAKE.tNODE;
    XCOLUM2          PKG_XMAKE.tNODE;
    XCOLUM          PKG_XMAKE.tNODE;

    XWO             PKG_XMAKE.tNODE;
  begin
    XCOLUM1 := PKG_XMAKE.CONCAT(iCURSOR1, PKG_XMAKE.ELEMENT(iCURSOR1,'Column',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Index','2'),
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Width','161.25')
                                                                                                 ) 
                                                          ),
                                         PKG_XMAKE.ELEMENT(iCURSOR1,'Column',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Width','150.75')
                                                                                                 ) 
                                                          ),
                                         PKG_XMAKE.ELEMENT(iCURSOR1,'Column',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Width','114')
                                                                                                 )
                                                        ),                                          
                                         PKG_XMAKE.ELEMENT(iCURSOR1,'Column',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Width','103.5')
                                                                                                ) 
                                                         ),   
                                         PKG_XMAKE.ELEMENT(iCURSOR1,'Column',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Width','139.5')
                                                                                                ) 
                                                         ),
                                         PKG_XMAKE.ELEMENT(iCURSOR1,'Column',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Width','103.5')
                                                                                                ) 
                                                         ),   
                                         PKG_XMAKE.ELEMENT(iCURSOR1,'Column',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Width','139.5')
                                                                                                ) 
                                                         ),                                                      
                                         PKG_XMAKE.ELEMENT(iCURSOR1,'Column',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Width','129')
                                                                                                ) 
                                                         ),
                                         PKG_XMAKE.ELEMENT(iCURSOR1,'Column',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Width','113.25')
                                                                                                ) 
                                                         ), 
                                         PKG_XMAKE.ELEMENT(iCURSOR1,'Column',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Width','341.25')
                                                                                                ) 
                                                         ),
                                         PKG_XMAKE.ELEMENT(iCURSOR1,'Column',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Width','113.25')
                                                                                                ) 
                                                         ), 
                                         PKG_XMAKE.ELEMENT(iCURSOR1,'Column',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Width','341.25')
                                                                                                ) 
                                                         ),                
                                         PKG_XMAKE.ELEMENT(iCURSOR1,'Column',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Width','36.75')
                                                                                                ) 
                                                         ),
                                         PKG_XMAKE.ELEMENT(iCURSOR1,'Column',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Width','60.75')
                                                                                                ) 
                                                         )
           );
     XCOLUM2 := PKG_XMAKE.CONCAT(iCURSOR1,                                                    
                                         PKG_XMAKE.ELEMENT(iCURSOR1,'Column',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Width','72')
                                                                                                ) 
                                                         ),
                                         PKG_XMAKE.ELEMENT(iCURSOR1,'Column',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Width','78.75')
                                                                                                ) 
                                                         ),
                                         PKG_XMAKE.ELEMENT(iCURSOR1,'Column',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Width','59.25')
                                                                                                ) 
                                                         ), 
                                        PKG_XMAKE.ELEMENT(iCURSOR1,'Column',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Width','212.25')
                                                                                                ) 
                                                         ), 
                                        PKG_XMAKE.ELEMENT(iCURSOR1,'Column',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Width','57')
                                                                                                ) 
                                                         ), 
                                        PKG_XMAKE.ELEMENT(iCURSOR1,'Column',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Width','85.5')
                                                                                                ) 
                                                         ), 
                                        PKG_XMAKE.ELEMENT(iCURSOR1,'Column',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Width','84')
                                                                                                ) 
                                                         ), 
                                        PKG_XMAKE.ELEMENT(iCURSOR1,'Column',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Width','138.75')
                                                                                                ) 
                                                         ), 
                                       PKG_XMAKE.ELEMENT(iCURSOR1,'Column',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Width','108')
                                                                                                ) 
                                                         ), 
                                       PKG_XMAKE.ELEMENT(iCURSOR1,'Column',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Width','64.5')
                                                                                                ) 
                                                         )                                                                                                                                                                                                                                    
                              );
    XCOLUM := PKG_XMAKE.CONCAT(iCURSOR1,XCOLUM1,XCOLUM2);                          
    /* Параметры листа */
    XWO := PKG_XMAKE.ELEMENT(iCURSOR1,'WorksheetOptions', PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'xmlns','urn:schemas-microsoft-com:office:excel')

                                                                              ),
                                      PKG_XMAKE.ELEMENT(iCURSOR1,'ProtectObjects', PKG_XMAKE.VALUE(iCURSOR1,'False')),
                                      PKG_XMAKE.ELEMENT(iCURSOR1,'ProtectScenarios', PKG_XMAKE.VALUE(iCURSOR1,'False'))
                            );

    XTBL    := PKG_XMAKE.ELEMENT(iCURSOR1,'Table',XCOLUM, XNODE);
   /* <Column ss:AutoFitWidth="0" ss:Width="57.75"/>
   <Column ss:Index="8" ss:AutoFitWidth="0" ss:Width="84.75"/>
   <Column ss:Width="83.25" ss:Span="1"/>
   <Column ss:Index="11" ss:Width="69" ss:Span="6"/>
   <Column ss:Index="18" ss:Width="50.25"/>
  */
    return PKG_XMAKE.CONCAT(iCURSOR1,XTBL,XWO);
  end NODETBL_MAKE;

  /* Создание элемента Листа книги с атрибутами XML */
  function WORKSHEET_MAKE
  (
    iCURSOR1        in integer,
    SNAMEL          in varchar2,        -- Наименование листа
    XNODE           PKG_XMAKE.tNODE     -- Подчиненный узел

  )return           PKG_XMAKE.tNODE
  is
    XWS             PKG_XMAKE.tNODE;
  begin
   XWS    := PKG_XMAKE.ELEMENT(iCURSOR1,
                               'Worksheet',
                               PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                    PKG_XMAKE.ATTRIBUTE(iCURSOR1, 'ss:Name', SNAMEL)
                                                    ),
                               XNODE
                              );
   return XWS;
  end WORKSHEET_MAKE;

  /* Шаблон стилей */
  function STYLE_MAKE
  (
    iCURSOR1        in integer
  )return           PKG_XMAKE.tNODE
  is
    bSTYL           PKG_STD.tLSTRING := '<Style ss:ID="Default" ss:Name="Normal"><Alignment ss:Vertical="Bottom"/><Borders/><Font ss:FontName="Calibri" x:CharSet="204" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/><Interior/><NumberFormat/><Protection/></Style><Style ss:ID="s62"><NumberFormat ss:Format="Short Date"/></Style><Style ss:ID="s63"><NumberFormat ss:Format="@"/></Style><Style ss:ID="s64"><NumberFormat ss:Format="#,##0.000"/></Style><Style ss:ID="s65"><NumberFormat ss:Format="Standard"/></Style>';
      XSTYLES         PKG_XMAKE.tNODE;
  begin

   XSTYLES := PKG_XMAKE.ELEMENT(iCURSOR1,'Styles',PKG_XMAKE.VALUE(iCURSOR1, bSTYL));
   return XSTYLES;
  end STYLE_MAKE;

  /* Создание корневого элемента с атрибутами XML  */
  function ROOTELEMENTATRIB_MAKE
  (
    iCURSOR1        in integer,
    XNODE           PKG_XMAKE.tNODE     -- Подчиненный узел
  )return           PKG_XMAKE.tNODE
  is
    tATRIB          PKG_XMAKE.tATTRIBUTES;
    XROOT           PKG_XMAKE.tNODE;
  begin
   tATRIB := PKG_XMAKE.ATTRIBUTES(iCURSOR1,
   PKG_XMAKE.ATTRIBUTE(iCURSOR1, 'xmlns', 'urn:schemas-microsoft-com:office:spreadsheet'),
   PKG_XMAKE.ATTRIBUTE(iCURSOR1, 'xmlns:o', 'urn:schemas-microsoft-com:office:office'),
   PKG_XMAKE.ATTRIBUTE(iCURSOR1, 'xmlns:x', 'urn:schemas-microsoft-com:office:excel'),
   PKG_XMAKE.ATTRIBUTE(iCURSOR1, 'xmlns:ss', 'urn:schemas-microsoft-com:office:spreadsheet'),
   PKG_XMAKE.ATTRIBUTE(iCURSOR1, 'xmlns:html', 'http://www.w3.org/TR/REC-html40'));

   XROOT := PKG_XMAKE.ELEMENT(iCURSOR1,'Workbook',tATRIB, XNODE);
   return XROOT;
  end ROOTELEMENTATRIB_MAKE;

  /* Формирование данных */
  procedure DATA_MAKE
  (
    iCURSOR1         in integer,
    nCOMPANY         in number,         -- Организация
    DBEG             in date default sysdate - 31,           -- начало периода
    DEND             in date default sysdate,                -- конец периода
    xDATA             out PKG_XMAKE.tNODE    -- Узел Данных Ведомости ФОВ
  )
  is
    XROWATRIB        PKG_XMAKE.tATTRIBUTES;    --
    XVAL_ROW         PKG_XMAKE.tNODE;    --
    
    N                PKG_STD.tNUMBER := 0;
    C                PKG_STD.tNUMBER := 0;
    NQUANT_          PKG_STD.tQUANT := 0;
    NSUMM_           PKG_STD.tSUMM := 0;
    NSUMM_NDS_       PKG_STD.tSUMM := 0;
    NSUMMTAX_        PKG_STD.tSUMM := 0;
    NQUANT           PKG_STD.tQUANT := 0;
    NSUMM            PKG_STD.tSUMM := 0;
    NSUMM_NDS        PKG_STD.tSUMM := 0;
    NSUMMTAX         PKG_STD.tSUMM := 0;
   
  begin
    for data_ in (select TRIM(PO.INDOCPREF)||get_options_def_str(nFLAG_SMART => 0,sCODE => 'PrefSymb')||TRIM(PO.INDOCNUMB) PO_NUMB,
                         to_char(PO.INDOCDATE,'dd.mm.yyyy') PO_DOC_DATE,
                         N.EXT_NUMB, 
                         to_char(N.EXT_DATE,'dd.mm.yyyy') EXT_DATE,
                         VSF.ACC_NUMB,
                         to_char(VSF.ACC_DATE,'dd.mm.yyyy') ACC_DATE, 
                         DT.DOCCODE||' '||TRIM(N.PREF)||get_options_def_str(nFLAG_SMART => 0,sCODE => 'PrefSymb')||TRIM(N.NUMB) N_NUMB,
                         to_char(N.DOC_DATE,'dd.mm.yyyy') N_DOC_DATE,
                         NOM.NOMEN_CODE,
                         NOM.NOMEN_NAME,
                         replace(replace(NS.original_name,'<',''),'>','') original_name,
                         --NS.Original_Name,
                         NS.Sernumb,
                         U.CODE_OKEI,
                        -- (select count(NS_C.RN)from ININVOICESSPC   NS_C where NS_C.PRN = NS.RN) NSC_COUNT,
                         (select count(PO_C.RN)from INORDERSPECSCLC PO_C where PO_C.PRN = PO_SP.RN) NSC_COUNT,
                         NS.RN NS_RN,
                         --NS.QUANT,
                         NS.PRICE,
                         PO_SP.RN PO_SP_RN,
                         PO_SP.FACTQUANT QUANT,
                         --PO_SP.ACC_PRICE,
                         PO_SP.FACTSUM/PO_SP.FACTQUANT  ACC_PRICE,
                         PO_SP.FACTSUM SUMM,
                         PO_SP.FACTSUMNDS SUMM_NDS,
                         PO_SP.FACTSUMTAX SUMMTAX,
                         /*NS.SUMM,
                         NS.SUMM_NDS,
                         NS.SUMMTAX,*/
                         /*(NS_C.QUANT_PLAN * NS.PRICE) SUMM,
                         ((NS.SUMM_NDS/NS.QUANT)*NS_C.QUANT_PLAN) SUMM_NDS,
                         ((NS.SUMMTAX/NS.QUANT)*NS_C.QUANT_PLAN) SUMMTAX,*/
                         NS.GTD,
                         A.AGNIDNUMB   INN,
                         A.REASON_CODE KPP,
                         A.AGNNAME,
                         P.EXT_NUMB EXT_NUMB_VSO,
                         to_char(P.REG_DATE,'dd.mm.yyyy') REG_DATE,
                         udo_f_get_doc_prop_val_num(SPROPERTY => 'НомерПП',SUNITCODE => 'IncomingOrdersSpecs',NDOCUMET => PO_SP.RN) NPP
                  from ININVOICES N,
                       ININVOICESSPECS NS,
                       --ININVOICESSPC   NS_C,
                       DOCTYPES DT,
                       DICNOMNS NOM,
                       AGNLIST  A,
                       PAYACCIN P,
                       
                       DICACCFI VSF,
                       
                       DICMUNTS U,
                       INORDERS PO,
                       INORDERSPECS PO_SP
                 where /*N.RN = 19486173
                   and*/ NS.PRN = N.RN
                   --and NS_C.PRN = NS.RN
                   --AND NS_C.FACEACCOUNT = F.RN
                   and N.DOCTYPE = DT.RN
                   and PO_SP.PRN = PO.RN 
                   and PO_SP.NOMMODIF = NS.MODIF
                   and cmp_vc2(PO_SP.Sernumb,NS.Sernumb) = 1
                   and cmp_num(PO_SP.ARTICLE,NS.ARTICLE) = 1
                   and NS.NOMEN = NOM.RN
                   and NOM.umeas_main = u.rn
                   and N.AGENT = A.RN
                   and f_doclinks_link_in_doc(sOUT_UNITCODE => 'IncomingInvoices',nOUT_DOCUMENT => N.RN,sIN_UNITCODE => 'PaymentAccountsIn') = P.RN(+)
                   
                   and f_doclinks_link_out_doc(sIN_UNITCODE => 'IncomingInvoices',nIN_DOCUMENT => N.RN,sOUT_UNITCODE => 'AccountFactInput') = VSF.RN(+)
                   
                   and f_doclinks_link_out_doc(sIN_UNITCODE => 'IncomingInvoices',nIN_DOCUMENT => N.RN,sOUT_UNITCODE => 'IncomingOrders') = PO.RN
                   
                   and N.doc_date between DBEG and DEND
                   --and po.rn = 57277413
                   and NS.original_name is not null
                   and NS.sernumb is not null
                   and N.company = nCOMPANY
                   order by PO.INDOCTYPE, PO.INDOCPREF, PO.INDOCNUMB, PO.INDOCDATE,
                   udo_f_get_doc_prop_val_num(SPROPERTY => 'НомерПП',SUNITCODE => 'IncomingOrdersSpecs',NDOCUMET => PO_SP.RN) asc )loop
           N := N +1;
          nQUANT_ := data_.QUANT;
          NSUMM_     := data_.SUMM;
          NSUMM_NDS_ := data_.SUMM_NDS;
          NSUMMTAX_  := data_.SUMMTAX;

          for CLC in (select NVL(NS_C.QUANT_PLAN,0) QUANT_PLAN, 
                             F.NUMB 
                       from
                       --ININVOICESSPC   NS_C,
                       INORDERSPECSCLC   NS_C,
                       FACEACC         F
                      where NS_C.PRN = data_.PO_SP_RN--data_.NS_RN
                       AND NS_C.FACEACCOUNT = F.RN)loop
          C := C + 1;
          nQUANT_ :=nQUANT_ - CLC.QUANT_PLAN;
           
          if data_.NSC_COUNT = C and nQUANT_ > 0 then 
            nQUANT   := CLC.QUANT_PLAN + nQUANT_;
            --nSUMM     := CLC.QUANT_PLAN * data_.PRICE;
            --nSUMM     := ((data_.SUMM/data_.QUANT)*CLC.QUANT_PLAN) + ((data_.SUMM/data_.QUANT)*nQUANT_);
          --  nSUMM     := round((data_.ACC_PRICE*CLC.QUANT_PLAN) + (data_.ACC_PRICE*nQUANT_), 2);
          --  nSUMM_NDS := round(((data_.SUMM_NDS/data_.QUANT)*CLC.QUANT_PLAN) + ((data_.SUMM_NDS/data_.QUANT)*nQUANT_),2);
        --    nSUMMTAX  := round(((data_.SUMMTAX/data_.QUANT)*CLC.QUANT_PLAN)+ ((data_.SUMMTAX/data_.QUANT)*nQUANT_),2);
          else
            nQUANT   := CLC.QUANT_PLAN;
            --nSUMM     := CLC.QUANT_PLAN * data_.PRICE;
            --nSUMM     := ((data_.SUMM/data_.QUANT)*CLC.QUANT_PLAN) + ((data_.SUMM/data_.QUANT)*nQUANT_);
           -- nSUMM     := round((data_.ACC_PRICE*CLC.QUANT_PLAN),2);
          --  nSUMM_NDS := round(((data_.SUMM_NDS/data_.QUANT)*CLC.QUANT_PLAN),2);
         --   nSUMMTAX  := round(((data_.SUMMTAX/data_.QUANT)*CLC.QUANT_PLAN),2);
          end if;  
            nSUMM_ :=nSUMM_ - (data_.ACC_PRICE*CLC.QUANT_PLAN);
           
          if (data_.NSC_COUNT = C and  nSUMM_ < 0.03) or (data_.NSC_COUNT = C and nSUMM_ > 0) then 
           --nQUANT   := CLC.QUANT_PLAN + nQUANT_;
            nSUMM     := (data_.ACC_PRICE*CLC.QUANT_PLAN) + nSUMM_;
           -- nSUMM_NDS := round(((data_.SUMM_NDS/data_.QUANT)*CLC.QUANT_PLAN) + ((data_.SUMM_NDS/data_.QUANT)*nQUANT_),2);
           -- nSUMMTAX  := round(((data_.SUMMTAX/data_.QUANT)*CLC.QUANT_PLAN)+ ((data_.SUMMTAX/data_.QUANT)*nQUANT_),2);
          else
            --nQUANT   := CLC.QUANT_PLAN;
            --nSUMM     := CLC.QUANT_PLAN * data_.PRICE;
            --nSUMM     := ((data_.SUMM/data_.QUANT)*CLC.QUANT_PLAN) + ((data_.SUMM/data_.QUANT)*nQUANT_);
            nSUMM     := (data_.ACC_PRICE*CLC.QUANT_PLAN);
            --nSUMM_NDS := round(((data_.SUMM_NDS/data_.QUANT)*CLC.QUANT_PLAN),2);
            --nSUMMTAX  := round(((data_.SUMMTAX/data_.QUANT)*CLC.QUANT_PLAN),2);
          end if;              
          nSUMM_NDS_ :=nSUMM_NDS_ - ((data_.SUMM_NDS/data_.QUANT)*CLC.QUANT_PLAN);
           
          if (data_.NSC_COUNT = C and nSUMM_NDS_ < 0.03) or (data_.NSC_COUNT = C and nSUMM_NDS_ > 0) then 
          
            nSUMM_NDS := ((data_.SUMM_NDS/data_.QUANT)*CLC.QUANT_PLAN) + nSUMM_NDS_;
           -- nSUMMTAX  := round(((data_.SUMMTAX/data_.QUANT)*CLC.QUANT_PLAN)+ ((data_.SUMMTAX/data_.QUANT)*nQUANT_),2);
          else
            nSUMM_NDS := ((data_.SUMM_NDS/data_.QUANT)*CLC.QUANT_PLAN);
            --nSUMMTAX  := round(((data_.SUMMTAX/data_.QUANT)*CLC.QUANT_PLAN),2);
          end if;              
          nSUMMTAX_ :=nSUMMTAX_ - ((data_.SUMMTAX/data_.QUANT)*CLC.QUANT_PLAN);
           
          if (data_.NSC_COUNT = C and nSUMMTAX_ < 0.03) or (data_.NSC_COUNT = C and nSUMMTAX_ > 0) then 
            nSUMMTAX  :=((data_.SUMMTAX/data_.QUANT)*CLC.QUANT_PLAN)+ nSUMMTAX_;
          else
            nSUMMTAX  := ((data_.SUMMTAX/data_.QUANT)*CLC.QUANT_PLAN);
          end if;            
          /* if n = 1 then
             XROWATRIB := PKG_XMAKE.ATTRIBUTES(iCURSOR1,Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Index','2'));
           else
              XROWATRIB := null;
           end if;*/

        if nQUANT != 0 then
           XVAL_ROW := PKG_XMAKE.CONCAT(iCURSOR1,XVAL_ROW,
                        PKG_XMAKE.ELEMENT(iCURSOR1,'Row',
                                                                 PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     --Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Index','2'),
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:StyleID','s63')
                                                                                                         ),
                                                                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                                                                    ),
                                                                                                                                PKG_XMAKE.VALUE(iCURSOR1,data_.ns_rn)
                                                                                                                                )
                                                                                                    )
                                                                    ),
                                                                  PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     --Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Index','2'),
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:StyleID','s63')
                                                                                                         ),
                                                                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                                                                    ),
                                                                                                                                PKG_XMAKE.VALUE(iCURSOR1,data_.ext_numb)
                                                                                                                                )
                                                                                                    )
                                                                    ),  
           /*XVAL_ROW := */                                       PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:StyleID','s63')
                                                                                                         ),
                                                                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                                                                    ),
                                                                                                                                PKG_XMAKE.VALUE(iCURSOR1,data_.ext_date)
                                                                                                                                )
                                                                                                    )
                                                                    ),
           /*XVAL_ROW := */                                       PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:StyleID','s63')
                                                                                                         ),
                                                                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                                                                    ),
                                                                                                                                PKG_XMAKE.VALUE(iCURSOR1,data_.acc_numb)
                                                                                                                                )
                                                                                                    )
                                                                    ),
            /*XVAL_ROW := */                                      PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:StyleID','s63')
                                                                                                         ),
                                                                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                                                                    ),
                                                                                                                                PKG_XMAKE.VALUE(iCURSOR1,data_.acc_date)
                                                                                                                                )
                                                                                                    )
                                                                    ),
            /*XVAL_ROW :=  */                                     PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:StyleID','s63')
                                                                                                         ),
                                                                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                                                                    ),
                                                                                                                                PKG_XMAKE.VALUE(iCURSOR1,data_.n_numb)
                                                                                                                                )
                                                                                                    )
                                                                    ),
            /*XVAL_ROW :=  */                                     PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:StyleID','s63')
                                                                                                         ),
                                                                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                                                                    ),
                                                                                                                                PKG_XMAKE.VALUE(iCURSOR1,data_.n_doc_date)
                                                                                                                                )
                                                                                                    )
                                                                    ),
            /*XVAL_ROW :=  */                                     PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:StyleID','s63')
                                                                                                         ),
                                                                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                                                                    ),
                                                                                                                                PKG_XMAKE.VALUE(iCURSOR1,data_.po_numb)
                                                                                                                                )
                                                                                                    )
                                                                    ),
            /*XVAL_ROW :=  */                                     PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:StyleID','s63')
                                                                                                         ),
                                                                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                                                                    ),
                                                                                                                                PKG_XMAKE.VALUE(iCURSOR1,data_.po_doc_date)
                                                                                                                                )
                                                                                                    )
                                                                    ),                                                                    
            /*XVAL_ROW :=  */                                     PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:StyleID','s63')
                                                                                                         ),
                                                                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                                                                    ),
                                                                                                                                PKG_XMAKE.VALUE(iCURSOR1,data_.sernumb)
                                                                                                                                )
                                                                                                    )
                                                                    ),
            /*XVAL_ROW :=  */                                     PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:StyleID','s63')
                                                                                                         ),
                                                                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                                                                    ),
                                                                                                                                PKG_XMAKE.VALUE(iCURSOR1,data_.original_name)
                                                                                                                                )
                                                                                                    )
                                                                    ),
            /*XVAL_ROW :=  */                                     PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:StyleID','s63')
                                                                                                         ),
                                                                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                                                                    ),
                                                                                                                                PKG_XMAKE.VALUE(iCURSOR1,data_.nomen_code)
                                                                                                                                )
                                                                                                    )
                                                                    ),
            /*XVAL_ROW :=  */                                     PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:StyleID','s63')
                                                                                                         ),
                                                                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                                                                    ),
                                                                                                                                PKG_XMAKE.VALUE(iCURSOR1,data_.nomen_name)
                                                                                                                                )
                                                                                                    )
                                                                    ),                                                                    
            /*XVAL_ROW :=  */                                     PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:StyleID','s63')
                                                                                                         ),
                                                                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                                                                    ),
                                                                                                                                PKG_XMAKE.VALUE(iCURSOR1,data_.code_okei)
                                                                                                                                )
                                                                                                    )
                                                                    ),  
            /*XVAL_ROW :=  */                                     PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:StyleID','s63')
                                                                                                         ),
                                                                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                                                                    ),
                                                                                                                                PKG_XMAKE.VALUE(iCURSOR1,nquant)
                                                                                                                                )
                                                                                                    )
                                                                    ),                   
            /*XVAL_ROW :=  */                                     PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:StyleID','s63')
                                                                                                         ),
                                                                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                                                                    ),
                                                                                                                                PKG_XMAKE.VALUE(iCURSOR1,round(data_.ACC_PRICE,2))
                                                                                                                                )
                                                                                                    )
                                                                    ),
            /*XVAL_ROW :=  */                                     PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:StyleID','s63')
                                                                                                         ),
                                                                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                                                                    ),
                                                                                                                                PKG_XMAKE.VALUE(iCURSOR1,round(nsumm,2))
                                                                                                                                )
                                                                                                    )
                                                                    ),
            /*XVAL_ROW :=  */                                     PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:StyleID','s63')
                                                                                                         ),
                                                                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                                                                    ),
                                                                                                                                PKG_XMAKE.VALUE(iCURSOR1,round(nsumm_nds,2))
                                                                                                                                )
                                                                                                    )
                                                                    ),
            /*XVAL_ROW :=  */                                     PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:StyleID','s63')
                                                                                                         ),
                                                                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                                                                    ),
                                                                                                                                PKG_XMAKE.VALUE(iCURSOR1,round(nsummtax,2))
                                                                                                                                )
                                                                                                    )
                                                                    ),
            /*XVAL_ROW :=  */                                     PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:StyleID','s63')
                                                                                                         ),
                                                                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                                                                    ),
                                                                                                                                PKG_XMAKE.VALUE(iCURSOR1,data_.gtd)
                                                                                                                                )
                                                                                                    )
                                                                    ),
            /*XVAL_ROW :=  */                                     PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:StyleID','s63')
                                                                                                         ),
                                                                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                                                                    ),
                                                                                                                                PKG_XMAKE.VALUE(iCURSOR1,data_.inn)
                                                                                                                                )
                                                                                                    )
                                                                    ),
            /*XVAL_ROW :=  */                                     PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:StyleID','s63')
                                                                                                         ),
                                                                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                                                                    ),
                                                                                                                                PKG_XMAKE.VALUE(iCURSOR1,data_.kpp)
                                                                                                                                )
                                                                                                    )
                                                                    ),
            /*XVAL_ROW :=  */                                     PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:StyleID','s63')
                                                                                                         ),
                                                                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                                                                    ),
                                                                                                                                PKG_XMAKE.VALUE(iCURSOR1,data_.agnname)
                                                                                                                                )
                                                                                                    )
                                                                    ),
            /*XVAL_ROW :=  */                                     PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:StyleID','s63')
                                                                                                         ),
                                                                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                                                                    ),
                                                                                                                                PKG_XMAKE.VALUE(iCURSOR1,data_.ext_numb_vso)
                                                                                                                                )
                                                                                                    )
                                                                    ),
            /*XVAL_ROW :=  */                                     PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:StyleID','s63')
                                                                                                         ),
                                                                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                                                                    ),
                                                                                                                                PKG_XMAKE.VALUE(iCURSOR1,CLC.NUMB)
                                                                                                                                )
                                                                                                    )
                                                                    )
                                 )
                                 
                                 );
    end if;
    end loop;
    C         := 0;
    nQUANT_   := 0;
    NSUMM_     := 0;
    NSUMM_NDS_ := 0;
    NSUMMTAX_  := 0;

    nQUANT    := 0;
    nSUMM     := 0;
    nSUMM_NDS := 0;
    nSUMMTAX  := 0;

    end loop;
    xDATA := XVAL_ROW; --PKG_XMAKE.CONCAT(iCURSOR1, XVAL_ROW);
  end DATA_MAKE;

  /* Создание тела xml */
  procedure XML_MAKE
  (
    NCOMPANY        in number,                  -- Организация
    DBEG            in date default sysdate - 31,           -- начало периода
    DEND            in date default sysdate,                -- конец периода
    bXML            out BLOB
  )
  is
    iCURSOR           integer;
    sLOBDATA          PKG_STD.tLSTRING;
    cLOBDATA          clob;
    XROOT_EL          PKG_XMAKE.tNODE;
    XSTYLES           PKG_XMAKE.tNODE;
    XWORKSHEET        PKG_XMAKE.tNODE;
    XTBL              PKG_XMAKE.tNODE;
    XROW              PKG_XMAKE.tNODE;
    XROOT             PKG_XMAKE.tNODE;
    XRD               PKG_XMAKE.tNODE;
    XSW               PKG_XMAKE.tNODE;
    xDATA             PKG_XMAKE.tNODE;
  begin
    iCURSOR := PKG_XMAKE.OPEN_CURSOR();
      /* Создание элемента Шапки книги с атрибутами XML */
      XROW     := NODEROW_MAKE(iCURSOR1 => iCURSOR);
      /* Данные отчета */
      DATA_MAKE(iCURSOR1         =>iCURSOR,
                nCOMPANY         => nCOMPANY,
                DBEG             => DBEG,
                DEND             => DEND,
                xDATA            => xDATA    -- Узел Данных Ведомости ФОВ
                );
     -- XROW := PKG_XMAKE.ELEMENT(iCURSOR,XROW,xDATA);

      XRD := PKG_XMAKE.CONCAT(iCURSOR,XROW,xDATA);
      /* Создание элемента таблицы книги с атрибутами XML */
      XTBL     := NODETBL_MAKE(iCURSOR,XRD/*,nMACOUNT*/);
      /* Создание элемента Листа книги с атрибутами XML */
      XWORKSHEET := WORKSHEET_MAKE(iCURSOR,'ВыгрузкаНоменклатуры2', XTBL);
      /* Стили ячеек */
      XSTYLES  := STYLE_MAKE(iCURSOR);
      XSW := PKG_XMAKE.CONCAT(iCURSOR,XSTYLES,XWORKSHEET);
      /* Корневой узел */
      XROOT := ROOTELEMENTATRIB_MAKE(iCURSOR,XSW);
      XROOT := PKG_XMAKE.CONCAT(iCURSOR,PKG_XMAKE.ELEMENT(iCURSOR,'?mso-application progid="Excel.Sheet"?'),XROOT);
    cLOBDATA := /*replace(*/replace(replace(replace(PKG_XMAKE.SERIALIZE_TO_CLOB/*SERIALIZE_TO_VARCHAR*/(iCURSOR => iCURSOR,
                                                                         iTYPE   => PKG_XMAKE.DOCUMENT_,
                                                                         rNODE   => XROOT,
                                                                         rHEADER => PKG_XHEADER.WRAP_ALL(PKG_XHEADER.VERSION_1_0_)),
                                          SOPTIONS_CHR_GT_TO,
                                          SOPTIONS_CHR_GT),
                                  SOPTIONS_CHR_LT_TO,
                                  SOPTIONS_CHR_LT),
                         /* SOPTIONS_CHR_X0A,
                          CR),*/
                          '"Excel.Sheet"?/',
                          '"Excel.Sheet"?');
    PKG_XMAKE.CLOSE_CURSOR(iCURSOR => iCURSOR);
    bXML :=clob2blob(cLOBDATA,PKG_CHARSET.CHARSET_UTF_);
  end XML_MAKE;

  /* Формирование имени файла */
  function FILENAME_MAKE
  (
    sPREF           in varchar2,        -- Префикс ведомости
    DBEG            in date default sysdate - 31,           -- начало периода
    DEND            in date default sysdate                -- конец периода
  )return           varchar2
  is
    SREZ            PKG_STD.tSTRING;
  begin
    SREZ := sPREF||'_'||to_char(DBEG,'yyyymmdd')||'_'||to_char(DEND,'yyyymmdd')||'.xls';
    return sREZ;
  end FILENAME_MAKE;

  /* Точка старта выгрузки отчетов */
  procedure START_OUT_MAKE
  (
    NCOMPANY         in number,         -- Организация
    NPROCESS         in number,         -- ID Процесса
    DBEG             in date default sysdate - 31,           -- начало периода
    DEND             in date default sysdate                -- конец периода
  )
  is
    nCOUNT_WS        PKG_STD.tNUMBER;
    BDATA            blob;
    cFILENAME        PKG_STD.tSTRING;
  begin
    /* Создание тела xml */
    XML_MAKE(NCOMPANY, DBEG, DEND, BDATA);
      /* Формирование имени файла */
 cFILENAME := FILENAME_MAKE
  (
    sPREF           => 'Номенклатура',
    DBEG            => DBEG,
    DEND            => DEND
  );
    P_FILE_BUFFER_INSERT(nIDENT => NPROCESS, cFILENAME => cFILENAME, cDATA => null, bLOBDATA => BDATA);
    update FILE_BUFFER B set B.RUN_CMD = 'excel.exe %1' where B.IDENT = NPROCESS and B.FILENAME = cFILENAME;

   end START_OUT_MAKE;

  /* Отправка запросов */
  procedure SEND_PACKGE
  (
    nCOMPANY         in number,                                     -- Организация
    SEXSSERVICE      in varchar2,                                   -- Мнемокод сервиса для обработки
    SEXSSERVICEFN    in varchar2,                                   -- Мнемокод функции обмена
    SFILENAME        in varchar2,                                   -- Имя файла для выгрузки
    SFILEPATCH       in varchar2,                                   -- Путь куда выгружать файл
    BMSG             in blob                                        -- Загружаемый XML с данными запроса в СКУД;
  )
  is
    NQ               PKG_STD.TREF;
    OPTS             PKG_EXS.TOPTIONS;
    AGENTOPTIONS     PKG_EXS.TOPTIONS;
    HDR_HEADERS      PKG_EXS.TOPTIONS;
    NEXSSERVICE      PKG_STD.TREF;       -- Рег. номер сервиса обработки
    REXSSERVICE      EXSSERVICE%rowtype; -- Запись сервиса обмена
  begin
  /*\* Найдем функцию сервиса обработки *\
  FIND_EXSSERVICE_CODE(NFLAG_SMART => 1, NFLAG_OPTION => 0, SCODE => SEXSSERVICE, NRN => NEXSSERVICE);

  \* Считывание записи сервиса обмена *\
  REXSSERVICE := GET_EXSSERVICE_ID(NFLAG_SMART => 0, NRN => NEXSSERVICE);   */

  /* регистрация имени файла в параметрах отправки */
  if SFILENAME is not null then
    /* Формирование дополнительных параметров отправки */
    PKG_EXS.OPTIONS_SET(OPTIONS => OPTS,
                        SCODE   => 'FILE_PATCH',
                        SVALUE  => SFILENAME);
  end if;

  if SFILENAME is not null then
    /* Формирование дополнительных параметров отправки */
    PKG_EXS.OPTIONS_SET(OPTIONS => OPTS,
                        SCODE   => 'FILE_NAME',
                        SVALUE  => SFILEPATCH);
  end if;

   PKG_EXS.OPTIONS_SET(OPTIONS => OPTS,
                        SCODE   => 'SEXSSERVICEFN',
                        SVALUE  => SEXSSERVICEFN);

  --Content-Length
  PKG_EXS.OPTIONS_SET(OPTIONS => HDR_HEADERS,
                      SCODE   => pkg_exs.SHTP_HDR_CNT_LENGTH,
                      SVALUE  => dbms_lob.getlength(BMSG));

  --Content-Type
  PKG_EXS.OPTIONS_SET(OPTIONS => HDR_HEADERS,
                      SCODE   => pkg_exs.SHTP_HDR_CNT_TP,
                      SVALUE  => pkg_exs.SHTP_HDR_CNT_TP_XML
                     );

  PKG_EXS.OPTIONS_SET(OPTIONS => OPTS,
                      SCODE   => pkg_exs.SMSG_OPTION_CODE_HEADERS,
                      SVALUE  => PKG_EXS.OPTIONS_SERIALIZE(OPTIONS => HDR_HEADERS,
                                                           BROOT   => false));


  PKG_EXS.QUEUE_PUT(SEXSSERVICE   => SEXSSERVICE,    --'СКУД',
                    SEXSSERVICEFN => SEXSSERVICEFN,  --'SendMessage',
                    BMSG          => BMSG,
                    NLNK_COMPANY  => nCOMPANY,
                    SOPTIONS      => PKG_EXS.OPTIONS_SERIALIZE(OPTIONS => OPTS),
                    NNEW_EXSQUEUE => NQ);
  end SEND_PACKGE;

  /* Запуск Формирование выгрузки через WEB API */
  procedure START_WEBAPI_OUT_MAKE
  (
    NCOMPANY         in number,                             -- Организация
    DBEG             in date default sysdate - 62,           -- начало периода
    DEND             in date default sysdate,               -- конец периода
    SPATTERN_DIR     in varchar2                            -- Каталог размещения файлов для выгрузки
  )
  is
    BDATA                     blob;                                  -- Данные файла
    SFILENAME                 PKG_STD.tSTRING;                       -- Имя файла
    NBUFFER_SIZE              constant PKG_STD.TNUMBER := 32767;                                               -- Размер буфера данных для загрузки ответа
    SSERVER                   constant PKG_STD.TSTRING := 'http://10.7.19.35:8080/ReadFiles/uploadFile?';      -- Адрес тестоого сервиса для разбора PDF и поиска страниц в нём
    SSERVER_PROD              constant PKG_STD.TSTRING := /*'https://webparus.module.ru/ReadFiles/uploadFile?';---*/'http://10.21.136.209:8080/ReadFiles/uploadFile?';   -- Адрес рабочего сервиса для разбора PDF и поиска страниц в нём
    SPATTERN_QUERY_DIR        constant PKG_STD.TSTRING := '%DIR%';                                             -- Шаблон для имени файла в запросе к серверу
    SPATTERN_QUERY_IDENT      constant PKG_STD.TSTRING := '%IDENT%';                                           -- Шаблон для имени файла в запросе к серверу
    SPATTERN_QUERY_FIND       constant PKG_STD.TSTRING := 'SDIR=' || SPATTERN_QUERY_DIR
                                                       || '&IDENT=' || SPATTERN_QUERY_IDENT;                  -- Шаблон имени файла с данными банковской выписки
    HTTP_REQ                  UTL_HTTP.REQ;                                                                    -- HTTP-запрос
    HTTP_RESP                 UTL_HTTP.RESP;                                                                   -- HTTP-ответ
    SURL                      PKG_STD.TLSTRING;                                                                -- URL для запроса
    BBUFFER                   raw(32767); -- Буфер для порции данных ответа
    BRESP                     blob;                                                                            -- Полный ответ
    SMSG                      PKG_STD.TSTRING;                                                                 -- Сообщение о статусе обработки текущего доумента
    NIDENT                    PKG_STD.tSTRING;          -- Идентификатор отмеченных записей

    NPROCESS                  PKG_STD.tREF;
    cFILENAME                 PKG_STD.tSTRING;
    NEXSQUEUE                 PKG_STD.tREF;
    OPTS                      PKG_EXS.TOPTIONS;
    HDR_HEADERS      PKG_EXS.TOPTIONS;

  begin
  --Z:\UPLOAD\1c
    /* Создание тела xml */
    XML_MAKE(NCOMPANY, DBEG, DEND, BDATA);
    SFILENAME := 'spr_32_V2.xls'; /*FILENAME_MAKE
  (
    sPREF           => 'Номенклатура',
    DBEG            => DBEG,
    DEND            => DEND
  );*/

    /*\* Отправка запросов *\
    SEND_PACKGE(nCOMPANY      => nCOMPANY,
                SEXSSERVICE   => sDEF_SEXSSERVICE,
                SEXSSERVICEFN => sDEF_SEXSSERVICEFN,
                SFILENAME     => SFILENAME,
                SFILEPATCH    => SPATTERN_DIR,
                BMSG          => BDATA);
*/
   NPROCESS := gen_id;
   cFILENAME := SPATTERN_DIR||'/'||SFILENAME;
    P_FILE_BUFFER_INSERT(nIDENT => NPROCESS, cFILENAME => cFILENAME, cDATA => null, bLOBDATA => BDATA);
    commit;
   begin
      /* Формирование дополнительных параметров отправки */
    PKG_EXS.OPTIONS_SET(OPTIONS => OPTS,
                        SCODE   => 'FILE_NAME',
                        SVALUE  => cFILENAME);
    PKG_EXS.OPTIONS_SET(OPTIONS => OPTS,
                        SCODE   => 'IDENT',
                        SVALUE  => NPROCESS);

    
    
    /* Кладем сообщение в очередь */
    PKG_EXS.QUEUE_PUT(SEXSSERVICE   => 'SendLoadFile',
                      SEXSSERVICEFN => 'uploadFile',
                      BMSG          => null,
                      SOPTIONS      => PKG_EXS.OPTIONS_SERIALIZE(OPTIONS => OPTS),
                      NNEW_EXSQUEUE => NEXSQUEUE);
   end;
  /* begin
      \* Сформируем адрес для запроса *\
      SURL := \*SSERVER*\SSERVER_PROD ||UTL_URL.ESCAPE(replace(replace(SPATTERN_QUERY_FIND,
                                             SPATTERN_QUERY_DIR,
                                             cFILENAME),
                                             SPATTERN_QUERY_IDENT,
                                             NPROCESS),
                             false,
                             PKG_CHARSET.CHARSET_UTF_);
      \* Выполняем запрос *\
      --UTL_HTTP.set_wallet('cert:' || 'C:\cert\webparus.module.ru\fullchain1.pem', null);
      --UTL_HTTP.set_wallet('key:' || 'C:\cert\webparus.module.ru\privkey1.pem', null);     
      HTTP_REQ  := UTL_HTTP.BEGIN_REQUEST(URL => SURL, METHOD => 'POST');
      HTTP_RESP := UTL_HTTP.GET_RESPONSE(R => HTTP_REQ);
      \* Создаем буфер для ответа *\
      DBMS_LOB.CREATETEMPORARY(LOB_LOC => BRESP, CACHE => false);
      DBMS_LOB.OPEN(LOB_LOC => BRESP, OPEN_MODE => DBMS_LOB.LOB_READWRITE);
      \* Читаем данные ответа *\
      begin
        loop
          UTL_HTTP.READ_RAW(R    => HTTP_RESP,
                            DATA => BBUFFER,
                            LEN  => NBUFFER_SIZE);
          DBMS_LOB.WRITEAPPEND(LOB_LOC => BRESP,
                               AMOUNT  => UTL_RAW.LENGTH(BBUFFER),
                               BUFFER  => BBUFFER);
        end loop;
      exception
        when others then
          if (sqlcode <> -29266) then
            raise;
          end if;
      end;
      \* Если ответ сервера с ошибкой *\
      if (HTTP_RESP.STATUS_CODE <> 200) then
        \* Вернём её *\
        if (DBMS_LOB.GETLENGTH(BRESP) <> 0) then
          SMSG := BLOB2CLOB(BRESP, PKG_CHARSET.CHARSET_UTF_);
        else
          SMSG := 'Ошибка выполнения запроса к серверу: ' ||
                  HTTP_RESP.REASON_PHRASE;
        end if;
      else
        \* Если данных в ответе нет *\
        if (DBMS_LOB.GETLENGTH(BRESP) = 0) then
          \* Скажем про это *\
          SMSG := 'Данных не найдено';
        else
          nIDENT := BLOB2CLOB(BRESP, PKG_CHARSET.CHARSET_UTF_);
        end if;
       end if;
        UTL_HTTP.END_RESPONSE(R => HTTP_RESP);
        DBMS_LOB.FREETEMPORARY(LOB_LOC => BRESP);
    exception
      when others then
        SMSG := 'Ошибка получения данных: ' || sqlerrm;
        if (HTTP_RESP.PRIVATE_HNDL is not null) then
          UTL_HTTP.END_RESPONSE(R => HTTP_RESP);
        end if;
        if (DBMS_LOB.ISTEMPORARY(LOB_LOC => BRESP) = 1) then
          DBMS_LOB.FREETEMPORARY(LOB_LOC => BRESP);
        end if;
    end;*/

  end START_WEBAPI_OUT_MAKE;

  /* обработка запроса выгрузки Журнала платежей в Файл*/
  procedure P_UPLOADFILE_PROCESS
  (
    NIDENT                    in number,        -- Идентификатор процесса
    NEXSQUEUE                 in number         -- Регистрационный номер обрабатываемой позиции очереди обмена
  )
  is
    REXSQUEUE                 EXSQUEUE%rowtype; -- Запись очереди
    SERR                      PKG_STD.TLSTRING; -- Буфер для ошибок
    nIDENT_MOV                PKG_STD.tREF;
    OPTS                      PKG_EXS.TOPTIONS;
    HDR_HEADERS               PKG_EXS.TOPTIONS;
    sNEW_DIROK                PKG_STD.TLSTRING;
    sNEW_DIRERR               PKG_STD.TLSTRING;
    sFILE_PATCH               PKG_STD.tSTRING;   -- Полный путь к файлу
    BRESPONSE                 blob;
    SQUERY                  PKG_STD.TSTRING;      -- Буфер для SQL-запроса
    ICURSOR                 integer;              -- Курсор для исполнения запроса

  begin
    /* Считаем запись очереди */
    REXSQUEUE := GET_EXSQUEUE_ID(NFLAG_SMART => 0, NRN => NEXSQUEUE);

     /* Считываем корневой элемент тела посылки */
     nIDENT_MOV := PKG_EXS.QUEUE_OPTIONS_READ(NEXSQUEUE => NEXSQUEUE,
                                 SPATH => 'qs/IDENT');
     /* Считываем корневой элемент тела посылки */
    /* sFILE_PATCH := PKG_EXS.QUEUE_OPTIONS_READ(NEXSQUEUE => NEXSQUEUE,
                                 SPATH => 'qs/SDIR');*/

     /* Считаем данные из буфера */
     SQUERY := 'select T.BDATA, T.FILENAME from FILE_BUFFER T where T.IDENT = :nIDENT_MOV';

 --    select t.bdata into BRESPONSE from FILE_BUFFER t where t.ident = nIDENT_MOV;
       begin
        ICURSOR := PKG_SQL_DML.OPEN_CURSOR(SWHAT => 'SELECT');
        PKG_SQL_DML.PARSE(ICURSOR => ICURSOR, SQUERY => SQUERY);
        PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'nIDENT_MOV', NVALUE => nIDENT_MOV);
        PKG_SQL_DML.DEFINE_COLUMN_BLOB(ICURSOR => ICURSOR, IPOSITION => 1);
        PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 2);
        if (PKG_SQL_DML.EXECUTE_AND_FETCH(ICURSOR => ICURSOR, BEXACT => false) > 0) then
          PKG_SQL_DML.COLUMN_VALUE_BLOB(ICURSOR => ICURSOR, IPOSITION => 1, LBVALUE => BRESPONSE);
          PKG_SQL_DML.COLUMN_VALUE_STR(ICURSOR => ICURSOR, IPOSITION => 2, SVALUE => sFILE_PATCH);
        else
          P_EXCEPTION(0,
                      'Данные типа для идентификатора "%s" не определены.',
                      TO_CHAR(nIDENT_MOV));
        end if;
        PKG_SQL_DML.CLOSE_CURSOR(ICURSOR => ICURSOR);
      exception
        when others then
          PKG_SQL_DML.CLOSE_CURSOR(ICURSOR => ICURSOR);
          raise;
      end;

  --Content-Length

  PKG_EXS.OPTIONS_SET(OPTIONS => OPTS,
                      SCODE   => 'FILE_PATCH',
                      SVALUE  => sFILE_PATCH);

  PKG_EXS.OPTIONS_SET(OPTIONS => HDR_HEADERS,
                      SCODE   => pkg_exs.SHTP_HDR_CNT_LENGTH,
                      SVALUE  => dbms_lob.getlength(BRESPONSE));
  --Content-Type
  PKG_EXS.OPTIONS_SET(OPTIONS => HDR_HEADERS,
                      SCODE   => pkg_exs.SHTP_HDR_CNT_TP,
                      SVALUE  => pkg_exs.SHTP_HDR_CNT_TYPE_PDF
                     );
   PKG_EXS.OPTIONS_SET(OPTIONS => OPTS,
                      SCODE   => pkg_exs.SMSG_OPTION_CODE_HEADERS,
                      SVALUE  => PKG_EXS.OPTIONS_SERIALIZE(OPTIONS => HDR_HEADERS,
                                                           BROOT   => false));


      /* Возвращаем ответ */
      PKG_EXS.PRC_RESP_RESULT_SET(NIDENT => NIDENT,
                                  SRESULT => PKG_EXS.SPRC_RESP_RESULT_OK,
                                  BRESP => BRESPONSE,
                                  SOPTIONS_RESP => PKG_EXS.OPTIONS_SERIALIZE(OPTIONS => OPTS)
                                  );
    exception
      when others then
        /* Вернём ошибку - это фатальная */
        PKG_STATE.DIAGNOSTICS_STACKED();
        PKG_EXS.PRC_RESP_RESULT_SET(NIDENT  => NIDENT,
                                    SRESULT => PKG_EXS.SPRC_RESP_RESULT_ERR,
                                    SMSG    => PKG_STATE.SQL_ERRM());


  end P_UPLOADFILE_PROCESS;

end UDO_PKG_UPLD_ININVICSSPCS_NM2;
/

