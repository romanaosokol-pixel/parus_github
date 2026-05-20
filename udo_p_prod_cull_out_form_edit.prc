create or replace procedure udo_p_prod_cull_out_form_edit(nprn              in number /* Рег. номер родительской записи */
                                                         ,pin_doc           in number /* Рег. номер записи */
                                                         ,nrn               in number /* Параметр действия (старное название!)*/
                                                         ,nmode             in out number /* режим обработки (0-добавление, 1-размножение, 2-исправление)  */
                                                         ,nfirst            in out number /* признак первого запуска (1-первый запуск, 0- последующие) */
                                                         ,sattrib           in varchar2 /* Изменяемый атрибут */
                                                         ,nsign_out         in out number /* признак записи */
                                                         ,nsupply           in out number /* рег. номер ТЗ */
                                                         ,snomen            in out varchar2
                                                         ,smodif            in out varchar2
                                                         ,snomen_name       in out varchar2
                                                         ,smodif_name       in out varchar2
                                                         ,scurrency         in out varchar2
                                                         ,sparty            in out varchar2
                                                         ,ssernumb          in out varchar2
                                                         ,sumeas            in out varchar2
                                                         ,store_cull_code   in out varchar2 /* склад документа */
                                                         ,ddoc_date         in out date /* Дата документа */
                                                         ,nquant            in out number /* кол-во переданное на сертификацию*/
                                                         ,nsumm             in out number /* сумма*/
                                                         ,nprice            in out number /* цена */
                                                         ,ssernumb_new      in out varchar2 /* Серия (новая)*/
                                                         ,scert_numb        in out varchar2 /* Номер сертификата */
                                                         ,dcert_from        in out date /* Дата с сертификата  */
                                                         ,dcert_to          in out date /* Дата по сертификата*/
                                                         ,ssernumb_new_vs   in out number /* Признак видимости атрибута "Серия (новая)"*/
                                                         ,scert_numb_vs     in out number /* Признак видимости атрибута "Номер сертификата"*/
                                                         ,dcert_from_vs     in out number /* Признак видимости атрибута "Дата с сертификата "*/
                                                         ,dcert_to_vs       in out number /* Признак видимости атрибута "Дата по сертификата"*/
                                                         ,ncert_gr_vs       in out number /* Признак видимости группы номер сертификата  */
                                                         ,dprod_date_d      in out date /* Дата производства дата */
                                                         ,sprod_date_s      in out varchar2 /* Дата производства текстом */
                                                         ,ssupplier_party   in out varchar2 /* Партия поставщика */
                                                         ,saccept           in out varchar2 /* Приемки */
                                                         ,srecheck_date     in out varchar2 /* Дата перепроверки */
                                                         ,sdp_mm_yyyy       in out varchar2 /* Дата производства в формате MM.YYYY */
                                                         ,sdp_mm_yyyy_txt   out varchar2 /* Сообщение об ошибке */
                                                         ,sdp_syyww         in out varchar2 /* Дата производства в формате YYWW год неделя*/
                                                         ,sdp_syyww_txt     out varchar2 /* Сообщение об ошибке YYWW */
                                                         ,sdp_sddmmyyyy     in out varchar2 /* Дата производства в формате DD.MM.YYYY */
                                                         ,sdp_sddmmyyyy_txt out varchar2 /* Сообщение об ошибке DD.MM.YYYY */
                                                         ,sdp_syy           in out varchar2 /* Дата производства в формате YY */
                                                         ,sdp_syy_txt       out varchar2 /* Сообщение об ошибке YY*/
                                                         ,ok_enable         out number --- Доступность кнопки "ОК"
                                                         ,err_txt           out varchar2 --- Сообщение об ошибке
                                                          ) is
  /*
  Процедура для валидатора формы редактирования спецификации "резкльтаты" раздела "Сертификация ТМЦ"  
  grant execute on UDO_P_PROD_CULL_OUT_FORM_EDIT to public;
  */
  rec                udo_prod_cull_out%rowtype; -- запись спецификации "Результаты"
  rec_sp             udo_prod_cull_sp%rowtype; -- запись спецификации "Передано"
  mrec               udo_prod_cull%rowtype; -- запись заголовка
  rparty             goodsparties%rowtype; -- запись партии товара
  date_chk           date;
  syear              varchar2(10);
  sweek              varchar2(10);
  ninorders          pkg_std.tref;
  rtransinvdeptspecs transinvdeptspecs%rowtype;
  rtransinvdept      transinvdept%rowtype;
  bexists            boolean := false;

  procedure attrib_date_chg is
  begin
    case sattrib
      when 'DATE_GG' then
        if sdp_syy is not null
        then
          begin
            dprod_date_d := to_date('01.01.' || sdp_syy, 'DD.MM.YY');
          exception
            when others then
              sdp_syy_txt       := sdp_syy || '- Неверный формат даты!';
              sdp_mm_yyyy       := null;
              ok_enable         := 0;
              sdp_mm_yyyy_txt   := null;
              sdp_syyww_txt     := null;
              sdp_sddmmyyyy_txt := null;
          end;
        
        else
          sdp_syy := null;
        end if;
        sprod_date_s  := sdp_syy || '+'; /*Непонятно зачем задают + после двух цифр года*/
        sdp_sddmmyyyy := null;
        sdp_mm_yyyy   := null;
        sdp_syyww     := null;
      when 'DATE_DD_MM_YYYY' then
        if sdp_sddmmyyyy is not null
        then
          begin
            dprod_date_d := to_date(sdp_sddmmyyyy, 'DD.MM.YYYY');
          exception
            when others then
              sdp_sddmmyyyy_txt := sdp_sddmmyyyy || '- Неверный формат даты!';
              sdp_sddmmyyyy     := null;
              ok_enable         := 0;
              sdp_mm_yyyy_txt   := null;
              sdp_syyww_txt     := null;
              sdp_syy_txt       := null;
          end;
        else
          sdp_sddmmyyyy := null;
        end if;
        sprod_date_s := sdp_sddmmyyyy;
        sdp_syy      := null;
        sdp_mm_yyyy  := null;
        sdp_syyww    := null;
      when 'DATE_YYNN' then
        if sdp_syyww is not null
        then
          syear := substr(sdp_syyww, 1, 2);
          sweek := substr(sdp_syyww, 3);
          begin
            dprod_date_d := to_date(to_char(trunc(to_date(syear, 'yy'), 'yy') + 7 * (to_number(sweek) - 1), 'dd.mm.yyyy'), 'dd.mm.yyyy');
          exception
            when others then
              sdp_syyww_txt := sdp_syyww || '- Неверный формат даты! ' || syear || ' ' || sweek;
              sdp_syyww     := null;
              ok_enable     := 0;
          end;
          if substr(sdp_syyww, 1, 2) != to_char(dprod_date_d, 'YY')
          then
            sdp_syyww_txt := sdp_syyww || '- Неверный номер недели!';
            sdp_syyww     := null;
            ok_enable     := 0;
          end if;
          sdp_mm_yyyy_txt   := null;
          sdp_sddmmyyyy_txt := null;
          sdp_syy_txt       := null;
        else
          sdp_syyww := null;
        end if;
        sprod_date_s  := sdp_syyww;
        sdp_syy       := null;
        sdp_sddmmyyyy := null;
        sdp_mm_yyyy   := null;
      when 'DATE_MMYYYY' then
        if sdp_mm_yyyy is not null
        then
          begin
            dprod_date_d := to_date('01.' || sdp_mm_yyyy, 'dd.mm.yyyy');
          exception
            when others then
              sdp_mm_yyyy       := null;
              sdp_mm_yyyy_txt   := 'Неверный формат даты!';
              ok_enable         := 0;
              sdp_syyww_txt     := null;
              sdp_sddmmyyyy_txt := null;
              sdp_syy_txt       := null;
          end;
        else
          sdp_mm_yyyy := null;
        end if;
        sprod_date_s  := sdp_mm_yyyy;
        sdp_syy       := null;
        sdp_sddmmyyyy := null;
        sdp_syyww     := null;
      else
        null;
    end case;
    if dprod_date_d > sysdate
    then
      sdp_mm_yyyy_txt   := 'Дата производства не может быть больше текущей даты!';
      sdp_syyww_txt     := null;
      sdp_sddmmyyyy_txt := null;
      sdp_syy_txt       := null;
      ok_enable         := 0;
    end if;
  end;

begin
  ok_enable := 1;
  err_txt   := null;

  /* запись спецификации "Передано" */
  udo_pkg_prod_cull.cull_sp_find(nrn => nprn, rcull_sp => rec_sp);
  /* запись заголовка */
  udo_pkg_prod_cull.cull_find(nrn => rec_sp.prn, rcull => mrec);
  rparty := udo_pkg_get.row_goodsparties(nsmart => 0, nrn => rec_sp.goodsparty);

  /* Если исправлялись дополнительные данные партии */
  if sattrib is not null
     and sattrib in ('DATE_MMYYYY', 'DATE_YYNN', 'DATE_DD_MM_YYYY', 'DATE_GG', 'PIN_SACCEPT', 'PIN_SUPPLIER_PARTY')
  then
    /*
    \* Если у заголовка есть связь по входу с Приходными ордерами *\
    if f_doclinks_link_in(sout_unitcode => 'UdoProdCull', nout_document => mrec.rn, sin_unitcode => 'IncomingOrders') is not null
    then
      \* Поиск отработанных Расходных накладными в подразделения *\
      for c in (select dl.out_document
                  from doclinks dl
                  join transinvdept tid
                    on tid.rn = dl.out_document
                   and tid.status != 0
                 where dl.in_document = mrec.rn)
      loop
        bexists := true;
        exit;
      end loop;
      \* Если у заголовка нет связей по выходу с отработанными Расходными накладными в подразделения *\
      if not bexists
      then
        p_exception(0
                   ,'Документ создан из приходных документов. Исправление дополнительных признаков партии (Дата производства, Партия поставщика, Вид приёмки) необходимо выполнять в них.');
      end if;
    end if;*/

    /* Проверка блокировки */
    for c in ( select o.rn
                 from udo_prod_cull_out o 
                where o.prn = rec_sp.prn 
                  and udo_pkg_prod_cull.cull_out_get_block_state( nrn => o.rn, ddate => sysdate ) = 1
                )
    loop
      p_exception(0, 'Запрещено исправление, т.к. имеются  Результаты, отработанные ранней датой (заблокированные).%s'
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'UdoProdCull', ndocument => rec_sp.prn  ) );
    end loop; 
  end if;

  /* изменение признака строки */
  if sattrib = 'NSIGN_OUT'
     or nfirst = 1
  then
    if mrec.mode_check = 1
       or (mrec.mode_check = 0 and nsign_out in (1))
    then
      scert_numb_vs   := 0;
      dcert_from_vs   := 0;
      dcert_to_vs     := 0;
      ncert_gr_vs     := 0;
      ssernumb_new_vs := 0;
      ssernumb_new    := null;
      scert_numb      := null;
      dcert_from      := null;
      dcert_to        := null;
    else
      scert_numb_vs := 1;
      dcert_from_vs := 1;
      dcert_to_vs   := 1;
      ncert_gr_vs   := 1;
      if nsign_out = 2
      then
        ssernumb_new_vs := 0;
      else
        ssernumb_new_vs := 1;
        ssernumb_new    := udo_pkg_prod_cull.get_sernumbnew(nfaceacc => mrec.faceacc_div, ssernumb => rparty.sernumb);
      end if;
    end if;
  end if;
  /*  изменить кол-во переданных в сертификацию  */
  if sattrib = 'NQUANT'
  then
    nsumm := nprice * nquant;
  end if;
  /* установка атрибутов при первом запуске*/
  if nfirst = 1
  then
    /* если размножение, то заполняем ссылку на ТЗ*/
    if nrn is not null
    then
      /* запись спецификации "Результаты" */
      udo_pkg_prod_cull.cull_out_find(nrn => nrn, rcull_out => rec);
      /* установка значений по умолчанию */
      nsupply := rec.supply;
      nmode   := 1; -- размножение 
    else
      /* поиск товарного запаса */
      begin
        select t.nrn
              ,t.nprice
              ,t.snomen
              ,t.snomen_name
              ,t.smodif
              ,t.smodif_name
              ,t.scurrency
              ,t.sparty
              ,t.ssernumb
              ,t.smeas
          into nsupply
              ,nprice
              ,snomen
              ,snomen_name
              ,smodif
              ,smodif_name
              ,scurrency
              ,sparty
              ,ssernumb
              ,sumeas
          from table(udo_pkg_prod_cull.get_goodssupply(ncompany    => mrec.company
                                                      ,sstore      => f_dicstore_get_numb(mrec.store_cull)
                                                      ,sarticle    => null
                                                      ,ddate       => mrec.doc_date
                                                      ,ngoodsparty => rec_sp.goodsparty)) t
         where rownum = 1;
      exception
        when no_data_found then
          nsupply     := null;
          nprice      := null;
          snomen      := null;
          snomen_name := null;
          smodif      := null;
          smodif_name := null;
          --          scurrency   := null;
      end;
      scurrency := 'RUB';
    
    end if;
  
    /* 
       При добавлении Определим результат сертификации "Статус ТМЦ" из свойства партии, если у партии свойство не заполнено, то по умолчанию 0 (можно задать как парметр процедуры)  
       nsupply  -- Goodsupply.rn
    */

  if nmode = 0 then 
    usr_f_cull_out_status_tmc(nsupply => nsupply, nsign_out => nsign_out);
  end if;  

    if nmode in (0, 1)
    then
      /* Доcтупное количество */
      nquant := rec_sp.quant - udo_pkg_prod_cull.get_quant_good(rec_sp.rn) - udo_pkg_prod_cull.get_quant_nogood(rec_sp.rn);
      /* Атрибуты записи родителя */
      ddoc_date := mrec.doc_date;
      /* склад списания*/
      if mrec.mode_check = 0
         and nsign_out = 2
      then
        store_cull_code := null;
      else
        store_cull_code := f_dicstore_get_numb(mrec.store_cull);
      end if;
      /* новый номер серии */
      if mrec.mode_check = 0
      then
        if ssernumb_new is null
        then
          ssernumb_new := udo_pkg_prod_cull.get_sernumbnew(nfaceacc => mrec.faceacc_div, ssernumb => rparty.sernumb);
        end if;
      end if;
    end if;
    /* расчет суммы */
    nsumm  := nprice * nquant;
    nfirst := 0;
  end if;

  if nmode = 0
     and sattrib is null
  then
    /* Добавление при открытии */
    begin
      select gp.prod_date
            ,usr_pkg_docs_props_vals.get_val_str(sprop_code => 'ПРИЕМКА', sunitcode => 'GoodsParties', ndocument => gp.rn)
            ,usr_pkg_docs_props_vals.get_val_str(sprop_code => 'Дата производства'
                                                ,sunitcode  => 'GoodsParties'
                                                ,ndocument  => gp.rn)
            ,usr_pkg_docs_props_vals.get_val_str(sprop_code => 'Дата перепроверки'
                                                ,sunitcode  => 'GoodsParties'
                                                ,ndocument  => gp.rn)
            ,usr_pkg_docs_props_vals.get_val_str(sprop_code => 'Партия поставщика'
                                                ,sunitcode  => 'GoodsParties'
                                                ,ndocument  => gp.rn)
        into dprod_date_d
            ,saccept
            ,sprod_date_s
            ,srecheck_date
            ,ssupplier_party
        from udo_prod_cull_sp t
        join goodsparties gp
          on gp.rn = t.goodsparty
       where t.rn = nprn;
    exception
      when no_data_found then
      
        null;
    end;
  
    /* Отрезаем тратий символ, т.к. зачем то вводят 25+ */
    if length(sprod_date_s) = 3
    then
      sprod_date_s := substr(sprod_date_s, 1, 2);
    end if;
  
    case length(sprod_date_s)
      when 7 then
        begin
          begin
            date_chk := to_date('01.' || sprod_date_s, 'DD.MM.YYYY');
          exception
            when others then
              date_chk := null;
          end;
          if date_chk != dprod_date_d
          then
            if date_chk is not null
            then
              sdp_mm_yyyy_txt := 'Исправьте некорректную дату!';
            else
              sdp_mm_yyyy_txt := 'Некорректный формат даты!';
            end if;
            ok_enable := 0;
          else
            sdp_mm_yyyy := sprod_date_s;
          end if;
        end;
      when 4 then
        begin
          syear    := substr(sprod_date_s, 1, 2);
          sweek    := substr(sprod_date_s, 3);
          date_chk := to_date(to_char(trunc(to_date(syear, 'yy'), 'iy') + 7 * (to_number(sweek) - 1), 'dd.mm.yyyy'), 'dd.mm.yyyy');
        exception
          when others then
            date_chk := null;
        end;
        if trunc(date_chk, 'Month') != trunc(dprod_date_d, 'Month')
        then
          if date_chk is not null
          then
            sdp_syyww_txt := 'Исправьте некорректную дату!!' || trunc(dprod_date_d, 'Month') || ' ' || trunc(date_chk, 'Month');
          else
            sdp_syyww_txt := 'Некорректный формат даты!' ||
                             to_char(trunc(to_date(syear, 'yy'), 'iy') + 7 * (to_number(sweek) - 1), 'dd.mm.yyyy');
          end if;
          ok_enable := 0;
        else
          sdp_syyww := sprod_date_s;
        end if;
      when 10 then
        begin
          date_chk := to_date(sprod_date_s, 'DD.MM.YYYY');
        exception
          when others then
            date_chk := null;
        end;
        if date_chk != dprod_date_d
        then
          if date_chk is not null
          then
            sdp_sddmmyyyy_txt := 'Исправьте некорректную дату!';
          else
            sdp_sddmmyyyy_txt := 'Некорректный формат даты!';
          end if;
          ok_enable := 0;
        else
          sdp_sddmmyyyy := sprod_date_s;
        end if;
      
      when 2 then
        begin
          date_chk := to_date('01.01.' || sprod_date_s, 'YYYY');
        exception
          when others then
            date_chk := null;
        end;
        if date_chk != trunc(dprod_date_d, 'YEAR')
        then
          if date_chk is not null
          then
            sdp_syy_txt := 'Исправьте некорректную дату!';
          else
            sdp_syy_txt := 'Некорректный формат даты!';
          end if;
          ok_enable := 0;
        else
          sdp_syy := sprod_date_s;
        end if;
      else
        ok_enable := 0;
        err_txt   := 'Задайте корректную дату производства!';
    end case;
  elsif nmode = 0
        and sattrib is not null
  then
  
    /* Добавление при изменении полей */
    attrib_date_chg();
  elsif nmode in (1, 2)
        and sattrib is null
  then
    /* Исправление или размножение при открытии*/
    begin
      select t.prod_date_d
            ,dz.str_value
            ,t.prod_date_s
            ,t.recheck_date
            ,t.supplier_party
        into dprod_date_d
            ,saccept
            ,sprod_date_s
            ,srecheck_date
            ,ssupplier_party
        from udo_prod_cull_out t
        left join extra_dicts_values dz
          on dz.rn = t.accept
       where t.rn = pin_doc;
    exception
      when no_data_found then
        null;
    end;
    /* Восстановим поле ввода */
    if length(sprod_date_s) = 3
    then
      sprod_date_s := substr(sprod_date_s, 1, 2);
    end if;
  
    case length(sprod_date_s)
      when 7 then
        sdp_mm_yyyy   := sprod_date_s;
        sdp_syy       := null;
        sdp_sddmmyyyy := null;
        sdp_syyww     := null;
      when 2 then
        sdp_mm_yyyy   := null;
        sdp_syy       := sprod_date_s || '+';
        sdp_sddmmyyyy := null;
        sdp_syyww     := null;
      when 10 then
        sdp_mm_yyyy   := null;
        sdp_syy       := null;
        sdp_sddmmyyyy := sprod_date_s;
        sdp_syyww     := null;
      when 4 then
        sdp_mm_yyyy   := null;
        sdp_syy       := null;
        sdp_sddmmyyyy := null;
        sdp_syyww     := sprod_date_s;
      else
        ok_enable := 0;
        err_txt   := 'Задайте корректную дату производства!';
    end case;
  elsif nmode in (1, 2) /*Исправление при изменеии полей */
        and sattrib is not null
  then
  
    attrib_date_chg();
  end if;

  if length(sprod_date_s) = 2
  then
    sprod_date_s := sprod_date_s || '+'; --- Захотели, чтоб после 2 цифр года ставился знак +
  end if;

end;
/
