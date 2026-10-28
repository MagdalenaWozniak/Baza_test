CREATE PROCEDURE [CDN].[Ankieta_Update]
  @id    int
 ,@opeId   int
 ,@stanAnkiety  int
 ,@przyczynaOdrzucenia nvarchar(512)
 ,@nazwaAnkiety  nvarchar(512)
 ,@opis    nvarchar(max)
 ,@osobaId   int
 ,@osobaTelefon  varchar(20)
 ,@osobaNazwisko nvarchar(40)
 ,@terminOd   datetime
 ,@terminDo   datetime
 ,@ocena   decimal(15,2)
 ,@dataWypelnienia datetime
 ,@dataZatwierdzenia datetime
AS
BEGIN
 SET NOCOUNT ON
 DECLARE @opeKod varchar(20), @opeNazwisko nvarchar(50)
 EXEC CDN.OpeKodNazwisko @opeID, @opeKod OUT, @opeNazwisko OUT
 DECLARE @query nvarchar(max), @addComma tinyint
 SET @addComma = 0
 SET @query = N'UPDATE [CDN].[AnkAnkietyNag] SET '
 IF @stanAnkiety IS NOT NULL
 BEGIN
  SET @query = @query + N'[AnkAnN_Stan]=@stanAnkiety'
  SET @addComma = 1
 END
 IF @przyczynaOdrzucenia IS NOT NULL
 BEGIN
  IF @addComma=1 SET @query = @query + N','
  SET @query = @query + N'[AnkAnN_PrzyczynaOdrzucenia]=@przyczynaOdrzucenia'
  SET @addComma = 1
 END
 IF @nazwaAnkiety IS NOT NULL
 BEGIN
  IF @addComma=1 SET @query = @query + N','
  SET @query = @query + N'[AnkAnN_Nazwa]=@nazwaAnkiety'
  SET @addComma = 1
 END
 IF @opis IS NOT NULL
 BEGIN
  IF @addComma=1 SET @query = @query + N','
  SET @query = @query + N'[AnkAnN_Opis]=@opis'
  SET @addComma = 1
 END
 IF @osobaId IS NOT NULL
 BEGIN
  IF @addComma=1 SET @query = @query + N','
  SET @query = @query + N'[AnkAnN_OsobaId]=@osobaId'
  SET @addComma = 1
 END
 IF @osobaTelefon IS NOT NULL
 BEGIN
  IF @addComma=1 SET @query = @query + N','
  SET @query = @query + N'[AnkAnN_OsobaTelefon]=@osobaTelefon'
  SET @addComma = 1
 END
 IF @osobaNazwisko IS NOT NULL
 BEGIN
  IF @addComma=1 SET @query = @query + N','
  SET @query = @query + N'[AnkAnN_OsobaNazwisko]=@osobaNazwisko'
  SET @addComma = 1
 END
 IF @terminOd IS NOT NULL
 BEGIN
  IF @addComma=1 SET @query = @query + N','
  SET @query = @query + N'[AnkAnN_TerminOd]=@terminOd'
  SET @addComma = 1
 END
 IF @terminDo IS NOT NULL
 BEGIN
  IF @addComma=1 SET @query = @query + N','
  SET @query = @query + N'[AnkAnN_TerminDo]=@terminDo'
  SET @addComma = 1
 END
 IF @ocena IS NOT NULL
 BEGIN
  IF @addComma=1 SET @query = @query + N','
  SET @query = @query + N'[AnkAnN_Ocena]=@ocena'
  SET @addComma = 1
 END
 IF @dataWypelnienia IS NOT NULL
 BEGIN
  IF @addComma=1 SET @query = @query + N','
  SET @query = @query + N'[AnkAnN_DataWypelnienia]=@dataWypelnienia'
  SET @addComma = 1
 END
 IF @dataZatwierdzenia IS NOT NULL
 BEGIN
  IF @addComma=1 SET @query = @query + N','
  SET @query = @query + N'[AnkAnN_DataZatwierdzenia]=@dataZatwierdzenia'
  SET @addComma = 1
 END
 IF @opeId IS NOT NULL
 BEGIN
  IF @addComma=1 SET @query = @query + N','
  SET @query = @query + N'[AnkAnN_OpeModID]=@opeId,[AnkAnN_TS_Mod]=GetDate(),[AnkAnN_OpeModKod]=@opeKod,[AnkAnN_OpeModNazwisko]=@opeNazwisko'
  SET @addComma = 1
 END
 SET @query = @query + N' WHERE AnkAnN_AnkAnNId=@id'
 EXECUTE sp_executesql @query
 ,N'@id    int
 ,@opeId   int
 ,@stanAnkiety  int
 ,@przyczynaOdrzucenia nvarchar(512)
 ,@nazwaAnkiety  nvarchar(512)
 ,@opis    nvarchar(max)
 ,@osobaId   int
 ,@osobaTelefon  varchar(20)
 ,@osobaNazwisko nvarchar(40)
 ,@terminOd   datetime
 ,@terminDo   datetime
 ,@ocena   decimal(15,2)
 ,@dataWypelnienia datetime
 ,@dataZatwierdzenia datetime
 ,@opeKod   varchar(20)
 ,@opeNazwisko  nvarchar(50)'
       ,@id = @id
      ,@opeId = @opeId
      ,@stanAnkiety = @stanAnkiety
      ,@przyczynaOdrzucenia= @przyczynaOdrzucenia
      ,@nazwaAnkiety=@nazwaAnkiety
      ,@opis=@opis
      ,@osobaId=@osobaId
      ,@osobaTelefon=@osobaTelefon
      ,@osobaNazwisko=@osobaNazwisko
      ,@terminOd=@terminOd
      ,@terminDo=@terminDo
      ,@ocena=@ocena
      ,@dataWypelnienia=@dataWypelnienia
      ,@dataZatwierdzenia=@dataZatwierdzenia
      ,@opeKod=@opeKod
      ,@opeNazwisko=@opeNazwisko
 DECLARE @numerPelny NVARCHAR(30), @opisRO NVARCHAR(200)
 SELECT TOP 1 @numerPelny = AnkAnN_NumerPelny FROM cdn.[AnkAnkietyNag] WHERE AnkAnN_AnkAnNId = @id
 SET @opisRO = N'Aktualizacja z Mobile'
    EXEC  CDN.RejestrOperacjiContextInfo @opeID
 EXEC [CDN].[RejestrOperacjiDodaj]  @ObiektTyp  = 710,
          @ObiektSubTyp = 0,
          @ObiektID  = @id,
          @ObiektNazwa = @numerPelny,
          @OperacjaTyp = 2,
          @Opis   = @opisRO
 SET NOCOUNT OFF
END
