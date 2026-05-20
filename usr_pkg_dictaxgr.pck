create or replace package USR_PKG_DICTAXGR is
  /*
  Package предназначен для работы с разделом "Группы пользователей".
  TaxiesGroups                      DICTAXGR       DTG
  Taxies                            DICTAXIS       DT
  */
  /*#########################################################################################################*/

  function DICTAXGR_GET
  /*
  Заголовок. Считывание записи
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0
  ) 
  return DICTAXGR%ROWTYPE;
  /*#########################################################################################################*/

  function DICTAXGR_GET_CODE
  /*
  Заголовок. Получить мнемокод по RN
  */
  (
   nRN        in number
  ,nCOMPANY   in number
  ,nFLAGSMART in number default 0
  ) 
  return varchar2;
  /*#########################################################################################################*/

  procedure DICTAXGR_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DICTAXGR_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DICTAXGR_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DICTAXGR_BDELETE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DICTAXGR_BMOVE_IN
  /*
  Заголовок. Проверка перед переносом в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DICTAXGR_BMOVE_OUT
  /*
  Заголовок. Проверка перед переносом из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DICTAXGR_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  function DICTAXIS_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0
  ) 
  return DICTAXIS%ROWTYPE;
  /*#########################################################################################################*/

  procedure DICTAXIS_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DICTAXIS_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DICTAXIS_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DICTAXIS_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DICTAXIS_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*########################################################################################################*/

  procedure DICTAXIS_CALC_BASE
  /*
  Процедура рассчёта сумм налогов
  */
  (
   nFLAGSMART     in number default 0
  ,nCOMPANY       in number default null
  ,dDATE          in date   default sysdate
  ,nTAXGR         in number
  ,nINSUMM        in number
  ,nINSUMM_NDS    in number default null  /* Сумма НДС */
  ,nSUMM_SIGN     in number default 1     /* Сумма с налогами: 0-нет, 1-да */
  ,nQUANT         in number default 1     /* Количество */
  ,nNCP_SIGN      in number default 1     /* Включать налог с продаж: 0-нет, 1-да */
  ,nROUND_SIGN    in number default 0     /* Округлять: 0-нет, 1-да */
  ,nSUMM          out number
  ,nSUMMWITHNDS   out number
  ,nSUMM_NDS      out number
  ,nPRICE         out number
  );
    /*########################################################################################################*/

  function DICTAXIS_CALC_BASE
  /*
  Функция рассчёта сумм налогов
  */
  (
   nFLAGSMART     in number default 0
  ,nCOMPANY       in number default null
  ,dDATE          in date   default sysdate
  ,nTAXGR         in number
  ,nINSUMM        in number
  ,nINSUMM_NDS    in number default null    /* Сумма НДС */
  ,nSUMM_SIGN     in number default 1       /* Сумма с налогами: 0-нет, 1-да */
  ,nQUANT         in number default 1       /* Количество */
  ,nNCP_SIGN      in number default 1       /* Включать налог с продаж: 0-нет, 1-да */
  ,nROUND_SIGN    in number default 0       /* Округлять: 0-нет, 1-да */
  ,nPARAM         in number default 0       /* 0 - Сумма без налогов, 2 - Сумма со всеми налогами, 8 - НДС */
  ) 
  return number;
  /*########################################################################################################*/

  function DICTAXIS_CALC_BASE
  /*
  Функция рассчёта сумм налогов
  */
  (
   nFLAGSMART     in number default 0
  ,nCOMPANY       in number default null
  ,dDATE          in date   default sysdate
  ,nTAXGR         in number
  ,nINSUMM        in number
  ,nINSUMM_NDS    in number default null    /* Сумма НДС */
  ,nSUMM_SIGN     in number default 1       /* Сумма с налогами: 0-нет, 1-да */
  ,nQUANT         in number default 1       /* Количество */
  ,nNCP_SIGN      in number default 1       /* Включать налог с продаж: 0-нет, 1-да */
  ,nROUND_SIGN    in number default 0       /* Округлять: 0-нет, 1-да */
  ,nPARAM         in number default 0       /* 0 - Сумма без налогов, 2 - Сумма со всеми налогами, 8 - НДС */
  ,nSUMM          out number
  ,nSUMMWITHNDS   out number
  ,nSUMM_NDS      out number
  ,nPRICE         out number
  ) 
  return number;
  /*########################################################################################################*/

  procedure DICTAXIS_CALC
  /*
  Процедура рассчёта сумм налогов
  */
  (
   nFLAGSMART     in number default 0
  ,nCOMPANY       in number default null
  ,dDATE          in date   default sysdate
  ,sTAXGR         in varchar2
  ,nINSUMM        in number
  ,nINSUMM_NDS    in number default null  /* Сумма НДС */
  ,nSUMM_SIGN     in number default 1     /* Сумма с налогами: 0-нет, 1-да */
  ,nQUANT         in number               /* Количество */
  ,nNCP_SIGN      in number default 1     /* Включать налог с продаж: 0-нет, 1-да */
  ,nROUND_SIGN    in number default 0     /* Округлять: 0-нет, 1-да */
  ,nSUMM          out number
  ,nSUMMWITHNDS   out number
  ,nSUMM_NDS      out number
  ,nPRICE         out number
  );
  /*#########################################################################################################*/

end USR_PKG_DICTAXGR;
/
create or replace package body USR_PKG_DICTAXGR is

  /*#########################################################################################################*/

  function DICTAXGR_GET
  /*
  Заголовок. Считывание записи
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0
  ) 
  return dictaxgr%rowtype
  is
    rRow dictaxgr%rowtype;
  begin
    begin
      select * into rRow from dictaxgr where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found( nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'DICTAXGR' );
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <'||nvl(to_char(nRN), 'Не задан')||'> '||
        'в разделе <'||f_unitlist_getname(get_unitlist_code_table(nflag_smart => 1, stable_name => 'DICTAXGR'))||'>.');
    end;
    return(rRow);
  end DICTAXGR_GET;
  /*#########################################################################################################*/

  function DICTAXGR_GET_CODE
  /*
  Заголовок. Получить мнемокод по RN
  */
  (
   nRN        in number
  ,nCOMPANY   in number
  ,nFLAGSMART in number default 0
  ) 
  return varchar2
  is
    sVar pkg_std.tstring; 
  begin
    find_dictaxgr_rn( nflag_smart  => nFLAGSMART
                     ,nflag_option => nFLAGSMART
                     ,ncompany     => nCOMPANY
                     ,nrn          => nRN
                     ,scode        => sVar );
    return( sVar );
  end DICTAXGR_GET_CODE;
  /*#########################################################################################################*/

  procedure DICTAXGR_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            dictaxgr%rowtype;
  begin
    null;
    /* Заголовок  */
    /*rRow      := dictaxgr_get(nRN);*/
  end DICTAXGR_AINSERT;
  /*#########################################################################################################*/

  procedure DICTAXGR_BUPDATE
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
    /* Считывание  */
    
    /* ПРОВЕРКИ */

  end DICTAXGR_BUPDATE;
  /*#########################################################################################################*/

  procedure DICTAXGR_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  IS
    rRow            dictaxgr%rowtype;
  begin
    null;
    /* Считывание */
    /*rRow := dictaxgr_get(nRN);*/

    /* ИСПРАВЛЕНИЯ */
    
    /* ПРОВЕРКИ */
    /* Базовая */
    /*dictaxgr_check_base(nrn => rRow.rn, ncompany => rRow.company);*/
    
  end DICTAXGR_AUPDATE;
  /*#########################################################################################################*/

  procedure DICTAXGR_BDELETE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow              dictaxgr%rowtype;
  begin
    /* Заголовок */
    rRow := dictaxgr_get(nrn => nRN);

    /* ИСПРАВЛЕНИЯ */
    
    /* ПРОВЕРКИ */

  end DICTAXGR_BDELETE;
  /*#########################################################################################################*/

  procedure DICTAXGR_BMOVE_IN
  /*
  Заголовок. Проверка перед переносом в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end DICTAXGR_BMOVE_IN;
  /*#########################################################################################################*/

  procedure DICTAXGR_BMOVE_OUT
  /*
  Заголовок. Проверка перед переносом из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  IS
  begin
    null;
  end DICTAXGR_BMOVE_OUT;
  /*#########################################################################################################*/

  procedure DICTAXGR_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end DICTAXGR_CHECK_BASE;
  /*#########################################################################################################*/

  function DICTAXIS_GET
  /*
  Спецификация. Считывание записи
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0
  ) 
  return dictaxis%rowtype
  is
    rRow dictaxis%rowtype;
  begin
    begin
      select * into rRow from dictaxis where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'DICTAXIS');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <'||nvl(to_char(nRN), 'Не задан')||'> '||
        'в разделе <'||f_unitlist_getname(get_unitlist_code_table(nflag_smart => 1, stable_name => 'DICTAXIS'))||'>.');
    end;
    return(rRow);
  end DICTAXIS_GET;
  /*#########################################################################################################*/

  procedure DICTAXIS_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
    /* Проверка базовая */
    /*dictaxis_check_base(nrn => nRN, ncompany => nCOMPANY);*/
  end DICTAXIS_AINSERT;
  /*#########################################################################################################*/

  procedure DICTAXIS_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end DICTAXIS_BUPDATE;
  /*#########################################################################################################*/

  procedure DICTAXIS_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
    /* Проверка базовая */
    /*dictaxis_check_base(nrn => nRN, ncompany => nCOMPANY);*/
  end DICTAXIS_AUPDATE;
  /*#########################################################################################################*/

  procedure DICTAXIS_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end DICTAXIS_BDELETE;
  /*#########################################################################################################*/

  procedure DICTAXIS_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow              dictaxis%rowtype;
  begin
    null;
    /* Считывание */
    /*rRow            := dictaxis_get(nrn => nRN);
    rIncomeFromDeps := dictaxgr_get(nrn => rRow.prn);*/

    /* ИСПРАВЛЕНИЕ */

    /* ПРОВЕРКА */

  end DICTAXIS_CHECK_BASE;
  /*########################################################################################################*/

  procedure DICTAXIS_CALC_BASE
  /*
  Процедура рассчёта сумм налогов
  */
  (
   nFLAGSMART     in number default 0
  ,nCOMPANY       in number default null
  ,dDATE          in date   default sysdate
  ,nTAXGR         in number
  ,nINSUMM        in number
  ,nINSUMM_NDS    in number default null  /* Сумма НДС */
  ,nSUMM_SIGN     in number default 1     /* Сумма с налогами: 0-нет, 1-да */
  ,nQUANT         in number default 1     /* Количество */
  ,nNCP_SIGN      in number default 1     /* Включать налог с продаж: 0-нет, 1-да */
  ,nROUND_SIGN    in number default 0     /* Округлять: 0-нет, 1-да */
  ,nSUMM          out number
  ,nSUMMWITHNDS   out number
  ,nSUMM_NDS      out number
  ,nPRICE         out number
  ) 
  is
    nNumber   pkg_std.tnumber;  
  begin
    /* Рассчёт сумм */
    p_dictaxis_calc_base( nflag_smart       => nFLAGSMART
                         ,ncompany          => nvl( nCOMPANY, get_session_company )
                         ,ddate             => dDATE
                         ,nsumm_sign        => nSUMM_SIGN
                         ,ninsumm           => nINSUMM
                         ,ninsumm_nds       => nINSUMM_NDS
                         ,ntaxgr            => nTAXGR
                         ,nquant            => nQUANT
                         ,nncp_sign         => nNCP_SIGN
                         ,nsumm_r           => nNumber
                         ,nsummwithaxs_r    => nNumber
                         ,nsummwithtax_r    => nSUMMWITHNDS
                         ,nsummwitoutnds_r  => nSUMM
                         ,nsummwithoutncp_r => nNumber
                         ,naxcise_sum_r     => nNumber
                         ,naxcise_prc_r     => nNumber
                         ,naxcise_ret_r     => nNumber
                         ,nnds_sum_r        => nSUMM_NDS
                         ,nnds_prc_r        => nNumber
                         ,nnds_ret_r        => nNumber
                         ,ngsm_sum_r        => nNumber
                         ,ngsm_prc_r        => nNumber
                         ,ngsm_ret_r        => nNumber
                         ,nncp_sum_r        => nNumber
                         ,nncp_prc_r        => nNumber
                         ,nncp_ret_r        => nNumber
                         ,nround_sign       => nROUND_SIGN );
    /* Рассчёт цены с НДС или без в зависимости от параметра */
    nPRICE := case nSUMM_SIGN when 0 then nSUMM else nSUMMWITHNDS end / nullif( nQUANT, 0 ); 

  end DICTAXIS_CALC_BASE;  
  /*########################################################################################################*/

  function DICTAXIS_CALC_BASE
  /*
  Функция рассчёта сумм налогов
  */
  (
   nFLAGSMART     in number default 0
  ,nCOMPANY       in number default null
  ,dDATE          in date   default sysdate
  ,nTAXGR         in number
  ,nINSUMM        in number
  ,nINSUMM_NDS    in number default null    /* Сумма НДС */
  ,nSUMM_SIGN     in number default 1       /* Сумма с налогами: 0-нет, 1-да */
  ,nQUANT         in number default 1       /* Количество */
  ,nNCP_SIGN      in number default 1       /* Включать налог с продаж: 0-нет, 1-да */
  ,nROUND_SIGN    in number default 0       /* Округлять: 0-нет, 1-да */
  ,nPARAM         in number default 0       /* 0 - Сумма без налогов, 2 - Сумма со всеми налогами, 8 - НДС */
  ) 
  return number 
  is
    nSumm          pkg_std.tsumm;  
    nSummWithNDS   pkg_std.tsumm;  
    nSumm_NDS      pkg_std.tsumm;    
    
    nNumber   pkg_std.tnumber;  
  begin
    /* Рассчёт сумм */
    dictaxis_calc_base( nflagsmart   => nFLAGSMART
                       ,ncompany     => nCOMPANY
                       ,ninsumm      => nINSUMM
                       ,ntaxgr       => nTAXGR
                       ,ddate        => dDATE
                       ,nsumm_sign   => nSUMM_SIGN
                       ,nquant       => nQUANT
                       ,nncp_sign    => nNCP_SIGN
                       ,nsumm        => nSumm
                       ,nsummwithnds => nSummWithNDS
                       ,nsumm_nds    => nSumm_NDS 
                       ,nprice       => nNumber );
    return case NPARAM 
             when 0 then nSumm
             when 2 then nSummWithNDS
             when 8 then nSumm_NDS
           else
             null
           end;

  end DICTAXIS_CALC_BASE;  
  /*########################################################################################################*/

  function DICTAXIS_CALC_BASE
  /*
  Функция рассчёта сумм налогов
  */
  (
   nFLAGSMART     in number default 0
  ,nCOMPANY       in number default null
  ,dDATE          in date   default sysdate
  ,nTAXGR         in number
  ,nINSUMM        in number
  ,nINSUMM_NDS    in number default null    /* Сумма НДС */
  ,nSUMM_SIGN     in number default 1       /* Сумма с налогами: 0-нет, 1-да */
  ,nQUANT         in number default 1       /* Количество */
  ,nNCP_SIGN      in number default 1       /* Включать налог с продаж: 0-нет, 1-да */
  ,nROUND_SIGN    in number default 0       /* Округлять: 0-нет, 1-да */
  ,nPARAM         in number default 0       /* 0 - Сумма без налогов, 2 - Сумма со всеми налогами, 8 - НДС */
  ,nSUMM          out number
  ,nSUMMWITHNDS   out number
  ,nSUMM_NDS      out number
  ,nPRICE         out number
  ) 
  return number 
  is
    nNumber   pkg_std.tnumber;  
  begin
    /* Рассчёт сумм */
    dictaxis_calc_base( nflagsmart   => nFLAGSMART
                       ,ncompany     => nCOMPANY
                       ,ninsumm      => nINSUMM
                       ,ntaxgr       => nTAXGR
                       ,ddate        => dDATE
                       ,nsumm_sign   => nSUMM_SIGN
                       ,nquant       => nQUANT
                       ,nncp_sign    => nNCP_SIGN
                       ,nsumm        => nSumm
                       ,nsummwithnds => nSummWithNDS
                       ,nsumm_nds    => nSumm_NDS 
                       ,nprice       => nNumber );
    return case NPARAM 
             when 0 then nSumm
             when 2 then nSummWithNDS
             when 8 then nSumm_NDS
           else
             null
           end;

  end DICTAXIS_CALC_BASE;  
  /*########################################################################################################*/

  procedure DICTAXIS_CALC
  /*
  Процедура рассчёта сумм налогов
  */
  (
   nFLAGSMART     in number default 0
  ,nCOMPANY       in number default null
  ,dDATE          in date   default sysdate
  ,sTAXGR         in varchar2
  ,nINSUMM        in number
  ,nINSUMM_NDS    in number default null  /* Сумма НДС */
  ,nSUMM_SIGN     in number default 1     /* Сумма с налогами: 0-нет, 1-да */
  ,nQUANT         in number               /* Количество */
  ,nNCP_SIGN      in number default 1     /* Включать налог с продаж: 0-нет, 1-да */
  ,nROUND_SIGN    in number default 0     /* Округлять: 0-нет, 1-да */
  ,nSUMM          out number
  ,nSUMMWITHNDS   out number
  ,nSUMM_NDS      out number
  ,nPRICE         out number
  ) 
  is
    nTaxGr    pkg_std.tref;  
  begin
    /* RN налоговой группы */
    find_dictaxgr_code(nflag_smart => nFLAGSMART
                      ,ncompany    => nCOMPANY
                      ,scode       => sTAXGR
                      ,nrn         => nTaxGr );
    /* Рассчёт сумм */
    dictaxis_calc_base( nflagsmart   => nFLAGSMART
                       ,ncompany     => nCOMPANY
                       ,ninsumm      => nINSUMM
                       ,ntaxgr       => nTaxGr
                       ,ddate        => dDATE
                       ,nsumm_sign   => nSUMM_SIGN
                       ,nquant       => nQUANT
                       ,nncp_sign    => nNCP_SIGN
                       ,nsumm        => nSUMM        
                       ,nsummwithnds => nSUMMWITHNDS 
                       ,nsumm_nds    => nSUMM_NDS    
                       ,nprice       => nPRICE );
  end DICTAXIS_CALC;  
  /*#########################################################################################################*/

end USR_PKG_DICTAXGR;
/
