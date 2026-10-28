CREATE PROCEDURE CDN.CenaPoRabacie
 @PodmiotTyp          INT
,@PodmiotId           INT
,@Twr_Id              INT
,@Twr_NumerCeny       INT
,@Twr_Stawka          DECIMAL(5,2)
AS
BEGIN
  SET NOCOUNT ON
  DECLARE @CenaPoRabacie           DECIMAL(17,4),
   @WartoscRabatu           DECIMAL(17,4),
   @Komunikat               NVARCHAR(200)
 EXEC CDN.ObliczCenePoRabacie
  @PodmiotTyp = @PodmiotTyp
  ,@PodmiotId = @PodmiotId
  ,@Twr_Id = @Twr_Id
  ,@Twr_NumerCeny = @Twr_NumerCeny
  ,@Twr_Stawka = @Twr_Stawka
  ,@cenaPoRabacie = @CenaPoRabacie OUTPUT
  ,@wartoscRabatu = @WartoscRabatu OUTPUT
  ,@komunikat  = @komunikat OUTPUT
  SELECT IsNull(@CenaPoRabacie,0) As CenaPoRabacie, IsNull(@WartoscRabatu,0) As Rabat, IsNull(@Komunikat,'') As Komunikat
  SET NOCOUNT OFF
  RETURN
END
