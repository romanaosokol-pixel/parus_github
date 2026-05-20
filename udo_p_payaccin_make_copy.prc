create or replace procedure UDO_P_PAYACCIN_MAKE_COPY
(
  
  sEXT_NUMB                 in varchar2,  -- Дата внешнего счета
  dEXT_DATE                 in date,      -- Дата счета
  nSUMM                     in number,    -- Сумма к оплате
  nRN                       in out number                   
) is
  /*
    07/09/2023 Степанов М. Формирование префикса по номеру года
    16/08/2022 Степанов М. Параметр "Цены включают налоги" всегда - Да
    Процедура для действия добавления счета на доплату из ВСО
    
    28-07-2025 Городецкий. Если счте полностью оплачен, то счет на доплату не формируется (выдается предупреждение)
    
        
    grant execute on udo_p_payaccin_make_copy to public;
  */   
  rPIN_IN                   PAYACCIN%rowtype;       -- Запись ВСО
  nPIN_IN                   pkg_std.tREF := nRN;    -- Рег. номер ВСО     
  /* Базовое добавление ВСО на доплату */
  procedure PAYACCIN_BMAKE
  (
    rPIN_IN                   in PAYACCIN%rowtype, -- Рег. номер ВСО
    sEXT_NUMB                 in varchar2,      -- Дата внешнего счета
    dEXT_DATE                 in date,          -- Дата счета
    nSUMM                     in number,        -- Сумма к оплате
    nPIN_OUT                  out number        -- Рег. номер ВСО на доплату
  )
  is
    nPIN_SP                   pkg_std.tREF;           -- Рег. номер спецификации ВСО на доплату
    sDoc_Numb                 PAYACCIN.DOC_NUMB%type; -- Номер ВСО
    sNOMEN                    dicnomns.nomen_code%type;     -- Номенклатура   
    sTAX_GROUP                dictaxgr.code%type;     -- Налоговая группа номенклатуры
    nNOMEN                    pkg_std.tREF;           -- Рег. номер номенклатуры
    nNOMMODIF                 pkg_std.tREF;           -- Рег.номер модификации
    nTAXGR                    pkg_std.tREF;           -- Рег. номер налоговой группы
    nSUMM_NDS                 pkg_std.tSUMM;          -- Сумма НДС
    nSUMM_WITHOUT_NDS         pkg_std.tSUMM;          -- Сумма без НДС
    tPAYCLC                   PAYACCINSPCLC%rowtype;
  begin
     /* Номер ВСО */
     p_payaccin_base_getnextnumb(nCOMPANY  => rPIN_IN.Company,
                                 nJUR_PERS => rPIN_IN.Jur_Pers,
                                 dDOC_DATE => sysdate,
                                 nDOC_TYPE => rPIN_IN.Doc_Type,
                                 sDOC_PREF => D_YEAR(sysdate)/* rPIN_IN.Doc_Pref */, /* 07/09/2023 Степанов М. Формирование префикса по номеру года */
                                 sDOC_NUMB => sDoc_Numb);
     
     /* Копируем заголовок */
     p_payaccin_base_insert(nCOMPANY       => rPIN_IN.COMPANY,
                            nCRN           => rPIN_IN.CRN,
                            nDOC_TYPE      => rPIN_IN.DOC_TYPE,
                            sDOC_PREF      => D_YEAR(sysdate) /*trim(rPIN_IN.DOC_PREF)*/, /* 07/09/2023 Степанов М. Формирование префикса по номеру года */
                            sDOC_NUMB      => sDoc_Numb,
                            sEXT_NUMB      => sEXT_NUMB,
                            dREG_DATE      => dEXT_DATE,
                            dDOC_DATE      => dEXT_DATE,
                            nDOC_STATE     => 0,
                            dSTATE_DATE    => null,
                            dPAY_DATE      => null,
                            nPAYER         => rPIN_IN.JUR_PERS,
                            nPAYERACC      => rPIN_IN.PAYERACC,
                            nSUPPLIER      => rPIN_IN.SUPPLIER,
                            nSUPPLACC      => rPIN_IN.SUPPLACC,
                            nFACEACC       => rPIN_IN.FACEACC,
                            nGRAPHPOINT    => rPIN_IN.GRAPHPOINT,
                            nCURRENCY      => rPIN_IN.CURRENCY,
                            nCURCOURS      => rPIN_IN.CURCOURS,
                            nCURBASE       => rPIN_IN.CURBASE,
                            nAGNFI         => rPIN_IN.AGNFI,
                            nAGNFO         => rPIN_IN.AGNFO,
                            nSTORE         => rPIN_IN.STORE,
                            nVDOC_TYPE     => rPIN_IN.VDOC_TYPE,
                            sVDOC_NUM      => rPIN_IN.VDOC_NUM,
                            dVDOC_DATE     => rPIN_IN.VDOC_DATE,
                            nPRICEWITHTAX  => 1, /* 16/08/2022 Степанов М. Параметр "Цены включают налоги" всегда - Да */
                            nFA_BASECOURSE => rPIN_IN.FA_BASECOURS,
                            nFA_COURSE     => rPIN_IN.FA_COURS,
                            nPLANPAYSUMM   => 0,
                            nFACTPAYSUMM   => 0,
                            nININVSUMM     => 0,
                            nINORDSUMM     => 0,
                            sCOMMENTS      => rPIN_IN.COMMENTS,
                            nPAYTYPE       => rPIN_IN.PAYTYPE,
                            nDISCOUNT      => rPIN_IN.DISCOUNT,
                            nRN            => nPIN_OUT);

     /* Копируем св-ва -- EZST Пока не нужно. */
 /*    pkg_docs_props_vals.COPY(sUNITCODE_FROM => 'PaymentAccountsIn',
                              nDOCUMENT_FROM => rPIN_IN.Rn,
                              sUNITCODE_TO   => 'PaymentAccountsIn',
                              nDOCUMENT_TO   => nPIN_OUT);*/
     
     /* Номенклатура для спецификации */
     sNOMEN := udo_f_get_const_val_str(nFLAG_SMART => 0,nCOMPANY =>  rPIN_IN.Company,sCONST_NAME => 'ВСО_ДОПЛАТА_НОМЕН');
     find_nomenclature_by_code(COMPANY => rPIN_IN.Company,
                               CODE    => sNOMEN,
                               RN      => nNOMEN);
     
     find_nomenclature_taxgroup(nFLAG_SMART  => 0,
                                nFLAG_OPTION => 0,
                                nCOMPANY     => rPIN_IN.Company,
                                sNOMEN       => sNOMEN,
                                sTAX_GROUP   => sTAX_GROUP); 
     begin
       select nm.rn
         into nNOMMODIF
         from nommodif nm
        where nm.prn = nNOMEN
          and rownum = 1;
     exception when no_data_found then 
       p_exception(0 ,'Для номенклатуры "%s" не определена модификация.', sNOMEN);
     end;
     
     /* Налоговая группа */
     find_dictaxgr_code(nFLAG_SMART => 1,
                        nCOMPANY    => rPIN_IN.Company,
                        sCODE       => sTAX_GROUP,
                        nRN         => nTAXGR);   
     
     /* Расчет сумм */
     PKG_DICTAXIS_CALC.P_CALCULATE_BASE(nFLAG_SMART => 0,-- Генерация исключени
                                        nCOMPANY    => rPIN_IN.Company,-- Организаци
                                        dDATE       => dEXT_DATE,-- Дата
                                        nSUMM_SIGN  => 1,-- Признак суммы (0 - без налогов, 1 - с налогами)
                                        nINSUMM     => nSUMM,-- Сумма
                                        nTAXGR      => nTAXGR,-- налоговая группа
                                        nQUANT      => 1,-- количество в основной ЕИ
                                        nNCP_SIGN   => 1);-- учитывать налог с продаж (0 - нет, 1 - да) 
     /* Сумма без налогов */
     nSUMM_WITHOUT_NDS := PKG_DICTAXIS_CALC.F_GET_VALUE( 1 );
     /* НДС */
     nSUMM_NDS := PKG_DICTAXIS_CALC.F_GET_VALUE( 8 );
     
     /* Добавляем спецификацию */
     p_payaccinspec_base_insert(nPRN           => nPIN_OUT,
                                nCOMPANY       => rPIN_IN.Company,
                                nCRN           => rPIN_IN.CRN,
                                nNOMEN         => nNOMEN,
                                nNOMMODIF      => nNOMMODIF,
                                nNOMPACK       => null,
                                nNOMMODIFPACK  => null,
                                sSERNUMB       => null,
                                nCOUNTRY       => null,
                                sGTD           => null,
                                nTAXGR         => nTAXGR,
                                nQUANT         => 1,
                                nQUANTALT      => 0,
                                dBEGINDATE     => null,
                                dENDDATE       => null,
                                nPRICE         => nSUMM,
                                nPRICEMEAS     => 0,
                                nSUMMWITHNDS   => nSUMM,
                                nSUMM          => nSUMM_WITHOUT_NDS,
                                nSUMM_NDS      => nSUMM_NDS,
                                nAUTOCALC_SIGN => 1,
                                nPLANQUANT     => null,
                                nFACTQUANT     => null,
                                nPLANSUMM      => null,
                                nFACTSUMM      => null,
                                nSTORE         => null,
                                sCOMMENTS      => null,
                                nDISCOUNT      => 0,
                                sORIGINAL_NAME => null,
                                nMDMNOMEN      => null,
                                nRN            => nPIN_SP);
     
     /* Связываем документы */
     p_linksall_link_direct(nCOMPANY          => rPIN_IN.Company,
                            sIN_UNITCODE      => 'PaymentAccountsIn',
                            nIN_DOCUMENT      => rPIN_IN.Rn,
                            nIN_PRN_DOCUMENT  => null,
                            dIN_IN_DATE       => trunc(sysdate),
                            nIN_STATUS        => 1,
                            sOUT_UNITCODE     => 'PaymentAccountsIn',
                            nOUT_DOCUMENT     => nPIN_OUT,
                            nOUT_PRN_DOCUMENT => null,
                            dOUT_IN_DATE      => trunc(sysdate),
                            nOUT_STATUS       => 1,
                            nBREAKUP_KIND     => 1);
                            
     begin
       select clc.* 
         into tPAYCLC 
         from PAYACCINSPCLC clc, PAYACCINSPEC sp 
        where clc.prn = sp.rn 
          and sp.prn = rPIN_IN.RN 
          and rownum = 1;
     exception
       when NO_DATA_FOUND then tPAYCLC := null;
     end;

     /*Добавим калькуляцию*/
     if tPAYCLC.Rn is not null then 
       p_payaccinspclc_base_insert(nCOMPANY      => rPIN_IN.Company,
                                   nPRN          => nPIN_SP,
                                   sNUMB         => '1',
                                   nCOST_ARTICLE => tPAYCLC.Cost_Article,
                                   nCOST_PLACE   => tPAYCLC.Cost_Place,
                                   nCOST_PLAN    => 0,
                                   nCOST_FACT    => 0,
                                   nPRIORITY     => tPAYCLC.Priority,
                                   nFACEACCOUNT  => tPAYCLC.Faceaccount,
                                   nGRAPHPOINT   => tPAYCLC.Graphpoint,
                                   nFINOPER_TYPE => tPAYCLC.Finoper_Type,
                                   nQUANT_PLAN   => tPAYCLC.Quant_Plan,
                                   nQUANT_FACT   => tPAYCLC.Quant_Fact,
                                   nSUBDIV       => tPAYCLC.Subdiv,
                                   nRN           => tPAYCLC.Rn);
    end if;                             
  
  end;  
  
begin
   /* Запись ВСО */
   begin
    select p.* 
      into rPIN_IN 
       from PAYACCIN p
     where p.rn = nPIN_IN; 
   exception
      when NO_DATA_FOUND then
        pkg_msg.RECORD_NOT_FOUND(nFLAG_SMART => 0, nDOCUMENT => nPIN_IN, sUNIT_TABLE => 'PAYACCIN');
   end; 
   
   if nvl(UDO_F_PAYACCIN_SUBTRACTSUMM(NRN => rPIN_IN.Rn),0) = 0 then 
   p_exception(0,'Данный счет полностью оплачен. Формирование счета на доплату недопустимо!');     
   end if;
   
  
  /* проверка прав доступа */
  PKG_ENV.PROLOGUE( rPIN_IN.COMPANY,null,rPIN_IN.CRN,'PaymentAccountsIn','PAYACCIN_INSERT','PAYACCIN' );
     
  /* базовое добавление ВСО на доплату */
  PAYACCIN_BMAKE(rPIN_IN   => rPIN_IN, 
                 sEXT_NUMB => sEXT_NUMB,
                 dEXT_DATE => dEXT_DATE,
                 nSUMM     => nSUMM,    
                 nPIN_OUT  => nRN); 
  
  /* фиксация окончания выполнение действия */
  PKG_ENV.EPILOGUE( rPIN_IN.COMPANY,null,rPIN_IN.CRN,'PaymentAccountsIn','PAYACCIN_INSERT','PAYACCIN',nRN );
  
end ;
/
