CREATE PROCEDURE CDN.KasujRozliczeniaWZ
 @DokId Int
As
Begin
Set NoCount On
Declare @KasujAutomatyczne TinyInt,
 @WhereParam VARCHAR(1024)
Set @KasujAutomatyczne = 1
If Not Exists (Select * From CDN.Firma Where Fir_Numer = 1394 And Fir_Wartosc = '1')
 Set @KasujAutomatyczne = 0
Select TrN_BZpID
InTo #BZpAuto
From CDN.TraNAG where TrN_TrNID = @DokId  and TrN_TypDokumentu = 306 and ISNULL(TrN_BZpID,0)>0
if (select count(*)from #BZpAuto) > 0 and @KasujAutomatyczne = 0
 BEGIN
          RAISERROR('##OPT32348##', 16, 1)
          ROLLBACK TRAN
          RETURN
        END
Declare zapisy Cursor Local Fast_Forward For Select TrN_BZpID From #BZpAuto
Declare @BzpAutoId Int
Open zapisy
While 1=1
 Begin
  Fetch Next From zapisy InTo @BZpAutoId
  If @@Fetch_Status <> 0 Break
   /*
  SELECT @WhereParam =
 'BRK_BRKId In (
 Select BRR_BRKId From CDN.BnkRozRelacje Join CDN.BnkZapisy On BRR_ZDokTyp = 2 And BRR_DDokTyp = 2 And BRR_ZDokID = BZp_BZpID
 Where  BZp_BZpID ='+CONVERT(VARCHAR(15),@BZpAutoId)+
 ')
 And ('+ CONVERT(VARCHAR(1),@KasujAutomatyczne) +' = ''1'' Or BRK_AutoOffLine=1)'
   EXEC cdn.RejestrOperacjiDodajEx @ObiektTyp = '1125',
         @ObiektSubTyp = '0',
         @ObiektID = 'BRK_BRKId',
         @ObiektNazwa = 'BRK_NumerPelny',
         @OperacjaTyp = 3,
         @Opis = '''''',
         @From = 'cdn.BnkRozKwoty',
         @Where = @WhereParam
*/
   Delete From CDN.BnkRozKwoty
 Where BRK_BRKId In (
 Select BRR_BRKId From CDN.BnkRozRelacje Join CDN.BnkZapisy On BRR_ZDokTyp = 2 And BRR_DDokTyp = 2 And BRR_ZDokID = BZp_BZpID
 Where  BZp_BZpID = @BZpAutoId
 )
 And (@KasujAutomatyczne = 1 Or BRK_AutoOffLine=1)
   if exists (Select BRR_BRKId From CDN.BnkRozRelacje Join CDN.BnkZapisy On BRR_ZDokTyp = 2 And BRR_DDokTyp = 1 And BRR_ZDokID = BZp_BZpID
  Where  BZp_BZpID = @BZpAutoId)
  BEGIN
          RAISERROR('##OPT34440##', 16, 1)
          ROLLBACK TRAN
          RETURN
     END
  SELECT @WhereParam = 'BZp_BZpId = ' + CONVERT(VARCHAR(15), @BZpAutoId)
   EXEC cdn.RejestrOperacjiDodajEx @ObiektTyp = '1000',
         @ObiektSubTyp = 'BZp_Kierunek',
         @ObiektID = 'BZp_BZpID',
         @ObiektNazwa = 'BZp_NumerPelny',
         @OperacjaTyp = 3,
         @Opis = '''''',
         @From = 'cdn.BnkZapisy',
         @Where = @WhereParam
  Delete From CDN.BnkZapisy Where BZp_BZpId = @BZpAutoId
 End
Close zapisy
Deallocate zapisy
Drop Table #BZpAuto
Set NoCount Off
End
