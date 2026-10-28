CREATE PROCEDURE [CDN].[ESKLEP_EksportZgodyKanaly_ver2]
  @ID INT      -- ID e-sklepu
 ,@TypExp INT  -- Typ eksportu (0 - różnicowy, 1 - pełny)
AS
BEGIN
 DECLARE
     @TSSynchr         nvarchar(254),
     @DateTSSynchr     DATETIME
 select @TSSynchr =  ESS_TS_SynchroPotw from cdn.eSklepStanowiska where ESS_IdISklep = @ID
 --IF not exists (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1836) SELECT @TSSynchr = 0 ELSE SELECT @TSSynchr = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1836
 SELECT  @DateTSSynchr = dateadd( second, CONVERT(INT,@TSSynchr),CONVERT(DATETIME,'1990-01-01',120))
 SELECT
 [@Typ]=A.RZFK_RZFKId,
 [@ID]=A.RZFK_GUID,
(
select  [@JezykID] = RZFKJ_JezykID , [@Nazwa] = RZFKJ_Nazwa from (
select RZFKJ_JezykID , RZFKJ_Nazwa
from cdn.RejestracjaZgodFormyKontaktuJezykObcy where RZFKJ_RZFKId = A.RZFK_RZFKId
and RZFKJ_JezykID > 1
union
 select 1  , case when  ISNULL(RZFKJ_Nazwa,'') ='' then B.RZFK_Nazwa else RZFKJ_Nazwa end
 from cdn.RejestracjaZgodFormyKontaktu B
left join cdn.RejestracjaZgodFormyKontaktuJezykObcy on RZFKJ_RZFKId = B.RZFK_RZFKId and RZFKJ_JezykID = 1
where B.RZFK_RZFKId = A.RZFK_RZFKId
) as c
 for xml  PATH('ZGKJ') ,root ('ZGKJI'),TYPE )
from cdn.RejestracjaZgodFormyKontaktu A
 WHERE A.RZFK_TS_Mod > CASE WHEN @TypExp=0 THEN @DateTSSynchr ELSE 0 END
for xml  PATH('ZGK'), type
END
