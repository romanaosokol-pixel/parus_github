create or replace procedure usr_p_iiv_update
/*
Приходные накладные.  Исправление
Если значение какого-либо параметра не задано, то используется текущее значение
23/05/2025 Степанов М.
*/
(
 nRN            in number
,sPREF          in varchar2
,dDOC_DATE      in date
,sCURRENCY      in varchar2
,dWORK_DATE     in date
,nUSE_DOC_DATE  in number   /* Использовать дату документа: 0 - нет, 1 - да */
)
is
  rV_Row                v_ininvoices%rowtype;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_IIV_UPDATE');

  /* Считывание текущей записи и заголовка */
  select * into rV_Row from v_ininvoices where nrn = usr_p_iiv_update.nrn;

  /* Подстановка значений */
  rV_Row.ddoc_date  := nvl( dDOC_DATE, rV_Row.ddoc_date );
  if sPREF is not null then
    rV_Row.spref := sPREF;
    p_ininvoices_getnextnumb( ncompany  => rV_Row.ncompany
                             ,sjur_pers => rV_Row.sjur_pers
                             ,ddoc_date => rV_Row.ddoc_date
                             ,stype     => rV_Row.sdoctype
                             ,spref     => rV_Row.spref
                             ,snumb     => rV_Row.snumb );
  end if;                          
  rV_Row.scurrency  := nvl( sCURRENCY, rV_Row.scurrency );
  if nUSE_DOC_DATE = 1 then 
    rV_Row.dwork_date := rV_Row.ddoc_date; 
  else    
    rV_Row.dwork_date := nvl( dWORK_DATE, rV_Row.dwork_date );
  end if;

  /* Выставляем флаг для обхода проверки */
  pkg_flag.set_flag;

  /* Исправление текущей записи */
  usr_pkg_ininvoices.ininvoices_update( rv_row => rV_Row, nmode => 1 );

  /* Улаляем флаг */
  pkg_flag.reset_flag;

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;

end USR_P_IIV_UPDATE;
/
