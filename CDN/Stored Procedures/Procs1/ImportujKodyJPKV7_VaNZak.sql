/*
Procedura dodaje podany kod JPKV7 do faktury zakupu w rejestrze VAT. Kody te są zapisane w pliku XML, w podwieszonej do dokumentu gałęzi KODY_JPK.
Uwaga. W przypadku importu plików pochodzących z OCR taka gałąź nie istnieje i kody JPK na dokumencie są dziedziczone z kontrahenta i kategorii (procedura cdn.ImportRejZak).
*/
CREATE PROCEDURE CDN.ImportujKodyJPKV7_VaNZak
@DokId int,
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
 SET @Warnings = ''
 DECLARE @ID INT, @Typ INT, @Rodzaj INT
 SELECT @ID = KV7_KV7ID, @Typ = KV7_Typ, @Rodzaj = KV7_Rodzaj FROM cdn.KodyJPKV7 WHERE KV7_Kod = @Kod
 IF @ID Is NULL
  RETURN
 IF NOT (@Typ = 0 OR @Typ = 1)
 BEGIN
  SET @Warnings = '##OPT34807##%%kod%%=' + IsNull(@Kod, '') + '##\'
  RETURN
 END
 IF @Rodzaj = 1
  RETURN -- bez ostrzeżenia
 IF NOT EXISTS(SELECT * FROM cdn.DokKodyJPKV7 WHERE DKV7_ParentTyp = 2 AND DKV7_ParentID = @DokId AND DKV7_KV7ID = @ID)
  INSERT INTO cdn.DokKodyJPKV7 (DKV7_ParentTyp, DKV7_ParentID, DKV7_KV7ID) VALUES(2, @DokId, @ID)
END
