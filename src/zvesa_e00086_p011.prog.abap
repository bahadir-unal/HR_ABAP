*&---------------------------------------------------------------------*
*& Report ZVESA_E00086_P011
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zvesa_e00086_p011.


"***************************************
*PULL REQUEST TEST BAHADIR 26.07.2026.
"***************************************


TABLES: p0000,p0001,p0002.
" JSON structure tanımı
TYPES: BEGIN OF ty_data,
         horoscope_data TYPE string,
         week TYPE string,
       END OF ty_data.

TYPES: BEGIN OF ty_json_response,
         data TYPE ty_data,
         status TYPE i,
         success TYPE abap_bool,
       END OF ty_json_response.

DATA: ls_structure TYPE ty_json_response.

CLASS gc_main DEFINITION DEFERRED .
DATA : go_report   TYPE REF TO gc_main.



DATA: lt_messages TYPE bapiret2_tab.

DATA: lv_url  TYPE string VALUE 'https://horoscope-app-api.vercel.app/api/v1/get-horoscope/weekly?sign=',
      lv_burc TYPE string,
      lv_json TYPE string.
DATA birth_date TYPE sy-datum.
DATA: BEGIN OF gs_out ,
        pernr TYPE pa0000-pernr,
        ename TYPE emnam,
        burc  TYPE string,
        gbort TYPE gbort,
      END OF gs_out,
      gt_out LIKE TABLE OF gs_out.

DATA : lo_client TYPE REF TO if_http_client,
       l_service TYPE string,
       l_result  TYPE string,
       lt_return TYPE TABLE OF bapiret2,
       ls_return TYPE bapireturn1.

CLASS gc_main DEFINITION.
  PUBLIC SECTION .
    " - ALV DEFINATION
    DATA: o_alv        TYPE REF TO cl_salv_table,
          go_display   TYPE REF TO cl_salv_display_settings,
          go_columns   TYPE REF TO cl_salv_columns_table,
          go_column    TYPE REF TO cl_salv_column_table,
          go_events    TYPE REF TO cl_salv_events_table,
          go_functions TYPE REF TO cl_salv_functions_list,
          go_selection TYPE REF TO cl_salv_selections,
          go_layout    TYPE REF TO cl_salv_layout,
          go_sorts     TYPE REF TO cl_salv_sorts,
          go_agg       TYPE REF TO cl_salv_aggregations,
          gs_key       TYPE        salv_s_layout_key.

    METHODS :
      get_data,
      set_data,
      calculate_zodiac_sign,
      post_service.

ENDCLASS.

CLASS gc_main IMPLEMENTATION .
  METHOD get_data.

* select p0~pernr,p1~ename, p2~gbort
*   from pa0000 as p0
*   left join pa0001 as p1 on p0~pernr = p1~pernr
*                         and p1~begda le @sy-datum
*                         and p1~endda ge @sy-datum
*   left join pa0002 as p2 on p0~pernr = p2~pernr
*                         and p2~begda le @sy-datum
*                         and p2~endda ge @sy-datum
*   into table @data(lt_info).

  ENDMETHOD.

  METHOD set_data.

    gs_out-pernr = p0000-pernr.
    gs_out-ename = p0001-ename.
    gs_out-gbort = p0002-gbort.



    birth_date = '2025-05-31'.


  ENDMETHOD.
  METHOD calculate_zodiac_sign.


    DATA rv_zodiac_sign TYPE string.

    " MMDD formatında string oluşturma
    DATA(lv_mmdd) = |{ birth_date+4(2) }{ birth_date+6(2) }|.

    rv_zodiac_sign = COND string(
    WHEN lv_mmdd BETWEEN '0321' AND '0419' THEN 'Aries'
    WHEN lv_mmdd BETWEEN '0420' AND '0520' THEN 'Taurus'
    WHEN lv_mmdd BETWEEN '0521' AND '0620' THEN 'Gemini'
    WHEN lv_mmdd BETWEEN '0621' AND '0722' THEN 'Cancer'
    WHEN lv_mmdd BETWEEN '0723' AND '0822' THEN 'Leo'
    WHEN lv_mmdd BETWEEN '0823' AND '0922' THEN 'Virgo'
    WHEN lv_mmdd BETWEEN '0923' AND '1022' THEN 'Libra'
    WHEN lv_mmdd BETWEEN '1023' AND '1121' THEN 'Scorpio'
    WHEN lv_mmdd BETWEEN '1122' AND '1221' THEN 'Sagittarius'
    WHEN lv_mmdd >= '1222' OR lv_mmdd <= '0119' THEN 'Capricorn'
    WHEN lv_mmdd BETWEEN '0120' AND '0218' THEN 'Aquarius'
    WHEN lv_mmdd BETWEEN '0219' AND '0320' THEN 'Pisces'
    ELSE 'Bilinmiyor'
  ).
    CONCATENATE lv_url rv_zodiac_sign INTO lv_url.
  ENDMETHOD.
  METHOD post_service.
    cl_http_client=>create_by_url(
        EXPORTING
          url                = lv_url
        IMPORTING
          client             = lo_client
        EXCEPTIONS
          argument_not_found = 1
          plugin_not_active  = 2
          internal_error     = 3
          OTHERS             = 4 ).

    CALL METHOD lo_client->request->set_header_field
      EXPORTING
        name  = '~request_method'
        value = 'GET'.

    CALL METHOD lo_client->request->set_header_field
      EXPORTING
        name  = 'Accept'
        value = 'application/json'.

    CALL METHOD lo_client->request->set_header_field
      EXPORTING
        name  = 'Accept-Language'
        value = 'tr-tr'.

    CALL METHOD lo_client->request->set_header_field
      EXPORTING
        name  = 'Cache-Control'
        value = 'no-cache'.

    lo_client->propertytype_logon_popup = lo_client->co_disabled.
    lo_client->propertytype_accept_cookie = lo_client->co_enabled.

*      CALL METHOD lo_client->request->set_cdata
*        EXPORTING
*          data   = xml_send_data
*          offset = 0
*          length = xml_send_data_len_i.

    lo_client->send( ).

    lo_client->receive(
        EXCEPTIONS
          http_communication_failure = 1
          http_invalid_state         = 2
          http_processing_failed     = 3 ).

    "STEP-5 : Read HTTP RETURN CODE
    DATA http_status_code TYPE i.
    DATA status_text TYPE string.
    CALL METHOD lo_client->response->get_status
      IMPORTING
        code   = http_status_code
        reason = status_text.


    " Check if HTTP request was successful
    IF http_status_code <> 200.
      " Error handling
      lo_client->close( ).
      FREE lo_client.
      RETURN.
    ENDIF.

    CALL METHOD lo_client->response->get_cdata
      RECEIVING
        data = l_result.

    /ui2/cl_json=>deserialize( EXPORTING json = l_result
                               CHANGING  data = ls_structure ).


  write: ls_structure-data-horoscope_data.
  ENDMETHOD.
ENDCLASS.
*&---------------------------------------------------------------------*
*&  Include           ZRHSF_IDM_I003
*&---------------------------------------------------------------------*
INITIALIZATION .
  CREATE OBJECT go_report.
  "go_report->init( ).

AT SELECTION-SCREEN.

START-OF-SELECTION.

*GET pernr.

  go_report->get_data( ).
  go_report->set_data( ).
  go_report->calculate_zodiac_sign( ).

END-OF-SELECTION.

  go_report->post_service( ).
