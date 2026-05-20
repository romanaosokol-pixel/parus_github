create or replace procedure usr_p_imp_avrep_create
(
  pin_idx          in number
 ,pin_com          in number default 90521
 ,PIN_DOC_TYPE     in varchar2
 ,pin_cat          in varchar2
 ,pin_sdate        in varchar2
 ,pin_agent_from   in varchar2
 ,pin_nazn_ao      in varchar2
 ,pin_valid_prf    in varchar2
 ,pin_vid_ao       in varchar2
 ,pin_ssum_out_tax in varchar
 ,pin_ssum_tax     in varchar
) is
  ncrn  number(17);
  ncomp cashdocs.company%type := get_session_company();

  
  ddoc_date     cashdocs.cash_docdate%type;

  scash_prefdoc cashdocs.cash_docpref%type;
  scash_numbdoc cashdocs.cash_docnumb%type;
 --- scash_doctype doctypes.doccode%type := 'АО';

  sagent_from_code agnlist.agnabbr%type;
  npay_sum         cashdocs.pay_sum%type;
  ---ntax_sum         cashdocs.tax_sum%type;

  v_nrn cashdocs.rn%type;
  
  idx integer:= instr(upper(pin_vid_ao),'РУБ.')+4; 

begin
if pin_agent_from is not null then 
 
 begin
    select a.rn
      into ncrn
      from acatalog a
     where a.name = PIN_CAT
       and a.docname = 'CashDocuments'
       and a.company = ncomp;
  
  exception
    when no_data_found then
      p_exception(0
                 ,'Каталог %s не найден'
                 ,PIN_CAT);
  end;

  begin
    ddoc_date := to_date(pin_sdate
                        ,'DD.MM.YYYY');
  exception
    when others then
      p_exception(0
                 ,'В строке %s файла импорта неверный формат даты %s. Требуется формат DD.MM.YYYY'
                 ,pin_idx
                 ,pin_sdate);
  end;

  scash_prefdoc := to_char(ddoc_date
                          ,'YYYY');

  p_cashdocs_getnextnumb(ncompany      => ncomp
                        ,sjur_pers     => 'Модуль'
                        ,dcash_docdate => ddoc_date
                        ,scash_docpref => scash_prefdoc
                        ,scash_doctype => pin_doc_type
                        ,scash_docnumb => scash_numbdoc);

  begin
    select mol.agnabbr
      into sagent_from_code
      from agnlist mol
     where mol.agnname = pin_agent_from
       and mol.emp = 1
       and mol.version = 91134;
  
  exception
    when no_data_found then
      p_exception(0
                 ,'Контрагент с наименованием %s и признаком "Сотрудник" не найден'
                 ,pin_agent_from);
    
  end;

  begin
    npay_sum := nvl(to_number(replace(replace(pin_ssum_out_tax
                                             ,' '
                                             ,'')
                                     ,','
                                     ,'.'))
                   ,0) + nvl(to_number(replace(replace(pin_ssum_tax
                                                      ,' '
                                                      ,'')
                                              ,','
                                              ,'.'))
                            ,0);
  exception
    when others then
      p_exception(0
                 ,'В строке IDX некоректный формат суммы.'
                 ,pin_idx);
    
  end;

  p_cashdocs_insert(ncompany         => ncomp
                   ,ncrn             => ncrn
                   ,scash_typedoc    => pin_doc_type
                   ,scash_prefdoc    => scash_prefdoc
                   ,scash_numbdoc    => scash_numbdoc
                   ,dcash_datedoc    => ddoc_date
                   ,svalid_typedoc   => 'АО'
                   ,svalid_numbdoc   => PIN_VALID_PRF
                   ,dvalid_datedoc   => ddoc_date    
                   ,sagent_from      => 'МОДУЛЬ'
                   ,sagent_to        => sagent_from_code
                   ,sbunit_mnemo     => null
                   ,stype_oper       => 'Расход Собст'
                   ,spay_info        => trim(pin_nazn_ao||' '||substr(pin_vid_ao, idx))
                   ,spay_note        => null
                   ,npay_sum         => npay_sum
                   ,ntax_sum         => 0
                   ,npercent_tax_sum => 0
                   ,ntax_sal_sum     => 0
                   ,scurrency        => 'RUB'
                   ,sjur_pers        => 'Модуль'
                   ,nunallotted_sum  => 0
                   ,sfin_source      => null
                   ,sspecial_mark    => null
                   ,suin             => null
                   ,nrn              => v_nrn);

end if;
end;
/
