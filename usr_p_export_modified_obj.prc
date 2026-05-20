create or replace procedure usr_p_export_modified_obj( ---ncompany in number
                                                      -- ,nprocess in number
                                                      nident in number
                                                      -- ,bcontent out blob
                                                      ) is
  sclob_tmp  clob;
  v_obj_name obj_maint.object_name%type;
  /*  Процедура выгружает в заданную директорию изменненые объекты Oracle, которые находятся на поддержке 
  Файл -- Экспорт в файл (раздел не важен, можно прямо из пользовательских процедур)
  
  Городецкий Апрель 2026
  
  https://www.dbops-tech.com/2024/11/blog-post_22.html  Примеры работы с LOB
  */
begin
  dbms_lob.createtemporary(sclob_tmp, true);
  for cur in (with obj as
                 (select distinct t.object_name
                   from obj_maint t
                  where t.in_use = 1)
                select t.name
                      ,t.text
                      ,lag(t.name, 1) over(order by t.name) lag_name
                      ,lead(t.name, 1) over(order by t.name) lead_name
                  from all_source t
                  join obj
                    on obj.object_name = t.name
                 order by t.name
                         ,t.line)
  loop
    
  
    if cmp_vc2(cur.lag_name, cur.name) = 0 or cur.lead_name is null
    
    then
    
    if cur.lead_name is null then 
      dbms_lob.append(sclob_tmp, trim(cur.text));
    end if;
    
    if cur.lag_name is not null then 
      p_file_buffer_insert(nident, cur.lag_name || '.txt', sclob_tmp, null);
      dbms_lob.createtemporary(sclob_tmp, true);
    end if;  
    
    end if;
    
     dbms_lob.append(sclob_tmp, trim(cur.text));
    
  end loop;
  
end;
/
