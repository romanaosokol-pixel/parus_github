create or replace procedure usr_p_faoop_update
/*
Раздел: Лицевые счета (план расхода)
Процедура: Исправить.
24/03/2026 Степанов М.
create public synonym usr_p_faoop_update for usr_p_faoop_update;
grant execute on usr_p_faoop_update to public;
*/
(
 nRN              in number
,dBEGIN_DATE      in date
,dEND_DATE        in date
,dREAL_DATE       in date   /* Свойство "Реальная дата" */
,sTAXGR           in varchar2
,nQUANT           in number
,nSUMMWITHNDS         in number
)
is
  rV_Row          v_fcacoperplans%rowtype;

  nNumber         pkg_std.tnumber; 
begin
  /* Открытие процесса */
  usr_pkg_process.process_open(sname => 'USR_P_FAOOP_UPDATE');

  /* Считывание */
  select * into rV_Row from v_fcacoperplans where nrn = usr_p_faoop_update.nrn;

  /* Заполнение переменных */
  rV_Row.dbegin_date   := nvl( dBEGIN_DATE   , rV_Row.dbegin_date );
  rV_Row.dend_date     := nvl( dEND_DATE     , rV_Row.dend_date );
  if dREAL_DATE is not null then
    pkg_docs_props_vals .modify( nproperty   => 7526416
                                ,sunitcode   => 'FaceAccountsOperOutPlans'
                                ,ndocument   => rV_Row.nrn
                                ,sstr_value  => null
                                ,nnum_value  => null
                                ,ddate_value => dREAL_DATE
                                ,nrn         => nNumber );
  end if;
  rV_Row.staxgr        := nvl( sTAXGR        , rV_Row.staxgr );
  rV_Row.nquant        := nvl( nQUANT        , rV_Row.nquant );
  rV_Row.nactm_quant   := rV_Row.nquant;
  rV_Row.nsummwithnds  := nvl( nSUMMWITHNDS  , rV_Row.nsummwithnds );

  /* Если заданы входные параметры, инициирующие пересчёт сумм */
  if sTAXGR       is not null 
  or nQUANT       is not null  
  or nSUMMWITHNDS is not null then
    /* Пересчёт сумм */
    usr_pkg_dictaxgr.dictaxis_calc( nflagsmart   => 0
                                   ,ncompany     => rV_Row.ncompany
                                   ,ddate        => sysdate
                                   ,staxgr       => rV_Row.staxgr
                                   ,ninsumm      => rV_Row.nsummwithnds
                                   ,nquant       => 1
                                   ,nsumm        => rV_Row.nsumm
                                   ,nsummwithnds => rV_Row.nsummwithnds
                                   ,nsumm_nds    => rV_Row.nsumm_nds
                                   ,nprice       => rV_Row.nprice );
  end if;

  /* Исправление */
  usr_pkg_faceacc.fcacoperplans_update( rv_row => rV_Row, nmode => 0 );

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;

end;
/
