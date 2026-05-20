create or replace procedure usr_p_seleclist_clear(
nident in number
) is


begin

/*Очистка Selectlist по Ident  */

  p_selectlist_clear(nident => nident);

end;
/
