  METHOD if_rap_query_provider~select.
    DATA lt_result TYPE STANDARD TABLE OF ZBS_I_SWCWorkingClassesVH.

    DATA(ld_skip) = io_request->get_paging( )->get_offset( ).
    DATA(ld_top) = io_request->get_paging( )->get_page_size( ).
    DATA(lt_sorted) = io_request->get_sort_elements( ).

    lt_result = VALUE #( ( WorkingClass = 'ZCL_BS_DEMO_PROCESS' Description = 'Automation process' )
                         ( WorkingClass = 'ZCL_BS_DEMO_NO_ONE' Description = 'One automation' )
                         ( WorkingClass = 'ZCL_TEST' Description = 'Test class' ) ).

    IF io_request->is_total_numb_of_rec_requested(  ).
      io_response->set_total_number_of_records( 3 ).
    ENDIF.

    IF io_request->is_data_requested(  ).
      io_response->set_data( lt_result ).
    ENDIF.
  ENDMETHOD.