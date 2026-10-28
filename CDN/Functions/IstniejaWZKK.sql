CREATE FUNCTION [CDN].[IstniejaWZKK](@TrNId INT)
RETURNS NVARCHAR(255)
AS
BEGIN
    DECLARE @Wynik INT,@id INT
    SET @Wynik = 0
    DECLARE @Numery NVARCHAR(255)
    SET @Numery = ''
     IF EXISTS(SELECT A.TrS_TrSId
    FROM cdn.TraSElem  A
    JOIN cdn.TraSElem B ON A.TrS_ZwrId = B.TrS_TrSId AND A.TrS_Rodzaj IN (306061,306071,306072)
    JOIN cdn.TraElem E  ON B.TrS_TrEId = E.TrE_TrEId
    JOIN cdn.TraNag N   ON N.TrN_TrNId = E.TrE_TrNId
    JOIN cdn.TraElem EWZKK  ON A.TrS_TrEId = EWZKK.TrE_TrEId
    JOIN cdn.TraNag NWZKK   ON NWZKK.TrN_TrNId = EWZKK.TrE_TrNId
    WHERE N.TrN_TrNId IN (SELECT WZKK.TrN_TrNID FROM CDN.TraNag WZKK WHERE WZKK.TrN_ZwrIDWZKK = @TrNId AND WZKK.TrN_Rodzaj IN (306061,306071,306072))
    and NWZKK.TrN_ZwrIDWZKK <> @TrNId
    )
  BEGIN
   SET @Wynik = 1
   SELECT top 1 @id =A.TrS_TrSId
    FROM cdn.TraSElem  A
    JOIN cdn.TraSElem B ON A.TrS_ZwrId = B.TrS_TrSId AND A.TrS_Rodzaj IN (306061,306071,306072)
    JOIN cdn.TraElem E  ON B.TrS_TrEId = E.TrE_TrEId
    JOIN cdn.TraNag N   ON N.TrN_TrNId = E.TrE_TrNId
    JOIN cdn.TraElem EWZKK  ON A.TrS_TrEId = EWZKK.TrE_TrEId
    JOIN cdn.TraNag NWZKK   ON NWZKK.TrN_TrNId = EWZKK.TrE_TrNId
    WHERE N.TrN_TrNId IN (SELECT WZKK.TrN_TrNID FROM CDN.TraNag WZKK WHERE WZKK.TrN_ZwrIDWZKK = @TrNId AND WZKK.TrN_Rodzaj IN (306061,306071,306072))
    and NWZKK.TrN_ZwrIDWZKK <> @TrNId
    select TOP 1 @Numery =Trn_NumerPelny from cdn.traselem join CDN.TraElem on tre_treid = trs_treid join cdn.TraNag  on trn_trnid = tre_trnID where trs_trsid in (@id)
   --SELECT TOP 1 @Numery = IsNull(WZKK.TrN_NumerPelny, '') FROM CDN.TraNag WZKK
   --WHERE WZKK.TrN_ZwrIDWZKK = @TrNId AND WZKK.TrN_Rodzaj IN (306061,306071,306072)
  END
    ELSE
      IF EXISTS(SELECT A.TrS_TrSId,NWZKK.TrN_ZwrID
    FROM cdn.TraSElem  A
    JOIN cdn.TraSElem B ON A.TrS_ZwrId = B.TrS_TrSId AND A.TrS_Rodzaj IN (306061,306071,306072)
         JOIN cdn.TraElem E  ON B.TrS_TrEId = E.TrE_TrEId
         JOIN cdn.TraElem EWZKK  ON A.TrS_TrEId = EWZKK.TrE_TrEId
         JOIN cdn.TraNag NWZKK   ON NWZKK.TrN_TrNId = EWZKK.TrE_TrNId
       JOIN cdn.TraNag N   ON N.TrN_TrNId = E.TrE_TrNId
    WHERE N.TrN_TrNId = @TrNId and NWZKK.TrN_ZwrID != @TrNId
    )
  BEGIN
   SET @Wynik = 1
   SELECT TOP 1 @Numery = IsNull(WZKK.TrN_NumerPelny, '')
   FROM cdn.TraSElem A
   JOIN cdn.TraSElem B ON A.TrS_ZwrId = B.TrS_TrSId AND A.TrS_Rodzaj IN (306061,306071,306072)
   JOIN cdn.TraElem E ON B.TrS_TrEId = E.TrE_TrEId
   JOIN cdn.TraNag  N ON N.TrN_TrNId = E.TrE_TrNId
   JOIN cdn.TraElem WZKK_E ON WZKK_E.TrE_TrEId = A.TrS_TrEId
   JOIN cdn.TraNag  WZKK ON WZKK.TrN_TrNId = WZKK_E.TrE_TrNId
   WHERE N.TrN_TrNId = @TrNId
  END
    RETURN @Numery
END
