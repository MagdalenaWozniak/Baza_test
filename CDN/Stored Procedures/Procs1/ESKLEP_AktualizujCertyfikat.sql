CREATE  PROCEDURE [CDN].[ESKLEP_AktualizujCertyfikat]
  @ESklepID   INT    -- ID e-sklepu
 ,@Certyfikat nvarchar(50)    -- Odcisk palca certyfikatu
AS
 SET NOCOUNT ON
   UPDATE CDN.FIRMA SET Fir_Wartosc = @Certyfikat WHERE Fir_NUMER = 1843
 SET NOCOUNT OFF
