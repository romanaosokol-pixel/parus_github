create or replace procedure UDO_P_TRINVDEP_UPDLIST_TMP
(
  nCOMPANY in number, -- организаци€
  nIDENT   in number,
  dBEG     in date, -- начало периода
  dEND     in date -- окончание периода
) as
  /*
    08/04/2023 ћарков ћ¬.
    ќтчет "∆урнал регистрации дл€ –асходных накладных в производство"
    UDO_TRINVDEP_UPDLIST_TMP
    UDO_TRINVDEP_UPDLIST_DETAILS
    UDO_TRINVDEP_UPDLIST_DOCUM
  */
  rTMP     UDO_TRINVDEP_UPDLIST_TMP%rowtype;
  rDET     UDO_TRINVDEP_UPDLIST_DETAILS%rowtype;
  rDOC     UDO_TRINVDEP_UPDLIST_DOCUM%rowtype;
  nTABLERN number(17);

  -- вставка детализации
  procedure ins_det(rROW in out UDO_TRINVDEP_UPDLIST_DETAILS%rowtype) is
  begin
    insert into UDO_TRINVDEP_UPDLIST_DETAILS values rROW;
  end ins_det;
  -- вставка документа
  procedure ins_doc(rROW in out UDO_TRINVDEP_UPDLIST_DOCUM%rowtype) is
  begin
    insert into UDO_TRINVDEP_UPDLIST_DOCUM values rROW;
  end ins_doc;
  -- вставка документа
  procedure ins_tmp(rROW in out UDO_TRINVDEP_UPDLIST_TMP%rowtype) is
  begin
    insert into UDO_TRINVDEP_UPDLIST_TMP values rROW;
  end ins_tmp;

begin
  rTMP.Ident     := nIDENT;
  rTMP.Authid    := utilizer;
  rTMP.Exec_date := sysdate;
  rDET.Ident     := nIDENT;
  rDOC.Ident     := nIDENT;
  -- выбираем удалени€ спецификаций или изменени€ количества в спецификации за период
  for rdp in ( select ARC.RN as ARC_RN,
                     null as UL_RN,
                     ARC.OPERATION,
                     ARC.MODIFDATE,
                     ARC.AUTHID,
                     ARC.OSUSER,
                     ARC.IP_ADDRESS,
                     ARC.NOTE,
                     ARC.TABLERN,
                     trim(substr(ARC.NOTE, 5, instr(ARC.NOTE, ',')-5)) as TABLEPRN,
                     (select DA.NUM_VALUE
                        from UPDATELIST_DETAIL_ARC DA
                       where DA.PRN = ARC.RN
                         and DA.COLUMN_NAME = 'QUANT') as QUANT,
                     (select DA.NUM_VALUE
                        from UPDATELIST_DETAIL DA
                       where DA.PRN = ARC.RN
                         and DA.COLUMN_NAME = 'NOMMODIF') as MODIF,
                     (select DA.NUM_VALUE
                        from UPDATELIST_DETAIL DA
                       where DA.PRN = ARC.RN
                         and DA.COLUMN_NAME = 'GOODSPARTY') as PARTY,
                     (select A.MODIFDATE from UPDATELIST_ARC A where A.TABLERN = ARC.TABLERN and A.OPERATION = 'I') as I_DATE,
                     (select DT.NUM_VALUE from UPDATELIST_ARC A, UPDATELIST_DETAIL_ARC DT
                      where A.TABLERN = ARC.TABLERN and A.OPERATION = 'I'
                        and DT.PRN = A.RN and DT.COLUMN_NAME = 'QUANT') as I_QUANT,
                     (select DT.NUM_VALUE from UPDATELIST_ARC A, UPDATELIST_DETAIL_ARC DT
                      where A.TABLERN = ARC.TABLERN and A.OPERATION = 'I'
                        and DT.PRN = A.RN and DT.COLUMN_NAME = 'NOMMODIF') as I_MODIF,
                     (select DT.NUM_VALUE from UPDATELIST_ARC A, UPDATELIST_DETAIL_ARC DT
                      where A.TABLERN = ARC.TABLERN and A.OPERATION = 'I'
                        and DT.PRN = A.RN and DT.COLUMN_NAME = 'GOODSPARTY') as I_PARTY
                from UPDATELIST_ARC ARC
               where ARC.MODIFDATE between dBEG and dEND
                 and ARC.COMPANY = nCOMPANY
                 and ARC.OPERATION in ('U', 'D')
                 and ARC.TABLENAME = 'TRANSINVDEPTSPECS'
                 and exists (select null
                        from UPDATELIST_DETAIL_ARC DA
                       where DA.PRN = ARC.RN
                         and DA.COLUMN_NAME = 'QUANT')
              union all
              select null as ARC_RN,
                     AR.RN as UL_RN,
                     AR.OPERATION,
                     AR.MODIFDATE,
                     AR.AUTHID,
                     AR.OSUSER,
                     AR.IP_ADDRESS,
                     AR.NOTE,
                     AR.TABLERN,
                     trim(substr(AR.NOTE, 5, instr(AR.NOTE, ',')-5)) as TABLEPRN,
                     (select DA.NUM_VALUE
                        from UPDATELIST_DETAIL DA
                       where DA.PRN = AR.RN
                         and DA.COLUMN_NAME = 'QUANT') as QUANT,
                     (select DA.NUM_VALUE
                        from UPDATELIST_DETAIL DA
                       where DA.PRN = AR.RN
                         and DA.COLUMN_NAME = 'NOMMODIF') as MODIF,
                     (select DA.NUM_VALUE
                        from UPDATELIST_DETAIL DA
                       where DA.PRN = AR.RN
                         and DA.COLUMN_NAME = 'GOODSPARTY') as PARTY,
                    (select A.MODIFDATE from UPDATELIST_ARC A where A.TABLERN = AR.TABLERN and A.OPERATION = 'I'
                     union
                     select U.MODIFDATE from UPDATELIST U where U.TABLERN = AR.TABLERN and U.OPERATION = 'I') as I_DATE,
                     (select DT.NUM_VALUE from UPDATELIST_ARC A, UPDATELIST_DETAIL_ARC DT
                       where A.TABLERN = AR.TABLERN and A.OPERATION = 'I'
                         and DT.PRN = A.RN and DT.COLUMN_NAME = 'QUANT'
                      union
                      select DU.NUM_VALUE from UPDATELIST U, UPDATELIST_DETAIL DU
                       where U.TABLERN = AR.TABLERN and U.OPERATION = 'I'
                         and DU.PRN = U.RN and DU.COLUMN_NAME = 'QUANT'
                      ) as I_QUANT,
                     (select DT.NUM_VALUE from UPDATELIST_ARC A, UPDATELIST_DETAIL_ARC DT
                       where A.TABLERN = AR.TABLERN and A.OPERATION = 'I'
                         and DT.PRN = A.RN and DT.COLUMN_NAME = 'NOMMODIF'
                      union
                      select DU.NUM_VALUE from UPDATELIST U, UPDATELIST_DETAIL DU
                       where U.TABLERN = AR.TABLERN and U.OPERATION = 'I'
                         and DU.PRN = U.RN and DU.COLUMN_NAME = 'NOMMODIF'
                      ) as I_MODIF,
                     (select DT.NUM_VALUE from UPDATELIST_ARC A, UPDATELIST_DETAIL_ARC DT
                       where A.TABLERN = AR.TABLERN and A.OPERATION = 'I'
                         and DT.PRN = A.RN and DT.COLUMN_NAME = 'GOODSPARTY'
                      union
                      select DU.NUM_VALUE from UPDATELIST U, UPDATELIST_DETAIL DU
                       where U.TABLERN = AR.TABLERN and U.OPERATION = 'I'
                         and DU.PRN = U.RN and DU.COLUMN_NAME = 'GOODSPARTY'
                      ) as I_PARTY
                from UPDATELIST AR
               where AR.MODIFDATE between dBEG and dEND
                 and AR.COMPANY = nCOMPANY
                 and AR.OPERATION in ('U', 'D')
                 and AR.TABLENAME = 'TRANSINVDEPTSPECS'
                 and exists (select null
                        from UPDATELIST_DETAIL DA
                       where DA.PRN = AR.RN
                         and DA.COLUMN_NAME = 'QUANT')) loop
    rDET.Ul_Rn      := rdp.ul_rn;
    rDET.Arc_Rn     := rdp.arc_rn;
    rDET.Operation  := rdp.operation;
    rDET.Modifdate  := rdp.modifdate;
    rDET.Authid     := rdp.authid;
    rDET.Osuser     := rdp.osuser;
    rDET.Ip_Address := rdp.ip_address;
    rDET.Note       := rdp.note;
    rDET.Tablern    := rdp.tablern;
    rDET.Quant      := rdp.quant;
    rDET.Tableprn   := to_number(rdp.tableprn);
    rDET.i_Date     := rdp.i_date;
    rDET.i_Quant    := rdp.i_quant;
    rDET.i_Modif      := rdp.i_modif;
    rDET.i_Goodsparty := rdp.i_party;
    rDET.Modif        := rdp.modif;
    rDET.Goodsparty   := rdp.party;
    ins_det(rROW => rDET);
  end loop;
  -- расходные накладные по изменени€м
  nTABLERN := to_number(null);
  for trn in ( select ARC.RN as ARC_RN,
                     null as UL_RN,
                     ARC.OPERATION,
                     ARC.MODIFDATE,
                     ARC.AUTHID,
                     ARC.OSUSER,
                     ARC.IP_ADDRESS,
                     ARC.NOTE,
                     ARC.TABLERN,
                     (select DA.NUM_VALUE
                        from UPDATELIST_DETAIL_ARC DA
                       where DA.PRN = ARC.RN
                         and DA.COLUMN_NAME = 'STATUS') as STATUS
                from UPDATELIST_ARC ARC
               where ARC.COMPANY = nCOMPANY
                 and ARC.TABLENAME = 'TRANSINVDEPT'
                 and exists(select null from UDO_TRINVDEP_UPDLIST_DETAILS D where D.IDENT = nIDENT and D.TABLEPRN = ARC.TABLERN)
                 and exists (select null
                        from UPDATELIST_DETAIL_ARC DA
                       where DA.PRN = ARC.RN
                         and DA.COLUMN_NAME = 'STATUS')
              union all
              select null as ARC_RN,
                     AR.RN as UL_RN,
                     AR.OPERATION,
                     AR.MODIFDATE,
                     AR.AUTHID,
                     AR.OSUSER,
                     AR.IP_ADDRESS,
                     AR.NOTE,
                     AR.TABLERN,
                     (select DA.NUM_VALUE
                        from UPDATELIST_DETAIL DA
                       where DA.PRN = AR.RN
                         and DA.COLUMN_NAME = 'STATUS') as STATUS
                from UPDATELIST AR
               where AR.COMPANY = nCOMPANY
                 and AR.TABLENAME = 'TRANSINVDEPT'
                 and exists(select null from UDO_TRINVDEP_UPDLIST_DETAILS D where D.IDENT = nIDENT and D.TABLEPRN = AR.TABLERN)
                 and exists (select null
                        from UPDATELIST_DETAIL DA
                       where DA.PRN = AR.RN
                         and DA.COLUMN_NAME = 'STATUS')
               order by TABLERN) loop
    rDOC.Tablern    := trn.tablern;
    rDOC.Operation  := trn.operation;
    rDOC.Arc_Rn     := trn.arc_rn;
    rDOC.Ul_Rn      := trn.ul_rn;
    rDOC.Modifdate  := trn.modifdate;
    rDOC.Authid     := trn.authid;
    rDOC.Osuser     := trn.osuser;
    rDOC.Ip_Address := trn.ip_address;
    rDOC.Note       := trn.note;
    rDOC.Status     := trn.status;
    ins_doc(rROW => rDOC);
    --
    if trn.operation = 'I' then
      rTMP.Trinvdep := trn.tablern;
      rTMP.i_Date   := trn.modifdate;
      rTMP.i_Authid := trn.authid;
      ins_tmp(rROW => rTMP);
    end if;
  end loop;

  -- обработка данных
  for rtm in (select *
                from UDO_TRINVDEP_UPDLIST_TMP T
               where T.IDENT = nIDENT
                 and exists (select null
                        from UDO_TRINVDEP_UPDLIST_DOCUM D
                       where D.IDENT = nIDENT
                         and D.TABLERN = T.TRINVDEP
                         and D.STATUS = 1)) loop
    rTMP := rtm;
    -- когда первый раз отработали как факт
    for r1 in (select DOC.MODIFDATE,
                      DOC.AUTHID
                 from UDO_TRINVDEP_UPDLIST_DOCUM DOC
                where DOC.IDENT = nIDENT
                  and DOC.TABLERN = rtm.trinvdep
                  and DOC.STATUS = 1
                order by DOC.MODIFDATE) loop
      rTMP.s_Date   := r1.modifdate;
      rTMP.s_Authid := r1.authid;
      exit;
    end loop;
    -- когда последний раз сн€ли отработку
    for r2 in (select DOC.MODIFDATE,
                      DOC.AUTHID
                 from UDO_TRINVDEP_UPDLIST_DOCUM DOC
                where DOC.IDENT = nIDENT
                  and DOC.TABLERN = rtm.trinvdep
                  and DOC.STATUS = 0
                  and DOC.OPERATION != 'I'
                order by DOC.MODIFDATE desc) loop
      rTMP.Us_Date   := r2.modifdate;
      rTMP.Us_Authid := r2.authid;
      exit;
    end loop;
    --
    update UDO_TRINVDEP_UPDLIST_TMP T
       set T.S_DATE    = rTMP.s_Date,
           T.S_AUTHID  = rTMP.s_Authid,
           T.Us_Date   = rTMP.Us_Date,
           T.Us_Authid = rTMP.Us_Authid
     where T.TRINVDEP = rtm.trinvdep;
  end loop;
end;
/

