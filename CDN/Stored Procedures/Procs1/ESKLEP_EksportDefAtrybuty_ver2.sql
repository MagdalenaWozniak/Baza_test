CREATE PROCEDURE CDN.ESKLEP_EksportDefAtrybuty_ver2
  @ID INT      -- ID e-sklepu
 ,@TypExp INT  -- Typ eksportu (0 - różnicowy, 1 - pełny)
AS
BEGIN
 DECLARE
     @TSSynchr         nvarchar(254),
  @PierwszaSynchroDefAtr int,
     @DateTSSynchr     DATETIME
 select @TSSynchr =  ESS_TS_SynchroTwrPotw, @PierwszaSynchroDefAtr = ESS_PierwszaSynchroDefAtr  from cdn.eSklepStanowiska where ESS_IdISklep = @ID
 --IF not exists (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1836) SELECT @TSSynchr = 0 ELSE SELECT @TSSynchr = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1836
 SELECT  @DateTSSynchr = dateadd( second, CONVERT(INT,@TSSynchr),CONVERT(DATETIME,'1990-01-01',120))
 if @PierwszaSynchroDefAtr = 0
 begin
 set @TypExp = 1
 update cdn.eSklepStanowiska set ESS_PierwszaSynchroDefAtr  = 1 where ESS_IdISklep = @ID
 end
  if
 (select COUNT(*)
   from cdn.DefAtrybuty as SATR
   WHERE DeA_TS_Mod >  CASE WHEN @TypExp=0 THEN @DateTSSynchr ELSE 0 END and DeA_Typ = 1 and DeA_ESklep = 1) > 0
 SELECT
[@AtrDefID] = SATR.DeA_DeAId,
[@Typ] = case when SATR.DeA_Format = 3 then 1 else 0 end,
[@Format] = case when SATR.DeA_Format = 3 then 1 else SATR.DeA_Format end,
( select [@JezykID] = DeA_JezykId , [@Nazwa] = case when dea_nazwa = '' then DeA_Kod else dea_nazwa end
from cdn.DefAtrybuty A where SATR.DeA_DeAId = A.DeA_DeAId for xml  PATH('SATRJ') ,root ('SATRJI'),TYPE ),
( select [@LpWart] = DAE_Lp,[@WartoscID]=DAE_DAEID,
( select [@JezykID] = SATR.DeA_JezykId , [@Wartosc] = B.DAE_Wartosc
from cdn.DefAtrElem B where Elem.DAE_DAEID = B.DAE_DAEID for xml  PATH('SATRWJ') ,root ('SATRWJI'),TYPE )
from cdn.DefAtrElem Elem where SATR.DeA_DeAId = DAE_DeAId and SATR.DeA_Format = 3 for xml  PATH('SATRW') ,root ('SATRWI'),TYPE )
from cdn.DefAtrybuty as SATR
 WHERE DeA_TS_Mod > CASE WHEN @TypExp=0 THEN @DateTSSynchr ELSE 0 END and DeA_Typ = 1 and DeA_ESklep = 1
FOR XML PATH('SATR') ,type
END
