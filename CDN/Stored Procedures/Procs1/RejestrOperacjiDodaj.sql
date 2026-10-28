CREATE PROCEDURE [CDN].[RejestrOperacjiDodaj]
@ObiektTyp   INTEGER ,
@ObiektSubTyp  INTEGER ,
@ObiektID   INTEGER ,
@ObiektNazwa  NVARCHAR(MAX) ,
@OperacjaTyp  INTEGER ,
@Opis    NVARCHAR(MAX)
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
 DECLARE @obiektNazwa100 NVARCHAR(100), @opis200 NVARCHAR(1000)
 IF @ObiektNazwa IS NULL
  SET @obiektNazwa100 = NULL
 ELSE
  SET @obiektNazwa100 = Substring(@ObiektNazwa, 1, 100)
 IF @Opis IS NULL
  SET @opis200 = NULL
 ELSE
  SET @opis200 = Substring(@Opis, 1, 1000)
 INSERT INTO CDN.RejestrOperacji(ROP_ObiektTyp, ROP_ObiektSubTyp, ROP_ObiektID, ROP_ObiektNazwa, ROP_Data, ROP_Operator, ROP_OperacjaTyp, ROP_Opis)
 VALUES (@ObiektTyp, @ObiektSubTyp, @ObiektID, @obiektNazwa100, GETDATE(), @Operator, @OperacjaTyp, @opis200)
END
SET NOCOUNT OFF
