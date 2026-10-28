CREATE PROCEDURE [CDN].[AnulowanieWZKK]
@TrnID  AS INT
AS
BEGIN
DECLARE @Komunikat      NVARCHAR(250)
if exists(select TrN_Bufor from cdn.tranag where TrN_Bufor= -1 and TrN_TrNID = @TrnID)
   begin
 -- wykasowanie subelementów kasowanego dokumentu i skojarzonej WZKK
  DELETE cdn.TraSElem
  FROM cdn.TraSElem  S
       JOIN cdn.TraElem E on  S.TrS_TrEId = E.TrE_TrEId
       JOIN cdn.TraNag N  on  N.TrN_TrNId = E.TrE_TrNId
  WHERE N.TrN_TrNId IN
                                    (SELECT WZKK.TrN_TrNID FROM CDN.TraNag WZKK
                                          WHERE WZKK.TrN_ZwrID = @TrnID AND WZKK.TrN_Rodzaj
                                            IN (306061,306071,306072))
   -- anulowanie WZKK
  IF EXISTS ( SELECT * FROM CDN.TraNag join
  (select TrN_TrNID as TrNID, TrN_ZwrID as ZwrID from CDN.TraNag WHERE  TrN_ZwrIDWZKK = @TrnID AND TrN_Rodzaj IN (306061,306071,306072)) as A on TrN_ZwrId = A.ZwRID
  where TrN_TrNID >TrNID and TrN_Bufor <> -1 AND TrN_Rodzaj NOT IN (306061,306071,306072))
  begin
  SET @Komunikat = '##OPT34441##'
  GOTO KOMUNIKAT
  end
  UPDATE CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_FaID=null, TrN_RelTrNId=null, TrN_ZwrID = NULL, TrN_ZwrIdWZKK = NULL WHERE  TrN_ZwrID = @TrnID AND TrN_Rodzaj IN (306061,306071,306072);
  -- kasuję powiązania WZKK
  DELETE CDN.TraNagRelacje WHERE TrR_TrNID IN
  (SELECT TrN_TrNID FROM CDN.TraNag WHERE  TrN_ZwrID = @TrnID AND TrN_Rodzaj IN (306061,306071,306072))
  DELETE CDN.TraNagRelacje WHERE TrR_FaID IN
  (SELECT TrN_TrNID FROM CDN.TraNag WHERE  TrN_ZwrID = @TrnID AND TrN_Rodzaj IN (306061,306071,306072))
  end
  KOMUNIKAT:
  IF @Komunikat <> ''
    BEGIN
      RAISERROR( @Komunikat, 16, 1)
      RETURN
    END
END
