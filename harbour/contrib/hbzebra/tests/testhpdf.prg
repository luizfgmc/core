/*
 * $Id$
 */

/*
 * Harbour Project source code:
 *
 * Copyright 2010 Viktor Szakats (harbour.01 syenar.hu)
 * www - http://harbour-project.org
 *
 */

#include "hbzebra.ch"
#include "harupdf.ch"

PROCEDURE Main()
   LOCAL pdf
   LOCAL page
   LOCAL nY, nInc

   pdf := HPDF_New()
   page := HPDF_AddPage( pdf )
   HPDF_Page_SetSize( page, HPDF_PAGE_SIZE_A4, HPDF_PAGE_PORTRAIT )
   HPDF_Page_SetFontAndSize( page, HPDF_GetFont( pdf, "Helvetica", NIL ), 12 )

   nY := 40
   nInc := 30

   DrawBarcode( page, nY,               1, "EAN13",   "477012345678" )
   DrawBarcode( page, nY += nInc,       1, "EAN8",    "1234567" )
   DrawBarcode( page, nY += nInc,       1, "UPCA",    "01234567891" )
   DrawBarcode( page, nY += nInc,       1, "UPCE",    "123456" )
   DrawBarcode( page, nY += nInc,       1, "CODE39",  "ABC123" )
   DrawBarcode( page, nY += nInc,       1, "CODE39",  "ABC123", HB_ZEBRA_FLAG_CHECKSUM )
   DrawBarcode( page, nY += nInc,     0.5, "CODE39",  "ABC123", HB_ZEBRA_FLAG_CHECKSUM + HB_ZEBRA_FLAG_WIDE2_5 )
   DrawBarcode( page, nY += nInc,       1, "CODE39",  "ABC123", HB_ZEBRA_FLAG_CHECKSUM + HB_ZEBRA_FLAG_WIDE3 )
   DrawBarcode( page, nY += nInc,       1, "ITF",     "1234", HB_ZEBRA_FLAG_WIDE3 )
   DrawBarcode( page, nY += nInc,       1, "ITF",     "12345678901", HB_ZEBRA_FLAG_CHECKSUM )
   DrawBarcode( page, nY += nInc,       1, "MSI",     "1234" )
   DrawBarcode( page, nY += nInc,       1, "MSI",     "1234", HB_ZEBRA_FLAG_CHECKSUM + HB_ZEBRA_FLAG_WIDE3 )
   DrawBarcode( page, nY += nInc,       1, "MSI",     "1234567", HB_ZEBRA_FLAG_CHECKSUM )
   DrawBarcode( page, nY += nInc,       1, "CODABAR", "40156", HB_ZEBRA_FLAG_WIDE3 )
   DrawBarcode( page, nY += nInc,       1, "CODABAR", "-1234", HB_ZEBRA_FLAG_WIDE3 )
   DrawBarcode( page, nY += nInc,       1, "CODE93",  "ABC-123" )
   DrawBarcode( page, nY += nInc,       1, "CODE93",  "TEST93" )
   DrawBarcode( page, nY += nInc,       1, "CODE11",  "12", HB_ZEBRA_FLAG_WIDE3 )
   DrawBarcode( page, nY += nInc,       1, "CODE11",  "1234567890", HB_ZEBRA_FLAG_CHECKSUM + HB_ZEBRA_FLAG_WIDE3 )
   DrawBarcode( page, nY += nInc,       1, "CODE128", "Code 128")
   DrawBarcode( page, nY += nInc,       1, "CODE128", "1234567890")
   DrawBarcode( page, nY += nInc,       1, "CODE128", "Wikipedia")
   DrawBarcode( page, nY += 2.5 * nInc, 1, "PDF417",  "Hello, World of Harbour!!! It's 2D barcode PDF417 :)" )

   ? HPDF_SaveToFile( pdf, "testhpdf.pdf" )

   RETURN

PROCEDURE DrawBarcode( page, nY, nLineWidth, cType, cCode, nFlags )
   LOCAL hZebra, nLineHeight

   nY := 841 - nY

   SWITCH cType
   CASE "EAN13"   ; hZebra := hb_zebra_create_ean13( cCode, nFlags )   ; EXIT
   CASE "EAN8"    ; hZebra := hb_zebra_create_ean8( cCode, nFlags )    ; EXIT
   CASE "UPCA"    ; hZebra := hb_zebra_create_upca( cCode, nFlags )    ; EXIT
   CASE "UPCE"    ; hZebra := hb_zebra_create_upce( cCode, nFlags )    ; EXIT
   CASE "CODE39"  ; hZebra := hb_zebra_create_code39( cCode, nFlags )  ; EXIT
   CASE "ITF"     ; hZebra := hb_zebra_create_itf( cCode, nFlags )     ; EXIT
   CASE "MSI"     ; hZebra := hb_zebra_create_msi( cCode, nFlags )     ; EXIT
   CASE "CODABAR" ; hZebra := hb_zebra_create_codabar( cCode, nFlags ) ; EXIT
   CASE "CODE93"  ; hZebra := hb_zebra_create_code93( cCode, nFlags )  ; EXIT
   CASE "CODE11"  ; hZebra := hb_zebra_create_code11( cCode, nFlags )  ; EXIT
   CASE "CODE128" ; hZebra := hb_zebra_create_code128( cCode, nFlags ) ; EXIT
   CASE "PDF417"  ; hZebra := hb_zebra_create_pdf417( cCode, nFlags ); nLineHeight := nLineWidth * 3; EXIT
   ENDSWITCH

   IF hZebra != NIL
      IF hb_zebra_geterror( hZebra ) == 0
         IF EMPTY( nLineHeight )
            nLineHeight := 16
         ENDIF
         HPDF_Page_BeginText( page )
         HPDF_Page_TextOut( page,  40, nY, cType )
         HPDF_Page_TextOut( page, 150, nY, hb_zebra_getcode( hZebra ) )
         HPDF_Page_EndText( page )
         hb_zebra_draw_hpdf( hZebra, page, 300, nY, nLineWidth, nLineHeight )
      ELSE
         ? "Type", cType, "Code", cCode, "Error", hb_zebra_geterror( hZebra )
      ENDIF
      hb_zebra_destroy( hZebra )
   ELSE
      ? "Invalid barcode type", cType
   ENDIF

   RETURN

STATIC FUNCTION hb_zebra_draw_hpdf( hZebra, page, ... )

   IF hb_zebra_GetError( hZebra ) != 0
      RETURN HB_ZEBRA_ERROR_INVALIDZEBRA
   ENDIF

   hb_zebra_draw( hZebra, {| x, y, w, h | HPDF_Page_Rectangle( page, x, y, w, h ) }, ... )

   HPDF_Page_Fill( page )

   RETURN 0