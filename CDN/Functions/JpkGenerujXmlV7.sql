CREATE FUNCTION cdn.JpkGenerujXmlV7(@JpkNagId int)
RETURNS XML
AS
BEGIN
	DECLARE @result XML = 
	(
		SELECT Year(CDN.JpkNag.DataOd) as Rok, Month(CDN.JpkNag.DataOd) Miesiac, CDN.JpkNag.*
		,(SELECT *
			FROM CDN.JpkV7
			WHERE JpkNag.Id = CDN.JpkV7.JpNId and  CDN.JpkV7.Typ = 2 order by LP asc
			FOR XML PATH('SprzedazWiersz'),TYPE, ELEMENTS XSINIL) 
		,(SELECT *
			FROM CDN.JpkV7
			WHERE JpkNag.Id = CDN.JpkV7.JpNId and  CDN.JpkV7.Typ = 1 order by LP asc
			FOR XML PATH('ZakupWiersz'),TYPE, ELEMENTS XSINIL) 

		,(	SELECT count(*) as LiczbaWierszySprzedazy,
			IsNull(
			sum(case when IsNull(TypDokumentu,'') <> 'FP' then (IsNull(K_16,0)+IsNull(K_18,0)+IsNull(K_20,0)+IsNull(K_24,0)+IsNull(K_26,0)+IsNull(K_28,0)+IsNull(K_30,0)+IsNull(K_32,0)+IsNull(K_33,0)+IsNull(K_34,0))-(IsNull(K_35,0)+IsNull(K_36,0)) else 0 end)
			,0) as PodatekNalezny
			FROM CDN.JpkV7
			WHERE JpkNag.Id = CDN.JpkV7.JpNId and CDN.JpkV7.Typ = 2 
			FOR XML PATH('SprzedazCtrl'),TYPE, ELEMENTS XSINIL) 

		,(SELECT count(*) as LiczbaWierszyZakupow,			
			IsNull(sum(IsNull(K_41,0)+IsNull(K_43,0)+IsNull(K_44,0)+IsNull(K_45,0)+IsNull(K_46,0)+IsNull(K_47,0)),0) as PodatekNaliczony
			FROM CDN.JpkV7
			WHERE JpkNag.Id = CDN.JpkV7.JpNId and  CDN.JpkV7.Typ = 1 
			FOR XML PATH('ZakupCtrl'),TYPE, ELEMENTS XSINIL) 

		,(SELECT *
			FROM CDN.JpkV7
			WHERE JpkNag.Id = CDN.JpkV7.JpNId and  CDN.JpkV7.Typ = 3 order by LP asc
			FOR XML PATH('Deklaracja'),TYPE, ELEMENTS XSINIL) 

		FROM CDN.JpkNag where JpkNag.Id = @JpkNagId
		FOR XML Path('RejestryVat')
	)
   
	RETURN @result
END
