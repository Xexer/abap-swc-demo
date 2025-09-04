  METHOD if_oo_adt_classrun~main.
    call_method( out ).
    call_with_changing( out ).
    call_with_reference( out ).
    call_for_reference( out ).
    call_with_exporting( out ).
    call_application_log( out ).
  ENDMETHOD.