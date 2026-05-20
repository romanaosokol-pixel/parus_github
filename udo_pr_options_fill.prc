create or replace procedure UDO_PR_OPTIONS_FILL(
       nCOMPANY    in number,  -- Организация
       nIDENT      in numeric  -- Регистрационный номер записи
)
is
-- Процедура размножения Параметров одного пользователя на всю его группу
nNewRN       number(17);
sAuthID      varchar2(30) := '';
nRowAdd      number(17) := 0;
nRowUpd      number(17) := 0;
opt_row      OPTIONS%rowtype;
opt_exist    OPTIONS%rowtype;

begin

--  begin
  for opt_row in (
    select opt.* --into opt_row /*authid into sAuthID*/ 
      from OPTIONS opt, selectlist sl
     where sl.ident = nIDENT and sl.document = opt.RN --and opt.rn = nIDENT
       and opt.company = nCOMPANY
       and (opt.str_value is not null or opt.num_value is not null or opt.date_value is not null)
/*     exception when NO_DATA_FOUND then
       sAuthID := '';
       p_exception(0,'Ошибка чтения данных пользователя IDENT="' || nIDENT || '" !!!');*/
--  end;
  ) loop
  
  sAuthID := opt_row.authid;
  if ('' = sAuthID or sAuthID is NULL) then
    p_exception(0,'Пользователь строки "' || opt_row.rn || '" неопределен!!!');
  end if;

  -- Если вдруг все значения пустые, то не размножаем.
  if (opt_row.str_value is null and opt_row.num_value is null and opt_row.date_value is null) then
    p_exception(0,'str_value "' || opt_row.str_value || '"; num_value "' || opt_row.num_value || '"; date_value "' || opt_row.date_value||'"');
  end if;

  for rec in (
    select us.* from USERLIST us 
     where us.crn in (select st.crn from USERLIST st where st.authid = sAuthID)
       and us.authid != sAuthID
    --t.crn = 7595112
  ) loop
--p_exception(0,'Name ' || rec.name || '; sAuthID ' || sAuthID);
    begin
      select opt.* into opt_exist from OPTIONS opt 
       where opt.company = opt_row.company and opt.unitcode = opt_row.unitcode
         and opt.code = opt_row.code and opt.numb = opt_row.numb
         and opt.authid = rec.authid;
       exception when NO_DATA_FOUND then
         opt_exist := NULL;
    end;

    if opt_exist.rn is null then
--p_exception(0,'RN is NULL  ' || opt_row.code);
         P_OPTIONS_BASE_INSERT(sCODE => opt_row.code,
                  sNAME          => opt_row.name,
                  sUNITCODE      => opt_row.unitcode,
                  nNUMB          => opt_row.numb,
                  sAUTHID        => rec.authid,
                  nCOMPANY       => opt_row.company,
                  nVERSION       => opt_row.version,
                  nOPT_LOAD      => opt_row.opt_load,
                  nOPT_TYPE      => opt_row.opt_type,
                  nOPT_KIND      => opt_row.opt_kind,
                  nOPT_MODE      => opt_row.opt_mode,
                  nENTRY_TYPE    => opt_row.entry_type,
                  nDATA_TYPE     => opt_row.data_type,
                  nSTR_WIDTH     => opt_row.str_width,
                  nNUM_WIDTH     => opt_row.num_width,
                  nNUM_PRECISION => opt_row.num_precision,
                  sENUM_CODE     => opt_row.enum_code,
                  sENUM_TEXT     => opt_row.enum_text,
                  nLINK_PARAM    => opt_row.link_param,
                  sLINK_OPTION   => opt_row.link_option,
                  sSTR_VALUE     => opt_row.str_value,
                  nNUM_VALUE     => opt_row.num_value,
                  dDATE_VALUE    => opt_row.date_value,
                  nRN            => nNewRN);
         nRowAdd := nRowAdd + 1;
    else 
--p_exception(0,'Name ' || opt_exist.authid || '; opt_exist.code ' || opt_exist.code);
      P_OPTIONS_BASE_UPDATE(nRN => opt_exist.rn,
                 sNAME          => opt_row.name,
                 sUNITCODE      => opt_row.unitcode, -- == opt_exist
                 nNUMB          => opt_row.numb,     -- == opt_exist
                 nOPT_TYPE      => opt_row.opt_type,
                 nOPT_KIND      => opt_row.opt_kind,
                 nOPT_MODE      => opt_row.opt_mode,
                 nENTRY_TYPE    => opt_row.entry_type,
                 nSTR_WIDTH     => opt_row.str_width,
                 nNUM_WIDTH     => opt_row.num_width,
                 nNUM_PRECISION => opt_row.num_precision,
                 sENUM_CODE     => opt_row.enum_code,
                 sENUM_TEXT     => opt_row.enum_text,
                 nLINK_PARAM    => opt_row.link_param,
                 sLINK_OPTION   => opt_row.link_option,
                 sSTR_VALUE     => opt_row.str_value,
                 nNUM_VALUE     => opt_row.num_value,
                 dDATE_VALUE    => opt_row.date_value);
         nRowUpd := nRowUpd + 1;
    end if;

  end loop;
  end loop;

  commit;
p_exception(0,'Добавлено: ' || nRowAdd || '; Изменено: ' || nRowUpd);
  
end UDO_PR_OPTIONS_FILL;
/

