CREATE PROCEDURE CDN.DodajKonto
 @OObID   INT   ,
 @Numer   NVARCHAR(50) ,
 @Nazwa   NVARCHAR(50) ,
 @TypKonta  SMALLINT ,
 @Rozrachunkowe SMALLINT ,
 @KontrolaSalda SMALLINT ,
 @Slownik  SMALLINT ,
 @SlownikGrupa SMALLINT ,
 @SlownikTyp  SMALLINT ,
 @SlownikId  INT   ,
 @OpeId   INT         ,
 @StaId   INT         = NULL,
 @Waluta         NVARCHAR(3)  = '',
 @KontrolaBudzetu Int = 0 ,
 @Nazwa2   NVARCHAR(50) = '',
 @OutID INT = 0 OUTPUT
AS
BEGIN
SET NOCOUNT ON
DECLARE @Licznik SMALLINT
DECLARE @SegmentPos SMALLINT
DECLARE @Segment NVARCHAR(50)
DECLARE @NumerIdx NVARCHAR(50)
DECLARE @ParentID INT
DECLARE @Poziom  SMALLINT
SET @NumerIdx = REPLACE (@Numer, '-', '.')
SET @SegmentPos = 0
SET @Licznik = 1
 declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @OpeId, @OpeModKod OUT, @OpeModNazwisko OUT
WHILE @Licznik <= LEN(@NumerIdx)
 BEGIN
 IF SUBSTRING (@NumerIdx, @Licznik, 1) = '.' SET @SegmentPos = @Licznik
  SET @Licznik = @Licznik + 1
    END
IF @SegmentPos = 0
 BEGIN
  SET @Segment = @Numer
  SET @ParentID = Null
  SET @Poziom  = 1
 END
ELSE
 BEGIN
  SET @Segment = SUBSTRING (@NumerIdx, @SegmentPos + 1, LEN(@NumerIdx) - @SegmentPos)
  SET @ParentID = Null
  SET @Poziom = 1
  SELECT @ParentID = Acc_AccId, @Poziom = Acc_Poziom + 1 FROM CDN.Konta WHERE Acc_OObId = @OObID AND Acc_NumerIdx = SUBSTRING (@NumerIdx, 1, @SegmentPos - 1)
 END
IF IsNull(@Segment,'') = ''
 BEGIN
  SET NOCOUNT OFF
  exec CDN.RiseOptimaException 32533
  --WITH SETERROR
  RETURN
 END
IF LEN(@Segment)>20
 BEGIN
  SET NOCOUNT OFF
  exec CDN.RiseOptimaException 32534, 's1', @Segment
  --WITH SETERROR
  RETURN
 END
INSERT INTO CDN.Konta (
 Acc_ParId   ,
 Acc_Numer   ,
 Acc_NumerIdx  ,
 Acc_Segment   ,
 Acc_Nazwa   ,
 Acc_Nazwa2  ,
 Acc_OObId   ,
 Acc_TypKonta  ,
 Acc_Rozrachunkowe ,
 Acc_KontrolaSalda ,
 Acc_Slownik   ,
 Acc_SlownikGrupa ,
 Acc_NextAccId  ,
 Acc_SlownikTyp  ,
 Acc_SlownikId  ,
 Acc_NieAktywne  ,
 Acc_Poziom   ,
 Acc_Analityka  ,
    Acc_Waluta          ,
 Acc_KontrolaBudzetu ,
 Acc_OpeZalID  ,
 Acc_OpeZalKod  ,
 Acc_OpeZalNazwisko  ,
 Acc_StaZalID  ,
 Acc_TS_Zal   ,
 Acc_OpeModID  ,
 Acc_OpeModKod  ,
 Acc_OpeModNazwisko  ,
 Acc_StaModID  ,
 Acc_TS_Mod
 )
VALUES (
 @ParentID  ,
 @Numer   ,
 @NumerIdx  ,
 @Segment  ,
 @Nazwa   ,
 @Nazwa2  ,
 @OObId   ,
 @TypKonta  ,
 @Rozrachunkowe ,
 @KontrolaSalda ,
 @Slownik  ,
 @SlownikGrupa ,
 Null   ,
 @SlownikTyp  ,
 @SlownikId  ,
 0    ,
 @Poziom   ,
 1    ,
    IsNull(@Waluta, '') ,
 @KontrolaBudzetu,
 @OpeId   ,
 @OpeModKod,
 @OpeModNazwisko,
 @StaId   ,
 GetDate()  ,
 @OpeId   ,
 @OpeModKod,
 @OpeModNazwisko,
 @StaId   ,
 GetDate()
 )
 set @outid = SCOPE_IDENTITY()
IF @@ERROR <> 0
 IF @@TRANCOUNT <> 0 ROLLBACK TRANSACTION
 exec CDN.RejestrOperacjiDodaj 450, 0, @outid, @Numer, 1, ''
SET NOCOUNT OFF
END
