CLASS lhc_rap_tdat_cts DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS get
      RETURNING VALUE(ro_result) TYPE REF TO if_mbc_cp_rap_tdat_cts.

ENDCLASS.


CLASS lhc_rap_tdat_cts IMPLEMENTATION.
  METHOD get.
    ro_result = mbc_cp_api=>rap_tdat_cts( tdat_name              = 'ZBS_SWC_TO_OBJECT'
                                          table_entity_relations = VALUE #(
                                              ( entity = 'BusinessConfigurati' table = 'ZBS_DMO_BC' ) ) )
                                       ##NO_TEXT.
  ENDMETHOD.
ENDCLASS.


CLASS lhc_zbs_i_swcbc_s DEFINITION INHERITING FROM cl_abap_behavior_handler FINAL.
  PRIVATE SECTION.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING
                        it_keys REQUEST is_requested_features FOR BusinessConfigAll
              RESULT    it_result.

    METHODS selectcustomizingtransptreq FOR MODIFY
      IMPORTING
                        it_keys FOR ACTION BusinessConfigAll~SelectCustomizingTransptReq
              RESULT    it_result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING
              REQUEST is_requested_authorizations FOR BusinessConfigAll
              RESULT is_result.
ENDCLASS.


CLASS lhc_zbs_i_swcbc_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA ld_edit_flag            TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.
    DATA ld_selecttransport_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.

    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      ld_edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    IF lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_false.
      ld_selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    READ ENTITIES OF zbs_i_swcbc_s IN LOCAL MODE
         ENTITY BusinessConfigAll
         ALL FIELDS WITH CORRESPONDING #( it_keys )
         RESULT DATA(lt_all).
    IF lt_all[ 1 ]-%is_draft = if_abap_behv=>mk-off.
      ld_selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    it_result = VALUE #( ( %tky                                = lt_all[ 1 ]-%tky
                           %action-edit                        = ld_edit_flag
                           %assoc-_BusinessConfigurati         = ld_edit_flag
                           %action-SelectCustomizingTransptReq = ld_selecttransport_flag ) ).
  ENDMETHOD.


  METHOD selectcustomizingtransptreq.
    MODIFY ENTITIES OF zbs_i_swcbc_s IN LOCAL MODE
           ENTITY BusinessConfigAll
           UPDATE FIELDS ( TransportRequestID HideTransport )
           WITH VALUE #( FOR ls_key IN it_keys
                         ( %tky               = ls_key-%tky
                           TransportRequestID = ls_key-%param-transportrequestid
                           HideTransport      = abap_false ) ).

    READ ENTITIES OF zbs_i_swcbc_s IN LOCAL MODE
         ENTITY BusinessConfigAll
         ALL FIELDS WITH CORRESPONDING #( it_keys )
         RESULT DATA(lt_entities).
    it_result = VALUE #( FOR ls_entity IN lt_entities
                         ( %tky   = ls_entity-%tky
                           %param = ls_entity ) ).
  ENDMETHOD.


  METHOD get_global_authorizations.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD 'ZI_BUSINESSCONFIGURATI' ID 'ACTVT' FIELD '02'.
    DATA(ld_is_authorized) = COND #( WHEN sy-subrc = 0
                                     THEN if_abap_behv=>auth-allowed
                                     ELSE if_abap_behv=>auth-unauthorized ).
    is_result-%update      = ld_is_authorized.
    is_result-%action-Edit                        = ld_is_authorized.
    is_result-%action-SelectCustomizingTransptReq = ld_is_authorized.
  ENDMETHOD.
ENDCLASS.


CLASS lsc_zbs_i_swcbc_s DEFINITION INHERITING FROM cl_abap_behavior_saver FINAL.
  PROTECTED SECTION.
    METHODS
      save_modified    REDEFINITION.
    METHODS
      cleanup_finalize REDEFINITION.
ENDCLASS.


CLASS lsc_zbs_i_swcbc_s IMPLEMENTATION.
  METHOD save_modified.
    READ TABLE update-BusinessConfigAll INDEX 1 INTO DATA(ls_all).
    IF ls_all-TransportRequestID IS NOT INITIAL.
      lhc_rap_tdat_cts=>get( )->record_changes( transport_request = ls_all-TransportRequestID
                                                create            = REF #( create )
                                                update            = REF #( update )
                                                delete            = REF #( delete ) ).
    ENDIF.
  ENDMETHOD.


  METHOD cleanup_finalize ##NEEDED.
  ENDMETHOD.
ENDCLASS.


CLASS lhc_zi_businessconfigurati DEFINITION INHERITING FROM cl_abap_behavior_handler FINAL.
  PRIVATE SECTION.
    METHODS validatedataconsistency FOR VALIDATE ON SAVE
      IMPORTING
                it_keys FOR BusinessConfigurati~ValidateDataConsistency.

    METHODS get_global_features FOR GLOBAL FEATURES
      IMPORTING
              REQUEST is_requested_features FOR BusinessConfigurati
              RESULT is_result.

    METHODS deprecate FOR MODIFY
      IMPORTING
                        it_keys   FOR ACTION BusinessConfigurati~Deprecate
              RESULT    it_result.

    METHODS invalidate FOR MODIFY
      IMPORTING
                        it_keys   FOR ACTION BusinessConfigurati~Invalidate
              RESULT    it_result.

    METHODS copybusinessconfigurati FOR MODIFY
      IMPORTING
                it_keys FOR ACTION BusinessConfigurati~CopyBusinessConfigurati.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING
              REQUEST is_requested_authorizations FOR BusinessConfigurati
              RESULT is_result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING
                        it_keys   REQUEST is_requested_features FOR BusinessConfigurati
              RESULT    it_result.

    METHODS validatetransportrequest FOR VALIDATE ON SAVE
      IMPORTING
                it_keys_businessconfigurati FOR BusinessConfigurati~ValidateTransportRequest.
ENDCLASS.


CLASS lhc_zi_businessconfigurati IMPLEMENTATION.
  METHOD validatedataconsistency.
    READ ENTITIES OF zbs_i_swcbc_s IN LOCAL MODE
         ENTITY BusinessConfigurati
         ALL FIELDS WITH CORRESPONDING #( it_keys )
         RESULT DATA(lt_businessconfigurati).
    DATA(lo_table) = xco_cp_abap_repository=>object->tabl->database_table->for( 'ZBS_DMO_BC' ).
    DATA: BEGIN OF ls_element_check,
            element TYPE string,
            check   TYPE REF TO if_xco_dp_check,
          END OF ls_element_check.
    DATA lt_element_checks LIKE TABLE OF ls_element_check WITH EMPTY KEY.
    LOOP AT lt_businessconfigurati ASSIGNING FIELD-SYMBOL(<ls_businessconfigurati>).
      lt_element_checks = VALUE #( ( element = 'IsUsed'
                                     check   = lo_table->field( 'IS_USED' )->get_value_check(
                                         ia_value = <ls_businessconfigurati>-IsUsed  ) )
                                   ( element = 'IsMandatory'
                                     check   = lo_table->field( 'IS_MANDATORY' )->get_value_check(
                                         ia_value = <ls_businessconfigurati>-IsMandatory  ) )
                                   ( element = 'ConfigDeprecationCode'
                                     check   = lo_table->field( 'CONFIGDEPRECATIONCODE' )->get_value_check(
                                         ia_value = <ls_businessconfigurati>-ConfigDeprecationCode  ) ) ).
      LOOP AT lt_element_checks INTO ls_element_check.
        INSERT VALUE #( %tky        = <ls_businessconfigurati>-%tky
                        %state_area = |BusinessConfigurati_{ ls_element_check-element }| ) INTO TABLE reported-BusinessConfigurati.
        ls_element_check-check->execute( ).
        IF ls_element_check-check->passed <> xco_cp=>boolean->false.
          CONTINUE.
        ENDIF.
        INSERT VALUE #( %tky = <ls_businessconfigurati>-%tky ) INTO TABLE failed-BusinessConfigurati.
        LOOP AT ls_element_check-check->messages ASSIGNING FIELD-SYMBOL(<lo_msg>).
          INSERT VALUE #(
              %tky                                = <ls_businessconfigurati>-%tky
              %state_area                         = |BusinessConfigurati_{ ls_element_check-element }|
              %path-BusinessConfigAll-SingletonID = 1
              %path-BusinessConfigAll-%is_draft   = <ls_businessconfigurati>-%is_draft
              %msg                                = mbc_cp_api=>message( )->get_behv_msg_from_value_check( <lo_msg> ) ) INTO TABLE reported-BusinessConfigurati ASSIGNING FIELD-SYMBOL(<ls_rep>).
          ASSIGN COMPONENT ls_element_check-element OF STRUCTURE <ls_rep>-%element TO FIELD-SYMBOL(<ld_comp>).
          <ld_comp> = if_abap_behv=>mk-on.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_global_features.
    DATA ld_edit_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.

    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      ld_edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    is_result-%update = ld_edit_flag.
  ENDMETHOD.


  METHOD deprecate.
    MODIFY ENTITIES OF zbs_i_swcbc_s IN LOCAL MODE
           ENTITY BusinessConfigurati
           UPDATE
           FIELDS ( ConfigDeprecationCode ConfigDeprecationCode_Critlty )
           WITH VALUE #( FOR ls_key IN it_keys
                         ( %tky                          = ls_key-%tky
                           ConfigDeprecationCode         = 'W'
                           ConfigDeprecationCode_Critlty = 2 ) ).
    READ ENTITIES OF zbs_i_swcbc_s IN LOCAL MODE
         ENTITY BusinessConfigurati
         ALL FIELDS WITH CORRESPONDING #( it_keys )
         RESULT DATA(lt_businessconfigurati).
    it_result = VALUE #( FOR ls_row IN lt_businessconfigurati
                         ( %tky   = ls_row-%tky
                           %param = ls_row ) ).
    reported-BusinessConfigurati = VALUE #(
        FOR ls_key IN it_keys
        ( %cid                                = ls_key-%cid_ref
          %tky                                = ls_key-%tky
          %action-Deprecate                   = if_abap_behv=>mk-on
          %element-ConfigDeprecationCode      = if_abap_behv=>mk-on
          %msg                                = mbc_cp_api=>message( )->get_item_deprecated( )
          %path-BusinessConfigAll-%is_draft   = ls_key-%is_draft
          %path-BusinessConfigAll-SingletonID = 1 ) ).
  ENDMETHOD.


  METHOD invalidate.
    MODIFY ENTITIES OF zbs_i_swcbc_s IN LOCAL MODE
           ENTITY BusinessConfigurati
           UPDATE
           FIELDS ( ConfigDeprecationCode ConfigDeprecationCode_Critlty )
           WITH VALUE #( FOR ls_key IN it_keys
                         ( %tky                          = ls_key-%tky
                           ConfigDeprecationCode         = 'E'
                           ConfigDeprecationCode_Critlty = 1 ) ).

    READ ENTITIES OF zbs_i_swcbc_s IN LOCAL MODE
         ENTITY BusinessConfigurati
         ALL FIELDS WITH CORRESPONDING #( it_keys )
         RESULT DATA(lt_businessconfigurati).
    it_result = VALUE #( FOR ls_row IN lt_businessconfigurati
                         ( %tky   = ls_row-%tky
                           %param = ls_row ) ).

    reported-BusinessConfigurati = VALUE #(
        FOR ls_key IN it_keys
        ( %cid                                = ls_key-%cid_ref
          %tky                                = ls_key-%tky
          %action-Invalidate                  = if_abap_behv=>mk-on
          %element-ConfigDeprecationCode      = if_abap_behv=>mk-on
          %msg                                = mbc_cp_api=>message( )->get_item_invalidated( )
          %path-BusinessConfigAll-%is_draft   = ls_key-%is_draft
          %path-BusinessConfigAll-SingletonID = 1 ) ).
  ENDMETHOD.


  METHOD copybusinessconfigurati.
    DATA lt_new_businessconfigurati TYPE TABLE FOR CREATE zbs_i_swcbc_s\_BusinessConfigurati.

    IF lines( it_keys ) > 1.
      INSERT mbc_cp_api=>message( )->get_select_only_one_entry( ) INTO TABLE reported-%other.
      failed-BusinessConfigurati = VALUE #( FOR ls_fkey IN it_keys
                                            ( %tky = ls_fkey-%tky ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF zbs_i_swcbc_s IN LOCAL MODE
         ENTITY BusinessConfigurati
         ALL FIELDS WITH CORRESPONDING #( it_keys )
         RESULT DATA(lt_ref_businessconfigurati)
         FAILED DATA(ls_read_failed).

    IF lt_ref_businessconfigurati IS NOT INITIAL.
      ASSIGN lt_ref_businessconfigurati[ 1 ] TO FIELD-SYMBOL(<ls_ref_businessconfigurati>).
      DATA(ls_key) = it_keys[ KEY draft %tky = <ls_ref_businessconfigurati>-%tky ].
      DATA(ld_key_cid) = ls_key-%cid.
      APPEND VALUE #( %tky-SingletonID = 1
                      %is_draft        = <ls_ref_businessconfigurati>-%is_draft
                      %target          = VALUE #( ( %cid      = ld_key_cid
                                                    %is_draft = <ls_ref_businessconfigurati>-%is_draft
                                                    %data     = CORRESPONDING #( <ls_ref_businessconfigurati> EXCEPT
                                                        SingletonID
                                                        ConfigDeprecationCode
                                                        LastChangedAt
                                                        LocalLastChangedAt ) ) ) )
             TO lt_new_businessconfigurati ASSIGNING FIELD-SYMBOL(<ls_new_businessconfigurati>).
      <ls_new_businessconfigurati>-%target[ 1 ]-ConfigId = ls_key-%param-ConfigId.

      MODIFY ENTITIES OF zbs_i_swcbc_s IN LOCAL MODE
             ENTITY BusinessConfigAll CREATE BY \_BusinessConfigurati
             FIELDS (
                      ConfigId
                      Description
                      IsUsed
                      IsMandatory
                      Processes
                      WorkingClass )
             WITH lt_new_businessconfigurati
             MAPPED DATA(ls_mapped_create)
             FAILED failed
             REPORTED reported.

      mapped-BusinessConfigurati = ls_mapped_create-BusinessConfigurati.
    ENDIF.

    INSERT LINES OF ls_read_failed-BusinessConfigurati INTO TABLE failed-BusinessConfigurati.

    IF failed-BusinessConfigurati IS INITIAL.
      reported-BusinessConfigurati = VALUE #(
          FOR ls_created IN mapped-BusinessConfigurati
          ( %cid                                = ls_created-%cid
            %action-CopyBusinessConfigurati     = if_abap_behv=>mk-on
            %msg                                = mbc_cp_api=>message( )->get_item_copied( )
            %path-BusinessConfigAll-%is_draft   = ls_created-%is_draft
            %path-BusinessConfigAll-SingletonID = 1 ) ).
    ENDIF.
  ENDMETHOD.


  METHOD get_global_authorizations.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD 'ZI_BUSINESSCONFIGURATI' ID 'ACTVT' FIELD '02'.
    DATA(ld_is_authorized) = COND #( WHEN sy-subrc = 0
                                     THEN if_abap_behv=>auth-allowed
                                     ELSE if_abap_behv=>auth-unauthorized ).
    is_result-%action-Deprecate               = ld_is_authorized.
    is_result-%action-Invalidate              = ld_is_authorized.
    is_result-%action-CopyBusinessConfigurati = ld_is_authorized.
  ENDMETHOD.


  METHOD get_instance_features.
    DATA lt_keys_act LIKE it_keys.

    READ ENTITIES OF zbs_i_swcbc_s IN LOCAL MODE
         ENTITY BusinessConfigurati
         FIELDS ( ConfigDeprecationCode ) WITH CORRESPONDING #( it_keys )
         RESULT DATA(lt_businessconfigurati).
    LOOP AT it_keys INTO DATA(ls_key) USING KEY draft WHERE %is_draft = if_abap_behv=>mk-on.
      ls_key-%is_draft = if_abap_behv=>mk-off.
      INSERT ls_key INTO TABLE lt_keys_act.
    ENDLOOP.

    READ ENTITIES OF zbs_i_swcbc_s IN LOCAL MODE
         ENTITY BusinessConfigurati
         FIELDS ( ConfigDeprecationCode ) WITH CORRESPONDING #( lt_keys_act )
         RESULT DATA(lt_businessconfigurati_act).
    LOOP AT it_keys INTO ls_key.
      DATA(ld_delete) = if_abap_behv=>fc-o-disabled.
      DATA(ld_deprecate) = if_abap_behv=>fc-o-disabled.
      DATA(ld_invalidate) = if_abap_behv=>fc-o-disabled.
      DATA(ld_copy) = if_abap_behv=>fc-o-disabled.

      IF ls_key-%is_draft = if_abap_behv=>mk-on.
        ld_copy = if_abap_behv=>fc-o-enabled.
        READ TABLE lt_businessconfigurati WITH KEY draft COMPONENTS %tky = ls_key-%tky ASSIGNING FIELD-SYMBOL(<ls_businessconfigurati>).
        IF <ls_businessconfigurati>-ConfigDeprecationCode = ''.
          ld_deprecate = if_abap_behv=>fc-o-enabled.
          ld_invalidate = if_abap_behv=>fc-o-enabled.
        ELSEIF <ls_businessconfigurati>-ConfigDeprecationCode = 'W'.
          ld_invalidate = if_abap_behv=>fc-o-enabled.
        ENDIF.
        IF NOT line_exists( lt_businessconfigurati_act[ KEY entity COMPONENTS %key = ls_key-%key ] ).
          ld_delete = if_abap_behv=>fc-o-enabled.
        ENDIF.
      ENDIF.

      INSERT VALUE #( %tky                            = ls_key-%tky
                      %delete                         = ld_delete
                      %action-CopyBusinessConfigurati = ld_copy
                      %action-deprecate               = ld_deprecate
                      %action-invalidate              = ld_invalidate ) INTO TABLE it_result.
    ENDLOOP.
  ENDMETHOD.


  METHOD validatetransportrequest.
    DATA ls_change TYPE REQUEST FOR CHANGE zbs_i_swcbc_s.

    IF it_keys_businessconfigurati IS NOT INITIAL.
      DATA(ld_is_draft) = it_keys_businessconfigurati[ 1 ]-%is_draft.
    ELSE.
      RETURN.
    ENDIF.

    READ ENTITY IN LOCAL MODE zbs_i_swcbc_s
         FROM VALUE #( ( %is_draft                   = ld_is_draft
                         SingletonID                 = 1
                         %control-TransportRequestID = if_abap_behv=>mk-on ) )
         RESULT FINAL(lt_transport_from_singleton).

    IF lines( lt_transport_from_singleton ) = 1.
      DATA(ld_transport_request) = lt_transport_from_singleton[ 1 ]-TransportRequestID.
    ENDIF.

    lhc_rap_tdat_cts=>get( )->validate_all_changes(
        transport_request     = ld_transport_request
        table_validation_keys = VALUE #( ( table = 'ZBS_DMO_BC' keys = REF #( it_keys_businessconfigurati ) ) )
        reported              = REF #( reported )
        failed                = REF #( failed )
        change                = REF #( ls_change ) ).
  ENDMETHOD.
ENDCLASS.