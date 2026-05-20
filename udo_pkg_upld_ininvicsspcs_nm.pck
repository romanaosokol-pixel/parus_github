create or replace package UDO_PKG_UPLD_ININVICSSPCS_NM
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
    DBEG             in date default sysdate - 31,           -- начало периода
    DEND             in date default sysdate,               -- конец периода  
    SPATTERN_DIR     in varchar2                            -- Каталог размещения файлов для выгрузки   
  );

end UDO_PKG_UPLD_ININVICSSPCS_NM;
/

create or replace package body UDO_PKG_UPLD_ININVICSSPCS_NM
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
    XCELL           PKG_XMAKE.tNODE; 
    

  begin

    /* Заголовок Таблицы */
    XCELL := PKG_XMAKE.CONCAT(iCURSOR1,   
    PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:StyleID','s62')
                                                           )),               
    PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:StyleID','s63')
                                                           ),
                                      PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                 Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                      ),
                                                                                 PKG_XMAKE.VALUE(iCURSOR1,'Номер платежного поручения')           
                                                                                )
                                                     )
                     ),                                                                                             
    PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:StyleID','s63')
                                                           ),
                                      PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                 Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                      ),
                                                                                 PKG_XMAKE.VALUE(iCURSOR1,'Дата платежного поручения')           
                                                                                )
                                                     )
                     ),                                                                                           
    PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:StyleID','s63')
                                                           ),
                                      PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                 Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                      ),
                                                                                 PKG_XMAKE.VALUE(iCURSOR1,'Наименование предприятия')           
                                                                                )
                                                     )
                     ), 
    PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:StyleID','s63')
                                                           ),
                                      PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                 Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                      ),
                                                                                 PKG_XMAKE.VALUE(iCURSOR1,'ИНН предприятия')           
                                                                                )
                                                     )
                     ),                                                                                                               
    PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:StyleID','s63')
                                                           ),
                                      PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                 Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                      ),
                                                                                 PKG_XMAKE.VALUE(iCURSOR1,'КПП предприятия')           
                                                                                )
                                                     )
                     ),                                                                                            
    PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:StyleID','s63')
                                                           ),
                                      PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                 Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                      ),
                                                                                 PKG_XMAKE.VALUE(iCURSOR1,'Номер счета в 1С')           
                                                                                )
                                                     )
                     ),                                                                                           
    PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:StyleID','s63')
                                                           ),
                                      PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                 Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                      ),
                                                                                 PKG_XMAKE.VALUE(iCURSOR1,'Дата счета в 1С')           
                                                                                )
                                                     )
                     ),                                                                                             
    PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:StyleID','s63')
                                                           ),
                                      PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                 Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                      ),
                                                                                 PKG_XMAKE.VALUE(iCURSOR1,'Номер счета в справочнике 1С')           
                                                                                )
                                                     )
                     ),
       PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:StyleID','s63')
                                                           ),
                                      PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                 Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                      ),
                                                                                 PKG_XMAKE.VALUE(iCURSOR1,'Дата счета в справочнике 1С')           
                                                                                )
                                                     )
                     ),                                                                                           
    PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:StyleID','s63')
                                                           ),
                                      PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                 Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                      ),
                                                                                 PKG_XMAKE.VALUE(iCURSOR1,'Сумма платежного поручения')           
                                                                                )
                                                     )
                     ),                                                                                          
    PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:StyleID','s69')
                                                           ),
                                      PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                 Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                      ),
                                                                                 PKG_XMAKE.VALUE(iCURSOR1,'Назначение платежа')           
                                                                                )
                                                     )
                     )                                                                                                                                                                                                     
                    );
    XROW    := PKG_XMAKE.CONCAT(iCURSOR1, XROW, PKG_XMAKE.ELEMENT(iCURSOR1,'Row',XCELL));
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
    XCOLUM          PKG_XMAKE.tNODE;
    XWO             PKG_XMAKE.tNODE;
  begin
    XCOLUM := PKG_XMAKE.CONCAT(iCURSOR1, PKG_XMAKE.ELEMENT(iCURSOR1,'Column',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:AutoFitWidth','0'),
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Width','9.75')
                                                                                                 ) 
                                                          ),
                                         PKG_XMAKE.ELEMENT(iCURSOR1,'Column',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:AutoFitWidth','0'),
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Width','42')
                                                                                                 ) 
                                                          ),
                                         PKG_XMAKE.ELEMENT(iCURSOR1,'Column',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:AutoFitWidth','0'),
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Width','64.5')
                                                                                                 )
                                                        ),                                          
                                         PKG_XMAKE.ELEMENT(iCURSOR1,'Column',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:AutoFitWidth','0'),
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Width','217.5')
                                                                                                ) 
                                                         ),   
                                         PKG_XMAKE.ELEMENT(iCURSOR1,'Column',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:AutoFitWidth','0'),
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Width','75.75')
                                                                                                ) 
                                                         ),
                                         PKG_XMAKE.ELEMENT(iCURSOR1,'Column',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:AutoFitWidth','0'),
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Width','84')
                                                                                                ) 
                                                         ),
                                         PKG_XMAKE.ELEMENT(iCURSOR1,'Column',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:AutoFitWidth','0'),
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Width','148.5')
                                                                                                ) 
                                                         ), 
                                         PKG_XMAKE.ELEMENT(iCURSOR1,'Column',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:AutoFitWidth','0'),
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Width','89.25')
                                                                                                ) 
                                                         ),
                                         PKG_XMAKE.ELEMENT(iCURSOR1,'Column',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:AutoFitWidth','0'),
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Width','64.5')
                                                                                                ) 
                                                         ),
                                         PKG_XMAKE.ELEMENT(iCURSOR1,'Column',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:AutoFitWidth','0'),
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Width','81.75')
                                                                                                ) 
                                                         ),
                                         PKG_XMAKE.ELEMENT(iCURSOR1,'Column',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:AutoFitWidth','0'),
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Width','66.75')
                                                                                                ) 
                                                         ),
                                         PKG_XMAKE.ELEMENT(iCURSOR1,'Column',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:AutoFitWidth','0'),
                                                           Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Width','198.75')
                                                                                                ) 
                                                         )                                                                                           
                              );  
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
    bSTYL           PKG_STD.tLSTRING := '<Style ss:ID="Default" ss:Name="Normal">
   <Alignment ss:Vertical="Bottom"/>
   <Borders/>
   <Font ss:FontName="Calibri" x:CharSet="204" x:Family="Swiss" ss:Size="11"
    ss:Color="#000000"/>
   <Interior/>
   <NumberFormat/>
   <Protection/>
  </Style>';
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
  begin
    for data_ in (select p.doc_date, 
                         replace(replace(sp.original_name,'<',''),'>','') original_name, 
                         sp.sernumb, 
                         sp.nomen, 
                         n.nomen_code, 
                         replace(replace(n.nomen_name,'<',''),'>','') nomen_name, 
                         u.code_okei, 
                         sp.modif, 
                         m.modif_code, 
                         m.modif_name  
                  from ININVOICES p, ININVOICESSPECS sp, nommodif m, dicnomns n, dicmunts u 
                  where SP.PRN = P.RN 
                  and sp.modif = m.rn 
                  and sp.nomen = n.rn 
                  and n.umeas_main = u.rn
                  and p.doc_date between DBEG and DEND 
                  and p.company = nCOMPANY
                  and sp.original_name is not null
                  and sp.sernumb is not null)loop
           N := N +1;
           
           if n = 1 then 
             XROWATRIB := PKG_XMAKE.ATTRIBUTES(iCURSOR1,Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Index','2'));
           else
              XROWATRIB := null;
           end if;
           
           
           XVAL_ROW := PKG_XMAKE.CONCAT(iCURSOR1,XVAL_ROW,
                        PKG_XMAKE.ELEMENT(iCURSOR1,'Row',XROWATRIB,
                                                                 PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Index','2')
                                                                                                         ),
                                                                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                                                                    ),
                                                                                                                                PKG_XMAKE.VALUE(iCURSOR1,data_.modif_code)           
                                                                                                                                )
                                                                                                    )          
                                                                    ),
           /*XVAL_ROW := */                                       PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',
                                                                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                                                                    ),
                                                                                                                                PKG_XMAKE.VALUE(iCURSOR1,data_.nomen_name)           
                                                                                                                                )
                                                                                                    )          
                                                                    ),
           /*XVAL_ROW := */                                       PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',
                                                                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                                                                    ),
                                                                                                                                PKG_XMAKE.VALUE(iCURSOR1,data_.sernumb)           
                                                                                                                                )
                                                                                                    )          
                                                                    ),
            /*XVAL_ROW := */                                      PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',
                                                                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                                                                    ),
                                                                                                                                PKG_XMAKE.VALUE(iCURSOR1,data_.original_name)           
                                                                                                                                )
                                                                                                    )          
                                                                    ),
            /*XVAL_ROW :=  */                                     PKG_XMAKE.ELEMENT(iCURSOR1,'Cell',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Index','7')
                                                                                                         ),
                                                                                     PKG_XMAKE.VALUE(iCURSOR1,PKG_XMAKE.ELEMENT(iCURSOR1,'Data',PKG_XMAKE.ATTRIBUTES(iCURSOR1,
                                                                                     Pkg_Xmake.ATTRIBUTE(iCURSOR1,'ss:Type','String')
                                                                                                                                                                    ),
                                                                                                                                PKG_XMAKE.VALUE(iCURSOR1,data_.code_okei)           
                                                                                                                                )
                                                                                                    )          
                                                                    )
                                 )
                                 );

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
     /* XROW     := NODEROW_MAKE(iCURSOR1 => iCURSOR\*,
                               nMACOUNT => nMACOUNT,
                               SVED     => TRIM(RWD_DISTRIB.PREF)||'/'||TRIM(RWD_DISTRIB.NUMB)||' от '|| to_char(RWD_DISTRIB.DOCDATE,'dd.mm.yyyy'),
                               nVED     => RWD_DISTRIB.RN,
                               SDEP     => UDO_GET_SUBDIV_CODE_ID(1,RWD_DISTRIB.SUBDIV),         -- Подразделение
                               SPRD     => f_smonth_base(RWD_DISTRIB.PRD_MONTH)||' '|| RWD_DISTRIB.PRD_YEAR*\
                               );*/
  
      /* Данные отчета */
      DATA_MAKE(iCURSOR1         =>iCURSOR,
                nCOMPANY         => nCOMPANY,         
                DBEG             => DBEG,
                DEND             => DEND,        
                xDATA            => xDATA    -- Узел Данных Ведомости ФОВ
                );
      XROW := PKG_XMAKE.ELEMENT(iCURSOR,'Table',xDATA);  
  
      XRD := PKG_XMAKE.CONCAT(iCURSOR,XROW);          
      /* Создание элемента таблицы книги с атрибутами XML */
      --XTBL     := NODETBL_MAKE(iCURSOR,XRD/*,nMACOUNT*/);
      /* Создание элемента Листа книги с атрибутами XML */
      XWORKSHEET := WORKSHEET_MAKE(iCURSOR,'ВыгрузкаНоменклатуры', XRD);
      /* Стили ячеек */ 
      XSTYLES  := STYLE_MAKE(iCURSOR);
      XSW := PKG_XMAKE.CONCAT(iCURSOR,XSTYLES,XWORKSHEET);
      /* Корневой узел */ 
      XROOT := ROOTELEMENTATRIB_MAKE(iCURSOR,XSW);
      XROOT := PKG_XMAKE.CONCAT(iCURSOR,PKG_XMAKE.ELEMENT(iCURSOR,'?mso-application progid="Excel.Sheet"?'),XROOT);    
    cLOBDATA := replace(replace(replace(replace(PKG_XMAKE.SERIALIZE_TO_CLOB/*SERIALIZE_TO_VARCHAR*/(iCURSOR => iCURSOR,
                                                                         iTYPE   => PKG_XMAKE.DOCUMENT_,
                                                                         rNODE   => XROOT,
                                                                         rHEADER => PKG_XHEADER.WRAP_ALL(PKG_XHEADER.VERSION_1_0_)),
                                          SOPTIONS_CHR_GT_TO,
                                          SOPTIONS_CHR_GT),
                                  SOPTIONS_CHR_LT_TO,
                                  SOPTIONS_CHR_LT),
                          SOPTIONS_CHR_X0A,
                          CR),
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
    DBEG             in date default sysdate - 31,           -- начало периода
    DEND             in date default sysdate,               -- конец периода  
    SPATTERN_DIR     in varchar2                            -- Каталог размещения файлов для выгрузки   
  )
  is
    BDATA                     blob;                                  -- Данные файла
    SFILENAME                 PKG_STD.tSTRING;                       -- Имя файла
    NBUFFER_SIZE              constant PKG_STD.TNUMBER := 32767;                                               -- Размер буфера данных для загрузки ответа
    SSERVER                   constant PKG_STD.TSTRING := 'http://10.7.19.35:8080/ReadFiles/uploadFile?';      -- Адрес тестового сервиса для разбора PDF и поиска страниц в нём
    SSERVER_PROD              constant PKG_STD.TSTRING := 'http://10.21.136.209:8080/ReadFiles/uploadFile?';   -- Адрес рабочего сервиса для разбора PDF и поиска страниц в нём
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
    SFILENAME := 'spr_32.xls'; /*FILENAME_MAKE
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
    
   /*begin
      \* Сформируем адрес для запроса *\
      SURL := \*SSERVER*\SSERVER_PROD ||UTL_URL.ESCAPE(replace(replace(SPATTERN_QUERY_FIND,
                                             SPATTERN_QUERY_DIR,
                                             cFILENAME),
                                             SPATTERN_QUERY_IDENT,
                                             NPROCESS),
                             false,
                             PKG_CHARSET.CHARSET_UTF_);
      \* Выполняем запрос *\
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

end UDO_PKG_UPLD_ININVICSSPCS_NM;
/

