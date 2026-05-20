create or replace procedure UDO_P_SYS_RENAME as
  /*
    Марков МВ.
    Обновление наименования матресурса по данным Интермех
  */
  type rec_MR is record(
    rN number(17),
    Nm varchar2(2000));
  type tMR is table of rec_MR index by binary_integer;
  rMR  tMR;
  iCNT integer;
begin
  select tt.rn,
         tt.ips_name bulk collect
    into rMR
    from (select m.rn,
                 nm.nomen_name,
                 m.name,
                 udo_f_depordsp_cmpl_name(nNOM_MODIF => m.nomen_modif) ips_name
            from fcmatresource     m,
                 dicnomns          nm,
                 udo_modif_matches mm
           where m.nomenclature = nm.rn
             and mm.prn = m.nomen_modif
             and m.nomen_modif not in (6901232, 6901189, 6901207, 6488190, 6002936, 7466761)
             ) tt
   where tt.name != tt.ips_name
     and instr(tt.ips_name, 'ЮФКВ') > 0 and rtrim(tt.ips_name) is not null;
  if rMR.Count > 0 then
    iCNT := 0;
    for Idx in rMR.First .. rMR.Last loop
      execute immediate 'begin
      update fcmatresource m set m.name = :NAME where m.rn = :RN;
      commit;
      end;' using rMR(Idx).Nm, rMR(Idx).Rn;
    end loop;
  end if;
end;
/

