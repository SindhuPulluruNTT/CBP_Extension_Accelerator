CLASS lhc_zpr_ud_display DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zpr_ud_display RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zpr_ud_display RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE zpr_ud_display.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE zpr_ud_display.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE zpr_ud_display.

    METHODS read FOR READ
      IMPORTING keys FOR READ zpr_ud_display RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zpr_ud_display.

ENDCLASS.

CLASS lhc_zpr_ud_display IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD create.

    TYPES: BEGIN OF lty_cond,

             cid   TYPE abp_behv_cid,
             kschl TYPE i_slsprcgconditionrecord-conditiontype,
             kwert TYPE i_slsprcgconditionrecord-conditionrateamount,

           END OF lty_cond.

    DATA: gv_code      TYPE c LENGTH 4,
          gv_cg        TYPE c LENGTH 8,
          lv_prueflos  TYPE zpr_de_ilot,
          lv_price_upd TYPE c,
          lt_cond_upd  TYPE STANDARD TABLE OF lty_cond,
          ls_cond_upd  LIKE LINE OF lt_cond_upd,
          lv_share     TYPE p DECIMALS 3,
          lv_post      TYPE c,
          lv_i         TYPE i VALUE 1,
          lv_message   TYPE string.

    LOOP AT entities INTO DATA(ls_data).

* Get Material Document and Purchase Order
      SELECT SINGLE * FROM i_insplotmatldocitem WHERE inspectionlot = @ls_data-lot
        INTO @DATA(ls_insplot).
      IF sy-subrc EQ 0.
        SELECT SINGLE * FROM i_materialdocumentitem_2 WHERE materialdocument = @ls_insplot-materialdocument
                                                      AND materialdocumentyear = @ls_insplot-materialdocumentyear
                                                      AND materialdocumentitem = @ls_insplot-materialdocumentitem
                                                      INTO @DATA(ls_gr).
        IF sy-subrc EQ 0.
          SELECT SINGLE * FROM i_purchaseorderitemapi01 WHERE purchaseorder = @ls_gr-purchaseorder
                                                        AND   purchaseorderitem = @ls_gr-purchaseorderitem
                                                        INTO @DATA(ls_po).
          IF sy-subrc EQ 0.
            lv_share =  ls_gr-quantityinbaseunit / ls_po-orderquantity.
          ENDIF.
        ENDIF.

      ENDIF.

      MODIFY ENTITY i_inspectionlottp_2
  EXECUTE recordusagedecision
  FROM VALUE #(
  ( %key-inspectionlot = ls_data-lot
  %param-selectedcodesetplant = ls_gr-plant
  %param-%control-selectedcodesetplant = if_abap_behv=>mk-on
  %param-insplotusgedcsnselectedset = ls_data-codegroup
  %param-%control-insplotusgedcsnselectedset = if_abap_behv=>mk-on
  %param-insplotusagedecisioncodegroup = ls_data-codegroup
  %param-%control-insplotusagedecisioncodegroup = if_abap_behv=>mk-on
  %param-inspectionlotusagedecisioncode = ls_data-code
  %param-%control-inspectionlotusagedecisioncode = if_abap_behv=>mk-on )
  )
  RESULT DATA(ls_result_1)
  MAPPED DATA(ls_mapped_1)
  FAILED DATA(ls_failed_1)
  REPORTED DATA(ls_reported_1).


      IF ls_failed_1-inspectionlot[] IS INITIAL.
* Add code for PO Update
        lv_price_upd = abap_true.
      ELSE.
        lv_message = 'Error when posting Usage Decision'.
      ENDIF.

      IF lv_message IS NOT INITIAL.
        APPEND VALUE #( %key = ls_data-%key ) TO failed-zpr_ud_display.
        APPEND VALUE #(                  %msg = new_message(
                   id = 'ZPR_MESSAGES_EXT'
                   number = '002'
                   v1 =   ls_data-lot
                   v2 =   lv_message
                   severity = if_abap_behv_message=>severity-error
                                      )
                 ) TO reported-zpr_ud_display.
      ENDIF.

      IF lv_price_upd EQ abap_true.

        SELECT SINGLE * FROM i_inspectionlot WHERE inspectionlot = @ls_data-lot
           INTO @DATA(ls_insp_lot).

        SELECT * FROM i_inspectionresult WHERE inspectionlot = @ls_data-lot
           INTO TABLE @DATA(lt_insp_results).
        IF sy-subrc EQ 0.
* Get inspection lot characteristic
          SELECT * FROM i_inspectioncharacteristic WHERE inspectionlot = @ls_data-lot
            INTO TABLE @DATA(lt_insp_char).

          IF sy-subrc EQ 0.
            SELECT * FROM zpr_tb_cmap_ext FOR ALL ENTRIES IN @lt_insp_char
              WHERE char_name = @lt_insp_char-inspectionspecification
              INTO TABLE @DATA(lt_cond).

* Fetch the custom condition types for PO update
            SELECT * FROM zpr_tb_price_ext FOR ALL ENTRIES IN @lt_cond
              WHERE cond_type = @lt_cond-cond_type
              AND start_date LE @sy-datum
              AND end_date GE @sy-datum
              AND deletion_ind = ''
              INTO TABLE @DATA(lt_price).
            IF sy-subrc EQ 0.
              SORT lt_price BY cond_type.
            ENDIF.

            SELECT SINGLE * FROM i_purorditmpricingelementapi01
             WHERE purchaseorder = @ls_gr-purchaseorder
             AND purchaseorderitem = @ls_gr-purchaseorderitem
             INTO @DATA(ls_element).

            LOOP AT lt_insp_char INTO DATA(ls_insp_char).
              READ TABLE lt_cond INTO DATA(ls_cond) WITH KEY char_name = ls_insp_char-inspectionspecification.
              IF sy-subrc EQ 0.
                READ TABLE lt_insp_results INTO DATA(ls_results) WITH KEY inspectionlot = ls_data-lot
                                                                          inspectioncharacteristic = ls_insp_char-inspectioncharacteristic.
                IF sy-subrc EQ 0.

                  LOOP AT lt_price INTO DATA(ls_price) WHERE cond_type = ls_cond-cond_type.
                    CLEAR: lv_post.
                    IF ls_price-single_value EQ abap_false.
                      IF ls_price-low LE ls_results-inspectionresultmeanvalue AND
                         ls_results-inspectionresultmeanvalue LE ls_price-high.
                        lv_post = abap_true.
                      ENDIF.
                    ELSE.
                      IF ls_price-low = ls_results-characteristicattributecode.
                        lv_post = abap_true.
                      ENDIF.
                    ENDIF.
                    IF lv_post EQ abap_true.
                      CLEAR: ls_cond_upd.
                      ls_cond_upd-cid = lv_i.
                      ls_cond_upd-kschl = ls_cond-cond_type.
                      IF ls_price-calc_type EQ 'Fixed amount'.
                        ls_price-cond_value = ( ls_price-cond_value / ls_price-per ) * ls_gr-quantityinbaseunit.
                        IF ls_price-cond_class = 'Discount'.
                          ls_price-cond_value = ls_price-cond_value * -1.
                        ENDIF.
                        ls_cond_upd-kwert =  ls_price-cond_value.
                      ELSE.
                        ls_cond_upd-kwert =  ( lv_share * ls_price-cond_value ).
                      ENDIF.
                      APPEND ls_cond_upd TO lt_cond_upd.
                      lv_i = lv_i + 1.
                    ENDIF.
                  ENDLOOP.
                ENDIF.
              ENDIF.
            ENDLOOP.


            IF lt_cond_upd[] IS NOT INITIAL.
* Update PO Price - add custom condition types based on results recording
              MODIFY ENTITIES OF i_purchaseordertp_2
                ENTITY purchaseorderitem
                CREATE BY \_purordpricingelement
                FIELDS ( conditiontype
                         conditionrateamount )
                WITH VALUE  #( (  purchaseorder = ls_gr-purchaseorder
                                  purchaseorderitem   = ls_gr-purchaseorderitem
                                  %target  =  VALUE #( FOR ls_target IN lt_cond_upd
                                                          ( %cid = ls_target-cid
                                                            pricingdocument    = ls_element-pricingdocument
                                                            pricingdocumentitem    = ls_element-pricingdocumentitem
                                                            conditiontype = ls_target-kschl
                                                            conditionrateamount = ls_target-kwert )
                                     ) ) )
                  FAILED DATA(ls_failed_2)
                  MAPPED DATA(ls_mapped_2)
                  REPORTED DATA(ls_reported_2).
              IF ls_failed_2-purorderitempricingelement[] IS NOT INITIAL.
                CONCATENATE 'Error when updating PO' ls_gr-purchaseorder INTO lv_message SEPARATED BY space.
              ENDIF.

              IF lv_message IS NOT INITIAL.
                APPEND VALUE #( %key = ls_data-%key ) TO failed-zpr_ud_display.
                APPEND VALUE #(                  %msg = new_message(
                           id = 'ZPR_MESSAGES_EXT'
                           number = '002'
                           v1 =   ls_data-lot
                           v2 =   lv_message
                           severity = if_abap_behv_message=>severity-information
                                              )
                         ) TO reported-zpr_ud_display.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zpr_ud_display DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zpr_ud_display IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.