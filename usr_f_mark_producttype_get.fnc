create or replace function usr_f_mark_producttype_get
(
  ncost_faceacc in udo_t_mark.cost_faceacc%type
 ,nfaceacc      in udo_t_mark.faceacc%type
) return varchar2 is

  v_producttype varchar2(2000);

begin
  /*
      Поиск признака "Тип продукции" в Показателях
   0. Если лицевой счет затрат показателя есть в этапе проекта, то берем из проекта
   1. Если проекта нет, то поищем по лицевому счету в договорах
   
  */

  begin
    /* 0 в проектах*/
    select usr_f_proj_producttype_get(ps.prn) into v_producttype from projectstage ps where ps.faceacc = ncost_faceacc;
  exception
    when no_data_found then
      /* 1 в договорах */
      begin
        select usr_f_cont_producttype_get(st.prn) into v_producttype from stages st where st.faceacc = nfaceacc;
      exception
        when others then
          return null;
      end;
  end;

  return v_producttype;

end;
/
