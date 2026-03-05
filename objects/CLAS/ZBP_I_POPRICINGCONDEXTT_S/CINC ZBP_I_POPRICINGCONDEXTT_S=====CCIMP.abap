CLASS lhc_zi_popricingconextt_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.
    CONSTANTS:
      co_entity               TYPE abp_entity_name VALUE `ZI_POPRICINGCONEXTT_S`,
      co_transport_object     TYPE mbc_cp_api=>indiv_transaction_obj_name VALUE `ZPOPRICINGCONDITIONT_EXT`,
      co_authorization_entity TYPE abp_entity_name VALUE `ZI_POPRICINGCONDEXTT`.

  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR popricingconditiall
        RESULT    result,
      selectcustomizingtransptreq FOR MODIFY
        IMPORTING
                  keys   FOR ACTION popricingconditiall~selectcustomizingtransptreq
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR popricingconditiall
        RESULT result,
      edit FOR MODIFY
        IMPORTING
          keys FOR ACTION popricingconditiall~edit,
      earlynumbering_create FOR NUMBERING
        IMPORTING entities_cba FOR CREATE popricingconditiall\_popricingconditiont.
ENDCLASS.

CLASS lhc_zi_popricingconextt_s IMPLEMENTATION.
  METHOD get_instance_features.
    mbc_cp_api=>rap_bc_api( )->get_instance_features(
      transport_object   = co_transport_object
      entity             = co_entity
      keys               = REF #( keys )
      requested_features = REF #( requested_features )
      result             = REF #( result )
      failed             = REF #( failed )
      reported           = REF #( reported ) ).
  ENDMETHOD.
  METHOD selectcustomizingtransptreq.
    mbc_cp_api=>rap_bc_api( )->select_transport_action(
      entity   = co_entity
      keys     = REF #( keys )
      result   = REF #( result )
      mapped   = REF #( mapped )
      failed   = REF #( failed )
      reported = REF #( reported ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
*  mbc_cp_api=>rap_bc_api( )->get_global_authorizations(
*    entity                   = co_authorization_entity
*    requested_authorizations = REF #( requested_authorizations )
*    result                   = REF #( result )
*    reported                 = REF #( reported ) ).
  ENDMETHOD.
  METHOD edit.
    mbc_cp_api=>rap_bc_api( )->get_default_transport_request(
      transport_object = co_transport_object
      entity           = co_entity
      keys             = REF #( keys )
      mapped           = REF #( mapped )
      failed           = REF #( failed )
      reported         = REF #( reported ) ).
  ENDMETHOD.
  METHOD earlynumbering_create.

    DATA: lv_item TYPE c LENGTH 3.

    READ TABLE entities_cba INTO DATA(lt_entity1) INDEX 1.
    READ TABLE lt_entity1-%target INTO DATA(ls_entity_item1) INDEX 1.


    SELECT MAX( counter  ) FROM zpr_tb_po_pr_d WHERE condtype = @ls_entity_item1-condtype INTO @DATA(lv_max_count).
    IF sy-subrc EQ 0.
      lv_item = lv_max_count + 1.
    ELSE.
      lv_item = 1.
    ENDIF.

    LOOP AT entities_cba INTO DATA(lt_entity).
      LOOP AT lt_entity-%target INTO DATA(ls_entity_item).
        IF ls_entity_item-counter EQ '000'.
          ls_entity_item-counter = lv_item.
        ENDIF.
        MODIFY lt_entity-%target FROM ls_entity_item.
        APPEND CORRESPONDING #( ls_entity_item ) TO mapped-popricingconditiont.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
CLASS lsc_zi_popricingconextt_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION.
ENDCLASS.

CLASS lsc_zi_popricingconextt_s IMPLEMENTATION.
  METHOD save_modified.
    mbc_cp_api=>rap_bc_api( )->record_changes(
      transport_object = lhc_zi_popricingconextt_s=>co_transport_object
      entity           = lhc_zi_popricingconextt_s=>co_entity
      create           = REF #( create )
      update           = REF #( update )
      delete           = REF #( delete )
      reported         = REF #( reported ) ).
    mbc_cp_api=>rap_bc_api( )->update_last_changed_date_time(
      maintenance_object = 'ZPOPRICINGCONDITIONT_EXT'
      entity             = lhc_zi_popricingconextt_s=>co_authorization_entity
      create             = REF #( create )
      update             = REF #( update )
      delete             = REF #( delete )
      reported           = REF #( reported ) ).
  ENDMETHOD.
ENDCLASS.
CLASS lhc_zi_popricingcondextt DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.
    CONSTANTS:
      co_entity TYPE sxco_cds_object_name VALUE `ZI_POPRICINGCONDEXTT`.

  PRIVATE SECTION.
    METHODS:
    "Insert by Sindhu
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR popricingconditiont
        RESULT    result,
    "Insert by Sindhu
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
          REQUEST requested_features FOR popricingconditiont
        RESULT result,
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys_popricingconditiall FOR popricingconditiall~validatetransportrequest
          keys_popricingconditiont FOR popricingconditiont~validatetransportrequest,
       markdel FOR MODIFY
        IMPORTING keys FOR ACTION popricingconditiont~markdel,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
            IMPORTING REQUEST requested_authorizations FOR popricingconditiont RESULT result,
      copyitem FOR MODIFY
            IMPORTING keys FOR ACTION popricingconditiont~copyitem.
ENDCLASS.

CLASS lhc_zi_popricingcondextt IMPLEMENTATION.
  METHOD get_global_features.
    mbc_cp_api=>rap_bc_api( )->get_global_features(
      transport_object   = lhc_zi_popricingconextt_s=>co_transport_object
      entity             = co_entity
      requested_features = REF #( requested_features )
      result             = REF #( result )
      reported           = REF #( reported ) ).


  ENDMETHOD.
  METHOD validatetransportrequest.

    DATA: lv_msg_num TYPE syst-msgno.

    mbc_cp_api=>rap_bc_api( )->validate_transport_request(
      transport_object = lhc_zi_popricingconextt_s=>co_transport_object
      entity           = lhc_zi_popricingconextt_s=>co_entity
      validation_keys  = VALUE #( ( REF #( keys_popricingconditiall ) )
                                  ( REF #( keys_popricingconditiont ) ) )
      failed           = REF #( failed )
      reported         = REF #( reported ) ).


    READ ENTITIES OF zi_popricingconextt_s IN LOCAL MODE
         ENTITY popricingconditiont
           ALL FIELDS WITH CORRESPONDING #( keys_popricingconditiont )
           RESULT DATA(entities).

    lv_msg_num = '001'.
    LOOP AT entities INTO DATA(ls_data).

      IF ls_data-single EQ abap_false.
        IF ls_data-calctype IS INITIAL OR
           ls_data-condclass IS INITIAL OR
           ls_data-condvalue IS INITIAL OR
           ls_data-high IS INITIAL OR
           ls_data-enddate IS INITIAL OR
           ls_data-low IS INITIAL OR
           ls_data-uom IS INITIAL OR
           ls_data-unit IS INITIAL OR
           ls_data-startdate IS INITIAL OR
           ls_data-per IS INITIAL.


          APPEND VALUE #( %key = ls_data-%key ) TO failed-popricingconditiont.
          APPEND VALUE #(
                        %key = ls_data-%key
                      %msg = new_message(
                      id = 'ZPR_MESSAGES_EXT'
                      number = lv_msg_num
                      severity = if_abap_behv_message=>severity-error )
                      ) TO reported-popricingconditiont.
        ENDIF.
      ELSE.
        IF ls_data-calctype IS INITIAL OR
          ls_data-condclass IS INITIAL OR
          ls_data-condvalue IS INITIAL OR
          ls_data-enddate IS INITIAL OR
          ls_data-low IS INITIAL OR
          ls_data-uom IS INITIAL OR
          ls_data-unit IS INITIAL OR
          ls_data-startdate IS INITIAL OR
          ls_data-per IS INITIAL.


          APPEND VALUE #( %key = ls_data-%key ) TO failed-popricingconditiont.
          APPEND VALUE #(
                        %key = ls_data-%key
                      %msg = new_message(
                      id = 'ZPR_MESSAGES_EXT'
                      number = lv_msg_num
                      severity = if_abap_behv_message=>severity-error )
                      ) TO reported-popricingconditiont.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD markdel.

    SELECT * FROM zpr_tb_price_ext
      FOR ALL ENTRIES IN @keys
      WHERE cond_type = @keys-condtype
      AND   counter = @keys-counter
      INTO TABLE @DATA(lt_po_price).
    IF sy-subrc EQ 0.
      LOOP AT lt_po_price INTO DATA(ls_po_price).
        ls_po_price-deletion_ind = 'X'.
        MODIFY zpr_tb_price_ext FROM @ls_po_price.
      ENDLOOP.

    ENDIF.

  ENDMETHOD.


  "Insert by Sindhu
  METHOD get_instance_features.

    READ ENTITIES OF zi_popricingconextt_s IN LOCAL MODE
            ENTITY popricingconditiont
              ALL FIELDS WITH CORRESPONDING #( keys )
              RESULT DATA(entities).
    READ TABLE entities INTO DATA(ls_entity) INDEX 1.

    result = VALUE #( FOR key IN keys
                              %tky = key-%tky

                             (  %field-high = COND #( WHEN ls_entity-single EQ abap_true
                                                       THEN if_abap_behv=>fc-f-read_only
                                                       ELSE if_abap_behv=>fc-f-unrestricted )
                                                   )  ).

  ENDMETHOD.
  "Insert by Sindhu
  METHOD copyitem.


    DATA : lt_new    TYPE  TABLE FOR CREATE zi_popricingconextt_s\_popricingconditiont,
           ls_new    LIKE LINE OF lt_new,
           ls_target LIKE LINE OF ls_new-%target.

    READ ENTITIES OF zi_popricingconextt_s IN LOCAL MODE
                    ENTITY popricingconditiont
                      ALL FIELDS WITH CORRESPONDING #( keys )
                      RESULT DATA(entities).

    READ TABLE entities INTO DATA(ls_entities) INDEX 1.
    MOVE-CORRESPONDING ls_entities TO ls_target.

    SELECT MAX( counter ) FROM zpr_tb_price_ext
      WHERE cond_type = @ls_target-condtype
      INTO @DATA(lv_counter).

    ls_target-counter = lv_counter + 1.
    ls_target-%cid = keys[ 1 ]-%cid.
    ls_target-%control-calctype = '01'.
    ls_target-%control-condclass = '01'.
    ls_target-%control-condtype = '01'.
    ls_target-%control-condvalue = '01'.
    ls_target-%control-counter = '01'.
    ls_target-%control-deletionind = '01'.
    ls_target-%control-enddate = '01'.
    ls_target-%control-high = '01'.
    ls_target-%control-low = '01'.
    ls_target-%control-per = '01'.
    ls_target-%control-single = '01'.
    ls_target-%control-singletonid = '01'.
    ls_target-%control-startdate = '01'.
    ls_target-%control-uom = '01'.
    ls_target-%control-unit = '01'.
    APPEND ls_target TO ls_new-%target.

    ls_new-%is_draft = '01'.
    ls_new-singletonid = 1.
    APPEND ls_new TO lt_new.

    MODIFY ENTITIES OF zi_popricingconextt_s IN LOCAL MODE
      ENTITY popricingconditiall
      CREATE BY \_popricingconditiont
      FROM lt_new
      MAPPED DATA(mapped_create)
      FAILED DATA(failed_create)
      REPORTED DATA(reported_create).

    READ ENTITIES OF zi_popricingconextt_s IN LOCAL MODE
      ENTITY popricingconditiont
      ALL FIELDS WITH CORRESPONDING #( mapped_create-popricingconditiont )
      RESULT DATA(read_created_result).

    mapped-popricingconditiont = mapped_create-popricingconditiont.

  ENDMETHOD.

ENDCLASS.