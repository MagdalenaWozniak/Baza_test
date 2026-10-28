CREATE  PROCEDURE cdn.CrmFaCyklDaneDlaKnt
@FcEId INT,
@FcKId INT
AS
 SELECT TOP 1
   Ilosc=IsNull(FcT_Ilosc, 0)
  ,JM=IsNull(FcT_JM, N'')
  ,Cena=CASE FcT_TypNB WHEN 1 THEN IsNull(FcT_Cena, 0.00) WHEN 2 THEN IsNull(FcT_CenaBrutto, 0.00) END
 FROM cdn.FaCyklTwrKnt WHERE FcT_FcEID=@FcEId AND FCT_FcKId=@FcKId
