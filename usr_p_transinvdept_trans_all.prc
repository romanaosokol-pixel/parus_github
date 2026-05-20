create or replace procedure usr_p_transinvdept_trans_all(nrn in transinvdept.rn%type) is
  ---  nrn    transinvdept.rn%type:= 158077744;
  nrn_sp transinvdeptspecs.rn%type;
begin
  for cur in (
              
              select t.rn
                     ,t.company
                     ,gp.rn gprn
                     ,gp.nommodif
                     ,gp.nomnmodifpack
                     ,gp.gtd
                     ,gy.summfact / gy.restfact price
                     ,gy.restfact q
                     ,gy.summfact s
                     ,gp.barcode
                     ,gp.sernumb
                     ,gy.cardnumb
                from transinvdept t
                join goodssupply gy
                  on gy.store = t.store
                 and gy.company = t.company
                join goodsparties gp
                  on gp.rn = gy.prn
               where t.rn = nrn
                 and gy.restfact != 0)
  loop
  
    p_transinvdeptsp_base_insert(ncompany         => cur.company
                                ,nprn             => cur.rn
                                ,nagent           => null
                                ,ngoodsparty      => cur.gprn
                                ,nnommodif        => cur.nommodif
                                ,nnomnmodifpack   => cur.nomnmodifpack
                                ,narticle         => null
                                ,ncell            => null
                                ,ntemperature     => null
                                ,nprice           => cur.price
                                ,nquant           => cur.q
                                ,nquantalt        => 0
                                ,ncoeff           => 0
                                ,ncoeff_val_sign  => 0
                                ,ncoeff_calc_sign => 0
                                ,npricemeas       => 0
                                ,nsummwithnds     => cur.s
                                ,dbegindate       => null
                                ,denddate         => null
                                ,snote            => null
                                ,sbcode           => cur.barcode
                                ,scardnumb        => cur.cardnumb
                                ,sstrcode         => null
                                ,ncons_rate       => null
                                ,nservlife        => null
                                ,nrevreas         => null
                                ,sres_comms       => null
                                ,nrn              => nrn_sp
                                ,nfrom_client     => 0);
  
  end loop;

end;
/
