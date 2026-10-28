CREATE PROCEDURE [CDN].Mobile_Ankieta_AddNew
 @id    int OUTPUT
 ,@opeID   int
 ,@stanowiskoId  int
 ,@dataDok   datetime
 ,@stanAnkiety  int
 ,@nazwaAnkiety  nvarchar(512)
 ,@opis    nvarchar(max)
 ,@idWzorcaAnkiety int
 ,@crmId   int
 ,@kntId   int
 ,@przedstawicielId int
 ,@dataWypelnienia  datetime
AS
BEGIN
 SELECT TOP 1 @id = DoR_DokumentId FROM cdn.DokRelacje WHERE DoR_ParentTyp=700 AND DoR_ParentId=@crmId AND DoR_DokumentTyp = 710
 IF @id IS NOT NULL AND @id > 0 RETURN
 IF @dataWypelnienia IS NOT NULL
 BEGIN
  IF Year(@dataWypelnienia) = 1970  AND Month(@dataWypelnienia) = 1 AND Day(@dataWypelnienia) = 1
    SET @dataWypelnienia = NULL
 END
 DECLARE @przyczynaOdrzucenia nvarchar(512)
   ,@osobaId   int
   ,@osobaTelefon  varchar(20)
   ,@osobaNazwisko  nvarchar(40)
   ,@terminOd   datetime
   ,@terminDo   datetime
   ,@ocena    decimal(15,2)
  SELECT  @przyczynaOdrzucenia = N''
   ,@osobaId = null
   ,@osobaTelefon = ''
   ,@osobaNazwisko = N''
   ,@terminOd = NULL
   ,@terminDo = NULL
   ,@ocena  = 0
 IF @opis IS NOT NULL
 BEGIN
  DECLARE @startIdx INT, @endIdx INT, @przyczyna NVARCHAR(40)
  SET @startIdx = CHARINDEX('[?]', @opis)
  SET @endIdx = CHARINDEX('[/?]', @opis, @startIdx+4)
  IF @startIdx > 0 AND @endIdx > 0
  BEGIN
   SET @stanAnkiety = 4 -- odrzucona
   SET @przyczynaOdrzucenia = substring(@opis, @startIdx+3, @endIdx - @startIdx - 3)
   SET @opis = substring(@opis, @endIdx+4, Len(Rtrim(@opis))- @endIdx - 3)
  END
 END
 IF @przedstawicielId IS NOT NULL AND @przedstawicielId > 0
 BEGIN
  SELECT TOP 1 @osobaNazwisko = KnO_Nazwisko,
      @osobaTelefon = CASE WHEN Len(RTrim(KnO_GSM)) > 0 THEN KnO_GSM  WHEN Len(RTrim(KnO_TelefonSms)) > 0 THEN KnO_TelefonSms ELSE KnO_Telefon END
  FROM cdn.KntOsoby WHERE KnO_KnOId = @przedstawicielId
 END
 DECLARE @seriaDok NVARCHAR(20)
 SELECT TOP 1 @seriaDok = DSta_Seria FROM CDN.DetalStanowiska  WHERE DSta_DStaId = @stanowiskoId
 EXEC [CDN].[Ankieta_AddNew]
       @id OUTPUT
       ,@opeID
       ,@stanowiskoId
       ,@seriaDok
       ,@dataDok
       ,@stanAnkiety
       ,@przyczynaOdrzucenia
       ,@idWzorcaAnkiety
       ,@nazwaAnkiety
       ,@opis
       ,1
       ,@kntId
       ,@przedstawicielId
       ,@osobaTelefon
       ,@osobaNazwisko
       ,@terminOd
       ,@terminDo
       ,@ocena
       ,@dataWypelnienia
       ,@dataWypelnienia
       ,@crmId
       ,2
END
