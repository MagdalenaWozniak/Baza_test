Create Procedure CDN.BnkRaportRenum @BRpId Int
As
Begin
Begin Transaction;
Set NoCount On
Alter Table CDN.BnkZapisy Disable Trigger All
If Exists (Select * From CDN.BnkRaporty Where BRp_BRpId = @BRpId And BRp_Zamkniety <> 0)
 Begin
 RAISERROR('##OPT33034##', 16, 1) --RaisError('Raport został zamknięty. ', 16, 1)
 If @@TranCount<>0 Rollback Transaction
 Set NoCount Off
 Return
 End
Declare Zapisy Cursor Local Fast_Forward For
 Select BZp_BZpId, BZp_BRpLp
 From CDN.BnkZapisy
 Where BZp_BRpId = @BRpId
 Order By BZp_DataDok, BZp_BZpId
Declare @Lp Int, @Licznik Int, @BZpId Int, @BZpLp Int
Set @Lp=1
Set @Licznik=0
Open Zapisy
While 1=1
 Begin
 Fetch Next From Zapisy Into @BZpId, @BZpLp
 If @@Fetch_Status<>0 Break
 If @BZpLp<>@Lp
  Begin
  Update CDN.BnkZapisy Set BZp_BRpLp=@Lp Where BZp_BZpId=@BZpId
  If @@Error<>0
  Begin
   If @@TranCount<>0 Rollback Transaction
   Set NoCount Off
   Return
  End
  DECLARE @WhereParam VARCHAR(20)
  SELECT @WhereParam = 'BZp_BZpID = ' + CONVERT(VARCHAR(10), @BZpID)
  EXEC cdn.RejestrOperacjiDodajEx @ObiektTyp = '1000', @ObiektSubTyp = 'BZp_Kierunek', @ObiektID = 'BZp_BZpID', @ObiektNazwa = 'BZp_NumerPelny',
         @OperacjaTyp = 2, @Opis = 'BZp_Opis', @From = 'cdn.BnkZapisy', @Where = @WhereParam
  Set @Licznik=@Licznik+1
 End
 Set @Lp=@Lp+1
End;
Close Zapisy
Deallocate Zapisy
Alter Table CDN.BnkZapisy Enable Trigger All
Set NoCount Off
If @@TranCount <> 0 Commit Transaction
Select @Licznik As Zmieniono
End
