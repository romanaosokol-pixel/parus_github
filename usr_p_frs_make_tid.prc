create or replace procedure USR_P_FRS_MAKE_TID
/*
Раздел: Переносы между темами (спецификация ТМЦ)
Процедура: Сформировать расходные накладные в подразделения 
04/11/2024 Степанов М.
*/
(
 nIDENT         in number
,nCOMPANY       in number
,sCATALOG       in varchar2
,sDOCTYPE       in varchar2
,dDOCDATE       in date
,sIN_STORE      in varchar2
,sIN_MOL       in varchar2
)
is
  nCatalog              pkg_std.tref; 
  rV_TransInvDept       v_transinvdept%rowtype;
  rV_TransInvDeptSpecs  v_transinvdeptspecs%rowtype;
  nTransInvDept         pkg_std.tref; 

  sVarchar          pkg_std.tstring;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_PAI_INSERT_SP_MIX_NDS');

  /* RN каталога */
  find_acatalog_name(nflag_smart => 0
                    ,ncompany    => nCOMPANY
                    ,nversion    => null
                    ,sunitcode   => 'GoodsTransInvoicesToDepts'
                    ,sname       => sCATALOG
                    ,nrn         => nCatalog);

  /* По отмеченным спецификациям */
  for c in ( select t.*
                   ,lag(t.sgsupply_store, 1) over(order by t.sgsupply_store) as store_lag
                   ,rownum as nrownum
               from selectlist               sl
                   ,udo_v_faceacc_replace_sp t
                   ,goodssupply              gs
              where sl.ident = nIDENT
                and t.nrn    = sl.document
                and gs.rn    = t.ngsupply
             order by t.sgsupply_store )
  loop
    /* Если текущий склад не равен предыдущему */
    if c.sgsupply_store != nvl(c.store_lag, 'null') then
      /* Заполняем значения в переменные для заголовка */
      rV_TransInvDept.ncompany   := nCOMPANY;
      rV_TransInvDept.ncrn       := nCatalog;
      rV_TransInvDept.sjur_pers  := get_jurpersons_code_id(nflag_smart => 0, njur_pers => c.njur_pers);
      rV_TransInvDept.sdoctype   := sDOCTYPE;
      rV_TransInvDept.spref      := d_year(dDOCDATE);
      rV_TransInvDept.ddocdate   := dDOCDATE;
      p_transinvdept_getnextnumb(ncompany  => rV_TransInvDept.ncompany
                                ,sjur_pers => rV_TransInvDept.sjur_pers
                                ,ddocdate  => rV_TransInvDept.ddocdate
                                ,stype     => rV_TransInvDept.sdoctype
                                ,spref     => rV_TransInvDept.spref
                                ,snumb     => rV_TransInvDept.snumb);
      rV_TransInvDept.sstoper     := 'РасходВнутр';
      rV_TransInvDept.sstore      := c.sgsupply_store;
      rV_TransInvDept.smol        := 'Администратор';
      rV_TransInvDept.ssheepview  := 'ПередПроизводство';
      rV_TransInvDept.scurrency   := 'RUB';
      rV_TransInvDept.ncurcours   := 1;
      rV_TransInvDept.ncurbase    := 1;
      rV_TransInvDept.sin_store   := sIN_STORE;
      rV_TransInvDept.sin_mol     := sIN_MOL;
      rV_TransInvDept.sin_stoper  := 'ПриходВнутр';
      /* Добавляем заголовок */
      usr_pkg_transinvdept.transinvdept_insert(rv_row => rV_TransInvDept, smsg => sVarchar);
      /* Сохраняем RN добавленного заголовка */
      nTransInvDept := rV_TransInvDept.nrn;
    end if;
    /* Заполняем значения в переменные для специфкации */
    rV_TransInvDeptSpecs.ncompany     := ncompany;
    rV_TransInvDeptSpecs.nprn         := nTransInvDept;
    rV_TransInvDeptSpecs.ncrn         := nCatalog;
    rV_TransInvDeptSpecs.snomen       := c.snomen_code;
    rV_TransInvDeptSpecs.snommodif    := c.smodif_code;
    rV_TransInvDeptSpecs.sgoodsparty  := c.sgparty_code;
    rV_TransInvDeptSpecs.ssernumb     := c.sgparty_sernumb;
    rV_TransInvDeptSpecs.nprice       := 0;
    rV_TransInvDeptSpecs.npricemeas   := 1;
    rV_TransInvDeptSpecs.nsummwithnds := 0;
    rV_TransInvDeptSpecs.nquant       := c.nquant;
    rV_TransInvDeptSpecs.nquantalt    := c.nquantalt;
    rV_TransInvDeptSpecs.ncoeff       := 0;
    rV_TransInvDeptSpecs.ncoeff_val_sign  := 0;
    rV_TransInvDeptSpecs.ncoeff_calc_sign := 1;
    /* Добавляем спецификацию */
    usr_pkg_transinvdept.transinvdeptspecs_insert(rv_row => rV_TransInvDeptSpecs, smsg => sVarchar);
    /* Обнуляем переменные спецификации */
    rV_TransInvDept.nrn  := null;           
    rV_TransInvDeptSpecs := null;
  end loop;

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;

end;
/
