create or replace procedure UP_DMSSRCGEN_FILLVIEW
(
  nCOMPANY     in number,
  nIDENT       in number
)
as
  nCLASS       PKG_STD.tREF;
  nVIEW        PKG_STD.tREF;
  nRN          PKG_STD.tREF;
begin
  /* Инициализация ******************************************************************************** */
  begin
    select V.RN, V.PRN
      into nVIEW, nCLASS
      from SELECTLIST L,
           DMSCLVIEWS V
     where L.IDENT = nIDENT
       and V.RN = L.DOCUMENT;
  exception
    when NO_DATA_FOUND then
      P_EXCEPTION(0, 'Представление не найдено.');
  end;

  for CUR in
  (
    select COLUMN_NAME, decode(D.DATA_TYPE, 0, 's', 1, 'n', 'd') as PREFIX
      from DMSCLATTRS A,
           DMSDOMAINS D
     where A.PRN = nCLASS
       and A.DOMAIN = D.RN
     order by POSITION
  )
  loop
    P_DMSCLVIEWSATTRS_INSERT(nVIEW, CUR.COLUMN_NAME, CUR.PREFIX || CUR.COLUMN_NAME, nRN);
  end loop;
end;
/

