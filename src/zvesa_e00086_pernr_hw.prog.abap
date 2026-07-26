*&---------------------------------------------------------------------*
*& Report ZVESA_E00086_PERNR_HW
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZVESA_E00086_PERNR_HW.

TABLES: pa0000. " PA0000 tablosu referansı

" Seçim ekranı tanımı
SELECT-OPTIONS: so_pernr FOR pa0000-pernr.
DATA: ls_pernr LIKE LINE OF so_pernr.  "Seçim aralığını işlemek için yapı

TYPES: BEGIN OF ty_employee_info,
         pernr TYPE pa0000-pernr,   " Personel numarası
         vorna TYPE pa0002-vorna,   " Ad
         nachn TYPE pa0002-nachn,   " Soyad
         orghe TYPE pa0001-orgeh,   " Organizasyon birimi
         plans TYPE pa0001-plans,   " Pozisyon
         gbdat TYPE pa0002-gbdat,   " Doğum tarihi
       END OF ty_employee_info.


TYPES: BEGIN OF ty_employee_info_with_color,
         pernr TYPE persno,         " Personel numarası
         vorna TYPE vorna,          " Ad
         nachn TYPE nachn,          " Soyad
         orghe TYPE orgeh,          " Organizasyon birimi
         plans TYPE plans,          " Pozisyon
         gbdat TYPE gbdat,          " Doğum tarihi
         color TYPE lvc_t_scol,     " Renk kodu
       END OF ty_employee_info_with_color.

DATA: lt_employee_info_with_color TYPE TABLE OF ty_employee_info_with_color,  " Renkli veriler içeren tablo
      ls_employee_info            TYPE ty_employee_info,                      " Veriyi alacağımız satır
      ls_employee_info_with_color TYPE ty_employee_info_with_color.           " Renkli satır

DATA: lt_employee_info TYPE TABLE OF ty_employee_info,  " İç tablo
      lt_colors        TYPE lvc_t_scol,                 " Renkler tablosu
      ls_color         TYPE lvc_s_scol.                 " Renk satırı

" (SALV) için tanımlamalar
DATA:   gt_salv_tab TYPE TABLE OF  ty_employee_info,        " SALV iç tablosu
        gs_salv_tab TYPE           ty_employee_info,        " SALV tablosu satırı
        gr_salv     TYPE REF TO    cl_salv_table,           " SALV nesnesi
        gr_columns  TYPE REF TO    cl_salv_columns_table,   " Kolonlar
        gr_column   TYPE REF TO    cl_salv_column.          " Kolon ayarı
    FIELD-SYMBOLS: <fs_salv> TYPE  ty_employee_info.

START-OF-SELECTION.
  " PA0000, PA0001 ve PA0002 tablolarını birleştirme ve SQL sorgusu.
  SELECT
         p0000~pernr,           " Personel numarası
         p0002~vorna,           " Ad
         p0002~nachn,           " Soyad
         p0001~orgeh,           " Organizasyon birimi
         p0001~plans,           " Pozisyon
         p0002~gbdat            " Doğum tarihi
    INTO TABLE @lt_employee_info
    FROM pa0000 AS p0000
    INNER JOIN pa0001 AS p0001 ON p0000~pernr = p0001~pernr
    INNER JOIN pa0002 AS p0002 ON p0000~pernr = p0002~pernr
    WHERE p0000~pernr IN @so_pernr.

* Kopya satırları silmek için gerekli kod parçası.
" Eğer ardışık değilse sort ile sıralama yapmak gerekiyor.
" SORT lt_employee_info BY pernr şeklinde.
" Yalnızca arka arkaya gelen aynı değerdeki satırları silmede kullanılır.
" Comparing pernr demek sadece pernr'e göre kıyasla yoksa bütün tabloyu kıyaslar.
" Pernr alanları aynıysa sil diyor.
  DELETE ADJACENT DUPLICATES FROM lt_employee_info COMPARING pernr.

*  LOOP AT lt_employee_info ASSIGNING FIELD-SYMBOL(<f>).
*    APPEND VALUE #(
*    fname = 'UNAME'
*    color-col = col_negative
*    color-int = 0
*    color-inv = 0
*    ) TO <f>-color.
*   ENDLOOP.


  " SALV Tablosu Gösterimi
  TRY.
      " ALV tablo nesnesini oluştur
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = gr_salv
        CHANGING
          t_table      = lt_employee_info ).

      " Kolonlara renk atamak için renk tablosunu kullan

      " SALV'yi görüntüle
      gr_salv->display( ).

  CATCH cx_salv_msg INTO DATA(lx_msg).
    MESSAGE lx_msg->get_text( ) TYPE 'E'.
  ENDTRY.
