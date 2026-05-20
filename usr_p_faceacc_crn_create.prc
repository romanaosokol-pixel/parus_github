create or replace procedure usr_p_faceacc_crn_create(ncompany        in number
                                                    ,cat_name        in varchar2
                                                    ,cat_parent_name in varchar2
                                                    ,nrn             out number) is

  n_pcrn acatalog.crn%type;

begin
  /*1 Проверим, что каталог с таким именем существует */
  begin
  
    select ac.rn
      into nrn
      from acatalog ac
     where ac.name = cat_name
       and ac.docname = 'FaceAccounts'
       and ac.company = ncompany;
  
  exception
    when no_data_found then
    
      /*2.1 Проверим, что вышестоящий каталог существует,  */
    
      begin
        select ac.rn
          into n_pcrn
          from acatalog ac
         where ac.name = cat_parent_name
           and ac.docname = 'FaceAccounts'
           and ac.company = ncompany;
      
      exception
        when no_data_found then
        
          /* если нет, то найдем RN корневого каталога*/
          select a.rn
            into n_pcrn
            from acatalog a
           where a.docname = 'FaceAccounts'
             and a.company = ncompany
             and a.is_root = 1;
      end;
    
      /*2.2. Создадим каталог без проверки прав на создание */
    
      p_acatalog_base_insert(ncrn      => n_pcrn
                            ,ncompany  => ncompany
                            ,nversion  => null
                            ,sunitcode => 'FaceAccounts'
                            ,sname     => cat_name
                            ,nrn       => nrn);
    
  end;

end;
/
