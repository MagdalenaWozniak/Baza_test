CREATE PROCEDURE CDN.ImportRejKwotyDod
@DokId int,
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@Kat_KodSzczegol nvarchar(20),
@Kat_ImportRowId nvarchar(36),
@Kdd_KwotaWal decimal(15,2),
@Kdd_Kwota decimal(15,2),
@Kdd_Segment1 nvarchar(50),
@Kdd_Segment2 nvarchar(50),
@Kdd_Waluta nvarchar(3),
@WKu_Symbol nvarchar(5),
@Kdd_KursL decimal(15,4),
@Kdd_KursM decimal(5,0),
@Kdd_DataKur nvarchar(10),
@Kdd_Opis nvarchar(50),
@Kat_KodSzczegol2 nvarchar(20),
@Kat_ImportRowId2 nvarchar(36),
@Kdd_Opis2 nvarchar(50),
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
 SELECT @KatId = Kat_KatId
 FROM CDN.Kategorie
 WHERE Kat_ImportRowId = @Kat_ImportRowId
 IF @KatId is NULL
  SELECT @KatId = Kat_KatId
  FROM CDN.Kategorie
  WHERE Kat_KodSzczegol = @Kat_KodSzczegol
 SELECT @Kat2Id = Kat_KatId
 FROM CDN.Kategorie
 WHERE Kat_ImportRowId = @Kat_ImportRowId2
 IF @Kat2Id is NULL
  SELECT @Kat2Id = Kat_KatId
  FROM CDN.Kategorie
  WHERE Kat_KodSzczegol = @Kat_KodSzczegol2
 EXECUTE @WKuId = CDN.GetTypKursuWaluty @Wku_Symbol, @ConfigDBName, @ServerName
 IF @WKuId is NULL
  RAISERROR('##OPT32090##', 16, 1) --RAISERROR('Brak kursu waluty',  16, 1)
 IF @Kdd_Kwota=0 -- import exportów z 12 do 13
  SET @Kdd_Kwota=@Kdd_KwotaWal
 IF @Kdd_DataKur = '1899-12-30'
  SELECT @Kdd_DataKur = convert(nvarchar(10), VaN_DataWys, 120) FROM CDN.VatNag WHERE VaN_VaNID=@DokId
 DECLARE @Kdd_Lp INT
 SELECT @Kdd_Lp = MAX(Kdd_Lp) FROM cdn.KwotyDodatkowe WHERE Kdd_DokumentTyp = 2 AND Kdd_DokumentID = @DokId
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
 (
 1,
 2,
 @DokId,
 @KatId,
 @Kdd_Kwota,
 @Kdd_KwotaWal,
 @Kdd_Segment1,
 @Kdd_Segment2,
 0,
 0,
 @Kdd_Waluta,
 @WKuId,
 case when @Kdd_KursL=0 then 1 else @Kdd_KursL end,
 case when @Kdd_KursM=0 then 1 else @Kdd_KursM end,
 convert(datetime, @Kdd_DataKur, 120),
 @Kdd_Opis,
 @Kat2Id,
 @Kdd_Opis2,
 @Kdd_Lp
 )
END
