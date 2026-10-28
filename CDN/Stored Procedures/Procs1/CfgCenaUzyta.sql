CREATE PROCEDURE CDN.CfgCenaUzyta @CenaId INT,@Nieaktywna INT
AS
BEGIN
 SET NOCOUNT OFF
    if @CenaId = 0
    BEGIN
      SELECT ''
   RETURN
    END
 DECLARE @DfC_Lp INT
 --szukamy lp
 SELECT @DfC_Lp = DfC_Lp FROM CDN.DefCeny WHERE DfC_DfCId = @CenaId
 IF @Nieaktywna =1
 BEGIN
  -- iSklep24
  IF (EXISTS(SELECT * FROM CDN.eSklepStanowiska WHERE (ESS_NrCeny = @DfC_Lp OR ESS_NrCenyDomyslnej = @DfC_Lp) AND ESS_Typ = 1))
  BEGIN
   SELECT 'w e-Sklepie'
   RETURN
  END
  IF EXISTS(SELECT KES_KESID FROM CDN.KntESklepy WHERE KES_TypCenyDomyslnej = @DfC_Lp)
  BEGIN
   SELECT 'kontrahenta w e-Sklepie'
   RETURN
  END
  -- iMall24
  IF (EXISTS(SELECT * FROM CDN.eSklepStanowiska WHERE (ESS_NrCeny = @DfC_Lp OR ESS_NrCenyDomyslnej = @DfC_Lp) AND ESS_Typ = 2))
  BEGIN
   SELECT 'w wszystko.pl'
   RETURN
  END
        -- kontrahenci
  IF EXISTS(SELECT KnT_KnTId FROM CDN.Kontrahenci WHERE Knt_Ceny = @DfC_Lp AND ISNull(Knt_NadId,0) = 0)
  BEGIN
   SELECT 'kontrahenta'
   RETURN
  END
        -- towar
  IF EXISTS(SELECT TwR_TwRId FROM CDN.Towary WHERE TwR_TwCNumer = @DfC_Lp)
  BEGIN
   SELECT 'towaru'
   RETURN
  END
   IF EXISTS(SELECT Mag_MagId FROM CDN.Magazyny WHERE Mag_TwCNumer = @DfC_Lp)
  BEGIN
   SELECT 'magazynu'
   RETURN
  END
  IF EXISTS(SELECT DDfc_DfcId FROM CDN.DetalCeny WHERE DDfc_DfcId = @CenaId)
  BEGIN
   SELECT 'urządzenia mobilnego'
   RETURN
  END
  -- FA CYKLICZNE
  IF EXISTS(SELECT FCE_FCEID FROM CDN.FaCyklElem WHERE FCE_GrupaCenowa = @DfC_Lp)
  BEGIN
   SELECT 'wybraną na wzorcu faktury cyklicznej'
   RETURN
  END
 END
    -- jeśli cena aktywna to sprawdzamy czy nie ma towarów które nie posiadają tej ceny
 IF @Nieaktywna =0
 BEGIN
  IF EXISTS( SELECT Twr_TwrId FROM CDN.Towary
     LEFT JOIN CDN.TwrCeny ON Twr_TwrId = TwC_TwrId AND TwC_TwCNumer = @DfC_Lp
     WHERE Twc_TwcId IS NULL)
     EXEC [CDN].[AktualizujCennik] @DfC_Lp,0
 END
 SELECT ''
 RETURN
SET NOCOUNT ON
END
