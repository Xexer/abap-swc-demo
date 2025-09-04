  METHOD call_method.
    DATA(dummy_data) = VALUE zif_bs_demo_swc_use=>dummys(
        ( number = 1 char = 'one' string = `First field` packed = '1.11' timestamp = utclong_current( ) )
        ( number = 2 char = 'two' string = `Second field` packed = '2.22' timestamp = utclong_current( ) ) ).

    out->write( dummy_data ).
  ENDMETHOD.