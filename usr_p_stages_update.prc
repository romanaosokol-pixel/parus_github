create or replace procedure usr_p_stages_update
/*
Раздел: Договоры (этапы)
Процедура: Исправить
Степанов М. 09/04/2021

Городецкий добавил исправление сумм этапа 17/12/2025 (пересчет сумм в валидаторе)
*/
(
 nRN              in number
,sDICTAXGR        in varchar2
,nDICTAXGR_CLEAR  in number
,nSTAGE_SUMTAX    in number
,sDESCRIPTION     in varchar2
,sCOMMENTS        in varchar2
)
IS
  rV_Row        v_stages%rowtype;
  rV_Faceacc    v_faceacc%rowtype;
  
  nNumber       pkg_std.tnumber; 
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_STAGES_UPDATE');

  /* Считывание */
  select * into rV_Row     from v_stages  where nrn = usr_p_stages_update.nrn;
  select * into rV_Faceacc from v_faceacc where nrn = rV_Row.nfaceacc;

  /* Подмена значений в переменную */
  rV_Row.staxgr   := nvl( sDICTAXGR, rV_Row.staxgr ) ;
  if nDICTAXGR_CLEAR = 1 then
    rV_Row.staxgr := null;
  end if;
  rV_Row.nstage_sumtax := nvl( nSTAGE_SUMTAX, rV_Row.nstage_sumtax ) ;
  rV_Row.sdescription  := nvl( sDESCRIPTION, rV_Row.sdescription ) ;
  rV_Row.scomments     := nvl( sCOMMENTS, rV_Row.scomments ) ;

  /* Если заданы входные параметры, инициирующие пересчёт сумм */
  if sDICTAXGR      is not null 
  or nSTAGE_SUMTAX  is not null then
    /* Пересчёт сумм */
    usr_pkg_dictaxgr.dictaxis_calc( nflagsmart   => 0
                                   ,ncompany     => rV_Row.ncompany
                                   ,ddate        => sysdate
                                   ,staxgr       => rV_Row.staxgr
                                   ,ninsumm      => rV_Row.nstage_sumtax
                                   ,nquant       => 1
                                   ,nsumm        => rV_Row.nstage_sum
                                   ,nsummwithnds => rV_Row.nstage_sumtax
                                   ,nsumm_nds    => rV_Row.nstage_sum_nds
                                   ,nprice       => nNumber );
  end if;

 /* Исправление */
  usr_pkg_contracts.stages_update( rv_row => rV_Row, rv_faceacc => rV_Faceacc, nmode => 1 );

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;
END;
/
