CREATE PROCEDURE [CDN].[ESKLEP_EksportZgodyTresci_ver2]
  @ID INT      -- ID e-sklepu
 ,@TypExp INT  -- Typ eksportu (0 - różnicowy, 1 - pełny)
AS
BEGIN
 DECLARE
     @TSSynchr         nvarchar(254),
     @DateTSSynchr     DATETIME,
  @ESSID            INT
 select @TSSynchr =  ESS_TS_SynchroPotw, @ESSID = ESS_ESSID from cdn.eSklepStanowiska where ESS_IdISklep = @ID
 --IF not exists (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1836) SELECT @TSSynchr = 0 ELSE SELECT @TSSynchr = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1836
 SELECT  @DateTSSynchr = dateadd( second, CONVERT(INT,@TSSynchr),CONVERT(DATETIME,'1990-01-01',120))
 SELECT
 [@Kategoria]=case when A.RZT_RZKID = 1 then 2
when A.RZT_RZKID = 2 then 3
when A.RZT_RZKID = 3 then 4
when A.RZT_RZKID = 4 then 1000
when A.RZT_RZKID = 5 then 5
when A.RZT_RZKID =6 then 1
end,
 [@ID]=A.RZT_GuidGlowny,
 [@VerID]=A.RZT_GuidVer,
 [@DataOd]=A.RZT_ObowiazujeOd,
( select [@JezykID] = RZTJ_JezykID , [@Nazwa] =A.RZT_Tytul, [@Tresc] = RZTJ_Tresc from
(
select RZTJ_JezykID , RZTJ_Tresc
from cdn.RejestracjaZgodTrescJezykObcy where RZTJ_RZTId = A.RZT_RZTId
and RZTJ_JezykID > 1
union
 select 1  , case when  ISNULL(RZTJ_Tresc,'') ='' then B.RZT_Tresc else RZTJ_Tresc end
 from cdn.RejestracjaZgodTresc B
left join cdn.RejestracjaZgodTrescJezykObcy on RZTJ_RZTId = B.RZT_RZTId and RZTJ_JezykID = 1
where B.RZT_RZTId = A.RZT_RZTId
) as c
 for xml  PATH('ZGDJ') ,root ('ZGDJI'),TYPE ),
( select [@ID] = RZFK_GUID from
(select RZFK_GUID
from cdn.RejestracjaZgodTresc d1
join CDN.RejestracjaZgodFormyKontaktu on RZFK_RZFKId = 1
where d1.RZT_EMAIL = 1 and d1.RZT_RZKID = 2 and d1.RZT_RZTId = A.RZT_RZTId
union
select RZFK_GUID
from cdn.RejestracjaZgodTresc d2
join CDN.RejestracjaZgodFormyKontaktu on RZFK_RZFKId = 2
where d2.RZT_SMS = 1 and d2.RZT_RZKID = 2  and d2.RZT_RZTId = A.RZT_RZTId
union
select RZFK_GUID
from cdn.RejestracjaZgodTresc d3
join CDN.RejestracjaZgodFormyKontaktu on RZFK_RZFKId = 3
where d3.RZT_Telefon = 1 and d3.RZT_RZKID = 2  and d3.RZT_RZTId = A.RZT_RZTId
union all
select RZFK_GUID
from cdn.RejestracjaZgodTresc d4
join CDN.RejestracjaZgodFormyKontaktu on RZFK_RZFKId = 4
where d4.RZT_List = 1 and d4.RZT_RZKID = 2 and d4.RZT_RZTId = A.RZT_RZTId) as zz for xml  PATH('ZGDK') ,root ('ZGDKI'),TYPE )
from cdn.RejestracjaZgodTresc A
join CDN.RejestracjaZgodTrescESklepy on A.RZT_RZTId = RZTES_RZTID and RZTES_eSklepID = @ESSID
 WHERE A.RZT_TS_Mod > CASE WHEN @TypExp=0 THEN @DateTSSynchr ELSE 0 END
 and A.RZT_Nieaktywny = 0 and RZTES_PrzyszlaZeSklep = 0 --and RZTES_eSklepWyslana = 0
for xml  PATH('ZGD'), type
END
update B set RZTES_eSklepWyslana = 1
 from cdn.RejestracjaZgodTresc A
join CDN.RejestracjaZgodTrescESklepy B on A.RZT_RZTId = RZTES_RZTID and RZTES_eSklepID = @ESSID
 WHERE A.RZT_TS_Mod > CASE WHEN @TypExp=0 THEN @DateTSSynchr ELSE 0 END
 and A.RZT_Nieaktywny = 0 and RZTES_PrzyszlaZeSklep = 0 and RZTES_eSklepWyslana = 0
