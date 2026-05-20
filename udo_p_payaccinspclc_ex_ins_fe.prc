create or replace procedure UDO_P_PAYACCINSPCLC_EX_INS_FE
  (
    nCOMPANY         in number,         -- Организация
    NPRN             in number,         -- Рег номер родителя
    SATRIB           in varchar2,       -- атрибут
    SFACEAC          in out varchar2,   -- Л/С строки калькуляции
    SFACEAC_ND       in out number      -- Л/С строки калькуляции
  )
is
begin
  /* Добавление записи расширения форма*/
  UDO_PKG_PAYACCINSPCLC_EX.PAYACCINSPCLC_EX_INS_FE
  (
    nCOMPANY         => nCOMPANY,
    NPRN             => NPRN,
    SATRIB           => SATRIB,
    SFACEAC          => SFACEAC,
    SFACEAC_ND       => SFACEAC_ND
  );
end UDO_P_PAYACCINSPCLC_EX_INS_FE;
-- grant execute on UDO_P_PAYACCINSPCLC_EX_INS_FE to public;
/

