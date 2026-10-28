create PROCEDURE [CDN].[RejestrOperacjiDodajExOpTyp]
@ObiektTyp   NVARCHAR(MAX) ,
@ObiektSubTyp  NVARCHAR(MAX) ,
@ObiektID   NVARCHAR(MAX) ,
@ObiektNazwa  NVARCHAR(MAX) ,
@OperacjaTyp  NVARCHAR(MAX) ,
@Opis    NVARCHAR(MAX),
@From    NVARCHAR(MAX),
@Where    NVARCHAR(MAX)
AS
SET NOCOUNT ON
DECLARE @BinVar varbinary(128);
SET @BinVar = CONTEXT_INFO()
DECLARE @Log INT;
SET @Log = CAST (substring ( @BinVar , 1, 4) AS INT)
if @Log = NULL
 SET @Log = 0
if @Log <>0
BEGIN
 DECLARE @Operator nvarchar(50);
 SET @Operator = N''
 DECLARE @OpeLen INT;
 SET @OpeLen = CAST (substring ( @BinVar , 5, 4) AS INT)
 IF @OpeLen >0
  SET @Operator = CAST ( substring ( @BinVar , 9, @OpeLen*2) AS NVARCHAR(50))
 SET @Operator = REPLACE(@Operator, '''', '''''')
DECLARE @sqlCommand NVARCHAR(MAX)
SET @sqlCommand ='INSERT INTO CDN.RejestrOperacji(ROP_ObiektTyp, ROP_ObiektSubTyp, ROP_ObiektID, ROP_ObiektNazwa, ROP_Data, ROP_Operator, ROP_OperacjaTyp, ROP_Opis)' +
'SELECT ' + @ObiektTyp + ', ' + @ObiektSubTyp + ', ' + @ObiektID + ', ' + @ObiektNazwa +', GETDATE(), ''' + @Operator + ''', ' + @OperacjaTyp + ', ' + @Opis
+ ' FROM ' + @From + ' WHERE ' + @Where
EXEC (@sqlCommand)
END
SET NOCOUNT OFF
