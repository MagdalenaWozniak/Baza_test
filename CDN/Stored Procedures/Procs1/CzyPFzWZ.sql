--  CzyPFzWZ
CREATE  PROCEDURE CDN.CzyPFzWZ
@ID INT
  AS
  SET NOCOUNT ON
 if EXISTS(SELECT WZ.TrN_TrNId
FROM cdn.TraNag WZ
JOIN cdn.TraNagRelacje a on TrN_TrNId = a.TrR_TrNId
left JOIN cdn.TraNagRelacje b on WZ.TrN_TrNId = b.TrR_TrNId and  b.TrR_FaTyp = 302
WHERE  a.TrR_FaId = @ID AND WZ.TrN_Rodzaj =306010 and b.TrR_FaTyp is null) select 1
else
if EXISTS(SELECT TrN_TrNId
FROM cdn.TraNag
JOIN cdn.TraElem  on TrN_TrNId = TrE_TrNId
JOIN cdn.Towary on TrE_TwrId = Twr_TwrId
WHERE  TrN_TrNID = @ID and Twr_Typ = 0 )
select -2
else
select 0
--SELECT count(TrN_TrNId)
--FROM cdn.TraNag
--JOIN cdn.TraNagRelacje a on TrN_TrNId = a.TrR_TrNId
--left JOIN cdn.TraNagRelacje b on TrN_TrNId = b.TrR_TrNId and  b.TrR_FaTyp = 302
--WHERE  a.TrR_FaId = @ID AND TrN_Rodzaj =306010 and b.TrR_FaTyp is null
SET NOCOUNT OFF
