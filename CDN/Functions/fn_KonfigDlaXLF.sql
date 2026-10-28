Create Function CDN.fn_KonfigDlaXLF ()
Returns @Tbl Table (
Kon_Numer Int,
Kon_Lp Int,
Kon_System Int,
Kon_Status Int,
Kon_Wartosc NVARCHAR(100),
Kon_Komentarz NVARCHAR(50)
)
As
Begin
Insert InTo @Tbl
Select 11, 0, 0, 0, '2', 'Domyślny numer kursu'
Insert InTo @Tbl
Select 12, 0, 0, 0, '1', 'Typ wyliczania marży'
Insert InTo @Tbl
Select 9913, 0, 0, 0, '', 'Stawka Vat dla eksportu'
Insert InTo @Tbl
Select 736, FPl_XLID, 0, 0, Cast (FPl_Nazwa As Char(20)) + Cast(LTrim(Str(FPl_Rabat,10,2)) As Char(10)) + Cast(LTrim(Str(FPl_Termin)) As Char(3)) + Cast (BRa_Akronim As Char(5)), 'Forma płatności'
From CDN.FormyPlatnosci Left Outer Join CDN.BnkRachunki On FPl_BRaId = BRa_BRaId Where IsNull(FPl_XLID, 0) <> 0
Insert InTo @Tbl
Select Fir_Numer + 8355, 0, 0, 0, Cast(Fir_Wartosc As NVARCHAR(100)), ''
From CDN.Firma Where Fir_Numer In (1559, 1560, 1561)
Insert InTo @Tbl
Select 9980, 0, 0, 0, Cast(Fir_Wartosc As NVARCHAR(100)), 'Czy rejestrować strukturę udzielonego rabatu'
From CDN.Firma Where Fir_Numer In (1690)
Return
End
