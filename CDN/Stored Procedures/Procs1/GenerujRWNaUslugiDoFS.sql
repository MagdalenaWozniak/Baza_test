CREATE PROCEDURE [CDN].[GenerujRWNaUslugiDoFS]
  @TrN_TrNId_Zrd_List  TEXT,         -- lista TrN_TrNId dokumentów źródłowych (paragonów, faktur), do których ma być wykonany dokument magazynowy
  @TrN_Data     DATETIME,     -- TrN_DataWys dokumentu docelowego
  @TrN_OpeZalId    INT,          -- Opertor zalogowany do programu, który wykonuje operację przekształcenia
  @TrN_StaZalId    INT,          -- Sanowisko, z którego jest wykonywana operacja przekształcenia
  @ServerCfgString     NVARCHAR(250), -- nazwa serwera z bazą konfiguracyjną
  @BazaCfgString       NVARCHAR(250), -- nazwa bazy konfiguracyjnej
  @DataToday           NVARCHAR(100), -- data bieżąca z programu
  @Seria               NVARCHAR(20),
  @Kontekst            INT = 1
AS
SET NOCOUNT ON
  DECLARE
    @TrN_TrNId_Zrd        INT,
    @TrN_TrNId_Doc        INT,
    @MagId     INT,
    -- do zakazow na magazyn
    @Mag_Symbol     NVARCHAR(20),
    @Tre_TwrKod     NVARCHAR(50),
    @Komunikat      NVARCHAR(512),
    @TrN_TrNId_Zrd_PA    INT ,
    @TrN_Rodzaj_Doc      INT,
 @TrN_TypDokumentu_Zrd INT,
 @NumerPelny           NVarchar(30),
 @TypDokumentu    int
  SELECT TOP 1 @TrN_TrNId_Zrd = NextIdINT FROM cdn.Text2TableINT ( @TrN_TrNId_Zrd_List )
  SELECT TOP 1
      @TrN_TypDokumentu_Zrd    =  TrN_TypDokumentu
    FROM cdn.TraNag
    WHERE TrN_TrNId = @TrN_TrNId_Zrd
    if @TrN_TypDokumentu_Zrd = 302
  set @TrN_Rodzaj_Doc = 304004
    else
  set @TrN_Rodzaj_Doc = 304006
   -- Sprawdzenie, czy to jest FA z PA
  SELECT
    @TrN_TrNId_Zrd_PA = PA.TrN_TrNId
  FROM cdn.TraNag PA
  JOIN cdn.TraNagRelacje REL on PA.TrN_TrNId = REL.TrR_TrNId
  WHERE REL.TrR_FAId = @TrN_TrNId_Zrd AND REL.TrR_FATYP = 302 AND REL.TrR_TrNTYP = 305
   IF ISNULL(@TrN_TrNId_Zrd_PA,0) <> 0
   begin
 set @TrN_Rodzaj_Doc = 304006
 set @TrN_TrNId_Zrd = @TrN_TrNId_Zrd_PA
   end
  --sprawdzenie zakazów na magazyn
   SELECT @Mag_Symbol ='',@Tre_TwrKod=''
   SELECT @Mag_Symbol=Mag_Symbol,@Tre_TwrKod=Tre_TwrKod
     FROM cdn.TraElem
     JOIN cdn.TraNag ON TrN_TrNId = TrE_TrNId
     JOIN cdn.Magazyny on TrE_MagId=Mag_MagId
     JOIN cdn.Magazynzakazy on MaZ_MagId=TrE_MagId
     WHERE TrN_TrNId = @TrN_TrNId_Zrd and TrE_Kaucja = 2 AND MaZ_OpeId = @TrN_OpeZalId
    IF @Mag_Symbol <> ''
    BEGIN
      SET @Komunikat ='##OPT34326##%%s1%%='+ @Mag_Symbol +'##'--'Operator ma ustawiony zakaz na magazyn '+ @Mag_Symbol +'.'
      RAISERROR( @Komunikat, 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
   IF @TrN_TrNId_Zrd IS NOT NULL
   BEGIN
         -- Kursor po ProdElem
     DECLARE Magazyny CURSOR LOCAL FAST_FORWARD FOR
        SELECT TrE_MagId
          FROM cdn.TraElem
            JOIN cdn.TraNag ON TrN_TrNId = TrE_TrNId
            WHERE TrE_TrNId = @TrN_TrNId_Zrd and TrE_Kaucja = 2
          group BY TrE_MagId
          OPEN Magazyny
          WHILE 1=1
            BEGIN
              FETCH NEXT FROM Magazyny INTO @MagId
                IF @@FETCH_STATUS <> 0 BREAK
    EXEC CDN.DodajTraNag
                    @TrN_TrNId_Zrd_List,                 -- @TrN_TrNId_Zrd      INT,           -- TrN_TrNId nagłówka do dodania lub do skopiowania (może być NULL, jeśli @TrN_Rodzaj_Doc IS NOT NULL AND @TrN_MagZrdId_Doc IS NOT NULL )
                    @TrN_Rodzaj_Doc,      -- @TrN_Rodzaj_Doc     INT,           -- TrN_Rodzaj dokumentu docelowego ( może być null, jeśli @TrN_TrNId_Zrd IS NOT NULL )
                    @MagId,             -- TrN_MagZrdId dokumentu docelowego ( może być null, jeśli @TrN_TrNId_Zrd IS NOT NULL )
                    @TrN_Data,     -- @TrN_DataDok_Doc    DATETIME,      --
                    @TrN_Data,     -- @TrN_DataWys_Doc    DATETIME,      --
                    @TrN_Data,     -- @TrN_DataOpe_Doc    DATETIME,      --
                    @ServerCfgString,     -- @SeverCfgString     NVARCHAR(250),  -- nazwa serwera z bazą konfiguracyjną
                    @BazaCfgString,       -- @BazaCfgString      NVARCHAR(250),  -- nazwa bazy konfiguracyjnej
                    @TrN_OpeZalId,        -- @TrN_OpeZalId_Doc   INT,           -- Opertor zalogowany do programu, który wykonuje operację przekształcenia
                    @TrN_StaZalId,        -- @TrN_StaZalId_Doc   INT,           -- Sanowisko, z którego jest wykonywana operacja przekształcenia
                    @DataToday,           -- @DataToday          NVARCHAR(100),  -- Data Today z programu (może być inna niż z serwera)
                    -1,                   -- @Kontekst           INT,           -- Kontekst wywołania: -1 (minus jeden) - nagłówek z kontrahentem "Nieokreślony"; 0 - WZ/PZ/WKA/PKA z formularza, 1 - WZ/PZ/WKA/PKA z listy, 2 - WKA/PKA jako nowy dokument z listy FA/PA/FZ
                    @Seria,
                    @TrN_TrNId_Doc OUTPUT -- @TrN_TrNId_Doc INT OUTPUT          -- zwracany TrN_TrNId dokumentu docelowego
                    -- związanie PW z AI
                 UPDATE cdn.TraNag SET
                 TrN_FaId = @TrN_TrNId_Zrd
                 WHERE TrN_TrNId = @TrN_TrNId_Doc
                 INSERT INTO [CDN].[TraNagRelacje]
                            ([TrR_TrNTyp]
                            ,[TrR_TrNId]
                            ,[TrR_FaTyp]
                            ,[TrR_FaId]
                            ,[TrR_Flaga])
                 VALUES
                           (304
                           ,@TrN_TrNId_Doc
                           ,0
                           ,@TrN_TrNId_Zrd
                           ,0
                           )
                 UPDATE Cdn.TraNag SET TrN_Bufor = 0 WHERE TrN_TrNId = @TrN_TrNId_Doc
     if exists (select * from cdn.tranag where trn_trnid = @TrN_TrNId_Doc and trn_bufor = 0)
     begin
        select @NumerPelny = TrN_numerPelny,@TypDokumentu = trn_typdokumentu from cdn.tranag where trn_trnid = @TrN_TrNId_Doc
     exec [CDN].[RejestrOperacjiDodaj] @TypDokumentu,0, @TrN_TrNId_Doc, @NumerPelny, 103, ''
     end
                 IF CONVERT(INT, @TrN_Rodzaj_Doc/1000) = 304
     UPDATE A SET
     A.TrN_PodmiotTyp = B.TrN_PodmiotTyp,
     A.TrN_PodID = B.TrN_PodID,
     A.TrN_PodNazwa1 = B.TrN_PodNazwa1,
     A.TrN_PodNazwa2 = B.TrN_PodNazwa2,
     A.TrN_PodNazwa3 = B.TrN_PodNazwa3,
     A.TrN_PodKraj = B.TrN_PodKraj,
     A.TrN_PodWojewodztwo = B.TrN_PodWojewodztwo,
     A.TrN_PodPowiat = B.TrN_PodPowiat,
     A.TrN_PodGmina = B.TrN_PodGmina,
     A.TrN_PodUlica = B.TrN_PodUlica,
     A.TrN_PodNrDomu = B.TrN_PodNrDomu,
     A.TrN_PodNrLokalu = B.TrN_PodNrLokalu,
     A.TrN_PodMiasto = B.TrN_PodMiasto,
     A.TrN_PodKodPocztowy = B.TrN_PodKodPocztowy,
     A.TrN_PodPoczta = B.TrN_PodPoczta,
     A.TrN_PodAdres2 = B.TrN_PodAdres2,
     A.TrN_PodNipKraj = B.TrN_PodNipKraj,
     A.TrN_PodNipE = B.TrN_PodNipE,
     A.TrN_PodmiotGLN = B.TrN_PodmiotGLN,
     A.TrN_Finalny = B.TrN_Finalny,
     A.TrN_PodatekVat = B.TrN_PodatekVat,
     A.TrN_Pesel = B.TrN_Pesel,
     A.TrN_Export = B.TrN_Export,
     A.TrN_OdbiorcaTyp = B.TrN_OdbiorcaTyp,
     A.TrN_OdbID = B.TrN_OdbID,
     A.TrN_OdbNazwa1 = B.TrN_OdbNazwa1,
     A.TrN_OdbNazwa2 = B.TrN_OdbNazwa2,
     A.TrN_OdbNazwa3 = B.TrN_OdbNazwa3,
     A.TrN_OdbKraj = B.TrN_OdbKraj,
     A.TrN_OdbWojewodztwo = B.TrN_OdbWojewodztwo,
     A.TrN_OdbPowiat = B.TrN_OdbPowiat,
     A.TrN_OdbGmina = B.TrN_OdbGmina,
     A.TrN_OdbUlica = B.TrN_OdbUlica,
     A.TrN_OdbNrDomu = B.TrN_OdbNrDomu,
     A.TrN_OdbNrLokalu = B.TrN_OdbNrLokalu,
     A.TrN_OdbMiasto = B.TrN_OdbMiasto,
     A.TrN_OdbKodPocztowy = B.TrN_OdbKodPocztowy,
     A.TrN_OdbPoczta = B.TrN_OdbPoczta,
     A.TrN_OdbAdres2 = B.TrN_OdbAdres2,
     A.TrN_OdbNipKraj = B.TrN_OdbNipKraj,
     A.TrN_OdbNipE = B.TrN_OdbNipE,
     A.TrN_KodTransakcji = B.TrN_KodTransakcji,
     A.TrN_IsNId = B.TrN_IsNId,
     A.TrN_DataTransportu = @TrN_Data,
     A.TrN_KodKraju = B.TrN_KodKraju,
     A.TrN_OpeZatwID = A.TrN_OpeModID ,
     A.TrN_OpeZatwKod= A.TrN_OpeModKod ,
     A.TrN_OpeZatwNazwisko= A.TrN_OpeModNazwisko,
     A.TrN_TS_Zatw = A.TrN_TS_Mod,
     A.TrN_PCId = case when @Kontekst = 0 then B.TrN_PCId else A.TrN_PCId end,
     A.TrN_PCJSID = case when @Kontekst = 0 then B.TrN_PCJSID else A.TrN_PCJSID end
     FROM CDN.TraNag A
     JOIN CDN.TraNag B ON B.TrN_TrNID =  @TrN_TrNId_Zrd
     WHERE A.TrN_TrNId = @TrN_TrNId_Doc
   UPDATE cdn.TraElem SET TrE_TrNId =     @TrN_TrNId_Doc,TrE_Kaucja = 0, TrE_DataOpe = @TrN_Data, TrE_DataDok = @TrN_Data WHERE TrE_TrNId = @TrN_TrNId_Zrd and TrE_Kaucja = 2 and TrE_MagId = @MagId
   UPDATE  A SET tre_Lp = lp,tre_Lppow = lp FROM cdn.TraElem A
   join
   (SELECT ROW_NUMBER()OVER (PARTITION BY TrE_TrNId  ORDER BY tre_treid) as lp ,B.tre_treid FROM cdn.TraElem  B WHERE TrE_TrNId = @TrN_TrNId_Doc)  B on B.tre_treid = A.tre_treid
   IF EXISTS(SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=1823 and Fir_Wartosc = '1')
   BEGIN
    INSERT INTO CDN.DokAtrybuty
    (
    [DAt_DeAId],
    [DAt_Kod],
    [DAt_WartoscTxt],
    [DAt_TrNId]
    )
    SELECT
    [DAt_DeAId],
    [DAt_Kod],
    [DAt_WartoscTxt],
    @TrN_TrNId_Doc
    FROM CDN.DokAtrybuty
    WHERE DaT_TrNId =@TrN_TrNId_Zrd
   END
   EXEC CDN.AktualizujTraVATTraNag @TrN_TrNId_Doc
   END
  CLOSE Magazyny
  DEALLOCATE Magazyny
  UPDATE D SET  TrE_KosztUslugi = koszt
  FROM  cdn.TraElem D
  left join cdn.Towary on Twr_TwrId = d.tre_twrid
  join (
  SELECT SUM(b.TrE_WartoscNetto) as koszt ,a.tre_treid as elemid FROM cdn.TraElem A
  left join cdn.traelem B on A.TrE_TrEID = B.TrE_UslugaZlozonaId
  WHERE a.TrE_TrNId = @TrN_TrNId_Zrd  and ISNULL(B.TrE_UslugaZlozonaId,0) > 0
  group by a.tre_treid) as C on c.elemid = d.TrE_TrEID
  WHERE d.TrE_TrNId = @TrN_TrNId_Zrd
  UPDATE D SET d.TrE_KosztUslugi =  a.TrE_KosztUslugi
    FROM  cdn.TraElem D
    left join cdn.TraNagRelacje on TrR_TrNId = d.tre_trnid
    left join cdn.TraNag on TrR_TrNId = TrN_TrNID
    left join cdn.TraElem a on TrR_FaId = a.TrE_TrNId and d.TrE_LpPow = a.tre_lppow
    where TrR_FaId = @TrN_TrNId_Zrd and TrR_TrNTyp = 302   and a.TrE_UslugaZlozona = 1 and TrN_Korekta = 0
  UPDATE D SET d.TrE_KosztUslugi =  a.TrE_KosztUslugi
    FROM  cdn.TraElem D
    left join cdn.TraNagRelacje on TrR_TrNId = d.tre_trnid
    left join cdn.TraNag on TrR_TrNId = TrN_TrNID
    left join cdn.TraElem a on TrR_FaId = a.TrE_TrNId and d.TrE_LpPow = a.tre_lppow
    where TrR_FaId = @TrN_TrNId_Zrd and TrR_TrNTyp = 306   and a.TrE_UslugaZlozona = 1 and TrN_Korekta = 0
   UPDATE D SET d.TrE_KosztUslugi =  0
    FROM  cdn.TraElem D
    left join cdn.TraNagRelacje on TrR_TrNId = d.tre_trnid
    left join cdn.TraNag on TrR_TrNId = TrN_TrNID
    left join cdn.TraElem a on TrR_FaId = a.TrE_TrNId and d.TrE_LpPow = a.tre_lppow
    where TrR_FaId = @TrN_TrNId_Zrd and TrR_TrNTyp = 306   and a.TrE_UslugaZlozona = 1 and TrN_Korekta = 1
   END
SET NOCOUNT OFF
