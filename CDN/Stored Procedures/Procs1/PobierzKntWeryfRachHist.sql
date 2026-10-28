CREATE PROCEDURE cdn.PobierzKntWeryfRachHist(@KntID INT)
AS
BEGIN
 SELECT KWRH_Data, KWRH_Nip, KWRH_RachunekNr, KWRH_Status, KWRH_IdOdpytania FROM CDN.KntWeryfRachHist WHERE KWRH_KntID = @KntID ORDER BY KWRH_Data, KWRH_Nip, KWRH_RachunekNr
END
