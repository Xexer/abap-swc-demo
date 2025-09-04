  METHOD create_log.
    TRY.
        DATA(lo_appl_log) = zcl_bc_tool_appl_log=>create(
            id_object         = 'ZBS_SWC_DEMO'
            id_subobject      = 'TEST'
        ).

        lo_appl_log->add_msg_text( id_type = if_bali_constants=>c_severity_warning id_text = 'Execution terminated, dataset not found' ).
        lo_appl_log->add_msg_exc( NEW cx_sy_zerodivide( ) ).

        IF lo_appl_log->save( ).
          COMMIT WORK.
          rd_result = lo_appl_log->get_handle( ).
        ENDIF.

      CATCH cx_root.
        CLEAR rd_result.
    ENDTRY.
  ENDMETHOD.