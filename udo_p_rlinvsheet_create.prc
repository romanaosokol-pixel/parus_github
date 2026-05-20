create or replace procedure usr_p_rlinvsheet_create(ncompany             in companies.rn%type /* регистрационный номер организации */
                                                   ,ncrn                 in rlinvsheet.crn%type  /*Каталог */
                                                   ,ddocdate             in date /* дата ведомости инвентаризации */
                                                   ,sstore               in azsazslistmt.azs_number%type /* код склада */
                                                   ,sstplracks_numb_from in varchar /* начальный номер ящика/ячейки */
                                                   ,sstplracks_numb_to   in varchar /* конечный номер ящика/ячейки */
                                                   ,snomen_crn           in acatalog.name%type /* наименование каталога номенклатуры */
                                                   ,snomen_group         in dicgnomn.group_code%type /* код группы номенклатуры */
                                                   ,snomen               in dicnomns.nomen_code%type /* код номенклатуры */
                                                   ,nrest_negative       in number /* отбор отрицательных остатков (0 - нет, 1 - да) */
                                                   ,nrest_sign           in number /*  отбор остатков с нулевым ко-вом в осн.ЕИ и не 0 в доп. 0 - нет, 1 - да */
                                                   ,ndetail_sign         in number /* детализация (0 - модификация/упаковка, 1 - партия) */
                                                   ,sfaceacc             in varchar2 /* ШПЗ */
                                                   )
/* Пользовательское действие для формирования ведомости по ячейкам 
  Столярский Е.З. 07/02/2024 
  
  Городецкий О.И. 13-04-2026 Добавил отбор по ШПЗ
  
  grant execute on UDO_P_RLINVSHEET_CREATE to public; */
 as
  nstore               azsazslistmt.rn%type; -- RN склада
  nnomen_crn           acatalog.rn%type; -- RN каталога номенклатуры
  nnomen_group         dicgnomn.rn%type; -- RN группы номенклатуры
  nnomen               dicnomns.rn%type; -- RN номенклатуры

  ntmprn               rlinvsheet.rn%type;
  sstplracks_pref_from stplracks.pref%type; -- начальный префикс ящика/ячейки
  sstplracks_pref_to   stplracks.pref%type; -- конечный префикс ящика/ячейки
  sstplracks_n_from    stplracks.numb%type; -- начальный номер ящика/ячейки
  sstplracks_n_to      stplracks.numb%type; -- конечный номер ящика/ячейки
  nrn number(17);
  ---ncrn                  rlinvsheet.crn%type; 
  ---rEnv          pkg_env_base.tenv;
  
  /* поиск регистрационных номеров (то же что и JOIN) */
  procedure solve_params(sstore       in azsazslistmt.azs_number%type /* код склада */
                        ,nstore       out azsazslistmt.rn%type /* -- RN склада */
                        ,snomen_crn   in acatalog.name%type /*-- наименование каталога номенклатуры */
                        ,nnomen_crn   out acatalog.rn%type /* -- RN каталога номенклатуры */
                        ,snomen_group in dicgnomn.group_code%type /* -- код группы номенклатуры */
                        ,nnomen_group out dicgnomn.rn%type /* -- RN группы номенклатуры */
                        ,snomen       in dicnomns.nomen_code%type /*-- код номенклатуры */
                        ,nnomen       out dicnomns.rn%type -- RN номенклатуры
                         ) is
  begin
    /* поиск склада */
    find_dicstore_numb(0, ncompany, sstore, nstore);
    /* поиск каталога по наименованию. */
    
    
    
    if not rtrim(snomen_crn) is null
    then
      find_acatalog_name(0, ncompany, null, 'Nomenclator', rtrim(snomen_crn), nnomen_crn);
    else
      nnomen_crn := null;
    end if;
    /* поиск группы ТМЦ */
    if not rtrim(snomen_group) is null
    then
      find_dicgnomn_code(0, 0, ncompany, rtrim(snomen_group), nnomen_group);
    else
      nnomen_group := null;
    end if;
    /* поиск номенклатуры */
    if not rtrim(snomen) is null
    then
      find_dicnomns_by_code(0, ncompany, rtrim(snomen), nnomen);
    else
      nnomen := null;
    end if;
  end;

begin
  --  nRN := null;
 
  sstplracks_pref_from := trim(substr(sstplracks_numb_from, 1, instr(sstplracks_numb_from, '-') - 1));
  sstplracks_n_from    := trim(substr(sstplracks_numb_from, instr(sstplracks_numb_from, '-') + 1));
  sstplracks_pref_to   := trim(substr(sstplracks_numb_to, 1, instr(sstplracks_numb_to, '-') - 1));
  sstplracks_n_to      := trim(substr(sstplracks_numb_to, instr(sstplracks_numb_to, '-') + 1));
  
  /* проверка прав доступа */
  pkg_env.prologue(ncompany, null, ncrn, 'RealizationInventorySheet', 'RLINVSHEET_INSERT', 'RLINVSHEET');
  /* поиск регистрационных номеров (то же что и JOIN) */
  solve_params(sstore, nstore, snomen_crn, nnomen_crn, snomen_group, nnomen_group, snomen, nnomen);
  /* базовое добавление */
  udo_p_rlinvsheet_base_create(ncompany
                              ,ncrn
                              ,ddocdate
                              ,nstore
                              ,sstplracks_pref_from
                              ,sstplracks_n_from
                              ,sstplracks_pref_to
                              ,sstplracks_n_to
                              ,nnomen_crn
                              ,nnomen_group
                              ,nnomen
                              ,nrest_negative
                              ,nrest_sign
                              ,ndetail_sign
                              ,sfaceacc  
                              ,ntmprn);
  /* фиксация окончания выполнение действия */
  pkg_env.epilogue(ncompany, null, ncrn, 'RealizationInventorySheet', 'RLINVSHEET_INSERT', 'RLINVSHEET', ntmprn);
end;
/
