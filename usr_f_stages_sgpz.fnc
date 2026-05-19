create or replace function usr_f_stages_sgpz(nfaceacc stages.faceacc%type) return varchar2 is

  v_res faceacc.numb%type;

begin
  /*¬озвращаем лицевой счет этапа проекта */
  /*1 Ћицевой счет этапа договора  присутствует в дицевых счетах этапа проекта (ƒоходный договор)*/
    select f.numb
      into v_res
      from projectstage prst
      join faceacc f
        on f.rn = prst.faceacc
     where prst.faceacc = nfaceacc;
  exception
    when no_data_found then
    
      begin
        /*2. Ћицевой счет этапа договора присутствет в лицевых счетах исполнителей проекта )ƒоговор с исполнителем)*/
      
        select f.numb
          into v_res
          from projectstagepf isp
          join projectstage ps
            on ps.rn = isp.prn
          join faceacc f
            on f.rn = ps.faceacc
         where isp.faceacc = nfaceacc
           and rownum = 1;
      
      exception
        when no_data_found then
          return null;
      end;
    
      return v_res;
    
  end;
/
