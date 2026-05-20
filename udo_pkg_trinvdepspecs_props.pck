create or replace package UDO_PKG_TRINVDEPSPECS_PROPS as

  -- Author  : P.SHESTERIKOV
  -- Created : 21.10.2022 16:30:23
  -- Purpose : Пакет "Свойства спецификации Расходной накладной на отпуск в подразделения"

  /*Партия товара*/
  function PARTY(NRN in number) return varchar2;

  /*Серийный номер*/
  function SERNUMBER(NRN in number) return varchar2;

  /*Поставщик*/
  function PRODUCER(NRN in number) return varchar2;

  /*Дата производства*/
  function PROD_DATE(NRN in number) return varchar2;


end UDO_PKG_TRINVDEPSPECS_PROPS;
/

create or replace package body UDO_PKG_TRINVDEPSPECS_PROPS as

  /*21.10.2022. Свойства спецификации Расходной накладной на отпуск в подразделения.*/

  /*Партия товара*/
  function PARTY(NRN in number) return varchar2 is
    SRES varchar2(40);
  
  begin
  
    begin
      select I.CODE
        into SRES
        from TRANSINVDEPTSPECS T,
             GOODSPARTIES      GP,
             INCOMDOC          I
       where T.GOODSPARTY = GP.RN
         and GP.INDOC = I.RN
         and T.RN = NRN;
    
    exception
      when NO_DATA_FOUND then
        SRES := null;
    end;
  
    if SRES is null then
      begin
        select IA.CODE
          into SRES
          from TRANSINVDEPTSPECS T,
               ARTICLESSUPPLY    SA,
               GOODSSUPPLY       GSA,
               GOODSPARTIES      GPA,
               INCOMDOC          IA
        
         where T.COMPANY = SA.COMPANY
           and T.ARTICLE = SA.ARTICLE
           and SA.PRN = GSA.RN
           and GSA.PRN = GPA.RN
           and GPA.INDOC = IA.RN
           and T.RN = NRN;
      
      exception
        when NO_DATA_FOUND then
          SRES := null;
      end;
    end if;
    return(SRES);
  end PARTY;


  /*Серийный номер*/
  function SERNUMBER(NRN in number) return varchar2 is
  
    SRES varchar2(40);
  
  begin
  
    begin
      select GP.SERNUMB
        into SRES
        from TRANSINVDEPTSPECS T,
             GOODSPARTIES      GP
      
       where T.GOODSPARTY = GP.RN
         and T.RN = NRN;
    
    exception
      when NO_DATA_FOUND then
        SRES := null;
    end;
  
    if SRES is null then
      begin
        select GPA.SERNUMB
          into SRES
          from TRANSINVDEPTSPECS T,
               ARTICLESSUPPLY    SA,
               GOODSSUPPLY       GSA,
               GOODSPARTIES      GPA
        
         where T.COMPANY = SA.COMPANY
           and T.ARTICLE = SA.ARTICLE
           and SA.PRN = GSA.RN
           and GSA.PRN = GPA.RN
           and T.RN = NRN;
      
      exception
        when NO_DATA_FOUND then
          SRES := null;
      end;
    end if;
    return(SRES);
  end SERNUMBER;

  /*Поставщик*/
  function PRODUCER(NRN in number) return varchar2 is
  
    SRES varchar2(40);
  
  begin
  
    begin
      select AL.AGNABBR
        into SRES
        from TRANSINVDEPTSPECS T,
             ARTICLESSUPPLY    SA,
             GOODSSUPPLY       GSA,
             GOODSPARTIES      GPA,
             INCOMDOC          IA,
             AGNLIST           AL
      
       where T.COMPANY = SA.COMPANY
         and T.ARTICLE = SA.ARTICLE
         and SA.PRN = GSA.RN
         and GSA.PRN = GPA.RN
         and GPA.INDOC = IA.RN
         and IA.AGENT = AL.RN
         and T.RN = NRN;
    exception
      when NO_DATA_FOUND then
        SRES := null;
    end;
  
    if SRES is null then
      begin
        select A.AGNABBR
          into SRES
          from TRANSINVDEPTSPECS T,
               GOODSPARTIES      GP,
               INCOMDOC          I,
               AGNLIST           A
        
         where T.GOODSPARTY = GP.RN
           and GP.INDOC = I.RN
           and I.AGENT = A.RN
           and T.RN = NRN;
      
      exception
        when NO_DATA_FOUND then
          SRES := null;
      end;
    end if;
    return(SRES);
  end PRODUCER;

  /*Дата производства*/
  function PROD_DATE(NRN in number) return varchar2 is
  
    SRES varchar2(40);
  
  begin
  --Поиск в свойствах спецификации Приходного ордера
    begin
      select trim(UDO_F_GET_DOC_PROP_VAL(NDOC => ISP.RN, SPROP => 'Дата производства'))
        into SRES
        from TRANSINVDEPTSPECS T,
             GOODSPARTIES      GP,
             GOODSSUPPLY       GS,
             INORDERSPECS      ISP
      
       where T.GOODSPARTY = GP.RN
         and GP.RN = GS.PRN
         and GS.RN = ISP.GOODSSUPPLY
         and T.RN = NRN;
    
    exception
      when NO_DATA_FOUND then
        SRES := null;
    end;
  --Для номеклатуры, загруженной из 1С
    if SRES is null then
      begin
        select SUBSTR(MS.PROD_DATE, 1, 200)
          into SRES
          from UDO_NOMODIF_SERIES MS
         where MS.SERIES = (select NVL(GP.SERNUMB, '9999999999')
                              from GOODSPARTIES      GP,
                                   TRANSINVDEPTSPECS T
                             where GP.RN = T.GOODSPARTY
                               and T.RN = NRN)
           and ROWNUM < 2;
      exception
        when NO_DATA_FOUND then
          SRES := null;
      end;
    end if;
  
  --"Кривой" поиск в свойствах спецификации Приходного ордера (возможно удалить)
    if SRES is null then
      begin
        select UDO_F_GET_DOC_PROP_VAL(NDOC => ISPA.RN, SPROP => 'Дата производства')
          into SRES
          from TRANSINVDEPTSPECS T,
               ARTICLESSUPPLY    SA,
               GOODSSUPPLY       GSA,
               INORDERSPECS      ISPA
        
         where T.COMPANY = SA.COMPANY
           and T.ARTICLE = SA.ARTICLE
           and SA.PRN = GSA.RN
           and GSA.RN = ISPA.GOODSSUPPLY
           and T.RN = NRN;
      exception
        when NO_DATA_FOUND then
          SRES := null;
      end;
    end if;
  --Поиск в свойствах Партии товаров (возхможно удалить)
    if SRES is null then
      begin
        select trim(UDO_F_GET_DOC_PROP_VAL(NDOC => GP.RN, SPROP => 'ПРЗВД_ДАТА'))
          into SRES
          from TRANSINVDEPTSPECS T,
               GOODSPARTIES      GP
        
         where T.GOODSPARTY = GP.RN
           and T.RN = NRN;
      
      exception
        when NO_DATA_FOUND then
          SRES := null;
      end;
    end if;
  
    return(SRES);
  end PROD_DATE;

end UDO_PKG_TRINVDEPSPECS_PROPS;
/

