CREATE  FUNCTION CDN.SklejPowiazaneKaucje (@Id INT,@TypDok INT)
RETURNS NVARCHAR(4000)
AS
BEGIN
  DECLARE @Wynik NVARCHAR(4000)
  DECLARE @DataDok NVARCHAR(15)
  DECLARE @NR_DOK NVARCHAR(30)
  DECLARE @SumaBrutto DECIMAL (15,2)
  DECLARE @SumaPlat DECIMAL(15,2)
  DECLARE @Wal NVARCHAR(3)
  SET @Wynik = ''
  DECLARE DOK_SKOJARZONE CURSOR FAST_FORWARD FOR
      SELECT TrN_NumerPelny, CONVERT (CHAR(10), TrN_DataDok, 120),
CASE
       WHEN @Wal = '' THEN TrN_RazemBrutto ELSE TrN_RazemBruttoWal END
      ,ISNULL (sum(Bzd_Kwota),0),MAX(Bzd_waluta) FROM CDN.TraNag
      LEFT OUTER JOIN CDN.BnkZdarzenia on BZD_DokumentTyp = 1 and Bzd_DokumentID = TrN_TrNID
      LEFT OUTER JOIN CDN.TraNagRelacje  ON TrN_TrNId = TrR_TrNId AND TrR_Flaga <> 1
      WHERE TrR_FaID = @Id and TrN_TypDokumentu = @TypDok
      GROUP BY TrN_NumerPelny,TrN_DataDok, TrN_RazemBrutto, TrN_RazemBruttoWal
    OPEN DOK_SKOJARZONE
    WHILE 1 = 1
    BEGIN
      FETCH NEXT FROM DOK_SKOJARZONE INTO @NR_DOK,@DataDok, @SumaBrutto ,@SumaPlat,@Wal
      IF @@FETCH_STATUS <> 0 BREAK
      SET @Wynik = @Wynik + @DataDok +'   '+@NR_DOK+'   '+ CONVERT(NVARCHAR(15),@SumaBrutto) +
      '           '+ISNULL('('+REPLACE(CONVERT( NVARCHAR(15),@SumaPlat),'.',',')+' '+@Wal+')  ','     BRAK')  + CHAR(13)
    END
    CLOSE DOK_SKOJARZONE
  RETURN @Wynik
END
