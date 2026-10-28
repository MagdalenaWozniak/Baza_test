CREATE PROCEDURE CDN.AktualizujTraElemAtr
@ID INT
AS
 BEGIN
  INSERT INTO [CDN].[TraElemAtr]
       ([TrA_TrEId]
       ,[TrA_Lp]
       ,[TrA_DeAId]
       ,[TrA_Kod]
       ,[TrA_Wartosc]
       ,[TrA_ESklep])
  select A.TrE_TrEId,TrA_Lp,TrA_DeAId,TrA_Kod,TrA_Wartosc,0 from CDN.TraElem A
  join CDN.TraNagRelacje on TrR_FaId = A.TrE_TrNId
  join CDN.traelem B on TrR_TrNId = B.TrE_TrNId and A.TrE_LpPow = B.TrE_LpPow
  join CDN.TraElemAtr on B.TrE_TrEID = TrA_TrEId
  where TrR_FaId = @ID and A.Tre_UstawAtrSQL = -2
  update CDN.TraElem set  Tre_UstawAtrSQL = -1 where TrE_TrNID = @ID
 END
