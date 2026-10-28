CREATE  FUNCTION CDN.SklejPowiazane (@Id INT,@TypDok INT)
RETURNS NVARCHAR(4000)
AS
BEGIN
  DECLARE @Wynik NVARCHAR(4000)
  DECLARE @DataDok NVARCHAR(15)
  DECLARE @NR_DOK CHAR(30)
  DECLARE @SumaBrutto DECIMAL(15,2)
  DECLARE @SumaPlat DECIMAL(15,2)
  DECLARE @Wal NVARCHAR(3)
  SET @Wynik = ''
      DECLARE DOK_SKOJARZONE CURSOR FAST_FORWARD FOR
      SELECT TrN_NumerPelny, Convert (Char(10), TrN_DataDok, 120),
      CASE
 WHEN @Wal = '' THEN TrN_RazemBrutto ELSE TrN_RazemBruttoWal END
      ,ISNULL (sum(Bzd_Kwota),0),max(Bzd_waluta) FROM CDN.TraNag
      left outer JOIN CDN.TraNagRelacje ON TrN_TrNId = TrR_TrNId
      left outer join CDN.BnkZdarzenia on BZD_DokumentTyp = 1 and Bzd_DokumentID = trn_trnId
      WHERE TrR_FAID = @Id and TrN_TypDokumentu = @TypDok
 group by TrN_NumerPelny,TrN_DataDok, TrN_RazemBrutto, TrN_RazemBruttoWal
    OPEN DOK_SKOJARZONE
    WHILE 1 = 1
    BEGIN
      FETCH NEXT FROM DOK_SKOJARZONE INTO @NR_DOK,@DataDok, @SumaBrutto ,@SumaPlat,@Wal
      IF @@FETCH_STATUS <> 0 BREAK
      SET @Wynik = @Wynik + @DataDok +'   '+@NR_DOK+'   '+
 CASE
 WHEN @TypDok = 306 THEN '' ELSE CONVERT(NVARCHAR(15),@SumaBrutto) END + '           '+
 CASE    WHEN @TypDok = 306 THEN '' ELSE ISNULL('('+REPLACE(CONVERT( NVARCHAR(15),@SumaPlat),'.',',')+' '+@Wal+')  ','     BRAK')  END + CHAR(13)
END
    CLOSE DOK_SKOJARZONE
  RETURN @Wynik
END
