CREATE  PROCEDURE CDN.ImportDokInnePos
@DokId int,
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@Kat_KodSzczegol nvarchar(20),
@Kat_ImportRowId nvarchar(36),
@Kdd_Kwota decimal(15,2),
@Kdd_Segment1 nvarchar(50),
@Kdd_Segment2 nvarchar(50),
@Kdd_Wartosc2 tinyint,
@Kdd_Wartosc1 tinyint,
@Kdd_Opis nvarchar(50),
@Kat_KodSzczegol2 nvarchar(20),
@Kat_ImportRowId2 nvarchar(36),
@Kdd_Opis2 nvarchar(50),
@Kdd_KwotaWal decimal(15,2),
@Kdd_Waluta nvarchar(3),
@WKu_Symbol nvarchar(5),
@Kdd_KursL decimal(15,4),
@Kdd_KursM decimal(5,0),
@Kdd_DataKur nvarchar(10),
@ZrdId nvarchar(5),
@OpeId int,
@IdParam int OUTPUT,
@Warnings nvarchar(1000) OUTPUT
AS
BEGIN
 DECLARE @KatId integer,
   @Kat2Id integer,
   @WkuId int,
   @sqltxt NVARCHAR (1000),
   @TmpSrvName SYSNAME
 IF( (@Kat_ImportRowId is not NULL OR @Kat_KodSzczegol is not NULL) AND(@Kat_ImportRowId <> '' OR @Kat_KodSzczegol <> ''))
 BEGIN
  SELECT @KatId = Kat_KatId
  FROM CDN.Kategorie
  WHERE Kat_ImportRowId = @Kat_ImportRowId
  IF @KatId is NULL
  BEGIN
   SELECT @KatId = Kat_KatId
   FROM CDN.Kategorie
   WHERE Kat_KodSzczegol = @Kat_KodSzczegol
   IF @KatId is NULL
    --SET @Warnings = 'Brak kategorii ' + @Kat_KodSzczegol + ' dla pozycji w bazie docelowej. Kategoria nie została zaimportowana\'
    SET @Warnings = '##OPT33184##%%kategoria%%=' + IsNull(@Kat_KodSzczegol, '') + '##\'
  END
 END
 IF( (@Kat_ImportRowId2 is not NULL OR @Kat_KodSzczegol2 is not NULL) AND(@Kat_ImportRowId2 <> '' OR @Kat_KodSzczegol2 <> ''))
 BEGIN
  SELECT @Kat2Id = Kat_KatId
  FROM CDN.Kategorie
  WHERE Kat_ImportRowId = @Kat_ImportRowId2
  IF @Kat2Id is NULL
  BEGIN
   SELECT @Kat2Id = Kat_KatId
   FROM CDN.Kategorie
   WHERE Kat_KodSzczegol = @Kat_KodSzczegol2
   IF @Kat2Id is NULL
    --SET @Warnings = 'Brak kategorii ' + @Kat_KodSzczegol2 + ' dla pozycji w bazie docelowej. Kategoria nie została zaimportowana\'
    SET @Warnings = '##OPT33184##%%kategoria%%=' + IsNull(@Kat_KodSzczegol, '') + '##\'
  END
 END
/* IF(@WKu_Symbol = '') SET @WKu_Symbol = '<-->'
 IF(@Wku_Symbol = '--' OR @Wku_Symbol = 'NIE')
   SET @Wku_Symbol = '<' + @Wku_Symbol + '>'
 SET @TmpSrvName = CAST ( SERVERPROPERTY ('MachineName') AS SYSNAME )
 IF CAST ( SERVERPROPERTY ('InstanceName') AS SYSNAME  ) <> ''
 SET @TmpSrvName = @TmpSrvName + '\' + CAST ( SERVERPROPERTY ('InstanceName') AS SYSNAME )
 SET @sqltxt = 'select Wku_WkuID FROM ['
 IF @ServerName <> @TmpSrvName
         SET @sqltxt = @sqltxt + @ConfigDBName +'].['
        SET @sqltxt = @sqltxt + @ConfigDBName + ']' + '.[CDN].[WalKursy] WHERE WkU_Symbol =' + ''''+ @WKu_Symbol + ''''
*/
 EXECUTE @WKuId = CDN.GetTypKursuWaluty @Wku_Symbol, @ConfigDBName, @ServerName
 IF @Kdd_Kwota=0 AND @Kdd_KwotaWal IS NOT NULL -- import exportów z 12 do 13
  SET @Kdd_Kwota=@Kdd_KwotaWal
 IF @Kdd_DataKur = '1899-12-30' OR @Kdd_DataKur IS NULL
  SELECT @Kdd_DataKur = convert(nvarchar(10), EDN_DataDok, 120) FROM CDN.EwidDodNag WHERE EDN_EDNID=@DokId
 DECLARE @Kdd_Lp INT
 SELECT @Kdd_Lp = MAX(Kdd_Lp) FROM cdn.KwotyDodatkowe WHERE Kdd_DokumentTyp = 12 AND Kdd_DokumentID = @DokId
 IF @Kdd_Lp Is Null
  SELECT @Kdd_Lp = 1
 ELSE
  SELECT @Kdd_Lp = @Kdd_Lp + 1
 INSERT
 INTO CDN.KwotyDodatkowe
 (Kdd_PrzekrojTyp,
 Kdd_DokumentTyp,
 Kdd_DokumentID,
 Kdd_KatID,
-- Kdd_Opis,
 Kdd_Kwota,
 Kdd_KwotaWal,
 Kdd_Segment1,
 Kdd_Segment2,
 Kdd_Wartosc1,
 Kdd_Wartosc2,
 Kdd_Waluta,
 Kdd_KursNumer,
 Kdd_KursL,
 Kdd_KursM,
 Kdd_DataKur,
 Kdd_Opis,
 Kdd_Kat2ID,
 Kdd_Opis2,
 Kdd_Lp
 )
 VALUES
 (1,
 12,
 @DokId,
 @KatId,
-- @Kat_Opis,
 convert(decimal(15,2), @Kdd_Kwota),
 IsNull(@Kdd_KwotaWal, @Kdd_Kwota),
 @Kdd_Segment1,
 @Kdd_Segment2,
 @Kdd_Wartosc1,
 @Kdd_Wartosc2,
 IsNull(@Kdd_Waluta, ''), -- '' oznacza walute systemowa
 IsNull(@WKuId, 2),
 case when IsNull(@Kdd_KursL, 0) = 0 then 1 else @Kdd_KursL end,
 case when IsNull(@Kdd_KursM, 0) = 0 then 1 else @Kdd_KursM end,
 IsNull(convert(datetime, @Kdd_DataKur, 120), GETDATE()),
 @Kdd_Opis,
 @Kat2Id,
 @Kdd_Opis2,
 @Kdd_Lp
 )
END
