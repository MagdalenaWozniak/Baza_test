CREATE  PROCEDURE [CDN].[ESKLEP_EksportCechy_ver2]
  @ID INT      -- ID e-sklepu
 ,@TypExp INT  -- Typ eksportu (0 - różnicowy, 1 - pełny)
AS
BEGIN
 DECLARE
     @TSSynchr         nvarchar(254),
     @DateTSSynchr     DATETIME,
     @CechyPartii      INT
      select @TSSynchr =  ESS_TS_SynchroTwrPotw,@CechyPartii =  ESS_WyslijCechyPartii from cdn.eSklepStanowiska where ESS_IdISklep = @ID
 --IF not exists (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1836) SELECT @TSSynchr = 0 ELSE SELECT @TSSynchr = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1836
 SELECT  @DateTSSynchr = dateadd( second, CONVERT(INT,@TSSynchr),CONVERT(DATETIME,'1990-01-01',120))
 if  @CechyPartii = 1
 select distinct TwA_DeAId AS '@ID', 1 AS '@JezykID',case when dea_nazwa = '' then DeA_Kod else dea_nazwa end AS '@Nazwa'
from cdn.twratrybuty
join cdn.DefAtrybuty on TwA_DeAId = DeA_DeAId
where TwA_CzyPrzenosicNaDostawy = 1 and DeA_Format = 3 and Twa_ESklep = 1
FOR XML PATH('CEC'), Type
END
