create or replace procedure udo_p_wrfactsp_strlp_prms_fe
(
  nCOMPANY    in number, -- Рег. номер организации
  nRN         in number, -- рег номер родителя
  sATRIB      in varchar2, -- Изменение атрибута
  nFIRST      in out number, -- 
  sSTORE      out varchar2, -- Мнемокод Склада
  sSTORE_ND   in out number, -- Доступность Склада
  sCELL       in out varchar2, -- Мнемокод ячейки
  sCELL_ND    in out number, -- Доступность ячейки
  sCELL_NN    in out number, -- Обязательность ячейки
  nREPLACE    in out number, -- с заменой
  nREPLACE_ND in out number, -- Доступность с заменой
  dRES_DATE   out date, -- дата резервирования
  sRES_TYPE   in out varchar2 -- тип резервирования (Приход, Расход)
) as
  /*
    01/11/2024 Марков МВ.
    Акты списания недостач/оприходования излишков (спецификация)
    Действие "Массовое резервирование по МХ"
    Инициализация формы, пересчеты
    grant execute on UDO_P_WRFACTSP_STRLP_PRMS_FE to public;
  */
begin
  /* Пользовательская форма */
  if nFIRST is null then nFIRST := 1; end if;
  UDO_PKG_STRPLRESJRNL_MASS_INS.WROFFACTS_PRMS_FE(nCOMPANY    => nCOMPANY,
                                                  nRN         => nRN,
                                                  sATRIB      => sATRIB,
                                                  nFIRST      => nFIRST,
                                                  sSTORE      => sSTORE,
                                                  sSTORE_ND   => sSTORE_ND,
                                                  sCELL       => sCELL,
                                                  sCELL_ND    => sCELL_ND,
                                                  sCELL_NN    => sCELL_NN,
                                                  nREPLACE    => nREPLACE,
                                                  nREPLACE_ND => nREPLACE_ND,
                                                  dRES_DATE   => dRES_DATE,
                                                  sRES_TYPE   => sRES_TYPE);

end;
/
