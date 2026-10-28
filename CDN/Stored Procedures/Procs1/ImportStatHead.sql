CREATE  PROCEDURE CDN.ImportStatHead
@MsgId nvarchar(50),
@ExportDate nvarchar(10),
@ImportDate nvarchar(10),
@DictSummExp nvarchar(10),
@DictSummImp nvarchar(10),
@DocSummExp nvarchar(10),
@DocSummImp nvarchar(10),
@OpeId int,
@LogFile nvarchar(100),
@IdParam int OUTPUT
AS
BEGIN
 INSERT INTO CDN.StatNag
 (
 StN_Zrodlo,
 StN_DataEksport,
 StN_DataImport,
 StN_LiczbaSlowEksp,
 StN_LiczbaSlowImp,
 StN_LiczbaDokEksp,
 StN_LiczbaDokImp,
 StN_Operator,
 StN_Log
 )
 VALUES
 (
 @MsgId,
 convert(datetime, @ExportDate, 120),
 convert(datetime, @ImportDate, 120),
 convert(int, @DictSummExp),
 convert(int, @DictSummImp),
 convert(int, @DocSummExp),
 convert(int, @DocSummImp),
 @OpeId,
 @LogFile
 )
 SET @IdParam = SCOPE_IDENTITY()
END
