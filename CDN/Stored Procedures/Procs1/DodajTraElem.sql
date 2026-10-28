-- Dodawanie elementów WZ/PZ, WKA/PKA
CREATE PROCEDURE CDN.DodajTraElem
  @TrN_TrNId_Zrd_List  TEXT,          -- TrN_TrNId nagłówka do dodania lub do skopiowania
  @TrN_TrNId_Doc       INT,          -- TrN_TrNId nagłówka do dodania lub do skopiowania
  @TrN_Rodzaj_Doc      INT,          -- Rodzaj dokumentu docelowego
  @TrN_DataDok_Doc     DATETIME,     --
  @TrN_DataWys_Doc     DATETIME,     --
  @TrN_DataOpe_Doc     DATETIME,     --
  @ServerCfgString     NVARCHAR(250), -- nazwa serwera z bazą konfiguracyjną
  @BazaCfgString       NVARCHAR(250), -- nazwa bazy konfiguracyjnej
  @DataToday           NVARCHAR(100), -- Data Today z programu (może być inna niż z serwera)
  @Kontekst            INT,          -- Kontekst wywołania: 0 - WZ/PZ z formularza, 1 - WZ/PZ z listy, 2 - WKA/PKA z formulara, 3 - WKA/PKA z listy
  @TrE_MagId           INT           -- Id magazynu
AS
SET NOCOUNT ON
  -- zmienne pomocnicze
  DECLARE
    @TrN_TrNId_Zrd      INT,
    @TrN_PodmiotTyp     INT,            --   INT,
    @TrN_PodId          INT,            --   INT,
    @TrN_Waluta         NVARCHAR(3),     --   NVARCHAR(3),
    @TrN_KursL          DECIMAL(15,4),  --   DECIMAL(15,4),
    @TrN_KursM          DECIMAL(5,0),   --   DECIMAL(5,0),
    @TrN_MagZrdId       INT,            --   INT,
    @TrN_RodzajZrd      INT,            --   INT,
    @TrN_TypNB          TINYINT,        --   TINYINT,
    @TrN_DataDokChar    NVARCHAR(25),    --   NVARCHAR(25),
    @TrN_DataOpeChar    NVARCHAR(25),    --   NVARCHAR(25),
    @TrN_PlatElemWalSys INT,            --   INT, -- czy ma byc liczone od zl
    @TrN_VatDlaDokWal   INT,            --   INT, -- czy ma byc liczony vat dla walutowych
    @TrN_TrNId_Zrd_PA   INT,
    @MagIdStr           NVARCHAR(10),
    @NumerPelny   NVARCHAR(30),
    @TypDokumentu  INT
  -- tablica z elementami do skopiowania
  DECLARE @TrE_TrEId_Do_Dodania TABLE ( TrE_TrEId INT,TrE_TwrId INT, TrE_LpPow INT, Twr_Typ INT,TrE_Ilosc  DECIMAL(15,4), TrE_IloscJM DECIMAL(15,4),Twr_KosztKGO DECIMAL(15,4),TrE_IFA24Mag tinyint, DoUsuniecia int,  LpPowNew INT, TrEIDZintegr INT,TrE_TrNId INT,ZestawWiazanie INT,Twr_OdwrotneObciazenie tinyint )
  DECLARE @TrNID TABLE ( TrNId INT)
  insert into @TrNID select NextIdInt from  CDN.Text2TableInt ( @TrN_TrNId_Zrd_List )
  -- TrN_TrNId dokumentu źródłowego (dla dokumentów, dla których jest tylko jeden źródłowy)
  SET @TrN_TrNId_Zrd = ( SELECT TOP 1 NextIdINT FROM cdn.Text2TableINT( @TrN_TrNId_Zrd_List ))
  -- magazyn id do stringa dla inicjujtraelem
  SET @MagIdStr = cast(@TrE_MagId as NVARCHAR(10))
  -- WZ/PZ - skopiowanie elementów z dokumentu źródłowego
  -- mogą być na dokumencie źródłowym lub na źródłowym i docelowym (dodano elementy do FA/FZ)
  IF CONVERT( INT, @TrN_Rodzaj_Doc/1000) IN (306, 307 )
    BEGIN
      INSERT INTO @TrE_TrEId_Do_Dodania ( TrE_TrEId, TrE_TwrId, TrE_LpPow, Twr_Typ, TrE_Ilosc, TrE_IloscJM, Twr_KosztKGO,TrE_IFA24Mag,DoUsuniecia ,  LpPowNew , TrEIDZintegr ,TrE_TrNId ,ZestawWiazanie,Twr_OdwrotneObciazenie )
         SELECT TrE_TrEId, TrE_TwrId, TrE_LpPow, Twr_Typ, TrE_Ilosc, TrE_IloscJM,Twr_KosztKGO,TrE_IFA24Mag,0,0,0,TrE_TrNId ,TrE_ZestawWiazanie,Twr_OdwrotneObciazenie
          FROM cdn.TraElem
            JOIN cdn.Towary ON Twr_TwrId = TrE_TwrId
            JOIN cdn.TraNag ON TrE_TrNId = TrN_TrNId
          WHERE TrE_TrNId in (select TrNId from @TrNID ) AND TrE_LpPow < 0 AND TrE_Kaucja = 0 AND TrN_Bufor <> -1 AND TrE_MagId = @TrE_MagId order by tre_treid-- TrE_Aktywny = 1
      -- jeśli nie było dodanych elementów, to mogą być elementy jeszcze bez skojarzonych WZ (nagłówek już istnieje)
      IF NOT EXISTS ( SELECT * FROM @TrE_TrEId_Do_Dodania )
        IF NOT EXISTS ( SELECT * FROM cdn.TraElem MAE JOIN cdn.TraNag MAN ON MAN.TrN_TrNId = MAE.TrE_TrNId JOIN cdn.TraNagRelacje REL on MAN.TrN_TrNId = REL.TrR_TrNId  and not (TrR_FaTyp = 302 and trr_trntyp = 301) and not (TrR_FaTyp = 301 and trr_trntyp = 302)
                        WHERE REL.TrR_FaId in (select TrNId from @TrNID ) AND MAN.TrN_TypDokumentu IN (302, 306, 307) AND TrN_Bufor <> -1 AND MAE.TrE_MagId = @TrE_MagId) or @TrN_Rodzaj_Doc = 306008
          INSERT INTO @TrE_TrEId_Do_Dodania ( TrE_TrEId, TrE_TwrId, TrE_LpPow, Twr_Typ, TrE_Ilosc, TrE_IloscJM,Twr_KosztKGO,TrE_IFA24Mag,DoUsuniecia ,  LpPowNew , TrEIDZintegr,TrE_TrNId ,ZestawWiazanie,Twr_OdwrotneObciazenie  )
            SELECT TrE_TrEId, TrE_TwrId, TrE_LpPow, Twr_Typ, TrE_Ilosc, TrE_IloscJM,Twr_KosztKGO,TrE_IFA24Mag,0,0,0,TrE_TrNId ,TrE_ZestawWiazanie,Twr_OdwrotneObciazenie
              FROM cdn.TraElem
                JOIN cdn.Towary ON TrE_TwrId = Twr_TwrId
                JOIN cdn.TraNag ON TrE_TrNId = TrN_TrNId
              WHERE TrE_TrNId in (select TrNId from @TrNID ) AND TrE_Kaucja = 0 AND TrN_Bufor <> -1  AND TrE_MagId = @TrE_MagId order by tre_treid-- TrE_Aktywny = 1
        ELSE
          IF EXISTS ( SELECT * FROM cdn.TraElem MAE JOIN cdn.TraNag MAN ON MAN.TrN_TrNId = MAE.TrE_TrNId JOIN cdn.TraNagRelacje REL on MAN.TrN_TrNId = REL.TrR_TrNId   and not (TrR_FaTyp = 302 and trr_trntyp = 301) and not (TrR_FaTyp = 301 and trr_trntyp = 302)
    WHERE REL.TrR_FaId in (select TrNId from @TrNID ) AND (MAN.TrN_Rodzaj = 306010 OR MAN.TrN_TypDokumentu = 302) )
           BEGIN
CREATE TABLE  #WZ(ter_parentid INT,tre_treid int, TrE_Ilosc DECIMAL(15,4), TrE_IloscJM DECIMAL(15,4))
              INSERT INTO #WZ(ter_parentid ,TrE_treid , TrE_Ilosc , TrE_IloscJM )
                        SELECT ter_parentid ,ter_childid ,ISNULL(Ter_Info,0) as TrE_Ilosc ,ISNULL(round(Ter_Info*PFElem.tre_JMPrzelicznikM/PFElem.tre_JMPrzelicznikL,4),0) as TrE_IloscJM  FROM cdn.TraElem MAE
                              join cdn.traelemrelacje on TeR_ChildId = MAE.TrE_treid and ter_parenttyp = 320
                              join cdn.traelem PFElem on ter_parentid = PFElem.TrE_TrEId
                              JOIN Cdn.TraNag MAN ON MAN.TrN_TrNId = MAE.TrE_TrNId JOIN cdn.TraNagRelacje REL on MAN.TrN_TrNId = REL.TrR_TrNId
                              WHERE REL.TrR_FaId in (select TrNId from @TrNID ) AND MAN.TrN_TypDokumentu in(306,302)
                              AND  MAE.TrE_Kaucja = 0 AND TrN_Bufor <> -1 AND MAE.TrE_LpPow > 0
                              AND NOT EXISTS (SELECT B.Trr_TrRId FROM CDN.TraNagRelacje B
                              JOIN Cdn.TraNag WZ ON B.Trr_trnId = WZ.TRN_TrNId
                              WHERE B.Trr_FAId = REL.TrR_TrNId  AND B.TrR_FaTyp = 302
                              AND WZ.TrN_Rodzaj = 306010)
                              --GROUP BY ter_parentid*/
                              --GROUP BY ter_parentid*/
               CREATE TABLE  #WZSum(ter_parentid INT, TrE_Ilosc DECIMAL(15,4), TrE_IloscJM DECIMAL(15,4), Ter_ChildId int )
               IF @TrN_Rodzaj_Doc=306010
               begin
               INSERT INTO #WZSum (ter_parentid , TrE_Ilosc , TrE_IloscJM )
               select ter_parentid, sum(TrE_Ilosc), sum(TrE_IloscJM) from (
               SELECT ter_parentid, TrE_Ilosc, TrE_IloscJM
               FROM #WZ
               union all
               select a.ter_parentid, b.TrE_Ilosc, b.TrE_IloscJM  from cdn.traelem b
               JOIN cdn.TraNag ON b.TrE_TrNId = TrN_TrNId
               join #WZ a on a.tre_treid = b.tre_zwrid and tre_typdokumentu = 306
               where TrN_Bufor <> -1
               AND NOT EXISTS (SELECT C.Trr_TrRId FROM CDN.TraNagRelacje C
               JOIN cdn.TraNag ON C.TrR_TrNID = TrN_TrNId
                              WHERE C.Trr_FAId =  b.TrE_TrNId  AND C.TrR_TrNTyp = 302 and TrN_Korekta = 1
                              )
               )as a
               GROUP BY a.ter_parentid
               INSERT INTO @TrE_TrEId_Do_Dodania ( TrE_TrEId, TrE_TwrId, TrE_LpPow, Twr_Typ, TrE_Ilosc,  TrE_IloscJM,Twr_KosztKGO,TrE_IFA24Mag,DoUsuniecia ,  LpPowNew , TrEIDZintegr,TrE_TrNId ,ZestawWiazanie,Twr_OdwrotneObciazenie  )
               SELECT  b.TrE_TrEId, b.TrE_TwrId, b.TrE_LpPow, Twr_Typ,b.TrE_Ilosc - ISNULL(a.TrE_Ilosc,0) as TrE_Ilosc,b.TrE_IloscJM - ISNULL(a.TrE_IloscJM,0) as TrE_IloscJM,Twr_KosztKGO,TrE_IFA24Mag,0,0,0,TrE_TrNId ,TrE_ZestawWiazanie,Twr_OdwrotneObciazenie
                  FROM cdn.TraElem b
                  JOIN cdn.Towary ON b.TrE_TwrId = Twr_TwrId
                  JOIN cdn.TraNag ON b.TrE_TrNId = TrN_TrNId
                  LEFT OUTER JOIN #WZSum a ON a.ter_parentid = b.TrE_TrEId
                  WHERE b.TrE_TrNId in (select TrNId from @TrNID ) AND b.TrE_Kaucja = 0 AND TrN_Bufor <> -1 AND b.TrE_LpPow > 0
               end
               else
               begin
               INSERT INTO #WZSum (ter_parentid , TrE_Ilosc , TrE_IloscJM )
               select ter_parentid, sum(TrE_Ilosc), sum(TrE_IloscJM)
               FROM #WZ
               GROUP BY ter_parentid
               update #wzsum set
               Ter_ChildId = tre_treid
                  FROM cdn.TraElem b
                  join cdn.traelemrelacje fa on TeR_ChildId = b.TrE_treid and ter_parenttyp = 320
                  JOIN cdn.Towary ON b.TrE_TwrId = Twr_TwrId
                  JOIN cdn.TraNag ON b.TrE_TrNId = TrN_TrNId
                  LEFT OUTER JOIN #WZSum a ON a.ter_parentid = fa.ter_parentid
                  WHERE b.TrE_TrNId in (select TrNId from @TrNID ) AND b.TrE_Kaucja = 0 AND TrN_Bufor <> -1 AND b.TrE_LpPow > 0
               INSERT INTO @TrE_TrEId_Do_Dodania ( TrE_TrEId, TrE_TwrId, TrE_LpPow, Twr_Typ, TrE_Ilosc,  TrE_IloscJM,Twr_KosztKGO,TrE_IFA24Mag,DoUsuniecia ,  LpPowNew , TrEIDZintegr ,TrE_TrNId ,ZestawWiazanie,Twr_OdwrotneObciazenie )
               SELECT  b.TrE_TrEId, b.TrE_TwrId, b.TrE_LpPow, Twr_Typ,b.TrE_Ilosc - ISNULL(a.TrE_Ilosc,0) as TrE_Ilosc,b.TrE_IloscJM - ISNULL(a.TrE_IloscJM,0) as TrE_IloscJM,Twr_KosztKGO,TrE_IFA24Mag,0,0,0,TrE_TrNId ,TrE_ZestawWiazanie,Twr_OdwrotneObciazenie
                  FROM cdn.TraElem b
                  JOIN cdn.Towary ON b.TrE_TwrId = Twr_TwrId
                  JOIN cdn.TraNag ON b.TrE_TrNId = TrN_TrNId
                  LEFT OUTER JOIN (select ter_childId, sum(tre_ilosc) as tre_ilosc,sum(tre_iloscJM) as tre_iloscJM from   #WZSum z  group by ter_childId)as a  ON a.Ter_ChildId = b.TrE_treid
                  WHERE b.TrE_TrNId in (select TrNId from @TrNID ) AND b.TrE_Kaucja = 0 AND TrN_Bufor <> -1 AND b.TrE_LpPow > 0 AND TrE_MagId = @TrE_MagId
               end
DROP TABLE #WZ
DROP TABLE #WZSum
               -- jeśli nie przenosimy usług na dokumet magazynowy (parametr z konfiguracji), to kasujemy je z zestawu elementów do skopiowania
                  IF CONVERT( INT, @TrN_Rodzaj_Doc/1000) IN (306, 307 )
                  AND ( SELECT TOP 1 CONVERT ( INT, ISNULL(SUBSTRING(MAX(Fir_Wartosc),1,1),0 ) )
                  FROM cdn.Firma
                  JOIN cdn.TraNag ON TrN_TrNId in (select TrNId from @TrNID )
                  WHERE Fir_Numer =
                  CASE
                      WHEN TrN_TypDokumentu IN ( 302, 305, 320 ) THEN 1576  -- przenoś usługi na WZ
                      WHEN TrN_TypDokumentu IN ( 301 )      THEN 1577  -- przenoś usługi na PZ
                 END
               ) = 0
               DELETE FROM @TrE_TrEId_Do_Dodania WHERE Twr_Typ = 0
               IF EXISTS(SELECT * FROM @TrE_TrEId_Do_Dodania)
               BEGIN
               DELETE FROM @TrE_TrEId_Do_Dodania WHERE (TrE_Ilosc<=0 and TrE_IloscJM<=0)
               IF NOT EXISTS(SELECT * FROM @TrE_TrEId_Do_Dodania)
                 IF @TrN_Rodzaj_Doc=306010
                 BEGIN
                   RAISERROR('##OPT34481##', 16, 1)
                   rollback
                   SET NOCOUNT OFF
                   RETURN
              END
               END
           END
      END
  -- Pozycje iFA24 ktore nie maja pobierać usuwamy
  DELETE FROM @TrE_TrEId_Do_Dodania WHERE TrE_IFA24Mag = 1
  -- WKA/PKA - skopiowanie elementów z dokumentu źródłowego (zawsze są tylko na źródłowym - docelowy jest pusty)
  IF CONVERT( INT, @TrN_Rodzaj_Doc/1000) IN ( 313, 314 )
    BEGIN
      -- jeśli jest to FA z PA, to elementy kaucyjne mogą pochodzić z paragonu.
      SELECT @TrN_TrNId_Zrd_PA = PA.TrN_TrNId
        FROM cdn.TraNag PA
          JOIN cdn.TraNagRelacje REL on PA.TrN_TrNId = REL.TrR_TrNId
         -- JOIN cdn.TraNag PA
          --ON  PA.TrN_TrNId = FA.TrN_FaId
          --AND FA.TrN_TrNId = PA.TrN_FaId
          --AND FA.TrN_TypDokumentu = 302
          --AND PA.TrN_TypDokumentu = 305
          --AND FA.TrN_TrNId = @TrN_TrNId_Zrd
        JOIN cdn.TraElem ON TrE_TrNId = PA.TrN_TrNId
        WHERE REL.TrR_FaId = @TrN_TrNId_Zrd AND REL.TrR_TrNTyp = 305 AND REL.TrR_FaTyp = 302
        AND TrE_Kaucja = 1 AND PA.TrN_Bufor <> - 1  AND TrE_LpPow > 0 -- AND TrE_Aktywny = 1
      IF @TrN_TrNId_Zrd_PA IS NOT NULL
        SET @TrN_TrNId_Zrd = @TrN_TrNId_Zrd_PA
      INSERT INTO @TrE_TrEId_Do_Dodania ( TrE_TrEId, TrE_LpPow, Twr_Typ, TrE_Ilosc, TrE_IloscJM, Twr_KosztKGO,DoUsuniecia ,  LpPowNew  , TrEIDZintegr ,TrE_TrNId ,ZestawWiazanie,Twr_OdwrotneObciazenie )
        SELECT TrE_TrEId, TrE_LpPow, Twr_Typ, TrE_Ilosc, TrE_IloscJM, Twr_KosztKGO,0,0,0,TrE_TrNId ,TrE_ZestawWiazanie,Twr_OdwrotneObciazenie
          FROM cdn.TraElem
            JOIN cdn.Towary ON Twr_TwrId = TrE_TwrId
            JOIN cdn.TraNag ON TrN_TrNId = TrE_TrNId
          WHERE TrE_TrNId = @TrN_TrNId_Zrd AND TrE_LpPow > 0 AND TrE_Kaucja = 1 AND TrN_Bufor <> -1 AND TrE_MagId = @TrE_MagId-- AND TrE_Aktywny = 1
    END
    -- jeśli nie przenosimy usług na dokumet magazynowy (parametr z konfiguracji), to kasujemy je z zestawu elementów do skopiowania
    IF CONVERT( INT, @TrN_Rodzaj_Doc/1000) IN (306, 307 ) and @TrN_Rodzaj_Doc != 306008
       AND ( SELECT TOP 1 CONVERT ( INT, ISNULL(SUBSTRING(MAX(Fir_Wartosc),1,1),0 ) )
           FROM cdn.Firma
             JOIN cdn.TraNag ON TrN_TrNId = @TrN_TrNId_Zrd
           WHERE Fir_Numer =
             CASE
               WHEN TrN_TypDokumentu IN ( 302, 305, 320 ) THEN 1576  -- przenoś usługi na WZ
               WHEN TrN_TypDokumentu IN ( 301 )      THEN 1577  -- przenoś usługi na PZ
             END
       ) = 0
      DELETE FROM @TrE_TrEId_Do_Dodania WHERE Twr_Typ = 0
      DELETE FROM @TrE_TrEId_Do_Dodania WHERE (TrE_Ilosc<=0 and TrE_IloscJM<=0)
    -- return, jeśli nie ma nic do dodania (nagłówek już funkcjonuje), chyba że jest to dodanie nowego WKA/PKA z listy
    IF NOT EXISTS ( SELECT * FROM @TrE_TrEId_Do_Dodania ) AND @Kontekst NOT IN ( 2 )
      BEGIN
        UPDATE cdn.TraNag SET TrN_Bufor = 1 WHERE TrN_TrNId = @TrN_TrNId_Doc
  select @NumerPelny = TrN_numerPelny,@TypDokumentu = trn_typdokumentu from cdn.tranag where trn_trnid = @TrN_TrNId_Doc
  DELETE FROM CDN.RejestrOperacji WHERE ROP_ObiektID = @TrN_TrNId_Doc and ROP_ObiektTyp = @TypDokumentu and ROP_ObiektNazwa = @NumerPelny
        DELETE FROM cdn.TraNag WHERE TrN_TrNId = @TrN_TrNId_Doc
        DELETE FROM cdn.TraNagRelacje WHERE TrR_TrNId = @TrN_TrNId_Doc
        DELETE FROM cdn.TraNagRelacje WHERE TrR_FAId = @TrN_TrNId_Doc
        SET NOCOUNT OFF
        RETURN
      END
    ELSE IF @Kontekst IN ( 2 )
      -- aktualizujemy nagłówek nawet jeśli nie ma elementów (może być pusty)
      EXEC CDN.AktualizujTraVATTraNag @TrN_TrNId_Doc
    -- Skasowanie subelementów z dokumentu źródłowego musi być wykonane przed tworzeniem elementów
    -- (przy fakturze z pobraniem może zabraknąć elementów)
    IF @Kontekst IN ( 0, 1, 7 )
      EXEC CDN.KasujTraSElemZDokZrodlowych @TrN_TrNId_Doc, @TrN_Rodzaj_Doc, @TrN_TrNId_Zrd
    -- WKA/PKA - opcja "dodaj nowy dokument" (kontekst 2):
    -- trzeba utworzyć elementy kaucyjne na dokumencie źródłowym
    IF CONVERT( INT, @TrN_Rodzaj_Doc/1000) IN ( 313, 314 ) AND @Kontekst = 2
      BEGIN
        -- trzeba raz wywołać procedurę inicjującą elemnty w celu wygenerowania elementów kaucyjnych
        SELECT
          @TrN_PodmiotTyp     = TrN_PodmiotTyp,
          @TrN_PodId          = TrN_PodId,
          @TrN_Waluta         = ISNULL(TrN_Waluta,''),
          @TrN_KursL          = TrN_KursL,
          @TrN_KursM          = TrN_KursM,
          @TrN_MagZrdId       = TrN_MagZrdId,
          @TrN_RodzajZrd      = TrN_Rodzaj,
          @TrN_TypNB          = TrN_TypNB,
          @TrN_DataDokChar    = CONVERT(NVARCHAR(25), TrN_DataDok, 120),
          @TrN_DataOpeChar    = CONVERT(NVARCHAR(25), TrN_DataOpe, 120),
          @TrN_PlatElemWalSys = TrN_PlatElemWalSys,
          @TrN_VatDlaDokWal   = TrN_VatDlaDokWal
        FROM cdn.TraNag
        WHERE TrN_TrNId = @TrN_TrNId_Zrd
        IF @TrN_Waluta = '   ' SET @TrN_Waluta = 'PLN'
        -- procedura doda elementy kaucyjne na podstawie towarów z dokumentu źródłowego i przypnie je do dokumentu źródłowego
        EXEC CDN.InicjujTraElem
         '0 ',                  --   TEXT,           -- id towarów rozdzielone przecinkami
         '0 ',                  --   TEXT,           -- ilosci towarow rozdzielone przecinkami
         '  ',                  --   TEXT,           -- jednostki miar towarow rozdzielone przecinkami
         '0 ',                  --   TEXT,           -- ceny walutowe
         @MagIdStr,             --   TEXT,           -- id magazynu
         @TrN_PodmiotTyp,       --   INT,
         @TrN_PodId,            --   INT,
         @TrN_Waluta,           --   NVARCHAR(3),
         @TrN_KursL,            --   DECIMAL(15,4),
         @TrN_KursM,            --   DECIMAL(5,0),
         @TrE_MagId,            --   INT,
         @TrN_Rodzaj_Doc,        --   INT,
         @TrN_TypNB,                     --   TINYINT,
         @TrN_DataDokChar,      --   NVARCHAR(25),
         @TrN_DataOpeChar,      --   NVARCHAR(25),
         @TrN_DataDokChar,      --   NVARCHAR(25),
         NULL,                  --   INT,            -- numer ceny wybrany na liście zasobów - jesli NULL, to procedura musi go zbudowac na podstawie ceny domyślnej kontrahenta i towaru
         @ServerCfgString,      --   NVARCHAR(512),   -- np. 'Z-GAJEWSKI'
         @BazaCfgString,        --   NVARCHAR(512),   -- np. 'CDN_Konfiguracja65'
         0,                     --   INT,            -- Lp z ostatniego elementu dokumentu - inicjowane elementy będą miały kolejne Lp
         '',                    --   NVARCHAR(30),    -- sortowanie towarów wg kodu, nazwy, numru katalogowego, EAN-u,
         @TrN_TrNId_Zrd,        --   INT,            -- jeśli ustawione, to dodajemy elemnty do tego nagłowka
         @TrN_PlatElemWalSys,   --   INT,            -- czy ma byc liczone od zl
         @TrN_VatDlaDokWal,     --   INT,            -- czy ma byc liczone vat dla wal
         0,                     --   SMALLINT,       -- FV Marża
         3,                     --   SMALLINT        -- Opakowania 0 - jeden towar z zakładki "ogólne", 1 - jedna kaucja z zakładki "kaucje", 2 - zestaw opakowań z zakładki "kaucje" na podstawie towarów z zakładki "ogólne" i schematów opakowań.
         1                      --   SMALLINT        -- DodajElementyDoBazy
       -- przepięcie elementów kaucyjnych na dokument docelowy (zostały dodane do źródłowego)
       UPDATE cdn.TraElem SET
         TrE_TrNId = @TrN_TrNId_Doc,
         TrE_Kaucja = 0
       WHERE TrE_TrNId = @TrN_TrNId_Zrd AND TrE_Kaucja = 1
      END
    -- WKA/PKAZ - przepinamy kaucje
    IF CONVERT( INT, @TrN_Rodzaj_Doc/1000) IN ( 313, 314 )  AND @Kontekst <> 2
      UPDATE CDN.TraElem SET
         TrE_TrNId        = @TrN_TrNId_Doc,
         TrE_TypDokumentu = CONVERT(INT, @TrN_Rodzaj_Doc/1000),
         TrE_Aktywny      = 1,
         TrE_DataDok      = @TrN_DataDok_Doc,
         TrE_DataOpe      = @TrN_DataOpe_Doc,
         TrE_Kaucja       = 0
       WHERE TrE_TrEId IN ( SELECT TrE_TrEId FROM @TrE_TrEId_Do_Dodania )
    -- WZ/PZ - dodajemy nowe elementy na WZ/PZ
     ELSE
     BEGIN
    -- Sprawdzamy dostepne ilosci dla WZ
     IF EXISTS(SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=1776 and Fir_Wartosc = '1' and @TrN_Rodzaj_Doc = 306010)
     BEGIN
      SELECT
         @TrN_MagZrdId       = TrN_MagZrdId,
            @TrN_KursL          = TrN_KursL,
            @TrN_KursM          = TrN_KursM,
   @TrN_Waluta         = ISNULL(TrN_Waluta,''),
            @TrN_PlatElemWalSys = TrN_PlatElemWalSys
         FROM cdn.TraNag
         WHERE TrN_TrNId in (select TrNId from @TrNID )
            CREATE TABLE  #TwrIlosci(TwI_TwrId INT, TwI_Ilosc DECIMAL(15,4))
            IF exists(     select a.Trr_TrNId from cdn.tranagrelacje a join cdn.tranag on trn_trnid = a.Trr_TrNId
    where a.TrR_FaId =@TrN_TrNId_Zrd AND a.Trr_TrNTyp =308 AND a.Trr_FaTyp =320 and TrN_ZwroconoCalaIlosc != 4 and TrN_Bufor != -1)
       begin
        IF EXISTS(SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=1536 and Fir_Wartosc = '1' and @TrN_Rodzaj_Doc = 306010)
        and EXISTS(SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=1970 and Fir_Wartosc = '0' and @TrN_Rodzaj_Doc = 306010)
         INSERT INTO #TwrIlosci SELECT TwI_TwrId, TwI_Ilosc - TwI_Rezerwacje+ case when TwI_Rezerwacje < TrE_Ilosc then TwI_Rezerwacje else  TrE_Ilosc end  FROM @TrE_TrEId_Do_Dodania
         LEFT OUTER JOIN cdn.TwrIlosci I ON TrE_TwrId = I.TwI_TwrId AND I.TwI_MagId = @TrE_MagId
         AND I.TwI_Data = (SELECT TOP 1 H.TwI_Data FROM CDN.TwrIlosci H WHERE H.TwI_TwrId = Tre_TwrId AND H.TwI_MagId = @TrE_MagId
         AND H.TwI_Data <=@TrN_DataDok_Doc ORDER BY H.TwI_Data DESC )
       else
        INSERT INTO #TwrIlosci SELECT TwI_TwrId, TwI_Ilosc  FROM @TrE_TrEId_Do_Dodania
        LEFT OUTER JOIN cdn.TwrIlosci I ON TrE_TwrId = I.TwI_TwrId AND I.TwI_MagId = @TrE_MagId
        AND I.TwI_Data = (SELECT TOP 1 H.TwI_Data FROM CDN.TwrIlosci H WHERE H.TwI_TwrId = Tre_TwrId AND H.TwI_MagId = @TrE_MagId
        AND H.TwI_Data <=@TrN_DataDok_Doc ORDER BY H.TwI_Data DESC )
       end
            else
       begin
        IF EXISTS(SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=1536 and Fir_Wartosc = '1' and @TrN_Rodzaj_Doc = 306010)
      INSERT INTO #TwrIlosci SELECT TwI_TwrId, TwI_Ilosc - TwI_Rezerwacje  FROM @TrE_TrEId_Do_Dodania
      LEFT OUTER JOIN cdn.TwrIlosci I ON TrE_TwrId = I.TwI_TwrId AND I.TwI_MagId = @TrE_MagId
      AND I.TwI_Data = (SELECT TOP 1 H.TwI_Data FROM CDN.TwrIlosci H WHERE H.TwI_TwrId = Tre_TwrId AND H.TwI_MagId = @TrE_MagId
      AND H.TwI_Data <=@TrN_DataDok_Doc ORDER BY H.TwI_Data DESC )
        else
      INSERT INTO #TwrIlosci SELECT TwI_TwrId, TwI_Ilosc  FROM @TrE_TrEId_Do_Dodania
      LEFT OUTER JOIN cdn.TwrIlosci I ON TrE_TwrId = I.TwI_TwrId AND I.TwI_MagId = @TrE_MagId
      AND I.TwI_Data = (SELECT TOP 1 H.TwI_Data FROM CDN.TwrIlosci H WHERE H.TwI_TwrId = Tre_TwrId AND H.TwI_MagId = @TrE_MagId
      AND H.TwI_Data <=@TrN_DataDok_Doc ORDER BY H.TwI_Data DESC )
       end
               DECLARE
                @TrE_TrEId   INT,
                @TrE_TwrId   INT,
                @Twr_Typ     INT,
                @TrE_Ilosc   DECIMAL(15,4),
                @TwI_Ilosc   DECIMAL(15,4),
                   @KGO         DECIMAL(15,4),
                @Roznica     DECIMAL(15,4),
                @TrE_IloscJM DECIMAL(15,4),
                @ZestawWiaz  INT
                 CREATE TABLE #UsuwaneZestaw(ZestawWiazanie INT)
               DECLARE N CURSOR LOCAL FAST_FORWARD FOR
                       SELECT TrE_TrEId, TrE_TwrId, Twr_Typ,  TrE_Ilosc, TrE_IloscJM, Twr_KosztKGO,ZestawWiazanie FROM @TrE_TrEId_Do_Dodania
                          OPEN N
                           WHILE 1=1
                            BEGIN
                             FETCH NEXT FROM N INTO @TrE_TrEId,  @TrE_TwrId, @Twr_Typ,@TrE_Ilosc, @TrE_IloscJM, @KGO, @ZestawWiaz
                             IF @@FETCH_STATUS <> 0 BREAK
                                 IF @Twr_Typ<>0 and @ZestawWiaz not in (select * from #UsuwaneZestaw)
                                   BEGIN
                                      SELECT @Roznica= NULL , @TwI_Ilosc=NULL
                                      SELECT @TwI_Ilosc = TwI_Ilosc, @Roznica = TwI_Ilosc-@TrE_Ilosc FROM  #TwrIlosci WHERE TwI_TwrId = @TrE_TwrId
                                      IF @Roznica>0
                                         UPDATE #TwrIlosci SET TwI_Ilosc = TwI_Ilosc - @TrE_Ilosc WHERE TwI_TwrId = @TrE_TwrId
                                      ELSE
                                         BEGIN
                                         if @ZestawWiaz > 0 and @Roznica<0
                                            BEGIN
            UPDATE #TwrIlosci SET TwI_Ilosc = TwI_Ilosc +  a.ilosc from #TwrIlosci join(
            SELECT sum(B.TrE_Ilosc) as ilosc ,B.TrE_TwrId as twrid FROM @TrE_TrEId_Do_Dodania B
            where DoUsuniecia = 0 and b.tre_treid < @TrE_TrEId and B.ZestawWiazanie = @ZestawWiaz
            group by B.TrE_TwrId) a on a.twrid = TwI_TwrId
            delete from
            @TrE_TrEId_Do_Dodania
            WHERE ZestawWiazanie = @ZestawWiaz
            insert into #UsuwaneZestaw select @ZestawWiaz
                                            END
                                         else
                                            BEGIN
            UPDATE #TwrIlosci SET TwI_Ilosc = 0 WHERE TwI_TwrId = @TrE_TwrId
            UPDATE @TrE_TrEId_Do_Dodania SET TrE_Ilosc = ISNULL(@TwI_Ilosc,0), TrE_IloscJM =ISNULL(@TwI_Ilosc*A.TrE_JMPrzelicznikM/A.TrE_JMPrzelicznikL,0)
            FROM @TrE_TrEId_Do_Dodania B
            JOIN  Cdn.TraElem A ON @TrE_TrEId = A.TrE_TrEId
            WHERE B.TrE_TrEId = @TrE_TrEId
                                            END
                                         END
                                   END
                           END
                        CLOSE N
                        DEALLOCATE N
      -- jeśli nie przenosimy usług na dokumet magazynowy (parametr z konfiguracji), to kasujemy je z zestawu elementów do skopiowania
      IF CONVERT( INT, @TrN_Rodzaj_Doc/1000) IN (306, 307 )
      AND ( SELECT TOP 1 CONVERT ( INT, ISNULL(SUBSTRING(MAX(Fir_Wartosc),1,1),0 ) )
       FROM cdn.Firma
         JOIN cdn.TraNag ON TrN_TrNId in (select TrNId from @TrNID )
       WHERE Fir_Numer =
        CASE
        WHEN TrN_TypDokumentu IN ( 302, 305, 320 ) THEN 1576  -- przenoś usługi na WZ
        WHEN TrN_TypDokumentu IN ( 301 )      THEN 1577  -- przenoś usługi na PZ
        END
      ) = 0
      DELETE FROM @TrE_TrEId_Do_Dodania WHERE Twr_Typ = 0 and @TrN_Rodzaj_Doc != 306008
      DELETE FROM @TrE_TrEId_Do_Dodania WHERE (TrE_Ilosc<=0 and TrE_IloscJM<=0)
                  IF NOT EXISTS(SELECT * FROM @TrE_TrEId_Do_Dodania)
                BEGIN
                  RAISERROR('##OPT34475##', 16, 1)
                  rollback
                  SET NOCOUNT OFF
                  RETURN
             END
      END
   if @TrN_Rodzaj_Doc = 306008
   begin
      CREATE TABLE  #Wydane(treid INT, Ilosc DECIMAL(15,4) )
      CREATE TABLE  #Zagregowane(treid INT, Ilosc DECIMAL(15,4), TwrId int,MagId int,TwrNazwa nvarchar(255),
      KatID int,Jm nvarchar(20),JMPrzelicznikL decimal(15, 2),JMPrzelicznikM decimal(7, 0) ,
      TwrOpis nvarchar(1024),Cena0WD decimal(17, 4),CenaWWD decimal(17, 4),Stawka decimal(5, 2), Flaga smallint ,Zrodlowa decimal(5, 2) ,
        CenaZCzteremaMiejscami smallint
       )
       insert into #Wydane(treid , Ilosc )
       SELECT TrS_TrEID,ABS(ISNULL(sum(TrS_Ilosc),0)) FROM CDN.TraElem Join CDN.TraSElem ON TrS_TrEID = TrE_TrEId WHERE TrE_TrEId in (select tre_treid FROM @TrE_TrEId_Do_Dodania)
       AND TRS_TrEIdWydania <>0  GROUP BY TrS_TrEID
        UPDATE B SET B.TrE_Ilosc = B.TrE_Ilosc - Ilosc, B.TrE_IloscJM = B.TrE_IloscJM - ROUND(Ilosc*A.TrE_JMPrzelicznikM/A.TrE_JMPrzelicznikL,4)
                  FROM @TrE_TrEId_Do_Dodania B
                  JOIN  Cdn.TraElem A ON B.TrE_TrEId = A.TrE_TrEId
                  JOIN  #Wydane ON B.TrE_TrEId =treid
         IF EXISTS(SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=2071 and Fir_Wartosc = '1')
      BEGIN
   insert into #Zagregowane(treid, Ilosc, TwrId, MagId, TwrNazwa,
   KatID, Jm, JMPrzelicznikL, JMPrzelicznikM,
   TwrOpis ,Cena0WD ,CenaWWD ,Stawka , Flaga  ,Zrodlowa  ,
   CenaZCzteremaMiejscami
   )
   select min(a.tre_treid),
    SUM(a.tre_ilosc) ,
    a.tre_twrid,
    a.TrE_MagId,
    a.TrE_TwrNazwa,
    a.TrE_KatID,
    a.TrE_JM,
    a.TrE_JMPrzelicznikL,
    a.TrE_JMPrzelicznikM,
    a.TrE_TwrOpis,
    a.TrE_Cena0WD,
    a.TrE_CenaWWD,
    a.TrE_Stawka,
    a.TrE_Flaga,
    a.TrE_Zrodlowa,
    a.TrE_CenaZCzteremaMiejscami
   from
   (
    select
     b.tre_treid,
     b.tre_ilosc ,
     a.tre_twrid,
     a.TrE_MagId,
     a.TrE_TwrNazwa,
     a.TrE_KatID,
     a.TrE_JM,
     a.TrE_JMPrzelicznikL,
     a.TrE_JMPrzelicznikM,
     a.TrE_TwrOpis,
     a.TrE_Cena0WD,
     a.TrE_CenaWWD,
     a.TrE_Stawka,
     a.TrE_Flaga,
     a.TrE_Zrodlowa,
     a.TrE_CenaZCzteremaMiejscami,
     (select TrA_DeAId,TrA_Wartosc from CDN.TraElemAtr  where TrA_TrEId = b.tre_treid order by TrA_DeAId,TrA_Wartosc FOR XML PATH('ATR') ) as  x
    from @TrE_TrEId_Do_Dodania B
    JOIN  Cdn.TraElem A ON B.TrE_TrEId = A.TrE_TrEId and A.TrE_ZTwID = 0) a
    group by
     a.tre_twrid,
     a.TrE_MagId,
     a.TrE_TwrNazwa,
     a.TrE_KatID,
     a.TrE_JM,
     a.TrE_JMPrzelicznikL,
     a.TrE_JMPrzelicznikM,
     a.TrE_TwrOpis,
     a.TrE_Cena0WD,
     a.TrE_CenaWWD,
     a.TrE_Stawka,
     a.TrE_Flaga,
     a.TrE_Zrodlowa,
     a.x,
     a.Tre_CenaZCzteremaMiejscami
   insert into #Zagregowane(treid , Ilosc , TwrId ,MagId ,TwrNazwa ,
   KatID ,Jm ,JMPrzelicznikL ,JMPrzelicznikM  ,
   TwrOpis ,Cena0WD ,CenaWWD ,Stawka , Flaga  ,Zrodlowa  ,
   CenaZCzteremaMiejscami
   )
   select b.tre_treid,b. tre_ilosc ,
   a.tre_twrid,
   a.TrE_MagId,
   a.TrE_TwrNazwa,
   a.TrE_KatID,
   a.TrE_JM,
   a.TrE_JMPrzelicznikL,
   a.TrE_JMPrzelicznikM,
   a.TrE_TwrOpis,
   a.TrE_Cena0WD,
   a.TrE_CenaWWD,
   a.TrE_Stawka,
   a.TrE_Flaga,
   a.TrE_Zrodlowa,
   a.Tre_CenaZCzteremaMiejscami
   from @TrE_TrEId_Do_Dodania B
   JOIN  Cdn.TraElem A ON B.TrE_TrEId = A.TrE_TrEId and A.TrE_ZTwID != 0
   update b set TrEIDZintegr = treid  from @TrE_TrEId_Do_Dodania B
   JOIN  Cdn.TraElem A ON B.TrE_TrEId = A.TrE_TrEId
   join #Zagregowane on
   TwrId = a.tre_twrid and
   MagId = a.TrE_MagId and
   TwrNazwa = a.TrE_TwrNazwa and
   ISNULL(KatID,0) = ISNULL(a.TrE_KatID,0) and
   Jm  = a.TrE_JM and
   JMPrzelicznikL  =  a.TrE_JMPrzelicznikL and
   JMPrzelicznikM   = a.TrE_JMPrzelicznikM and
   TwrOpis  = a.TrE_TwrOpis and
   Cena0WD  = a.TrE_Cena0WD and
   CenaWWD  = a.TrE_CenaWWD and
   Stawka  = a.TrE_Stawka and
   Flaga   = a.TrE_Flaga and
   Zrodlowa   = a.TrE_Zrodlowa and
   not exists(
   select TrA_DeAId,TrA_Wartosc from CDN.TraElemAtr where TrA_TrEId = treid
   EXCEPT
   select TrA_DeAId,TrA_Wartosc from CDN.TraElemAtr where TrA_TrEId = B.TrE_TrEId
   union all
   select TrA_DeAId,TrA_Wartosc from CDN.TraElemAtr where TrA_TrEId = B.TrE_TrEId
   EXCEPT
   select TrA_DeAId,TrA_Wartosc from CDN.TraElemAtr where TrA_TrEId = treid
   )
   and CenaZCzteremaMiejscami = a.Tre_CenaZCzteremaMiejscami
   and A.TrE_ZTwID = 0
   update b set TrEIDZintegr = B.TrE_TrEId  from @TrE_TrEId_Do_Dodania B
   JOIN  Cdn.TraElem A ON B.TrE_TrEId = A.TrE_TrEId
   and A.TrE_ZTwID != 0
   update B set DoUsuniecia = 1 from @TrE_TrEId_Do_Dodania B  where TrE_TrEId not in (select treid from #Zagregowane )
   UPDATE B SET B.TrE_Ilosc = Ilosc, B.TrE_IloscJM =  case when B.TrE_Ilosc = Ilosc then B.TrE_IloscJM else   ROUND(Ilosc*A.TrE_JMPrzelicznikM/A.TrE_JMPrzelicznikL,4) end
              FROM @TrE_TrEId_Do_Dodania B
              JOIN  Cdn.TraElem A ON B.TrE_TrEId = A.TrE_TrEId
              JOIN  #Zagregowane ON B.TrE_TrEId =treid
      end
  else
   begin
   update b set TrEIDZintegr = TrE_TrEId from @TrE_TrEId_Do_Dodania B
   end
      CREATE TABLE #TrELppow(TrE_TrEId_Old INT, TrE_Lp_New INT IDENTITY ( 1,1 ) )
        INSERT INTO #TrELppow ( TrE_TrEId_Old )
         SELECT TrE_TrEId FROM @TrE_TrEId_Do_Dodania WHERE DoUsuniecia = 0
            ORDER BY TrE_TrEId
         UPDATE @TrE_TrEId_Do_Dodania SET LpPowNew = TrE_Lp_New
           FROM @TrE_TrEId_Do_Dodania JOIN #TrELppow ON TrE_TrEId_Old = TrEIDZintegr
         DROP TABLE #TrELppow
         CREATE TABLE #TrEZestawWiazanie(TrE_ZestawWiazanieOld INT,TrNID INT, ZestawWiazanieNew INT IDENTITY ( 1,1 ) )
        INSERT INTO #TrEZestawWiazanie ( TrE_ZestawWiazanieOld,TrNID )
         SELECT distinct ZestawWiazanie,TrE_TrNID FROM @TrE_TrEId_Do_Dodania where ZestawWiazanie>0
         UPDATE @TrE_TrEId_Do_Dodania SET ZestawWiazanie = ZestawWiazanieNew
           FROM @TrE_TrEId_Do_Dodania JOIN #TrEZestawWiazanie ON TrE_ZestawWiazanieOld  = ZestawWiazanie AND TrE_TrNID = TrNID
         DROP TABLE #TrEZestawWiazanie
         IF EXISTS(SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=1776 and Fir_Wartosc = '1' and @TrN_Rodzaj_Doc = 306008)
         BEGIN
   SELECT
    @TrN_MagZrdId       = TrN_MagZrdId,
    @TrN_KursL          = TrN_KursL,
    @TrN_KursM          = TrN_KursM,
    @TrN_KursM          = TrN_KursM,
    @TrN_Waluta         = ISNULL(TrN_Waluta,''),
    @TrN_PlatElemWalSys = TrN_PlatElemWalSys
    FROM cdn.TraNag
    WHERE TrN_TrNId in (select TrNId from @TrNID )
    CREATE TABLE  #TwrIlosci1(TwI_TwrId INT, TwI_Ilosc DECIMAL(15,4))
    IF EXISTS(SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=1536 and Fir_Wartosc = '1' and @TrN_Rodzaj_Doc = 306008)
    and EXISTS(SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=1970 and Fir_Wartosc = '0' and @TrN_Rodzaj_Doc = 306008)
     INSERT INTO #TwrIlosci1 SELECT TwI_TwrId, TwI_Ilosc - TwI_Rezerwacje+ TrE_Ilosc  FROM @TrE_TrEId_Do_Dodania
     LEFT OUTER JOIN cdn.TwrIlosci I ON TrE_TwrId = I.TwI_TwrId AND I.TwI_MagId = @TrE_MagId
     AND I.TwI_Data = (SELECT TOP 1 H.TwI_Data FROM CDN.TwrIlosci H WHERE H.TwI_TwrId = Tre_TwrId AND H.TwI_MagId = @TrE_MagId
     AND H.TwI_Data <=@TrN_DataDok_Doc ORDER BY H.TwI_Data DESC ) where DoUsuniecia = 0
    else
     INSERT INTO #TwrIlosci1 SELECT TwI_TwrId, TwI_Ilosc  FROM @TrE_TrEId_Do_Dodania
     LEFT OUTER JOIN cdn.TwrIlosci I ON TrE_TwrId = I.TwI_TwrId AND I.TwI_MagId = @TrE_MagId
     AND I.TwI_Data = (SELECT TOP 1 H.TwI_Data FROM CDN.TwrIlosci H WHERE H.TwI_TwrId = Tre_TwrId AND H.TwI_MagId = @TrE_MagId
     AND H.TwI_Data <=@TrN_DataDok_Doc ORDER BY H.TwI_Data DESC ) where DoUsuniecia = 0
       DECLARE
     @TrE_TrEId1   INT,
     @TrE_TwrId1   INT,
     @Twr_Typ1     INT,
     @TrE_Ilosc1   DECIMAL(15,4),
     @TwI_Ilosc1   DECIMAL(15,4),
     @KGO1         DECIMAL(15,4),
     @Roznica1     DECIMAL(15,4),
     @TrE_IloscJM1 DECIMAL(15,4),
     @ZestawWiazanie INT
      CREATE TABLE #UsuwaneZestawy(ZestawWiazanie INT)
       DECLARE N CURSOR LOCAL FAST_FORWARD FOR
       SELECT TrE_TrEId, TrE_TwrId, Twr_Typ,  TrE_Ilosc, TrE_IloscJM, Twr_KosztKGO, ZestawWiazanie FROM @TrE_TrEId_Do_Dodania where DoUsuniecia = 0 order by TrE_TrEId
         OPEN N
          WHILE 1=1
        BEGIN
         FETCH NEXT FROM N INTO @TrE_TrEId1,  @TrE_TwrId1, @Twr_Typ1,@TrE_Ilosc1, @TrE_IloscJM1, @KGO1 ,@ZestawWiazanie
         IF @@FETCH_STATUS <> 0 BREAK
          IF @Twr_Typ1<>0 and @ZestawWiazanie not in (select * from #UsuwaneZestawy)
            BEGIN
            SELECT @Roznica1= NULL , @TwI_Ilosc1=NULL
            SELECT @TwI_Ilosc1 = TwI_Ilosc, @Roznica1 = TwI_Ilosc-@TrE_Ilosc1 FROM  #TwrIlosci1 WHERE TwI_TwrId = @TrE_TwrId1
            IF @Roznica1>0
            UPDATE #TwrIlosci1 SET TwI_Ilosc = TwI_Ilosc - @TrE_Ilosc1 WHERE TwI_TwrId = @TrE_TwrId1
            ELSE
            BEGIN
            if @ZestawWiazanie > 0 and @Roznica1<0
             begin
             UPDATE #TwrIlosci1 SET TwI_Ilosc = TwI_Ilosc +  a.ilosc from #TwrIlosci1 join(
             SELECT sum(B.TrE_Ilosc) as ilosc ,B.TrE_TwrId as twrid FROM @TrE_TrEId_Do_Dodania B
             where DoUsuniecia = 0 and b.tre_treid < @TrE_TrEId1 and B.ZestawWiazanie = @ZestawWiazanie
             group by B.TrE_TwrId) a on a.twrid = TwI_TwrId
             delete from
             @TrE_TrEId_Do_Dodania
             WHERE ZestawWiazanie = @ZestawWiazanie
             insert into #UsuwaneZestawy select @ZestawWiazanie
            end
            else
            begin
             UPDATE #TwrIlosci1 SET TwI_Ilosc = 0 WHERE TwI_TwrId = @TrE_TwrId1
             UPDATE @TrE_TrEId_Do_Dodania SET TrE_Ilosc = ISNULL(@TwI_Ilosc1,0), TrE_IloscJM =ISNULL(@TwI_Ilosc1*A.TrE_JMPrzelicznikM/A.TrE_JMPrzelicznikL,0)
             FROM @TrE_TrEId_Do_Dodania B
             JOIN  Cdn.TraElem A ON @TrE_TrEId1 = A.TrE_TrEId
             WHERE B.TrE_TrEId = @TrE_TrEId1
            end
            END
          END
         END
         CLOSE N
         DEALLOCATE N
   END
   -- jeśli nie przenosimy usług na dokumet magazynowy (parametr z konfiguracji), to kasujemy je z zestawu elementów do skopiowania
   delete FROM @TrE_TrEId_Do_Dodania WHERE TrEIDZintegr in(
   select TrEIDZintegr from @TrE_TrEId_Do_Dodania WHERE TrE_Ilosc<=0 and TrE_IloscJM<=0 and DoUsuniecia = 0 )
   IF NOT EXISTS(SELECT * FROM @TrE_TrEId_Do_Dodania)
   BEGIN
    SET NOCOUNT OFF
    RETURN
   END
      END
      IF @TrN_Rodzaj_Doc in (306010,306008) AND ( @TrN_KursL is NULL or @TrN_KursM is NULL or @TrN_PlatElemWalSys is NULL)
        SELECT
         @TrN_MagZrdId       = TrN_MagZrdId,
            @TrN_KursL          = TrN_KursL,
            @TrN_KursM          = TrN_KursM,
   @TrN_Waluta         = ISNULL(TrN_Waluta,''),
            @TrN_PlatElemWalSys = TrN_PlatElemWalSys
         FROM cdn.TraNag
         WHERE TrN_TrNId in (select TrNId from @TrNID )
      declare @roznekursy int = 0
      IF @TrN_Rodzaj_Doc in (306008)
         if exists (SELECT *
         FROM cdn.TraNag
         WHERE TrN_TrNId = @TrN_TrNId_Doc
         and (@TrN_KursL!= TrN_KursL or TrN_KursM != @TrN_KursM))
         set @roznekursy = 1
         SELECT
            @TrN_KursL          = TrN_KursL,
            @TrN_KursM          = TrN_KursM,
            @TrN_Waluta         = ISNULL(TrN_Waluta,'')
         FROM cdn.TraNag
         WHERE TrN_TrNId = @TrN_TrNId_Doc
      IF @TrN_Waluta = '   ' SET @TrN_Waluta = 'PLN'
      INSERT INTO cdn.TraElem
        (
          TrE_TrNId,
          TrE_ZwrId,
          TrE_TrEIdProd,
          TrE_PdRId,
          TrE_Lp,
          TrE_LpPow,
          TrE_TypDokumentu,
          TrE_Aktywny,
          TrE_DataDok,
          TrE_DataOpe,
          TrE_PodmiotTyp,
          TrE_PodID,
          TrE_KatID,
          TrE_TwrId,
          TrE_TwrNazwa,
          TrE_TwrEAN,
    TrE_TwrTyp ,
    TrE_TwrKodDostawcy,
          TrE_TwrNumerKat,
          TrE_TwrKod,
          TrE_TwrOpis,
          TrE_TwrSWW,
          TrE_Stawka,
          TrE_Flaga,
          TrE_Zrodlowa,
          TrE_TwCNumer,
          TrE_TypNB,
          TrE_Cena0,
          TrE_Rabat,
          TrE_CenaW,
          TrE_Waluta,
          TrE_KursNumer,
          TrE_KursL,
          TrE_KursM,
          TrE_CenaT,
          TrE_Ilosc,
          TrE_Jm,
          TrE_JmZ,
          TrE_JmCalkowite,
          TrE_JMPrzelicznikL,
          TrE_JMPrzelicznikM,
          TrE_IloscJM,
          TrE_WartoscNetto,
          TrE_WartoscBrutto,
          TrE_KosztUslugi,
          TrE_WartoscZakupuWylicz,
          TrE_Cena0WD,
          TrE_CenaWWD,
          TrE_WartoscNettoWal,
          TrE_WartoscBruttoWal,
          TrE_Prog,
          TrE_UpustTyp,
          TrE_Upust,
          TrE_UpustKnt,
          TrE_UpustKntTyp,
          TrE_Kaucja,
          TrE_IloscJMKW,
          TrE_IloscKW,
          TrE_Atr1_DeAId,
          TrE_Atr1_Kod,
          TrE_Atr1_Wartosc,
          TrE_Atr2_DeAId,
          TrE_Atr2_Kod,
          TrE_Atr2_Wartosc,
          TrE_Atr3_DeAId,
          TrE_Atr3_Kod,
          TrE_Atr3_Wartosc,
          TrE_Atr4_DeAId,
          TrE_Atr4_Kod,
          TrE_Atr4_Wartosc,
          TrE_Atr5_DeAId,
          TrE_Atr5_Kod,
          TrE_Atr5_Wartosc,
          TrE_Akcyza_DeAId,
          TrE_Akcyza_Kod,
          TrE_Akcyza_Wartosc,
          TrE_MagId,
          TrE_WyborDostaw,
          TrE_KosztKGO,
          TrE_kodCN,
          TrE_AkcyzaOpal,
          TrE_AkcyzaStawka,
          Tre_AkcyzaJMPomPrzelicznikL,
          Tre_AkcyzaJMPomPrzelicznikM,
    TrE_SJRodzajPaliwa,
    TrE_SJSystemCertyfikacji,
    TrE_SJPopiol,
    TrE_SJCzesciLotne,
    TrE_SJWartoscOpalowa,
    TrE_SJZdolnoscSpiekania ,
    TrE_SJWymiarZiarna ,
    TrE_SJZawartoscPodziarna ,
    TrE_SJZawartoscNadziarna ,
    TrE_SJZawartoscWilgoci ,
          TrE_ZTwID,
          TrE_ZTwGlowny,
          TrE_ZestawWiazanie,
          TrE_zTwKod,
    TrE_zTwIlosc,
    Tre_OdwrotneObciazenie,
    TrE_CenaZCzteremaMiejscami,
    TrE_SplitPay
        )
        SELECT
         @TrN_TrNId_Doc,
          B.TrE_ZwrId,
          B.TrE_TrEIdProd,
          B.TrE_PdRId,
          B.TrE_Lp,
          case when @TrN_Rodzaj_Doc =306008 then  a.LpPowNew else B.TrE_LpPow end,
          CONVERT(INT, @TrN_Rodzaj_Doc/1000),     -- TrE_TypDokumentu
          1,                                      -- TrE_Aktywny,
         @TrN_DataDok_Doc,
         @TrN_DataOpe_Doc,
          B.TrE_PodmiotTyp,
          B.TrE_PodID,
          B.TrE_KatID,
          B.TrE_TwrId,
          B.TrE_TwrNazwa,
          B.TrE_TwrEAN,
    B.TrE_TwrTyp ,
    B.TrE_TwrKodDostawcy,
          B.TrE_TwrNumerKat,
          B.TrE_TwrKod,
          B.TrE_TwrOpis,
          B.TrE_TwrSWW,
          B.TrE_Stawka,
          B.TrE_Flaga,
          B.TrE_Zrodlowa,
          B.TrE_TwCNumer,
          B.TrE_TypNB,
          case when @TrN_Rodzaj_Doc =306008 and @TrN_Waluta != TrE_Waluta then round(B.TrE_Cena0WD * TrE_KursM/TrE_KursL * @TrN_KursL / @TrN_KursM, case when B.Tre_CenaZCzteremaMiejscami = 1 then 4 else 2 end) else  B.TrE_Cena0 end,
          B.TrE_Rabat,
          case when @TrN_Rodzaj_Doc =306008 and @TrN_Waluta != TrE_Waluta then round( B.TrE_CenaWWD * @TrN_KursL / @TrN_KursM * TrE_KursM / TrE_KursL , case when B.Tre_CenaZCzteremaMiejscami = 1 then 4 else 2 end)  else  B.TrE_CenaW end,
          B.TrE_Waluta,
          B.TrE_KursNumer,
          B.TrE_KursL,
          B.TrE_KursM,
          case when @TrN_Rodzaj_Doc =306008 then round( B.TrE_CenaWWD * @TrN_KursL / @TrN_KursM  , case when B.Tre_CenaZCzteremaMiejscami = 1 then 4 else 2 end)  else B.TrE_CenaT end,
          A.TrE_Ilosc,
          B.TrE_Jm,
          B.TrE_JmZ,
          B.TrE_JmCalkowite,
          B.TrE_JMPrzelicznikL,
          B.TrE_JMPrzelicznikM,
          A.TrE_IloscJM,
          case when @TrN_Rodzaj_Doc in (306010,306008) and (A.TrE_IloscJM != B.TrE_IloscJM or @roznekursy =1) then
               case when B.TrE_TypNB=1 then
                    case when @TrN_PlatElemWalSys=1
                         then ROUND(A.TrE_IloscJM * B.TrE_CenaT,2)
                         else ROUND(ROUND (A.TrE_IloscJM * B.TrE_CenaWWD,2) * @TrN_KursL / @TrN_KursM , 2)
                    end
               else
                    case when @TrN_PlatElemWalSys=1
                         then ROUND(A.TrE_IloscJM * B.TrE_CenaT,2) - ROUND ( ROUND(A.TrE_IloscJM * B.TrE_CenaT,2) *  B.TrE_Stawka / (100 + B.TrE_Stawka) , 2 )
                         else ROUND(ROUND (A.TrE_IloscJM * B.TrE_CenaWWD,2) * @TrN_KursL / @TrN_KursM , 2)- ROUND ( ROUND(ROUND (A.TrE_IloscJM * B.TrE_CenaWWD,2) * @TrN_KursL / @TrN_KursM , 2) *  B.TrE_Stawka / (100 + B.TrE_Stawka) , 2 )
                    end
               end
          else
             B.TrE_WartoscNetto
          end,
          case when @TrN_Rodzaj_Doc in (306010,306008) and (A.TrE_IloscJM != B.TrE_IloscJM or @roznekursy =1) then
               case when B.TrE_TypNB=2
                    then
                        case when @TrN_PlatElemWalSys=1
                             then ROUND(A.TrE_IloscJM * B.TrE_CenaT,2)
                             else ROUND(ROUND (A.TrE_IloscJM * B.TrE_CenaWWD,2) * @TrN_KursL / @TrN_KursM , 2)
                             end
                        else
                             case when @TrN_PlatElemWalSys=1
                                  then ROUND(ROUND(A.TrE_IloscJM * B.TrE_CenaT,2)* (100 + B.TrE_Stawka )/100, 2)
                                  else ROUND(ROUND(ROUND (A.TrE_IloscJM * B.TrE_CenaWWD,2) * @TrN_KursL / @TrN_KursM , 2)* (100 + B.TrE_Stawka )/100, 2)
                        end
              end
          else
             B.TrE_WartoscBrutto
          end,
          B.TrE_KosztUslugi*A.TrE_IloscJM/B.TrE_IloscJM,
          0,
          B.TrE_Cena0WD,
          B.TrE_CenaWWD,
          case when @TrN_Rodzaj_Doc in (306010,306008) and (A.TrE_IloscJM != B.TrE_IloscJM) then
                    case when B.TrE_TypNB=1
                         then ROUND (A.TrE_IloscJM * B.TrE_CenaWWD,2)
                         else ROUND (A.TrE_IloscJM * B.TrE_CenaWWD,2) - ROUND ( ROUND (A.TrE_IloscJM * B.TrE_CenaWWD,2) *  B.TrE_Stawka / (100 + B.TrE_Stawka) , 2 )
                    end
          else
             B.TrE_WartoscNettoWal
          end,
          case when @TrN_Rodzaj_Doc in (306010,306008) and (A.TrE_IloscJM != B.TrE_IloscJM) then
                    case when TrE_TypNB=2
                         then ROUND (A.TrE_IloscJM * B.TrE_CenaWWD,2)
                         else ROUND(ROUND (A.TrE_IloscJM * B.TrE_CenaWWD,2) * (100 + B.TrE_Stawka )/100, 2)
                    end
          else
             B.TrE_WartoscBruttoWal
          end,
          B.TrE_Prog,
          B.TrE_UpustTyp,
          B.TrE_Upust,
          B.TrE_UpustKnt,
          B.TrE_UpustKntTyp,
          0,                                       -- TrE_Kaucja
          case when @TrN_Rodzaj_Doc in (306010,306008) then A.TrE_IloscJM else B.TrE_IloscJMKW end,
          case when @TrN_Rodzaj_Doc in (306010,306008) then A.TrE_Ilosc else B.TrE_IloscKW end,
          B.TrE_Atr1_DeAId,
          B.TrE_Atr1_Kod,
          B.TrE_Atr1_Wartosc,
          B.TrE_Atr2_DeAId,
          B.TrE_Atr2_Kod,
          B.TrE_Atr2_Wartosc,
          B.TrE_Atr3_DeAId,
          B.TrE_Atr3_Kod,
          B.TrE_Atr3_Wartosc,
          B.TrE_Atr4_DeAId,
          B.TrE_Atr4_Kod,
          B.TrE_Atr4_Wartosc,
          B.TrE_Atr5_DeAId,
          B.TrE_Atr5_Kod,
          B.TrE_Atr5_Wartosc,
          B.TrE_Akcyza_DeAId,
          B.TrE_Akcyza_Kod,
          B.TrE_Akcyza_Wartosc,
          B.TrE_MagId,
          B.TrE_WyborDostaw,
          case when @TrN_Rodzaj_Doc in (306010,306008)
          then
             case when B.TrE_TypNB = 2 then (Twr_KosztKGO  +  ( Twr_KosztKGO * ( B.TrE_Stawka / 100 ))) else Twr_KosztKGO end
          else
             case when CONVERT( INT, @TrN_Rodzaj_Doc/1000) IN (306, 307 ) then B.TrE_KosztKGO else 0 end
          end,
          B.TrE_kodCN,
          B.TrE_AkcyzaOpal,
          B.TrE_AkcyzaStawka,
          B.Tre_AkcyzaJMPomPrzelicznikL,
          B.Tre_AkcyzaJMPomPrzelicznikM,
          B.Tre_SJRodzajPaliwa,
          B.Tre_SJSystemCertyfikacji,
          B.Tre_SJPopiol,
          B.Tre_SJCzesciLotne,
          B.Tre_SJWartoscOpalowa,
          B.Tre_SJZdolnoscSpiekania,
          B.Tre_SJWymiarZiarna,
          B.Tre_SJZawartoscPodziarna,
          B.Tre_SJZawartoscNadziarna,
          B.Tre_SJZawartoscWilgoci,
          B.TrE_ZTwID,
          B.TrE_ZTwGlowny,
          ZestawWiazanie,
          B.TrE_ZTwKod,
    B.TrE_zTwIlosc,
    case when @TrN_Rodzaj_Doc in (306010,306008) then Twr_OdwrotneObciazenie else B.Tre_OdwrotneObciazenie end,
    B.TrE_CenaZCzteremaMiejscami,
    B.TrE_SplitPay
        FROM cdn.TraElem B
        JOIN @TrE_TrEId_Do_Dodania A ON  A.TrE_TrEId = B.TrE_TrEId
  where a.DoUsuniecia = 0
  order by A.TrE_TrEId
        --WHERE TrE_TrEId IN ( SELECT TrE_TrEId FROM @TrE_TrEId_Do_Dodania )
  --rt nowe atr
  if @TrN_Rodzaj_Doc = 306008
  begin
   INSERT INTO [CDN].[TraElemAtr]
    ([TrA_TrEId]
    ,[TrA_Lp]
    ,[TrA_DeAId]
    ,[TrA_Kod]
    ,[TrA_Wartosc]
    ,[TrA_ESklep])
   select
    B.tre_treid,
    TrA_Lp,
    TrA_DeAId,
    TrA_Kod,
    TrA_Wartosc,
    TrA_ESklep
   FROM cdn.TraElemAtr
   JOIN @TrE_TrEId_Do_Dodania A ON  TrA_TrEId = a.TrE_TrEID
   left join cdn.traelem B on B.TrE_LpPow = a.LpPowNew
   where  B.TrE_TrNId = @TrN_TrNId_Doc  and A.DoUsuniecia = 0
   -- renumeracja Lp na dokumencie wynikowym
   CREATE TABLE #TrELp(TrE_TrEId_Old INT, TrE_Lp_New INT IDENTITY ( 1,1 ) )
   INSERT INTO #TrELp ( TrE_TrEId_Old )
            SELECT A.TrE_TrEId FROM cdn.TraElem A
   JOIN @TrE_TrEId_Do_Dodania B ON a.TrE_LpPow = b.LpPowNew
   WHERE A.TrE_TrNId = @TrN_TrNId_Doc
            ORDER BY  B.TrE_TrNId,A.TrE_Lp,A.TrE_TrEId
   UPDATE cdn.TraElem SET TrE_Lp = TrE_Lp_New
   FROM cdn.TraElem JOIN #TrELp ON TrE_TrEId_Old = TrE_TrEId
   DROP TABLE #TrELp
  end
  else
   INSERT INTO [CDN].[TraElemAtr]
    ([TrA_TrEId]
    ,[TrA_Lp]
    ,[TrA_DeAId]
    ,[TrA_Kod]
    ,[TrA_Wartosc]
    ,[TrA_ESklep])
   select
    B.tre_treid,
    TrA_Lp,
    TrA_DeAId,
    TrA_Kod,
    TrA_Wartosc,
    TrA_ESklep
   FROM cdn.TraElemAtr
   JOIN @TrE_TrEId_Do_Dodania A ON  TrA_TrEId = a.TrE_TrEID
   left join cdn.traelem B on B.TrE_LpPow = a.TrE_LpPow
   where  B.TrE_TrNId = @TrN_TrNId_Doc
  END
  -- poprawiamy dostawy trzeba podmienic treid z FA/FZ na WZ/PZ
  UPDATE CDN.TraSElemDost SET TsD_TreId = B.TrE_TrEID FROM CDN.TraSElemDost
    JOIN CDN.TraElem A ON TsD_TrEId = A.TrE_TrEID
    JOIN CDN.TraElem B ON B.TrE_TrNID = @TrN_TrNId_Doc AND A.TrE_Lppow = B.TrE_LpPow
   WHERE A.TrE_TrEID IN ( SELECT TrE_TrEId FROM @TrE_TrEId_Do_Dodania )
  UPDATE CDN.TraSElemDost SET TsD_TreId = B.TrE_TrEID FROM CDN.TraSElemDost
    JOIN CDN.TraElem A ON TsD_TrEId = A.TrE_TrEID
    JOIN CDN.TraNagRelacje ON TrR_FaID = A.TrE_TrnId  AND TrR_TrnID = @TrN_TrNId_Zrd AND TrR_FaTyp = 305 AND TrR_TrNTyp = 302
    JOIN CDN.TraElem B ON B.TrE_TrNID = @TrN_TrNId_Doc AND A.TrE_Lppow = B.TrE_LpPow
  UPDATE CDN.TraSElemDost SET TsD_TreId = B.TrE_TrEID FROM CDN.TraSElemDost
    JOIN CDN.TraElem A ON TsD_TrEId = A.TrE_TrEID
    JOIN CDN.TraNagRelacje ON TrR_FaID = A.TrE_TrnId  AND TrR_TrnID = @TrN_TrNId_Zrd AND TrR_TrNTyp = 305 AND TrR_FATyp = 302
    JOIN CDN.TraElem B ON B.TrE_TrNID = @TrN_TrNId_Doc AND A.TrE_Lppow = B.TrE_LpPow
  -- poprawiamy relacje elementowe miedzy RO/ZD a FA/FZ
  UPDATE CDN.TraSElem SET TrS_TrEIdWydania = B.TrE_TrEID FROM CDN.TraSElem
    JOIN CDN.TraElem A ON TrS_TrEIdWydania = A.TrE_TrEID
    JOIN CDN.TraElem B ON B.TrE_TrNID = @TrN_TrNId_Doc AND A.TrE_Lppow = B.TrE_LpPow
   WHERE A.TrE_TrEID IN ( SELECT TrE_TrEId FROM @TrE_TrEId_Do_Dodania ) AND B.TrE_TypDokumentu IN (306,307) AND A.TrE_TypDokumentu IN (301,302,305)
  UPDATE CDN.TraElemRelacje SET TeR_ChildId = B.TrE_TrEID, TeR_ChildTyp =B.TrE_TypDokumentu FROM CDN.TraElemRelacje
    JOIN CDN.TraElem A ON TeR_ChildId = A.TrE_TrEID
    JOIN CDN.TraElem B ON B.TrE_TrNID = @TrN_TrNId_Doc AND A.TrE_Lppow = B.TrE_LpPow
   WHERE A.TrE_TrEID IN ( SELECT TrE_TrEId FROM @TrE_TrEId_Do_Dodania ) AND B.TrE_TypDokumentu IN (306,307) AND A.TrE_TypDokumentu IN (301,302,305) AND TeR_ParentTyp <> 320 AND TeR_ParentTyp NOT IN (901,902)
  /*if exists(
      select a.Trr_TrNId from cdn.tranagrelacje a
      where a.TrR_FaId =@TrN_TrNId_Zrd AND a.Trr_TrNTyp =308 AND a.Trr_FaTyp =320)*/
  UPDATE A SET A.TrE_Lppow = A.TrE_Lppow FROM CDN.TraElem A
    JOIN CDN.TraElem B ON B.TrE_TrNID = @TrN_TrNId_Doc AND A.TrE_Lppow = B.TrE_LpPow
   WHERE A.TrE_TrEID IN ( SELECT TrE_TrEId FROM @TrE_TrEId_Do_Dodania ) AND B.TrE_TypDokumentu = 306 AND A.TrE_TypDokumentu = 320
     if @TrN_Rodzaj_Doc = 306008
   begin
     UPDATE A SET a.TrE_LppowRel = A.TrE_Lppow,A.TrE_Lppow = B.LpPowNew FROM CDN.TraElem A
    JOIN @TrE_TrEId_Do_Dodania B ON B.TrE_TreID = A.TrE_TrEID
   end
  SET NOCOUNT OFF
