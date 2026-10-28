CREATE PROCEDURE [CDN].Mobile_Ankieta_Pytanie_OdpUpdate
 @idAnkiety   int
   ,@idPytania   int
   ,@idOdpowiedzi  int
   ,@odpowiedzTxt  nvarchar(max)
   ,@odpowiedzMulti  nvarchar(max)
   ,@opeID    int
AS
BEGIN
 DECLARE  @id int, @wypelniajacyTyp int, @wypelniajacyId int, @odpowiedzWyb int, @punkty decimal(15,2)
 SET @wypelniajacyTyp = 8
 SET @wypelniajacyId = @opeID
 SELECT TOP 1 @id = AnkAnP_AnkAnPId FROM cdn.AnkAnkietyPyt WHERE AnkAnP_AnkAnNId = @idAnkiety AND AnkAnP_AnkSpId = @idPytania
 IF @id IS NULL RETURN
 IF @odpowiedzMulti IS NULL SET @odpowiedzMulti = N''
 IF LEN(LTRIM(RTRIM(@odpowiedzMulti))) = 0
 BEGIN
  SELECT   @odpowiedzWyb = AnkAnO_Lp
    ,@punkty = AnkAnO_Punkty
  FROM cdn.AnkAnkietyOdp WHERE AnkAnO_AnkAnPId = @id AND AnkAnO_AnkSpOId = @idOdpowiedzi
 END
 ELSE
 BEGIN
  DECLARE @query nvarchar(max)
  SET @query = N'SELECT @odpowiedzWyb = SUM(POWER(2, AnkAnO_Lp)), @punkty = SUM(AnkAnO_Punkty) FROM cdn.AnkAnkietyOdp WHERE AnkAnO_AnkAnPId = @id AND AnkAnO_AnkSpOId IN ( '
     + RTRIM(@odpowiedzMulti) + N')'
  EXECUTE sp_executesql @query
        ,N'@id    int
        ,@odpowiedzWyb  int OUTPUT
        ,@punkty   DECIMAL(15,2) OUTPUT'
       ,@id = @id
      ,@odpowiedzWyb = @odpowiedzWyb OUTPUT
      ,@punkty = @punkty OUTPUT
 END
 IF @odpowiedzWyb IS NULL SET @odpowiedzWyb = 0
 IF @punkty IS NULL SET @punkty = 0
 IF @odpowiedzTxt IS NULL SET @odpowiedzTxt = N''
 EXEC [CDN].[Ankieta_Pytanie_OdpUpdate]   @id
           ,@odpowiedzWyb
           ,@odpowiedzTxt
           ,@punkty
           ,@wypelniajacyTyp
           ,@wypelniajacyId
END
