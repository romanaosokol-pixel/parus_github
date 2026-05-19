create or replace function usr_f_udodepordssupply_inorder
(
  COMPANY in number,
  NGOODSPARTIES     in number
) return varchar2 is
/* 14/05/2025
 Вызываем функцию #Калькуляция ПО из Заказы подразделений, спецификация, Буфер резервирования товраа по партиям, Партии доступные для резервировнаия
   05/03/2025 KHOK 
   Калькуляция Серии товарного запаса по Приходному ордеру 
   grant execute on USR_F_UdoDepordsSupply_INORDER to public;  
*/

begin
  return UDO_F_GOODSSPLCLC_INORDER(NCOMPANY => COMPANY, NPRN => NGOODSPARTIES);
end ;
/
