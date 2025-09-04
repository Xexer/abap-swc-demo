  METHOD call_with_exporting.
    DATA changed_data TYPE zif_bs_demo_swc_use=>dummys.

    DATA(reuse) = NEW zcl_bs_demo_swc_reuse_copy( ).

    reuse->table_exporting( IMPORTING data = changed_data ).

    out->write( changed_data ).
  ENDMETHOD.