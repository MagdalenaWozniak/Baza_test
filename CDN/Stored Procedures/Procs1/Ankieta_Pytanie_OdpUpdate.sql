CREATE PROCEDURE [CDN].[Ankieta_Pytanie_OdpUpdate]
  @id    int
 ,@odpowiedzWyb  int
 ,@odpowiedzTxt  nvarchar(max)
 ,@punkty   decimal(15,2)
 ,@wypelniajacyTyp int
 ,@wypelniajacyId int
AS
BEGIN
 SET NOCOUNT ON
 IF @punkty IS NULL SET @punkty = 0
 UPDATE [CDN].[AnkAnkietyPyt] SET
   AnkAnP_OdpowiedzWyb = @odpowiedzWyb
  ,AnkAnP_Odpowiedz = @odpowiedzTxt
  ,AnkAnP_PunktyZaOdp = @punkty
  ,AnkAnP_WypelniajacyTyp = @wypelniajacyTyp
  ,AnkAnP_WypelniajacyId = @wypelniajacyId
 WHERE AnkAnP_AnkAnPId = @id
 SET NOCOUNT OFF
END
