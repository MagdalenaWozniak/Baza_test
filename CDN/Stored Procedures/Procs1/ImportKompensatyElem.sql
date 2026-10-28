CREATE PROCEDURE CDN.ImportKompensatyElem
@KPNID int,
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@BRK_ImportRowID nvarchar(36),
@BRK_NumerPelny nvarchar(50),
@BRK_LNumer nvarchar(256),
@BRK_PNumer nvarchar(256),
@BRK_DataDok nvarchar(10),
@BRK_Kwota DECIMAL(15,2),
@ZrdID nvarchar(5),
@OpeID int,
@IdParam int OUTPUT,
@Warnings nvarchar(1000) OUTPUT
AS
BEGIN
 DECLARE @BRKID INT
 DECLARE @Error nvarchar(256)
 SET @Warnings = ''
 SET @BRKID = NULL
 IF(@BRK_ImportRowID is not NULL)
 BEGIN
  SELECT @BRKID = BRK_BRKID
  FROM CDN.BnkRozKwoty
  WHERE BRK_ImportRowID = @BRK_ImportRowID /*AND
     BRK_LNumer = @BRK_LNumer AND BRK_PNumer = @BRK_PNumer AND BRK_DataDok = CONVERT(datetime, @BRK_DataDok, 120) AND BRK_Kwota = @BRK_Kwota*/
 END
 IF @BRKID is NULL
 BEGIN
  -- SET @Warnings = 'Brak definicji dokumentu o zadanym symbolu i zgodnym schemacie numeracji ' + IsNull(@DDf_Symbol, '') + ' w bazie docelowej.\'
  RAISERROR('##OPT33085##', 16, 1) --RAISERROR('W bazie docelowej brak rozliczenia, do którego odwołuje się importowany element dokumentu kompensaty.', 16, 1)
  RETURN
 END
 INSERT
 INTO CDN.KompensatyElem
 (
 KPE_KPNID,
 KPE_BRKID
 )
 VALUES
 (
 @KPNID,
 @BRKID
 )
 SET @IdParam = SCOPE_IDENTITY()
END
