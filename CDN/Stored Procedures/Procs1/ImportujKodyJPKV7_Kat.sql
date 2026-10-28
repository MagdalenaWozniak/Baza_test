CREATE PROCEDURE CDN.ImportujKodyJPKV7_Kat
@KatID int,
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@Kod NVARCHAR(256),
@ZrdId nvarchar(5),
@OpeId int,
@IdParam int OUTPUT,
@Warnings nvarchar(1000) OUTPUT
AS
BEGIN
 DECLARE @KV7ID INT
 DECLARE @KV7Typ INT
 SELECT @KV7ID = KV7_KV7ID, @KV7Typ = KV7_Typ FROM cdn.KodyJPKV7 WHERE KV7_Kod = @Kod
 DECLARE @KatTyp INT
 SELECT @KatTyp = Kat_Typ FROM cdn.Kategorie WHERE Kat_KatID = @KatID
 SET @Warnings = ''
 IF @KatTyp = 1 AND @KV7Typ <> 0 AND @KV7Typ <> 1 OR @KatTyp = 2 AND @KV7Typ <> 0 AND @KV7Typ <> 2
 BEGIN
  SET @Warnings = '##OPT34887##%%kodJPK%%=' + IsNull(@Kod, '') + '##\'
  RETURN
 END
 --IF (@OnlyNew = 1)
 --BEGIN
  IF NOT EXISTS(SELECT * FROM cdn.DokKodyJPKV7 WHERE DKV7_ParentTyp = 3 AND DKV7_ParentID = @KatID AND DKV7_KV7ID = @KV7ID)
   INSERT INTO cdn.DokKodyJPKV7 (DKV7_ParentTyp, DKV7_ParentID, DKV7_KV7ID) SELECT 3, @KatID, @KV7ID
 --END
 --ELSE
 --BEGIN
 -- INSERT INTO cdn.DokKodyJPKV7 (DKV7_ParentTyp, DKV7_ParentID, DKV7_KV7ID) VALUES(0, @KntID, @KV7ID)
 --END
END
