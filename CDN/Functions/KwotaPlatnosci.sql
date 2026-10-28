Create Function CDN.KwotaPlatnosci (@DokTyp Int, @DokId Int, @Tryb NVARCHAR(20))
Returns Numeric (15,2)
As
Begin
 Declare @Wynik Numeric(15,2)
 declare @kkw_TrNId int = NULL;
 if @DokTyp = 1 and @Tryb <> 'Kierunek'
 begin
  if exists (select * from cdn.tranag where TrN_ZwrId = @DokId and TrN_Anulowany = 0 and TrN_Korekta=8)
   select top 1 @kkw_TrNId = trn_trnid from cdn.tranag where TrN_ZwrId = @DokId and TrN_Anulowany = 0 and TrN_Korekta=8;
  else
   set @kkw_TrNId = NULL;
 end
 Select @Wynik = CDN.KwotaPlatnosciPojedynczyDokument (@DokTyp, @DokId, @Tryb)
 --Doliczenie wartość z korekty kursów walut dla dokumentów handlowych.
 -- Z uwagi na relacje Trn_VaNId, dokumenty w rejestrze vat powstałe z księgowania dokumentów ha/mag powinny działać poprawnie,
 -- a to dlatego, że Trn_VaNId dla dokumentu korygowanego i korekty jest taki sam;
 if @kkw_TrNId is Not NULL
 begin
  declare @podWynik Numeric(15,2) = 0.00;
  Select @podWynik = CDN.KwotaPlatnosciPojedynczyDokument(@DokTyp, @kkw_TrNId, @Tryb);
  Set @Wynik = IsNull(@Wynik,0.00) + IsNull(@podWynik, 0.00)
 end
 if @Tryb = 'Zaliczka'
 or @Tryb = 'ZaliczkaWal'
 or @Tryb = 'Razem'
 or @Tryb = 'RazemWal'
 or @Tryb = 'Pozostaje'
 or @Tryb = 'PozostajeWal'
 or @Tryb = 'Rozliczona'
 or @Tryb = 'RozliczonaWal'
 or @Tryb = 'RozliczonaAuto'
 or @Tryb = 'RozliczonaAutoWal'
  begin
    Set @Wynik = Abs(IsNull(@Wynik,0))
  end
 Return IsNull(@Wynik,0)
End
