*"* use this source file for your ABAP unit test classes

CLASS ltc_test_something DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS first_test  FOR TESTING RAISING cx_static_check.
    METHODS second_test FOR TESTING.
ENDCLASS.

CLASS zcl_bs_swc_test_contracts DEFINITION LOCAL FRIENDS ltc_test_something.

CLASS ltc_test_something IMPLEMENTATION.
  METHOD first_test.
    cl_abap_unit_assert=>fail( 'Implement your first test here' ).
  ENDMETHOD.


  METHOD second_test.
    DATA(lo_cut) = NEW zcl_bs_swc_test_contracts( ).

    DATA(ld_result) = lo_cut->create_log( ).

    cl_abap_unit_assert=>assert_not_initial( ld_result ).
  ENDMETHOD.
ENDCLASS.