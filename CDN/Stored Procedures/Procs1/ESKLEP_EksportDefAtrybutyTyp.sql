CREATE PROCEDURE CDN.ESKLEP_EksportDefAtrybutyTyp
  @ID INT      -- ID e-sklepu
 ,@TypExp INT  -- Typ eksportu (0 - różnicowy, 1 - pełny)
AS
BEGIN
 DECLARE
     @TSSynchr         nvarchar(254),
     @DateTSSynchr     DATETIME
 select @TSSynchr =  ESS_TS_SynchroTwrPotw from cdn.eSklepStanowiska where ESS_IdISklep = @ID
 --IF not exists (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1836) SELECT @TSSynchr = 0 ELSE SELECT @TSSynchr = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1836
 SELECT  @DateTSSynchr = dateadd( second, CONVERT(INT,@TSSynchr),CONVERT(DATETIME,'1990-01-01',120))
 if
 (select COUNT(*)
   from cdn.DefAtrybuty as SATR
   WHERE DeA_TS_Mod >  CASE WHEN @TypExp=0 THEN @DateTSSynchr ELSE 0 END and DeA_Typ = 1 and DeA_ESklep = 1) > 0
 SELECT
[@Typ] = 3,
[@AtrDefID] = DeA_DeAId,
[@Obowiazkowy] = 0,
[@Lp] = 1
from cdn.DefAtrybuty
 WHERE DeA_TS_Mod > CASE WHEN @TypExp=0 THEN @DateTSSynchr ELSE 0 END and DeA_Typ = 1 and DeA_ESklep = 1
FOR XML PATH('OATR') ,root ('OATRI')
END
