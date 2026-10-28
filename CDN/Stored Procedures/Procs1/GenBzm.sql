-- Generowanie BZM dla wydruku Crystal - BZM Wzor standard
CREATE PROCEDURE [CDN].[GenBzm]
@DataOpe DATETIME
AS
BEGIN
 SET NOCOUNT ON;
 SELECT  TwI_Data, TwI_Ilosc, TwI_Wartosc, Twr_Kod, Twr_Nazwa, TwI_MagId, Mag_Symbol, Mag_Nazwa, Twr_JM, Kod
 FROM CDN.Towary T
   LEFT OUTER JOIN cdn.TwrIlosci I ON T.Twr_TwrId = I.TwI_TwrId
     AND I.TwI_Data = (SELECT TOP 1 H.TwI_Data FROM CDN.TwrIlosci H
     WHERE H.TwI_TwrId = T.Twr_TwrId AND H.TwI_MagId = I.TwI_MagId AND H.TwI_Data <= @DataOpe ORDER BY H.TwI_Data DESC)
      JOIN CDN.Magazyny M on I.TwI_MagID = M.Mag_MagID
      JOIN CDN.TwrGrupyView G on T.Twr_TwGGIDNumer = G.GiDNumer
 SET NOCOUNT OFF;
END
