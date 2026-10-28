CREATE FUNCTION cdn.JpkGenerujXmlVat(@JpkNagId int)
RETURNS XML
AS
BEGIN
	DECLARE @result XML = 
	(
		SELECT CDN.JpkNag.*
		,(SELECT *
			FROM CDN.JpkVAT
			WHERE JpkNag.Id = CDN.JpkVAT.JpNId and  CDN.JpkVAT.Typ = 2 order by LP asc
			FOR XML PATH('SprzedazWiersz'),TYPE, ELEMENTS XSINIL) 
		,(SELECT *
			FROM CDN.JpkVAT
			WHERE JpkNag.Id = CDN.JpkVAT.JpNId and  CDN.JpkVAT.Typ = 1 order by LP asc
			FOR XML PATH('ZakupWiersz'),TYPE, ELEMENTS XSINIL) 

		,(SELECT count(*) as LiczbaWierszySprzedazy,
			IsNull(sum((IsNull(K_16,0)+IsNull(K_18,0)+IsNull(K_20,0)+IsNull(K_24,0)+IsNull(K_26,0)+IsNull(K_28,0)+IsNull(K_30,0)+IsNull(K_33,0)+IsNull(K_35,0)+IsNull(K_36,0)+IsNull(K_37,0))-(IsNull(K_38,0)+IsNull(K_39,0)) ),0) as PodatekNalezny
			FROM CDN.JpkVAT
			WHERE JpkNag.Id = CDN.JpkVAT.JpNId and  CDN.JpkVAT.Typ = 2
			FOR XML PATH('SprzedazCtrl'),TYPE, ELEMENTS XSINIL) 

		,(SELECT count(*) as LiczbaWierszyZakupow,			
			IsNull(sum(IsNull(K_44,0)+IsNull(K_46,0)+IsNull(K_47,0)+IsNull(K_48,0)+IsNull(K_49,0)+IsNull(K_50,0)),0) as PodatekNaliczony
			FROM CDN.JpkVAT
			WHERE JpkNag.Id = CDN.JpkVAT.JpNId and  CDN.JpkVAT.Typ = 1 
			FOR XML PATH('ZakupCtrl'),TYPE, ELEMENTS XSINIL) 

		FROM CDN.JpkNag where JpkNag.Id = @JpkNagId
		FOR XML Path('RejestryVat')
	)
   
	RETURN @result
END
