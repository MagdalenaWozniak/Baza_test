CREATE VIEW cdn.KnfOdsetkiKBView
(KOKBV_Typ, KOKBV_OkresOd, KOKBV_OkresDo, KOKBV_Stopa)
AS
SELECT
CASE WHEN CfK_Nazwa = 'Odsetki ustawowe od zaległości' THEN 1 WHEN CfK_Nazwa = 'Odsetki od zaległości w trans.' THEN 4 ELSE 3 END,
CFK_OkresOd, CFK_OkresDo, CAST(REPLACE(CFW_Wartosc, ',', '.') AS DECIMAL(7,2))
FROM [SRV1].[CDN_KNF_ONE].cdn.CfgKlucze JOIN [SRV1].[CDN_KNF_ONE].cdn.CfgWartosci ON CFW_CfkId = CFK_CfkId
WHERE CfK_Nazwa = 'Odsetki ustawowe od zaległości' OR CfK_Nazwa = 'Odsetki podatkowe' OR CfK_Nazwa = 'Odsetki od zaległości w trans.'