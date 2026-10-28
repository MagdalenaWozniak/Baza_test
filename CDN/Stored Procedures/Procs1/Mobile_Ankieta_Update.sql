CREATE PROCEDURE [CDN].Mobile_Ankieta_Update
  @id    int
 ,@stanAnkiety  int
 ,@nazwaAnkiety  nvarchar(512)
 ,@opis    nvarchar(max)
 ,@dataWypelnienia datetime
 ,@opeID    int
AS
BEGIN
 DECLARE
    @przyczynaOdrzucenia nvarchar(512)
   ,@osobaId    int
   ,@osobaTelefon   varchar(20)
   ,@osobaNazwisko  nvarchar(40)
   ,@terminOd    datetime
   ,@terminDo    datetime
   ,@ocena    decimal(15,2)
   ,@dataZatwierdzenia datetime
 -- NULL oznacza, że dana kolumna nie ma być zmieniana
 SELECT @przyczynaOdrzucenia = NULL
  ,@osobaId = NULL
  ,@osobaTelefon = NULL
  ,@osobaNazwisko = NULL
  ,@terminOd = NULL
  ,@terminDo = NULL
  ,@ocena = NULL
  ,@dataZatwierdzenia = NULL
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
 DECLARE @actualStanAnkiety INT
 SELECT TOP 1 @actualStanAnkiety = AnkAnN_Stan FROM cdn.AnkAnkietyNag WHERE AnkAnN_AnkAnNId = @id
 IF @actualStanAnkiety = NULL SET @actualStanAnkiety = @stanAnkiety
 IF @actualStanAnkiety < @stanAnkiety
 BEGIN
  SET @actualStanAnkiety = @stanAnkiety
 END
 IF @stanAnkiety = 3 SET @dataZatwierdzenia = GetDate()
  EXEC [CDN].[Ankieta_Update] @id
        ,@opeID
        ,@actualStanAnkiety
        ,@przyczynaOdrzucenia
        ,@nazwaAnkiety
        ,@opis
        ,@osobaId
        ,@osobaTelefon
        ,@osobaNazwisko
        ,@terminOd
        ,@terminDo
        ,@ocena
        ,@dataWypelnienia
        ,@dataZatwierdzenia
END
