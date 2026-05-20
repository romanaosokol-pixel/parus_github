create or replace procedure UDO_P_WROFFACTS_COMMENTS_COPY
(
  NCOMPANY in number, -- Рег. номер Компании
  NIDENT   in number,  -- Идентификатор отмеченной записи
  SCOMMENTS in varchar2 -- Комментарий 
  
)

  /*Процедура для раздела Акты недосдачи/оприходования излишков.
  Копирование примечания в выбранные строки Актов*/

 is

begin

 /* for C in (select W1.RN
              from SELECTLIST SL,
                   WROFFACTS  W1
             where SL.IDENT = NIDENT
               and SL.DOCUMENT = W1.RN
               and W1.COMPANY = NCOMPANY)
  
  loop*/
  
  update WROFFACTS W 
  set W.COMMENTS = SCOMMENTS 
  where W.RN in (select WR.RN
                 from SELECTLIST SL,
                      WROFFACTS  WR
                 where SL.IDENT = NIDENT
                 and SL.DOCUMENT = WR.RN
                 and WR.COMPANY = NCOMPANY);
  
/*  end loop;*/

end UDO_P_WROFFACTS_COMMENTS_COPY;
/

