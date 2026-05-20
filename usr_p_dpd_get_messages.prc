create or replace procedure usr_p_dpd_get_messages
/*
Раздел: Распоряжения об изменении заказов подразделений,
        Распоряжения об изменении заказов подразделений (спецификация)
Процедура для получения данных об отправленных писмьах.
create public synonym usr_p_dpd_get_messages for usr_p_dpd_get_messages;
grant execute on usr_p_dpd_get_messages to public;
*/
(
 nRN        in number
,sUNITCODE  in varchar2
,sOUT       out varchar2
)
as
begin
  sOUT := ' ';
  for c in ( select ml.rec_date, mlc.title, mlc.content, listagg( mlca.address, ', ' ) within group ( order by mlca.address ) as saddress
               from doclinks       dl
               join maillst        ml    on ml.rn    = dl.out_document
               join maillstcnt     mlc   on mlc.prn  = ml.rn
               join maillstcntadr  mlca  on mlca.prn = mlc.rn
              where dl.in_unitcode  = sUNITCODE
                and dl.in_document  = nRN
                and dl.out_unitcode = 'MailingList'
             group by ml.rec_date, mlc.title, mlc.content )
  loop
    sOUT := trim( substr( strcombine( sOUT, dts2s( c.rec_date ) ||', '|| c.title, cr||'Заголовок: ' ), 0, 3999 ) );
    sOUT := substr( strcombine( sOUT, c.saddress, cr||'Получатели: ' ), 0, 3999 );
    /*sOUT := substr( strcombine( sOUT, c.content , cr||'Содержание: '||cr ), 0, 3999 ) ;*/
    sOUT := substr( sOUT || cr  ||'-----------------------', 0, 3999 );
  end loop;
end;
/
