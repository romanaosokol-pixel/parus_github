create or replace procedure UDO_P_SHEETD28_GETNEXTNUMB
(
  nCOMPANY        in number,
  sJUR_PERS       in varchar2,
  dDOCDATE        in date,
  sDOCTYPE        in varchar2,
  sDOCPREF        in varchar2,
  sDOCNUMB        out varchar2
)
as
  nJUR_PERS       PKG_STD.tREF;
  nDOCTYPE        PKG_STD.tREF;
begin
  /* –азрешение ссылок */
  FIND_JURPERSONS_CODE(0, 0, nCOMPANY, sJUR_PERS, nJUR_PERS);
  FIND_DOCTYPES_CODE_EX(0, 0, nCOMPANY, sDOCTYPE, nDOCTYPE);

  /* генераци€ следующего номера */
  UDO_PKG_SHEETD28_BASE.DOC_GETNEXTNUMB(nCOMPANY, nJUR_PERS, dDOCDATE, nDOCTYPE, sDOCPREF, sDOCNUMB);

end UDO_P_SHEETD28_GETNEXTNUMB;
/

