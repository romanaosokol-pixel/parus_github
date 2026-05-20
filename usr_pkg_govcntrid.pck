create or replace package usr_pkg_govcntrid is
  /*
  Городецкий О.И. 17/09/2025
    Package предназначен для работы с разделом "Идентификаторы Государственных контрактов".
  
    */

  /*#########################################################################################################*/

  procedure govcntrid_ainsert
  /*
    Заголовок. после добавления
    */
  (
    nrn      in number
   ,ncompany in number
  );
  /*#########################################################################################################*/
  
  procedure govcntrid_aupdate
  /*
    Заголовок. после добавления
    */
  (
    nrn      in number
   ,ncompany in number
  );
  /*#########################################################################################################*/

end;
/
create or replace package body usr_pkg_govcntrid is


 /*#########################################################################################################*/

  procedure govcntrid_ainsert
  /*
    Заголовок. после добавления
    */
  (
    nrn      in number
   ,ncompany in number
  ) is
  
    scode            govcntrid.code%type;
    ngovcustomer_old govcntrid.govcustomer%type;
    ngovcustomer_new govcntrid.govcustomer%type;
  
  begin
  
    select id.code
          ,id.govcustomer
      into scode
          ,ngovcustomer_old
      from govcntrid id
     where id.rn = nrn;
  
    if scode is not null
    then
      begin
        select ag.rn
          into ngovcustomer_new
          from docs_props_vals zsv
          join agnlist ag
            on ag.rn = zsv.unit_rn
         where zsv.str_value = substr(scode
                                     ,5
                                     ,3)
           and zsv.unitcode = 'AGNLIST'
           and zsv.docs_prop_rn = 217650557;
      
      exception
        when no_data_found then
          ngovcustomer_new := null;
      end;
    
      if nvl(ngovcustomer_old
            ,0) != nvl(ngovcustomer_new
                      ,0) /* Проверим необходимость замены*/
      then
        update govcntrid id set id.govcustomer = ngovcustomer_new where id.rn = nrn;
      end if;
    end if;
  
  end;
 /*#########################################################################################################*/
 
 
  procedure govcntrid_aupdate
  /*
    Заголовок. после добавления
    */
  (
    nrn      in number
   ,ncompany in number
  ) is
  
    scode            govcntrid.code%type;
    ngovcustomer_old govcntrid.govcustomer%type;
    ngovcustomer_new govcntrid.govcustomer%type;
  
  begin
  
    select id.code
          ,id.govcustomer
      into scode
          ,ngovcustomer_old
      from govcntrid id
     where id.rn = nrn;
  
    if scode is not null
    then
      begin
        select ag.rn
          into ngovcustomer_new
          from docs_props_vals zsv
          join agnlist ag
            on ag.rn = zsv.unit_rn
         where zsv.str_value = substr(scode
                                     ,5
                                     ,3)
           and zsv.unitcode = 'AGNLIST'
           and zsv.docs_prop_rn = 217650557;
      
      exception
        when no_data_found then
          ngovcustomer_new := null;
      end;
    
      if nvl(ngovcustomer_old
            ,0) != nvl(ngovcustomer_new
                      ,0) /* Проверим необходимость замены*/
      then
        update govcntrid id set id.govcustomer = ngovcustomer_new where id.rn = nrn;
      end if;
    end if;
  
  end;
 /*#########################################################################################################*/
 
end usr_pkg_govcntrid;
/
