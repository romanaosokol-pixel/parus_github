create or replace function usr_f_mark_projectstage_name
(
  ndocument in number
 ,sunitcode in varchar2
) return varchar2 is

  v_res projectstage.name%type:=ndocument||' '||sunitcode;

begin

  case sunitcode
    when 'PayNotes' then
      
    
      begin
        select ps.name
          into v_res
          from paynotes pn            
          join projectstage ps
            on ps.faceacccust = pn.faceacc
         where PN.rn = ndocument
           and rownum = 1;
      exception
        when no_data_found then
          return null;
      end;
    else
      return null;
    
  end case;
  return v_res;
end;
/
