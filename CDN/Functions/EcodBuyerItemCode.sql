CREATE  FUNCTION CDN.EcodBuyerItemCode(@twrId INT, @podmiotTyp INT, @podmiotId INT)
RETURNS NVARCHAR(35)
BEGIN
 RETURN Substring(IsNull((Select TOP 1 IsNull(TkA_WartoscTxt, '')
   From CDN.TwrKntAtrybuty
   Join CDN.TwrAtrybuty ON TkA_TwAId=TwA_TwAId
   Join CDN.DefAtrybuty ON TwA_DeAId=DeA_DeAId
   Where DeA_Kod = 'BUYERITEMCODE' And TwA_TwrId = @twrId
   And TkA_PodmiotTyp = @podmiotTyp
   And TkA_PodmiotId = @podmiotId), ''),1,35)
END
