create or replace procedure UDO_P_LOADEXT_ORD_SP_RELINK
(
  nRN      in number,
  nCOMPANY in number,
  sNOMEN   in varchar2,
  sMODIF   in varchar2
) as
  /*
    28/10/2022 Марков МВ.
    Загрузка из внешних источников
    Пользовательская процедура изменения связи между Интермех и модификацией
    Эта процедура необходима, чтобы заменить связь модуля или сборочной единицы при изменении спецификации
    По Интермех меняется версия объекта (по ID версии связь), но сам объект остается без изменения.
    В этом случае не надо создавать новую модификацию, а достаточно заменить связь.
  */
  rSP    UDO_LOADEXT_ORD_SP%rowtype;
  rLINK1 UDO_MODIF_MATCHES%rowtype;
  rLINK2 UDO_MODIF_MATCHES%rowtype;
  nNOMEN PKG_STD.tREF;
  nMODIF PKG_STD.tREF;
begin
  -- ограничение по правам исполнения
  if utilizer not in('CITK_MARKOV', 'MARANICHENKO_AP', 'KHOK') then
    p_exception(0, 'У Вас нет прав на выполнение процедуры изменения связи с модификацией.');
  end if;
  -- строка
  begin
    select SP.*
      into rSP
      from UDO_LOADEXT_ORD_SP SP
     where SP.RN = nRN
       and SP.COMPANY = nCOMPANY;
  exception
    when no_data_found then
      p_exception(0, 'Спецификация загрузки не найдена.');
  end;
  -- связь
  begin
    select MT.* into rLINK1 from UDO_MODIF_MATCHES MT where to_char(MT.EXT_ID) = rSP.Ext_Id;
  exception
    when no_data_found then
      rLINK1 := null;
  end;
  -- модификация
  FIND_DICNOMNS_BY_CODE(nFLAG_SMART => 0, nCOMPANY => nCOMPANY, sNOMEN_CODE => sNOMEN, nRN => nNOMEN);
  FIND_NOMMODIF_BY_CODE(nPRN => nNOMEN, sCODE => sMODIF, nFRN => nMODIF);
  begin
    select MT.* into rLINK2 from UDO_MODIF_MATCHES MT where MT.PRN = nMODIF;
  exception
    when no_data_found then
      rLINK2 := null;
  end;
  
  -- замена ссылки по загрузкам
  update UDO_LOADEXT_ORD_SP SP
     set SP.NOMEN = nNOMEN,
         SP.MODIF = nMODIF
   where SP.Nomen = rSP.Nomen
     and SP.MODIF = rSP.Modif;
   
  -- заменим линк
  update UDO_MODIF_MATCHES MT
     set MT.EXT_ID = to_number(rSP.Ext_Id),
         MT.EXT_NAME = rSP.Ext_Nomen
   where MT.PRN = rLINK2.Prn;
  
  -- удалим старый линк
  if rLINK1.Prn is not null then
    delete from UDO_MODIF_MATCHES where PRN = rLINK1.Prn;
  end if;
  
end;
/

