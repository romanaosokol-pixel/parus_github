create or replace function USR_F_TIDS_PONOTE
/*
Раздел: Расходные накладные на отпуск в подразделения (спецификации)
Возвращает примечание ПЭО из спецификаций приходных документов приходной партии
grant execute on USR_F_TIDS_PONOTE to public;
*/
(
 nCOMPANY    in number
,sGOODSPARTY in varchar2
,sNOMEN      in varchar2
,sNOMMODIF   in varchar2
,sSERNUMB    in varchar2
,sCOUNTRY    in varchar2
,sGTD        in varchar2
)
return varchar2 
is
  nGoodsParty pkg_std.tref;
  sRez        pkg_std.tstring;
begin
  /* Приходная партия */
  find_goodsparties_by_doc(ncompany      => nCOMPANY
                          ,nflag_smart   => 1
                          ,sindoc        => sGOODSPARTY
                          ,snomen        => sNOMEN
                          ,snommodif     => sNOMMODIF
                          ,snommodifpack => null
                          ,ssernumb      => sSERNUMB
                          ,scountry      => sCOUNTRY
                          ,sgtd          => sGTD
                          ,nrn           => nGoodsParty);
  /* По примечаниям спецификаций приходных документов */
  for data_ in (select ps.note
                  from inorderspecs ps
                      ,goodssupply  gp
                 where gp.prn         = nGoodsParty
                   and gp.company     = ncompany
                   and ps.goodssupply = gp.rn
                   and rtrim(ps.note) is not null
                union
                select nvl(ps.note, ifd.note) as note
                  from incomefromdepsspec ps
                      ,goodssupply        gp
                      ,incomefromdeps     ifd
                 where gp.prn     = nGoodsParty
                   and gp.company = ncompany
                   and ps.supply  = gp.rn
                   and ps.prn     = ifd.rn
                   and (rtrim(ps.note) is not null or rtrim(ifd.note) is not null))
  loop
    sRez := strcombine(sRez, data_.note, ', ');
  end loop;

  /* Результат */
  return rtrim(sRez, ';');

end;
/
