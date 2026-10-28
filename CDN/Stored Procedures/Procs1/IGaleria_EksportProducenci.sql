CREATE PROCEDURE [CDN].[IGaleria_EksportProducenci]
 @TypExp INT  -- Typ eksportu (0 - różnicowy, 1 - pełny)
AS
BEGIN
 DECLARE
     @TSSynchr         nvarchar(254),
     @DateTSSynchr     DATETIME
 select  top 1 @TSSynchr = ESS_TS_SynchroTwrPotw
   from cdn.eSklepStanowiska where ESS_typ = 2
 --IF not exists (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1836) SELECT @TSSynchr = 0 ELSE SELECT @TSSynchr = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1836
 SELECT  @DateTSSynchr = dateadd( second, CONVERT(INT,@TSSynchr),CONVERT(DATETIME,'1990-01-01',120))
 SELECT DISTINCT
Prd_PrdId as PdrID,
Prd_Kod as ProducentKod,
Prd_Nazwa as ProducentNazwa,
Prd_URL as ProducentURL--,
--Prd_Logo as ProducentLogo
from cdn.producenci as PDR
 WHERE Prd_TS_Mod > CASE WHEN @TypExp=0 THEN @DateTSSynchr ELSE 0 END
FOR XML AUTO
END
