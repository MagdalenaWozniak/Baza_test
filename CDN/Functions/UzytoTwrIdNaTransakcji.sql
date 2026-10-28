CREATE  FUNCTION CDN.UzytoTwrIdNaTransakcji ( @TwrId INT )
 RETURNS     INT
AS
BEGIN
 IF EXISTS( SELECT TrE_TrEID FROM CDN.TraElem WHERE TrE_TwrID = @TwrId
    UNION
    SELECT TrS_TrSID FROM CDN.TraSElem WHERE TrS_TwrID = @TwrId )
    BEGIN
  RETURN 1
    END
 -- Sprawdzenie, czy towar nie jest wzięty na zlecenie
 IF EXISTS (SELECT * FROM cdn.SrsCzesci WHERE SrC_TwrId = @TwrId )
    BEGIN
  RETURN 1
    END
 IF EXISTS (SELECT * FROM cdn.SrsCzynnosci WHERE SrY_TwrId = @TwrId)
    BEGIN
  RETURN 1
    END
 -- Sprawdzenie, czy towar nie jest wzięty na urządzenie
 IF EXISTS (SELECT * FROM cdn.SrsUrzadzenia WHERE SrU_TwrId = @TwrId )
    BEGIN
  RETURN 1
    END
 RETURN 0
END
