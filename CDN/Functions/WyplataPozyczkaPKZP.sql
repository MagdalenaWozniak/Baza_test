CREATE  Function CDN.WyplataPozyczkaPKZP (@WpEId int, @typ_wyplaty NVARCHAR(255), @nazwa_pozyczki NVARCHAR(255))
Returns int
As
Begin
 Declare @nResult int
 Set @nResult = 1
 if exists( select * from
       CDN.WypElementy A
       left outer join CDN.WypSkladniki ON (A.WPE_WPEId = WPS_WPEID)
       left outer join CDN.WypElementy B ON (B.WPE_WPEId = WPS_Zaliczka)
       left outer join CDN.TypWyplata C ON (A.WPE_TwpId = C.TWP_TwpId)
       left outer join CDN.TypWyplata D ON (B.WPE_TwpId = D.TWP_TwpId)
       where A.WPE_WPEId = @WpEId and C.TWP_Skrot = @typ_wyplaty and  D.TWP_Skrot = @nazwa_pozyczki )
  Set @nResult = 1
 else
  Set @nResult = 0
 Return @nResult
End
