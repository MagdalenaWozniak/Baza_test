CREATE Function [CDN].[UslugiVAT] (@VaNId Int, @VaNTrNId Int, @Opis SmallInt) Returns
@Table Table (VaNId Int, DataWyst DateTime, Dokument NVARCHAR(30), Opis NVARCHAR(1024), KwotaNetto Decimal(15,2), TrNId Int)
As
Begin
If @VaNTrNId <> 0 And @Opis = 1 and (select trn_zwrid from cdn.TraNag where TrN_TrNID=@VaNTrNId)is null
   Insert Into @Table (VaNId, DataWyst, Dokument, Opis, KwotaNetto, TrNId)
   Select @VaNId, VaN_DataWys, VaN_Dokument, TrE_TwrNazwa, Case When TrN_Rodzaj In (302003, 302103) Then TrE_CenaT * TrE_IloscJMKW Else TrE_WartoscNetto End, @VaNTrNId
   From CDN.TraElem Left Outer Join CDN.TraNag On TrE_TrNId = TrN_TrNId Left Outer Join CDN.VatNag On VaN_VaNId = @VaNId Left Outer Join CDN.Towary On Twr_TwrId = TrE_TwrId
   Where TrN_TrNId = @VaNTrNId And Twr_Typ = 0 And
             ((VaN_Export = 3 And TrE_Flaga = 4 And TrE_Stawka = 0 And VaN_Wewnetrzna = 0) Or
              (VaN_Export = 4 And TrE_Flaga = 4 And TrE_Stawka = 0 And VaN_Wewnetrzna = 0) Or
              (VaN_Export = 6) Or
              (VaN_Export = 7 And TrE_Flaga = 4 And TrE_Stawka = 0) Or
     (VaN_Export = 8 And TrE_Flaga = 4 And TrE_Stawka = 0 And VaN_Wewnetrzna = 0) Or
     (VaN_Export = 9 And TrE_Flaga = 4 And TrE_Stawka = 0 And VaN_Wewnetrzna = 0) )
Else
   Insert Into @Table (VaNId, DataWyst, Dokument, Opis, KwotaNetto, TrNId)
   Select VaN_VaNId, VaN_DataWys, VaN_Dokument, VaT_KatOpis, VaT_NettoDoVAT, VaN_TrNId
   From CDN.VatNag Left Outer Join CDN.VatTab On VaT_VaNId = VaN_VaNId
   Where VaN_VaNId = @VaNId And VaT_RodzajZakupu = 4 And
             ((VaN_Export = 3 And VaT_Flaga = 4 And VaT_Stawka = 0 And VaN_Wewnetrzna = 0) Or
              (VaN_Export = 4 And VaT_Flaga = 4 And VaT_Stawka = 0 And VaN_Wewnetrzna = 0) Or
              (VaN_Export = 6) Or
              (VaN_Export = 7 And VaT_Flaga = 4 And VaT_Stawka = 0) Or
     (VaN_Export = 8 And VaT_Flaga = 4 And VaT_Stawka = 0 And VaN_Wewnetrzna = 0) Or
     (VaN_Export = 9 And VaT_Flaga = 4 And VaT_Stawka = 0 And VaN_Wewnetrzna = 0) )
Return
End
