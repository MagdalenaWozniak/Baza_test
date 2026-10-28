CREATE VIEW cdn.KatalogZakazyView
(
	[KtZ_KtZId]
	,[KtZ_Typ]
	,[KtZ_KtlId]
	,[KtZ_OpeId]
	,[KtZ_Dodawanie]
	,[KtZ_Podglad]
	,[KtZ_ZmianaWlas]
	,[KtZ_ZmianaInne]
	,[KtZ_KasowanieWlas]
	,[KtZ_KasowanieInne]
)
AS
SELECT
	[KtZ_KtZId]
	,1
	,[KtZ_KtlId]
	,[KtZ_OpeId]
	,[KtZ_Dodawanie]
	,[KtZ_Podglad]
	,[KtZ_ZmianaWlas]
	,[KtZ_ZmianaInne]
	,[KtZ_KasowanieWlas]
	,[KtZ_KasowanieInne]
FROM cdn.KatalogZakazy
UNION ALL
SELECT
	[KtZ_KtZId]
	,2
	,[KtZ_KtlId]
	,[KtZ_OpeId]
	,[KtZ_Dodawanie]
	,[KtZ_Podglad]
	,[KtZ_ZmianaWlas]
	,[KtZ_ZmianaInne]
	,[KtZ_KasowanieWlas]
	,[KtZ_KasowanieInne]
FROM [SRV1].[CDN_KNF_ONE].cdn.KatalogZakazy