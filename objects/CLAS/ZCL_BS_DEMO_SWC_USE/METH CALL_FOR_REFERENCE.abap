  METHOD call_for_reference.
    DATA(reuse) = NEW zcl_bs_demo_swc_reuse_copy( ).

    DATA(reference) = reuse->table_with_type( type_name = 'ZIF_BS_DEMO_SWC_USE=>DUMMYS' ).

    out->write( reference->* ).
  ENDMETHOD.