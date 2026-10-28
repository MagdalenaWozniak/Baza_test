CREATE PROCEDURE CDN.ListaPracownikow @Data DATETIME, @Guid NVARCHAR(50), @OperId INT
as
begin
select
PRI_Nadrzedny,
PRI_Kod,
PRI_ParentId,
A.DKM_Nazwa As Stanowisko,
B.DKM_Nazwa As Funkcja,
* from [CDN].[PracEtaty]
join CDN.RptZaznaczenia2 on PRE_PraId = RpZ2_GIDNumer
join CDN.PracIdx on PRI_PraId = PRE_PraId
left join CDN.DaneKadMod A on A.DKM_DkmId = PRE_ETADkmIdStanowisko
left join CDN.DaneKadMod B on B.DKM_DkmId = PRE_ETADkmIdFunkcja
left join CDN.DzialZakazy on PRE_DzlId = DZA_DzlId and DZA_OpeId = @OperId
WHERE RpZ2_GUID = @Guid and PRI_Typ = 1 and @Data between PRE_DataOd and PRE_DataDo and (DZA_DzaId is null or DZA_PracView = 0)
end
