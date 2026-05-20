create or replace procedure usr_p_project_props_modif_ini(nrn          in number
                                                         ,protype_old  out varchar2
                                                         ,sotr_peo_old out varchar2
                                                         ,tkpa_old     out varchar2
                                                         ,zam_gd_old   out varchar2
                                                         ,protype      out varchar2
                                                         ,sotr_peo     out varchar2
                                                         ,tkpa         out varchar2
                                                         ,zam_gd       out varchar2) is
begin
  /*Пользователь имеет роль ВСЕ права или Управлене Финансами*/

  protype_old := usr_pkg_docs_props_vals.get_val_str(sprop_code => 'PrProductType', sunitcode => 'Projects', ndocument => nrn);
  protype     := protype_old;

  tkpa_old := usr_pkg_docs_props_vals.get_val_str(sprop_code => 'ТКПА', sunitcode => 'Projects', ndocument => nrn);
  tkpa     := tkpa_old;

  zam_gd_old := usr_pkg_docs_props_vals.get_val_str(sprop_code => 'Заместитель ГД', sunitcode => 'Projects', ndocument => nrn);
  zam_gd     := zam_gd_old;

  sotr_peo_old := usr_pkg_docs_props_vals.get_val_str(sprop_code => 'Сотрудник', sunitcode => 'Projects', ndocument => nrn);
  sotr_peo     := sotr_peo_old;

end;
/
