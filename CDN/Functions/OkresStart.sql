CREATE FUNCTION CDN.OkresStart (@Rok Int, @Mies Int, @Dzien Int)
RETURNS DateTime
AS
BEGIN
Declare @DataX DateTime
Declare @DataMin DateTime
Declare @DataMax DateTime
Declare @OObId Int
Declare @X Int
Declare @Wynik NVARCHAR(30)
Set @DataX=Convert(DateTime,Convert(NVARCHAR(4),@Rok) + '-' + Convert(NVARCHAR(2),@Mies) + '-' + Convert(NVARCHAR(2),@Dzien),120)
Select @DataMin = Min(OOb_DataOtw), @DataMax= Max(OOb_DataKoncowa) From CDN.OkresyObrach
If @DataX < @DataMin or (Select fir_wartosc from cdn.firma where fir_opis='Rodzaj księgowości')<>3 Select @X = 4
Else If @DataX > @DataMax Select @X = 3
Else If Exists (Select * From CDN.OkresyObrach Where @DataX Between OOb_DataOtw And OOb_DataKoncowa) Select @X = 1
Else Select @X = 4
Set @OObId = (Select OOb_OObID From CDN.OkresyObrach Where OOb_DataOtw <= @DataX AND OOb_DataKoncowa >= @DataX)
If @X = 1 Select @Wynik = (Select Convert(DateTime, Max(OOb_DataOtw),120) From CDN.OkresyObrach Where OOb_OObID = @OObId)
If @X = 2 Select @Wynik = (Select Max(OOb_DataOtw) From CDN.OkresyObrach)
If @X = 3 Select @Wynik = (Select Max(OOb_DataKoncowa)+1 From CDN.OkresyObrach)
If @X = 4 Select @Wynik = Convert(DateTime, Convert(NVARCHAR(4), @Rok) + '-01-01', 120)
Return @Wynik
END
