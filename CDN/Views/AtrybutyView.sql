CREATE VIEW CDN.AtrybutyView (Atr_AtrID, Atr_Kod, Atr_WartoscTXT, Atr_CzyKod, Atr_PodmiotTyp, Atr_PodmiotID, Atr_TwrID)
AS
SELECT  1000000+TwA_TwAID, DeA_Kod, TwA_WartoscTxt = CASE WHEN DeA_Format = 4 THEN CASE WHEN TwA_WartoscTxt ='' THEN '' ELSE convert( NVARCHAR(10), convert(datetime, dateadd(day,CAST(TwA_WartoscTxt as integer),'18001228'), 120), 120 ) END ELSE TwA_Wartosctxt END, TwA_CzyKod, 0 , 0, TwA_TwrID FROM CDN.Twratrybuty JOIN CDN.defatrybuty ON TwA_DeAID = DeA_DeAID
  WHERE TwA_CzyKopiowac = 1  AND TwA_Zalezny = 0
UNION
 SELECT TKA_TKAID, DeA_Kod, TKA_Wartosctxt = CASE WHEN DeA_Format = 4 THEN CASE WHEN TKA_WartoscTxt ='' THEN '' ELSE convert( NVARCHAR(10), convert(datetime, dateadd(day,CAST(TKA_WartoscTxt as integer),'18001228'), 120), 120 ) END ELSE TKA_WartoscTxt END, TwA_CzyKod, TKA_PodmiotTyp, TKA_PodmiotID, TwA_TwrID  FROM CDN.twratrybuty JOIN CDN.defatrybuty ON TwA_DeAID = DeA_DeAID
  JOIN CDN.twrkntatrybuty ON TKA_TwAID = TwA_TwAID
  WHERE TwA_CzyKopiowac = 1 AND TwA_Zalezny = 1
UNION
  SELECT -KnA_KnAID, DeA_Kod, KnA_Wartosctxt = CASE WHEN DeA_Format = 4 THEN CASE WHEN KnA_WartoscTxt ='' THEN '' ELSE convert( NVARCHAR(10), convert(datetime, dateadd(day,CAST(KnA_Wartosctxt as integer),'18001228'), 120), 120 ) END ELSE KnA_Wartosctxt END, KnA_CzyKod, KnA_PodmiotTyp, KnA_PodmiotID, 0 FROM CDN.kntatrybuty JOIN CDN.defatrybuty ON KnA_DeAID = DeA_DeAID
--  WHERE KnA_CzyKopiowac = 1
