create or replace function usr_f_proj_producttype_get(nrn in project.rn%type) return varchar2 is

  /*v_sptype      prjtype.code%type;
  v_producttype varchar2(2000);
  v_dog_rn      contracts.rn%type;*/

begin
/*По заявке от 30-04-2026 Куроедовой А.Б. Тикет: 230426/24542
  Тип продукции это свойство проекта!
  Нет проекта - нет типа продукции.
  
  Городецкий О.И.
*/

begin
 return usr_pkg_docs_props_vals.get_val_str(ndoc_prop => 219295664
                                                        ,sunitcode => 'Projects'
                                                        ,ndocument => nrn);
end;                                                        




/*  \* Поиск признака "Тип продукции
   0. Если тип проекта 22, то NULL
   1. Смотрим в номенклатурах проекта (Проект. Этап. Ведомость производства )     
   2. Если не нашли, то смотрим, связан ли Проект с договором
       2.1. Если связи нет, то берем из свойства проекта
       2.2. Если связь есть, то берем из номенклатур договора (график отгрузки)  
          2.2.1. если в номенклатуре нет, то берем из Свойства Договора
          2.2.2. Если не нашли тип продукции, то берем из свойства Проекта
  *\

  \*0 Тип проекта *\
  begin
    select pt.code into v_sptype from project pr join prjtype pt on pt.rn = pr.prjtype where pr.rn = nrn;
  exception
    when no_data_found then
      v_sptype := null;
  end;

  if v_sptype = '22'
  then
    return null;
  end if;

  \*1 смотрим номенклатуры ведомости производства этапа проекта *\
  for nom in (select distinct usr_f_prst_sht_producttype_get(nnomen_rn => mr.nomenclature) tp
                from projectstage ps
                join udo_projectstage_sht psv
                  on psv.prn = ps.rn
                join fcmatresource mr
                  on mr.rn = psv.matres
               where ps.prn = nrn
               order by 1)
  loop
  
    v_producttype := strcombine(sleft      => v_producttype
                               ,sright     => nom.tp
                               ,sdelimeter => ';');
  end loop;
  

  if v_producttype is not null
  then
    return v_producttype||' (1)';
  end if;

  \* Если проект связан с договором, то Смотрим в договоре *\
  begin
    select dl.out_document
      into v_dog_rn
      from doclinks dl
     where dl.in_document = nrn
       and dl.in_unitcode = 'Projects'
       and dl.out_unitcode = 'Contracts' and rownum = 1;
         
  exception
    when no_data_found then
      v_dog_rn := null;
    
  end;
 
  if v_dog_rn is null
  then
    \* 2.2 Если связи с договорами нет, то берем из свойства проекта *\
    return usr_pkg_docs_props_vals.get_val_str(ndoc_prop => 219295664
                                                        ,sunitcode => 'Projects'
                                                        ,ndocument => nrn);
  
  else
    \* связь есть Берем из номенклатур Договора либо свойства Договора *\
    for nom in (select distinct usr_f_prst_sht_producttype_get(nnomen_rn => gr.nomen) tp
                  from stages st
                  join fcacoperplans gr
                    on gr.prn = st.faceacc
                 where st.prn = v_dog_rn
                   and inexp_sign = 1 \* расход*\
                 order by 1)
    loop
      v_producttype := strcombine(sleft      => v_producttype
                                 ,sright     => nom.tp
                                 ,sdelimeter => ';');
    
    end loop;
    
    if v_producttype is not null then return v_producttype'; end if;
    
    return usr_pkg_docs_props_vals.get_val_str(ndoc_prop => 219295664
                                                      ,sunitcode => 'Contracts'
                                                      ,ndocument => v_dog_rn)';
    
      
  end if;

  return null;*/

end;
/
