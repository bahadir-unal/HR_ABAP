*&---------------------------------------------------------------------*
*& Report ZVESA_E00086_P06
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZVESA_E00086_P06.


*----------------------------------------------------------------------
*-----------------------SALV-------------------------------------------


*DATA: gt_sbook TYPE TABLE OF sbook,
*      go_salv TYPE REF TO cl_salv_table.
*START-OF-SELECTION.
*SELECT * UP TO 20 ROWS FROM sbook
*  into TABLE gt_sbook.
*
*cl_salv_table=>FACTORY(
*  importing
*    R_SALV_TABLE   =     go_salv
*  changing
*    T_TABLE        = gt_sbook
*).
*
*go_salv->DISPLAY( ).


DATA: gt_sbook TYPE TABLE OF sbook,
      go_salv TYPE REF TO cl_salv_table.
START-OF-SELECTION.
SELECT * UP TO 20 ROWS FROM sbook
  into TABLE gt_sbook.

cl_salv_table=>FACTORY(
  importing
    R_SALV_TABLE   =     go_salv
  changing
    T_TABLE        = gt_sbook
).

DATA: lo_display TYPE REF TO cl_salv_display_settings.
lo_display = go_salv->GET_DISPLAY_SETTINGS( ) .

* TABLO BAŞLIĞI AYARLAMA
lo_display->SET_LIST_HEADER( value = 'SALV EĞİTİM' ) .
* ZEBRA SATIRLAR OLUŞTURUR.
lo_display->SET_STRIPED_PATTERN( VALUE = 'X' ).

DATA: lo_cols TYPE REF TO cl_salv_columns.

lo_cols = go_salv->GET_COLUMNS( ) .
* TABLO GENİŞLİĞİNİ AYARLIYOR OTOMATİK FAZLA BOŞLUK BIRAKMIYOR
lo_cols->SET_OPTIMIZE( value = 'X' ) .



DATA: lo_col TYPE REF TO cl_salv_column.
* KOLON İSMİNİ STRING İÇERİSİNDE YANLIŞ GİRERSEN ANLIK YAKALAMAZ AMA RUNTIME KISMINDA HATA VERİR.
*lo_col = lo_cols->GET_COLUMN( COLUMNNAME = 'FORCURAM'  ) .
*lo_col->SET_LONG_TEXT( VALUE = 'TOPLAM TUTAR' )  .
*lo_col->SET_MEDIUM_TEXT( VALUE = 'TUTAR'  ).
*lo_col->SET_SHORT_TEXT( VALUE = 'TTR' ).

* SEÇİLEN KOLUNUN GÖZÜKÜP GÖZÜKMEMESİ İÇİN GEREKLİ KOD.
lo_col = lo_cols->GET_COLUMN( COLUMNNAME = 'MANDT'  ) .
lo_col->SET_VISIBLE( VALUE = IF_SALV_C_BOOL_SAP=>FALSE ).

DATA: lo_header  TYPE REF TO  cl_salv_form_layout_grid,
      lo_h_label TYPE REF TO  cl_salv_form_label,
      lo_h_flow  TYPE REF TO  cl_salv_form_layout_flow.

CREATE OBJECT lo_header.
lo_h_label = lo_header->CREATE_LABEL( ROW = 1 COLUMN      = 1 ).
lo_h_label->SET_TEXT( VALUE = 'Başlık İlk Satır'  ).
lo_h_flow = lo_header->CREATE_FLOW( ROW = 2      COLUMN  = 1 ) .
lo_h_flow->CREATE_TEXT( exporting TEXT     = 'Başlık İkinci Satır.' ).

go_salv->SET_TOP_OF_LIST( value = lo_header ) .
* ALV'Yİ POP UP ŞEKLİNDE BİR PENCEREDE GÖSTERİR BOYUTLARINI AYARLADIK.
*go_salv->SET_SCREEN_POPUP(
*  exporting
*    START_COLUMN = 10
*    END_COLUMN   = 75
*    START_LINE   = 5
*    END_LINE     = 25
*).

go_salv->DISPLAY( ).
