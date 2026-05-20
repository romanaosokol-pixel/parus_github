create or replace procedure UDO_P_NOMMODIF_TABLE_ALL_NOMEN(
                            nNOMMODIF_OLD   in number,    -- RN модификации (что)
                            sNOMMODIF_NEW   in varchar2,  -- Мнемокод модификации (на что)
                            nCOMPANY        in number/*,
                            nDocs_ols       in number*/                            
                            )is                            
-- Чумаков А.М. 13.11.2013 подмена модификации
nCRN            number;
nNomenOLD       number(17);
sNomenOLD       varchar2(40);
sNOMN_NEW       varchar2(40);  -- Мнемокод номенклатуры (на что)
--nRESULT         number;
begin 
  /* Открываем процесс */
  usr_pkg_process.process_open(sname => 'UDO_P_NOMMODIF_TABLE_ALL_NOMEN');

 /* считывание записи */
  P_NOMMODIF_EXISTS( nCOMPANY,nNOMMODIF_OLD,nCRN );

  /* фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE( nCOMPANY,null,nCRN,'NomenclatorModification','NOMMODIF_DELETE','NOMMODIF',nNOMMODIF_OLD );  
  
  begin
    select d.rn, d.nomen_code
      into nNomenOLD,
           sNomenOLD  
      from dicnomns d, nommodif n
     where n.prn = d.rn
       and n.rn = nNOMMODIF_OLD;   
  end;
  sNOMN_NEW := sNomenOLD;

  UDO_P_DUBLICATS_MATRES
    ( 
       nold_modif => nNOMMODIF_OLD --in number 
      ,smodif => sNOMMODIF_NEW --in number 
      ,snomen => sNOMN_NEW --in number
      ,nDocs_ols => 0
      ); 
 
  -- делаем подмену
  UDO_PKG_DBMS_SUBSTITUTION_VAL.P_NOMMODIF_TABLE_ALL_NOMEN(nNOMMODIF_OLD,sNOMN_NEW,sNOMMODIF_NEW,nCOMPANY);
 
   /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE( nCOMPANY,null,nCRN,'NomenclatorModification','NOMMODIF_DELETE','NOMMODIF',nNOMMODIF_OLD );
  
  /* Закрываем процесс */
  usr_pkg_process.process_close;

/* Аварийный выход */
exception 
when others then
  /* Закрываем процесс */
  usr_pkg_process.process_close;

  /* Выдаём сообщение */
  raise;

end UDO_P_NOMMODIF_TABLE_ALL_NOMEN;
/
