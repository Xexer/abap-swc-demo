  METHOD call_application_log.
    DATA(messages) = VALUE zcl_bs_demo_swc_reuse_copy=>messages( id = 'ZDUMMY'
                                                                 ( type = 'S' number = '001' )
                                                                 ( type = 'W' number = '002' ) ).

*    DATA(header) = cl_bali_header_setter=>create( object      = 'ZBS_APPL_REUSE'
*                                                  subobject   = 'TEST'
*                                                  external_id = CONV #( xco_cp=>uuid( )->value ) ).

    DATA(reuse) = NEW zcl_bs_demo_swc_reuse_copy( ).

    reuse->save_messages( messages = messages
*                          header   = header
                          ).

    out->write( messages ).
  ENDMETHOD.