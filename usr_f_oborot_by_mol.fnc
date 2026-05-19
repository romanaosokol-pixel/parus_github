create or replace function usr_f_oborot_by_mol
(
  pin_com       goodssupply.company%type
 ,pin_nstore    goodssupply.store%type
 ,pin_nmol      agnlist.rn%type      /* RN МОЛ из документа */
 ,pin_rest_date date default trunc(sysdate)                /* Дата остатка */
 ,pin_gprn      goodssupply.prn%type default null/* Если отбор по партии  */
 ,pin_nmodif    goodsparties.nommodif%type default null/* Если хотим отбор по модификации номенклатуры (Если задан PIN_GPRN, то не имеет смысла) */
 ,pin_ser       goodsparties.sernumb%type default null /* отбор по серии */

  
) return usr_tp_oborot_mol
  pipelined is
begin
  
/* 

   2025-06-20 Городецкий 
   Функция предназначена для вывода движения по складу на котором ведется учет по МОЛ  - "Временное перемещение" 
   Для алгоритма вычисления остатка по МОЛ 
   
*/

  /*--- Создаем описание строки таблицы
  CREATE OR REPLACE TYPE USR_TR_OBOROT_MOL AS OBJECT (GPRN number(17), gyrn number(17), nmol number(17), Q NUMBER(17,5));
  --- Создаем описание таблицы
  CREATE OR REPLACE TYPE USR_TP_OBOROT_MOL AS TABLE OF USR_TR_OBOROT_MOL;  */

  /* Создаем курсор, который вернем из функции */

  /* 
  Так будем его использовать: SELECT * FROM TABLE(USR_F_OBOROT_BY_MOL(pin_com => 90521,...))
  */

  for rec in ( --- Расход (C МОЛ списываем) количество отрицательное
              select gp.rn gprn
                     ,gy.rn gyrn
                     ,st.rn strn
                     ,coalesce(case std.gsmways_type
                                 when 0 then
                                  td.mol
                                 else
                                  td.in_mol
                               end
                               
                              ,wa.agent
                              ,vp.mol
                              ,n.mol) nmol --  MOL_TO
                      /* тип складской операции 0 - расход, 1 - приход */
                     ,case st.oper_type
                        when 0 then
                         -st.quant
                        else
                         st.quant
                      end q -- Приход с + расход с -
              
                from storeoperjourn st
                join goodssupply gy
                  on gy.rn = st.goodssupply
                join goodsparties gp
                  on gp.rn = gy.prn
              
                join doclinks dl
                  on dl.out_document = st.rn
                 and dl.out_unitcode = 'StoreOpersJournal'
              
                left join transinvdept td
                  on td.rn = dl.in_document
                 and dl.in_unitcode = 'GoodsTransInvoicesToDepts'
                left join azsgsmwaystypes std
                  on std.rn = td.stoper /* Тип складской операции (0 - расход, 1 - приход) */
                 and std.company = dl.in_company
              /* */
                left join wroffacts wa
                  on wa.rn = dl.in_document
                 and dl.in_unitcode = 'WriteOffActs'
                left join azsgsmwaystypes swa
                  on swa.rn = wa.stoper /* Тип складской операции (0 - расход, 1 - приход) */
                 and swa.company = dl.in_company
                 and swa.gsmways_type = 0
              
                left join rinvtosup vp
                  on vp.rn = dl.in_document
                 and dl.in_unitcode = 'ReturnInvoicesToSuppliers'
                 and dl.out_unitcode = 'StoreOpersJournal'
              
                left join transinvcust n
                  on n.rn = dl.in_document
                 and dl.in_unitcode = 'GoodsTransInvoicesToConsumers'
              
               where st.operdate <= pin_rest_date
                 and st.company = pin_com
                 and st.oper_type = 0 -- Только расход по журналу
                 and dl.out_unitcode = 'StoreOpersJournal'
                 and gy.store = pin_nstore
                 
                 /*исключим операции где оба МОЛ заданы и МОЛ от кого = МОЛ комму */
                 and  not ( td.mol is not null and td.in_mol is not null and td.mol = td.in_mol)
                    
                 and (pin_gprn is null or gp.rn = pin_gprn)
                 and (pin_nmodif is null or gp.nommodif = pin_nmodif)
                 and (pin_ser is null or gp.sernumb = pin_ser)
                    
                 and gy.company = st.company
                 and coalesce(case std.gsmways_type
                                when 0 then
                                 td.mol
                                else
                                 td.in_mol
                              end
                              
                             ,wa.agent
                             ,vp.mol
                             ,n.mol) = pin_nmol
              
              union all
              --- Приход на мол
              select gp.rn GPRN
                     ,gy.rn GYRN
                     ,st.rn strn
                     ,coalesce(case std.gsmways_type
                                 when 0 then --- Если накладная классическая, то приход на МОЛ - кому, а если стоит складская операция прихлода, то меняем МОЛ местами
                                  td.mol -- (Обратное расходу)
                                 else
                                  td.in_mol
                               end
                               
                              ,wa.agent
                              ,id.agent
                              ,po.agent) mol_rn --  MOL_TO
                      /* тип складской операции 0 - расход, 1 - приход */
                     ,case st.oper_type
                        when 0 then
                         -st.quant
                        else
                         st.quant
                      end q -- Приход с + расход с -
              
                from storeoperjourn st
                join goodssupply gy
                  on gy.rn = st.goodssupply
                join goodsparties gp
                  on gp.rn = gy.prn
                join doclinks dl
                  on dl.out_document = st.rn
                 and dl.out_unitcode = 'StoreOpersJournal'
              
                left join transinvdept td
                  on td.rn = dl.in_document
                 and dl.in_unitcode = 'GoodsTransInvoicesToDepts'
                left join azsgsmwaystypes std
                  on std.rn = td.in_stoper /* Тип складской операции (0 - расход, 1 - приход) */
                 and std.company = dl.in_company
              /* */
                left join wroffacts wa
                  on wa.rn = dl.in_document
                 and dl.in_unitcode = 'WriteOffActs'
                left join azsgsmwaystypes swa
                  on swa.rn = wa.stoper /* Тип складской операции (0 - расход, 1 - приход) */
                 and swa.company = dl.in_company
                 and swa.gsmways_type = 1
              
                left join incomefromdeps id
                  on id.rn = dl.in_document
                 and dl.in_unitcode = 'IncomFromDeps'
              
                left join inorders po
                  on po.rn = dl.in_document
                 and dl.in_unitcode = 'IncomingOrders'
              
               where st.operdate <= pin_rest_date
                 and st.company = pin_com
                 
                 and (pin_gprn is null or gp.rn = pin_gprn)
                 and (pin_nmodif is null or gp.nommodif = pin_nmodif)
                 and (pin_ser is null or gp.sernumb = pin_ser)
                 
                 and dl.out_unitcode = 'StoreOpersJournal'
                 and st.oper_type = 1 -- Только расход по журналу
                 and gy.store = pin_nstore
                 
                  /*исключим операции где оба МОЛ заданы и МОЛ от кого = МОЛ комму */
                 and  not ( td.mol is not null and td.in_mol is not null and td.mol = td.in_mol)
                    
                 and gy.company = st.company
                 and coalesce(case std.gsmways_type
                                when 0 then --- Если накладная классическая, то приход на МОЛ - кому, а если стоит складская операция прихода, то меняем МОЛ местами
                                 td.mol -- (Обратное расходу)
                                else
                                 td.in_mol
                              end
                              
                             ,wa.agent
                             ,id.agent
                             ,po.agent) = pin_nmol)
  loop
    pipe row(usr_tr_oborot_mol(rec.gprn, rec.gyrn, rec.strn, rec.nmol, rec.q));
  end loop;
  return;
end;
/
