create or replace procedure USR_P_IIV_CREATE_IO
/*
Приходные накладные. Заголовок. Формирование приходного ордера
23/08/2023 Степанов М.
*/
(
 nRN                    in number
,nCOMPANY               in number
,sSTORE                 in varchar2
,nIO_STATUS             in number   /* Отрабатывать приходный ордер */
,nINCTRL_CREATE         in number   /* Формировать сетритификация/входной контроль */
,sINCTRL_CATALOG        in varchar2
,sINCTRL_DOC_TYPE       in varchar2
,dINCTRL_SERT_DATE      in date
,sINCTRL_STORE_SPOIL    in varchar2
,sINCTRL_STOPER_SPOIL   in varchar2
,sINCTRL_NOTE           in varchar2
,nTID_CREATE            in number   /* Формировать РН в подразделения */
,sTID_CATALOG           in varchar2
,sTID_STOPER            in varchar2
,sTID_SHEEPVIEW         in varchar2
,sTID_FACEACC           in varchar2
,sTID_IN_STORE          in varchar2
,sTID_IN_STOPER         in varchar2
,sTID_SUBDIV            in varchar2
) 
is
  rRow      ininvoices%rowtype;
  
  nNumber         pkg_std.tnumber;
  sVarchar        pkg_std.tstring;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_IIV_CREATE_IO');

  /* Заголовок */
  rRow := usr_pkg_ininvoices.ininvoices_get(nRN);

  /* Если накладная не отработана, отрабатываем */
  if rRow.status = 0 then
    p_ininvoices_set_status(ncompany   => rRow.company
                           ,nrn        => rRow.rn
                           ,nstatus    => 2
                           ,dwork_date => rRow.doc_date
                           ,nwarning   => nNumber
                           ,smsg       => sVarchar);
    /* если были ошибки */
    if nNumber = 1 then
      p_exception(0, sVarchar);
    end if;
  end if;

  /* Формирование ПО */
  usr_pkg_ininvoices.ininvoices_make_inorders( nrn => nRN, ncompany => nCOMPANY, sstore => sSTORE, nmode => 1 );

  /* Если отработать ПО */
  if nIO_STATUS = 1 then

    /* По заголовкам сформированных документов */
    for c in ( select distinct out_document0 from usr_t_inhierbuff_common ) 
    loop
      /* Отработка */
      p_inorders_set_status( ncompany   => nCOMPANY
                            ,nident     => null
                            ,nrn        => c.out_document0
                            ,nstatus    => 2
                            ,dwork_date => rRow.doc_date
                            ,nwarning   => nNumber
                            ,smsg       => sVarchar );
      /* если были ошибки */
      if nNumber = 1 then
        p_exception(0, sVarchar);
      end if;

      /* Если формировать РН в подразделения */
      if cmp_num( nTID_CREATE, 1 ) = 1 then
          usr_pkg_inorders.inorders_make_transinvdept( nrn        => c.out_document0
                                                      ,ncompany   => NCOMPANY
                                                      ,ddocdate   => rRow.doc_date
                                                      ,scatalog   => sTID_CATALOG
                                                      ,sstoper    => sTID_STOPER
                                                      ,ssheepview => sTID_SHEEPVIEW
                                                      ,sfaceacc   => sTID_FACEACC
                                                      ,sin_store  => sTID_IN_STORE
                                                      ,sin_stoper => sTID_IN_STOPER
                                                      ,ssubdiv    => sTID_SUBDIV );
      end if;

      /* Если формировать сетритификация/входной контроль */
      if cmp_num( nINCTRL_CREATE, 1 ) = 1 then
        udo_p_inorders_make_inctrl( nrn           => c.out_document0
                                   ,sctlg         => sINCTRL_CATALOG
                                   ,sdoc_type     => sINCTRL_DOC_TYPE
                                   ,dsert_date    => dINCTRL_SERT_DATE
                                   ,sstore_spoil  => sINCTRL_STORE_SPOIL
                                   ,sstoper_spoil => sINCTRL_STOPER_SPOIL
                                   ,snote         => sINCTRL_NOTE );
      end if;
    end loop;
  end if;
  
  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end USR_P_IIV_CREATE_IO;
/
