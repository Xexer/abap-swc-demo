  METHOD if_oo_adt_classrun~main.
    DATA lt_data TYPE STANDARD TABLE OF ZBS_S_SWCDataStructure WITH EMPTY KEY.

    DATA(lo_api) = zcl_bc_test_shared_functions=>create( ).

    " Create application log from other SWC
    DATA(ld_handle) = create_log( ).
    out->write( |The handle: { ld_handle }| ).

    " Read application log from other SWC
    out->write( lo_api->read_log_messages( ld_handle ) ).

    " Analyze structure
    DATA(ls_data) = VALUE ZBS_S_SWCDataStructure( identifier = 'ABCDEF'
                                                  idate      = '20240528'
                                                  itime      = '231259'
                                                  text       = `Test und so` ).
    out->write( lo_api->analyze_type( ls_data ) ).

    " Generate data from another SWC
    lt_data = lo_api->generate_line_of_type( 'ZBS_S_SWCDATASTRUCTURE' )->*.
    out->write( lt_data ).
  ENDMETHOD.