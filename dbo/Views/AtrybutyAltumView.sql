create View AtrybutyAltumView
(Pra_ImportRowId,ATK_ImportRowId, ATH_AthId , ATH_DataOd, ATH_DataDo , ATH_Wartosc, ATH_ImportRowId)
as
SELECT      cdn.PracKod.Pra_ImportRowId , CDN.OAtrybutyKlasy.ATK_ImportRowId, CDN.OAtrybutyHist.ATH_ATHId, CDN.OAtrybutyHist.ATH_DataOd, CDN.OAtrybutyHist.ATH_DataDo, CDN.OAtrybutyHist.ATH_Wartosc, CDN.OAtrybutyHist.ATH_ImportRowId
FROM            CDN.OAtrybuty join CDN.OAtrybutyHist on ATH_OatId = Oat_Oatid INNER JOIN   CDN.OAtrybutyKlasy ON CDN.OAtrybutyHist.ATH_AtkId = CDN.OAtrybutyKlasy.ATK_AtkId join cdn.PracKod on PRA_PraID = Oat_PrcId
