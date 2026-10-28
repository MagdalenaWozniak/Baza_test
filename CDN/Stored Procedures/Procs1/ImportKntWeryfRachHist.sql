CREATE PROCEDURE CDN.ImportKntWeryfRachHist
@SlowId int,
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@KWRH_Data nvarchar(10),
@KWRH_Nip nvarchar(20),
@KWRH_RachunekNr nvarchar(50),
@KWRH_Status tinyint,
@KWRH_IdOdpytania nvarchar(16),
@ZrdId nvarchar(5),
@OpeId int,
@IdParam int OUTPUT,
@Warnings nvarchar(1000) OUTPUT
AS
BEGIN
 DECLARE @KWRH_RachunekNr0 nvarchar(50)
 SELECT @KWRH_RachunekNr0 = REPLACE(REPLACE(@KWRH_RachunekNr, '-', ''), ' ', '')
 IF LEN(@KWRH_RachunekNr0) > 2 AND SUBSTRING(@KWRH_RachunekNr0, 1, 2) = 'PL'
  SELECT @KWRH_RachunekNr0 = SUBSTRING(@KWRH_RachunekNr0, 3, LEN(@KWRH_RachunekNr0)-2)
 IF NOT EXISTS (SELECT * FROM CDN.KntWeryfRachHist WHERE KWRH_KntID = @SlowId AND KWRH_Data = CONVERT(datetime, @KWRH_Data, 120) AND KWRH_Nip = @KWRH_Nip AND KWRH_RachunekNr = @KWRH_RachunekNr0)
  INSERT INTO CDN.KntWeryfRachHist (
       KWRH_KntID,
    KWRH_Data,
    KWRH_Nip,
    KWRH_RachunekNr,
    KWRH_Status,
    KWRH_IdOdpytania
    )
   VALUES(
    @SlowId,
       CONVERT(datetime, @KWRH_Data, 120),
    @KWRH_Nip,
    @KWRH_RachunekNr0,
       @KWRH_Status,
    @KWRH_IdOdpytania
    )
 ELSE
  UPDATE CDN.KntWeryfRachHist SET KWRH_Status = @KWRH_Status, KWRH_IdOdpytania = @KWRH_IdOdpytania WHERE KWRH_KntID = @SlowId AND KWRH_Data = CONVERT(datetime, @KWRH_Data, 120) AND KWRH_Nip = @KWRH_Nip AND KWRH_RachunekNr = @KWRH_RachunekNr0
END
