Create Function CDN.fn_CenyDlaCDNXL ()
Returns Table
As
Return
Select
Naz_GIDTyp = Cast (64 As SmallInt),
Naz_GIDFirma = Cast (0 As Int),
Naz_GIDNumer = Cast (0 As Int),
Naz_GIDLp = DfC_XL_Lp,
Naz_Nazwa = Cast (Cast (DfC_Nazwa As Char(10)) + Case DfC_Typ When 1 Then 'N1' When 2 Then 'B1' End As NVARCHAR(20)),
Naz_Nazwa1 = Cast('' As NVARCHAR(20)),
Naz_Opis = Cast('' As NVARCHAR(60))
From CDN.DefCeny Where DfC_XL_Lp Is Not Null
