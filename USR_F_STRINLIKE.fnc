create or replace function USR_F_STRINLIKE(sSUBSTR in varchar2,
                                                 sSOURCE in varchar2,
                                                 sDELIM  in varchar2,
                                                 sBLANK  in varchar2,
                                                 NotSymb in varchar2) return binary_integer

 as

  V_COL integer;
  V_I   integer;

  V_ZAP varchar2(4000);
  V_UTV varchar2(4000) := '';
  V_OTR varchar2(4000) := '';

begin
  /* Функция обрабатывает по маске утверждения и отрицания
  обрабатываются символы * (любые символы), ? (один любой символ), ! (отрицание)-- Заданные в параметрах системы ; (перечисление по ИЛИ)

  */


  if sSOURCE is null or sSOURCE = '' then
    return 1;
  end if;

  V_col := length(sSOURCE) - length(replace(sSOURCE, sDELIM));
  V_col := case V_COL
             when 0 then
              1
             else
              V_COL
           end; -- если разделителей нет, то это одно утверждение

  --- Отделим утверждения от отрицаний
  for V_I in 1 .. V_COL + 1 loop
    V_ZAP := strtok(sSOURCE, sDELIM, V_I);
    if substr(V_ZAP, 1, 1) = NotSymb then
      V_OTR := V_OTR || sDELIM || substr(V_ZAP, 2); -- вырезали символ отрицания
    else
      V_UTV := V_UTV || sDELIM || V_ZAP;
    end if;
  end loop;

  V_OTR := substr(V_OTR, 2);
  V_UTV := substr(V_UTV, 2);
  if V_UTV = '' or V_UTV is null then
    V_UTV := '%';
  end if;

  return case when strinlike(sSUBSTR, V_UTV, sDELIM, sBLANK) = 1 and not STRINLIKE(sSUBSTR, V_OTR, sDELIM, sBLANK) = 1 then 1 else 0 end;
end;
/
