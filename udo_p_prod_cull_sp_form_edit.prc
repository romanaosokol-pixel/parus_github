create or replace procedure UDO_P_PROD_CULL_SP_FORM_EDIT
(
  nRN                         in number, -- Рег. номер
  nMODE                       in out number,
  nFIRST                      in out number,
  sATTRIB                     in varchar2,
  nPRN                        in number,
  STORE_CULL_CODE             in out varchar2, -- склад документа
  DDOC_DATE                   in out date,     -- Дата документа
  NQUANT                      in out number, -- кол-во переданное на сертификацию
  NQUANT_GOOD                 in out number -- количесво годных
) is
  /*
  Процедура для валидатора формы редактирования спецификации раздела "Сертификация ТМЦ"  
  grant execute on UDO_P_PROD_CULL_SP_FORM_EDIT to public;
  */
  nTMP pkg_std.tREF;
  
  /* проверка значений */
  procedure check_quant
  (
    NQUANT    in number,
    NQUANT_GOOD    in number
  )
  is
  begin
    if NQUANT < NQUANT_GOOD then
      p_exception(0,'Количество сертифицированных должно быть меньше либо равно количеству переданных на сертификацию.');
    end if;
  end;
   
begin
  if nFIRST = 1 then 
  
    if nMODE in (0,1) then  
      /* Атрибуты записи родителя */
      UDO_PKG_PROD_CULL.CULL_FIND_ATTR(nRN         => nPRN,
                                       dDOC_DATE   => DDOC_DATE,
                                       nSTORE_CULL => nTMP,
                                       sSTORE_CULL => STORE_CULL_CODE);

      NQUANT_GOOD := 0;
     else 
      NQUANT_GOOD := UDO_PKG_PROD_CULL.GET_QUANT_GOOD(nRN);
     end if;
          
     nFIRST := 0;
   end if; 
      
   /*  изменить кол-во переданных в сертификацию  */
   if sATTRIB = 'NQUANT' then
     
     /* проверка корректности значения */
     check_quant(NQUANT => NQUANT, NQUANT_GOOD => NQUANT_GOOD);
   end if; 
   
   /*
// Наименование номенклатуры
function GetNomenName()
{
 try{
    //параметры родителя
    Query.Sql.Text = "select UDO_F_DICNOMMODIF_NAME((select t.nomen_name from v_dicnomns t  where t.nomen_code  ='"+ SNOMEN.Value+"' and t.version  = f_company_to_version(0 ,"+company+",'Nomenclator')),"+
                     "                              (select t.smodif_code from v_nommodif t where t.snomen_code ='"+ SNOMEN.Value+"' and t.nversion = f_company_to_version(0 ,"+company+",'Nomenclator') and t.smodif_code ='"+SMODIF.Value+"')) sname from dual ";
    //ShowMessage (Query.Sql.Text);
    Query.Open();
      SNOMEN_NAME.Value = Query.FieldByName("sname").Value;
    Query.Close();
   }
catch(e){ShowMessage(e.description)}
}*/
end UDO_P_PROD_CULL_SP_FORM_EDIT;
/

