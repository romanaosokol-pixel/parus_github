create or replace procedure usr_p_buyplanespref_svod_cre
(
  nrn      in buyplane.rn%type
 ,ncompany in buyplane.company%type
) is

begin
--- Очищаем таблицу
  delete usr_tab_buyplanespref_svod t
   where t.company = ncompany
     and t.authid = utilizer;
--- Заполняем таблицу
  insert into usr_tab_buyplanespref_svod
    (rn
    ,prn
    ,company
    ,crn
    ,authid
    ,nmodif
    ,tema
    ,obs
    ,ost_zp
    ,quant_plan 
    ,IGK
    ,OBS_CODE
    ,SUPPLIER_RN
    ,ZAKAZ_SVD
    )
    select gen_id_fix
          ,z.prn
          ,z.company
          ,z.crn
          ,utilizer
          ,z.nommodif
          ,z.tema
          ,z.obs
          ,z.ost_zp
          ,z.quant_plan
          ,Z.IGK 
          ,(select fpt.code
                       from agnacc acc, finpaytool fpt
                      where acc.agnacc = Z.obs
                        and fpt.payer_acc = acc.rn and rownum = 1)
          ,z.suppl_rn
          ,usr_f_buyplanespref_svod_nz(nrn => nrn, nnommodif => z.nommodif, stema => z.tema, sobs => z.obs, sigk => z.igk, nagent => z.suppl_rn) ZAKAZ_SVD /*Номер заявки*/  /*Надо написать свою функцию !*/ 
      from (select bsp.prn
                  ,bsp.company
                  ,bsp.crn
                  ,nm.rn nommodif
                  ,d.nomen_code
                  ,d.nomen_name
                  ,ei.meas_mnemo oei
                  ,nm.modif_code
                  ,nm.modif_name
                  ,udo_f_buyplanespref_shifr(lz.rn) tema
                  ,udo_f_buyplanespref_obs(lz.rn) obs
                  ,sum(udo_f_buyplanespref_qnt_cntr_r(lz.rn)) ost_zp
                  ,sum(lz.quant_plan) quant_plan
                  ,udo_f_buyplanespref_igk(LZ.rn) IGK
                  ,bsp.agent suppl_rn
                  
              from buyplanesp bsp
              join buyplanespref lz
                on lz.prn = bsp.rn
              join dicnomns d
                on d.rn = bsp.nomen
              join dicmunts ei
                on ei.rn = d.umeas_main
              join nommodif nm
                on nm.rn = bsp.nommodif
             where bsp.prn = nrn
               and d.rn = nm.prn

             group by bsp.prn
                     ,bsp.company
                     ,bsp.crn
                     ,bsp.agent
                     ,nm.rn
                     ,d.nomen_code
                     ,d.nomen_name
                     ,ei.meas_mnemo
                     ,nm.modif_code
                     ,nm.modif_name
                     ,udo_f_buyplanespref_shifr(lz.rn)
                     ,udo_f_buyplanespref_obs(lz.rn)
                     ,udo_f_buyplanespref_igk(lz.rn)
                    --- ,udo_f_buyplanespref_req_numb(nrn => lz.rn)
            ) z;

end;
/
