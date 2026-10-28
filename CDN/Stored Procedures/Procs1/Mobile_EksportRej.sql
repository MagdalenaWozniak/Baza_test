create Procedure [CDN].[Mobile_EksportRej]
@ID    INT -- ID centrum praw struktury firmy - id mobilnego sprzedawcy
AS
BEGIN
  select BRa_Akronim as Rejestr,1 as NumerRaportu,0.0 as StanPoczatkowy from cdn.bnkrachunki
 join cdn.detalstanowiska on Bra_Braid = DSta_BraId where DSta_DStaid = @Id
END
