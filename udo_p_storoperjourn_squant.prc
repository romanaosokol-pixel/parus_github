create or replace procedure UDO_P_STOROPERJOURN_SQUANT
(sSERNUMB in varchar2,
 sSTORE in varchar2,
 dDATE in date,  
 nQUANT out number)
 /*Процедура рассчета складских остатков по номенклатурному номеру*/
 
is
nTEST number(1);
begin

--проверка наличия серии

begin
select 1
into
nTEST
from GOODSPARTIES G
where G.SERNUMB = sSERNUMB
and rownum = 1;
exception
when NO_DATA_FOUND then
  p_exception(0, 'Указаная серия не найдена!');
end;

--вычисление количества ТМЦ на дату для склада; парамерты не обязательны 
  
select sum(sj.quant *(2*sj.oper_type-1))
into
nQUANT
from STOREOPERJOURN SJ,
     GOODSSUPPLY GS,
     GOODSPARTIES GP, 
     AZSAZSLISTMT AZS 
where SJ.GOODSSUPPLY = GS.RN
and GS.PRN = GP.RN 
and GS.STORE = AZS.RN 
and (sj.operdate <= dDATE or sj.operdate <= trunc(sysdate)) --если дата не указана, то остатки считаются на текущую дату;
and (sSTORE is null or AZS.AZS_NAME = sSTORE) -- склад - не обязательный параметh;
and gp.sernumb = sSERNUMB;

end UDO_P_STOROPERJOURN_SQUANT;
/

