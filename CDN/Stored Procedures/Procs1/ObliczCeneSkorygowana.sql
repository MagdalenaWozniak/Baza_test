CREATE PROCEDURE CDN.ObliczCeneSkorygowana @Tre_TreId INT
AS
BEGIN
  SET NOCOUNT ON
  DECLARE @LastId           INT
  DECLARE @WartoscNWalOrg   NUMERIC(15,2)
  DECLARE @WartoscBWalOrg   NUMERIC(15,2)
  DECLARE @IloscJMOrg       NUMERIC(15,4)
  DECLARE @CenaT            NUMERIC(17,5)
    IF EXISTS (SELECT * FROM cdn.TraNag JOIN cdn.TraElem ON TrE_TrNId = TrN_TrNId WHERE TrE_ZwrId = @Tre_TreId AND TrN_Korekta = 2 AND TrN_Rodzaj not in (306061,306071,306072) and trn_bufor != -1 )
    BEGIN
      SELECT
        @WartoscNWalOrg   = A.TrE_WartoscNettoWal  + SUM(IsNull(B.TrE_WartoscNettoWal,0)),
        @WartoscBWalOrg   = A.TrE_WartoscBruttoWal + SUM(IsNull(B.TrE_WartoscBruttoWal,0)),
        @IloscJmOrg    = A.TrE_IloscJm       + SUM(IsNull(B.TrE_IloscJm,0)),
        @LastId        = CASE WHEN MAX(IsNull(B.TrE_TrEId,0)) > A.TrE_TrEId THEN MAX(IsNull(B.TrE_TrEId,0)) ELSE A.TrE_TrEId END
      FROM CDN.TraElem A LEFT OUTER JOIN
       (CDN.TraElem B JOIN CDN.TraNag  C ON B.TrE_TrNId = C.TrN_TrNId AND C.TrN_Korekta<>5 AND C.TrN_Bufor<>1)
      ON A.TrE_TrEId = B.TrE_ZwrId AND B.TrE_Aktywny = 1
      WHERE A.TrE_TrEId = @Tre_TreId
      GROUP BY A.TrE_TrEId, A.TrE_WartoscNettoWal, A.TrE_WartoscBruttoWal, A.TrE_IloscJm
      SELECT
        @CenaT =CASE WHEN @IloscJmOrg=0 THEN 0 ELSE (CASE WHEN TrN_TypNB=1 THEN (@WartoscNWalOrg / @IloscJmOrg)*TrN_KursL / TrN_KursM ELSE (@WartoscBWalOrg / @IloscJmOrg)*TrN_KursL / TrN_KursM END) END
      FROM CDN.TraElem
      RIGHT outer JOIN CDN.TraNag on TrE_TrNId=TrN_TrNId
      WHERE TrE_TrEId = @LastId
    END
   ELSE
    SET @CenaT = -0.00001
   SET NOCOUNT OFF
   SELECT @CenaT
END
