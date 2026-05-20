create or replace package USR_PKG_STPLGOODSSUPPLY is
  /*
  Степанов М. 11/12/2025
  Package предназначен для работы с разделом "Места хранения товарного запаса". 
  StoragePlacesGoodsSupply    STPLGOODSSUPPLY      SPGS
  */
  /*#########################################################################################################*/

  function STPLGOODSSUPPLY_GET
  /*
  Заголовок. Считывание 
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0
  ) 
  return stplgoodssupply%rowtype;
  /*#########################################################################################################*/

  function STPLGOODSSUPPLY_GET_BY_ARTICLE
  /*
  Заголовок. Поиск по изделию
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0
  )
  return number;
  /*#########################################################################################################*/

  procedure STPLGOODSSUPPLY_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure STPLGOODSSUPPLY_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure STPLGOODSSUPPLY_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure STPLGOODSSUPPLY_BDELETE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure STPLGOODSSUPPLY_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure STPLGOODSSUPPLY_BASE_INSERT
  /*
  Заголовок. Базовое добавление
  */
  (
   rROW             in stplgoodssupply%rowtype
  ,nRN              out number
  );
  /*#########################################################################################################*/
  
end USR_PKG_STPLGOODSSUPPLY;
/
create or replace package body USR_PKG_STPLGOODSSUPPLY is

  /*#########################################################################################################*/

  function STPLGOODSSUPPLY_GET
  /*
  Заголовок. Считывание 
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0
  ) 
  return stplgoodssupply%rowtype
  is
    rRow stplgoodssupply%rowtype;
  begin
    begin
      select * into rRow from stplgoodssupply where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'STPLGOODSSUPPLY');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'STPLGOODSSUPPLY')));
    end;
    return(rRow);
  end STPLGOODSSUPPLY_GET;
  /*#########################################################################################################*/

  function STPLGOODSSUPPLY_GET_BY_ARTICLE
  /*
  Заголовок. Поиск по изделию
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0
  ) 
  return number
  is
    nRef    pkg_std.tref; 
  begin

    begin
      select rn 
        into nRef
        from stplgoodssupply
       where article = nRN
         and quant  != 0;
    exception
      when no_data_found then
        p_exception(nFLAGSMART, 'Не найдены записи для изделия с RN "%s" в разделе "%s".'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'STPLGOODSSUPPLY')));
      when too_many_rows then
        p_exception(nFLAGSMART, 'Найдено больше одного изделия с RN "%s" в разделе "%s".'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'STPLGOODSSUPPLY')));
      when others then
        p_exception(0, 'Неопределённая ситуация при поиске для изделия с RN "%s" в разделе "%s".'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'STPLGOODSSUPPLY')));
    end;

    return( nRef );

  end STPLGOODSSUPPLY_GET_BY_ARTICLE;
  /*#########################################################################################################*/

  procedure STPLGOODSSUPPLY_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            stplgoodssupply%rowtype;
  begin
    /* Считывание
     rRow := STPLGOODSSUPPLY_GET(nRN); */

    /* ПРОВЕРКИ */
    /* Базовая */
    stplgoodssupply_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end STPLGOODSSUPPLY_AINSERT;
  /*#########################################################################################################*/

  procedure STPLGOODSSUPPLY_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;    
  end STPLGOODSSUPPLY_BUPDATE;
  /*#########################################################################################################*/

  procedure STPLGOODSSUPPLY_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow                     stplgoodssupply%rowtype;
  begin
    /* Считывание
     rRow := stplgoodssupply_get(nRN); */

    /* ПРОВЕРКИ */
    /* Базовая */
    stplgoodssupply_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end STPLGOODSSUPPLY_AUPDATE;
  /*#########################################################################################################*/

  procedure STPLGOODSSUPPLY_BDELETE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;    
  end STPLGOODSSUPPLY_BDELETE;
  /*#########################################################################################################*/

  procedure STPLGOODSSUPPLY_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow     stplgoodssupply%rowtype;
  begin
    null;
    /* Заголовок */  
    /* rRow := stplgoodssupply_get(nrn => nRN); */
    
  end STPLGOODSSUPPLY_CHECK_BASE;
  /*#########################################################################################################*/

  procedure STPLGOODSSUPPLY_BASE_INSERT
  /*
  Заголовок. Базовое добавление
  */
  (
   rROW             in stplgoodssupply%rowtype
  ,nRN              out number
  ) 
  is 
  begin
    p_stplgoodssupply_base_insert(ncompany     => rROW.COMPANY
                                 ,ncell        => rROW.CELL
                                 ,ngoodssupply => rROW.GOODSSUPPLY
                                 ,narticle     => rROW.ARTICLE
                                 ,ngoodsunit   => rROW.GOODSUNIT
                                 ,nrn          => nRN);
  end STPLGOODSSUPPLY_BASE_INSERT;
  /*#########################################################################################################*/

end USR_PKG_STPLGOODSSUPPLY;
/
