CREATE PROCEDURE [CDN].[IGaleria_EksportPtw]
AS
DECLARE  @TypPtw_Knt SMALLINT
  ,@TypPtw_Zam SMALLINT
  ,@TypPtw_ZamStan SMALLINT
  ,@TypPtw_Twr SMALLINT
  ,@TypPtw_CrosSeling SMALLINT
  ,@TypPtw_NrListuPrzew SMALLINT
   ,@TypPtw_NrListuPrzewSendit SMALLINT
SELECT @TypPtw_Knt  = 1
      ,@TypPtw_Zam  = 2
   ,@TypPtw_ZamStan = 3
     ,@TypPtw_Twr  = 4
  ,@TypPtw_CrosSeling = 8
  ,@TypPtw_NrListuPrzew  = 3
  ,@TypPtw_NrListuPrzewSendit  = 61 -- sendit url
DECLARE
     @TSSynchr         nvarchar(254),
     @TSSynchrGrup     nvarchar(254),
     @TSSynchrGrupInt  INT,
     @TSSynchrTwr      nvarchar(254),
     @TSSynchrTwrDate  DATETIME,
     @DateTSSynchr     DATETIME,
     @TwGNumer         nvarchar(254),
     @TwGNumerInt      INT,
     @NrCeny           nvarchar(20),
     @NrCenyInt        INT,
     @EsklepCena0      nvarchar(254),
     @EsklepCena0Int   INT,
  @ESSID            int
 CREATE TABLE #TwrGrupyESklep (TwGID INT, Kod nvarchar(50), Nazwa nvarchar(255), Poziom INT, GIDNumer INT, GrONumer INT, GIDTyp SMALLINT,GrOTyp SMALLINT, CzasModyfikacji INT, eSklepLp INT, PRIMARY KEY(Poziom, GrONumer, GIDNumer, GIDTyp))
 select  top 1 @ESSID = ESS_ESSID, @TSSynchr = ESS_TS_SynchroPotw,@TSSynchrTwr = ESS_TS_SynchroTwrPotw, @TwGNumerInt = ESS_TwGNumer,
   @NrCenyInt = ESS_NrCeny,@EsklepCena0Int = ESS_EsklepCena0
 from cdn.eSklepStanowiska where ESS_typ = 2
 --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1930) SELECT @TSSynchr = 0 ELSE SELECT @TSSynchr = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1930
 SELECT @DateTSSynchr = dateadd( second, CONVERT(INT,@TSSynchr),CONVERT(DATETIME,'1990-01-01',120))
 --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1934) SELECT @TSSynchrTwr = 0 ELSE SELECT @TSSynchrTwr = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1934
 SELECT @TSSynchrTwrDate = dateadd( second, CONVERT(INT,@TSSynchrTwr),CONVERT(DATETIME,'1990-01-01',120))
 -- IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1900) SELECT @TwGNumer = 0 ELSE SELECT @TwGNumer = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1900
 --SELECT @TwGNumerInt = CONVERT(INT,@TwGNumer)
 --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1904) SELECT @NrCeny = 0 ELSE SELECT @NrCeny = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1904
 --SELECT @NrCenyInt = CONVERT(INT,@NrCeny)
 --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1905) SELECT @EsklepCena0= 0 ELSE SELECT @EsklepCena0 = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1905
 --SELECT @EsklepCena0Int = CONVERT(INT,@EsklepCena0)
 INSERT INTO  #TwrGrupyESklep
     SELECT * FROM CDN.TwrGrupyESklep (@TwGNumerInt)
-- Potwierdzenia kontrahentów
SELECT  1 AS Tag, NULL AS Parent,
   PTW.Typ  AS [PTW!1!Typ]
  ,PTW.ID   AS [PTW!1!ID]
  ,PTW.GIDTyp  AS [PTW!1!GIDTyp]
  ,PTW.GIDNumer AS [PTW!1!GIDNumer]
  ,PTW.Status  AS [PTW!1!Status]
  ,PTW.Data  AS [PTW!1!Data]
  ,PTW.Opis  AS [PTW!1!Opis]
  ,PTW.NrList  AS [PTW!1!NrList]
FROM
 (
      SELECT  @TypPtw_Knt  AS Typ
             ,Knt_GIDNumer AS ID
             ,32           AS GIDTyp
             ,Knt_KntId    AS GIDNumer
             ,0            AS Status
             ,''           AS Data
             ,''           AS Opis
    ,NULL           AS NrList
      FROM CDN.Kontrahenci  WITH(NOLOCK)
      WHERE Knt_GIDFirma = 1 AND Knt_GIDNumer>0 AND KnT_TS_MOD > @DateTSSynchr and Knt_eSklepID = @ESSID
      UNION ALL
      SELECT  @TypPtw_Zam
             ,TrN_GidNumer
             ,32
             ,TrN_TrNID
             ,0
             ,datediff(second,convert(DATETIME,'1990-01-01',120), TrN_DaTaWys)
             ,TrN_NumerPelny
    ,NULL
      FROM CDN.TraNag
      WHERE TrN_GIDNumer > 0 AND TrN_TS_MOD > @DateTSSynchr AND TrN_eSklepID = @ESSID
      UNION ALL
      SELECT  DISTINCT @TypPtw_ZamStan
             ,TrN_GidNumer
             ,32
             ,TrN_TrNID
             ,CASE WHEN TrN_Bufor = 1                          THEN 1   -- oczekuje na potwierdzenie
                   WHEN TrN_Bufor = 0 AND TrR_FAID is NULL AND ISNULL(TrN_Zwroconocalailosc,0) < 3     THEN 2  -- potwierdzone
                   WHEN TrN_Bufor = 0 AND TrR_FAID is NOT NULL AND ISNULL(TrN_Zwroconocalailosc,0) < 3 THEN 2  -- potwierdzone
                   WHEN TrN_Bufor = 0 AND TrR_FAID is NOT NULL AND ISNULL(TrN_Zwroconocalailosc,0) > 2 THEN 3  -- zrealizowane
                   WHEN TrN_Bufor = 0 AND TrR_FAID is NULL AND ISNULL(TrN_Zwroconocalailosc,0) = 4     THEN 3  -- zrealizowane
                   WHEN TrN_Bufor = -1                         THEN 4  -- anulowane
              END
             ,CASE WHEN TrN_Bufor = 1   THEN ''
                   WHEN TrN_Bufor = 0 AND TrR_FAID is NULL   THEN datediff(second,convert(DATETIME,'1990-01-01',120),TrN_TS_Mod)
                   WHEN TrN_Bufor = 0 AND TrR_FAID is NOT NULL THEN datediff(second,convert(DATETIME,'1990-01-01',120), TrN_TS_Mod)
                   WHEN TrN_Bufor = -1  THEN ''
              END
             ,''
    ,NULL
      FROM CDN.TraNag
      LEFT OUTER JOIN CDN.TraNagRelacje ON TrN_TrNId = TrR_TrNId AND TrR_FaTyp <> 309
      WHERE TrN_GIDNumer > 0 AND TrN_TS_Mod > @DateTSSynchr  AND TrN_eSklepID = @ESSID
UNION ALL
      SELECT DISTINCT @TypPtw_NrListuPrzew
              ,A.TrN_GidNumer AS ID
             ,32 AS GIDTyp
             ,A.TrN_TrNID AS GIDNumer
             ,NULL AS Status
             ,datediff(second,convert(DATETIME,'1990-01-01',120), A.TrN_DaTaWys) AS Data
    ,NULL  AS Opis
             ,A.TrN_NrListuPrzewozowego as NrList
      FROM CDN.TraNag A
      left JOIN CDN.TraNagRelacje RELWZ ON A.TrN_TrNID = RELWZ.TrR_TrNId AND RELWZ.TrR_TrNTyp = 308 AND RELWZ.TrR_FATyp in (306,302,305)
    left JOIN CDN.TraNag B ON RELWZ.TrR_FaId = B.TrN_TrNID
         left JOIN CDN.TraNagRelacje RELFS ON RELWZ.TrR_FAID = RELFS.TrR_TrNId AND RELFS.TrR_TrNTyp in (306,302,305) AND (RELFS.TrR_FATyp = 302 or RELFS.TrR_FATyp = 305 or RELFS.TrR_FATyp = 306)
         left JOIN CDN.TraNag c ON RELFS.TrR_FaId = c.TrN_TrNID
       WHERE A.TrN_GIDNumer > 0 AND A.TrN_eSklepID = @ESSID AND A.TrN_TS_Mod > @DateTSSynchr
   and not exists (select * from CDN.SenditZleceniePrzesylki where  SZL_FaId = A.TrN_TrNID and ISNULL(SZL_NrListuPrzewozowego,'') != '')
     and not exists (select * from CDN.SenditZleceniePrzesylki where  SZL_FaId = B.TrN_TrNID and ISNULL(SZL_NrListuPrzewozowego,'') != '')
    and not exists (select * from CDN.SenditZleceniePrzesylki where  SZL_FaId = C.TrN_TrNID and ISNULL(SZL_NrListuPrzewozowego,'') != '')
 and ((ISNULL(A.TrN_NrListuPrzewozowego,'')) != '' or (
 ISNULL(A.TrN_NrListuPrzewozowego,'') = ''
 and ISNULL(B.TrN_NrListuPrzewozowego,'') = ''
 and ISNULL(C.TrN_NrListuPrzewozowego,'') = ''
 ))
UNION
      SELECT DISTINCT @TypPtw_NrListuPrzew
            ,A.TrN_GidNumer
             ,32
             ,A.TrN_TrNID
             ,NULL
             ,datediff(second,convert(DATETIME,'1990-01-01',120), A.TrN_DaTaWys)
    ,NULL
             ,B.TrN_NrListuPrzewozowego
         FROM CDN.TraNag A
      JOIN CDN.TraNagRelacje RELWZ ON A.TrN_TrNID = RELWZ.TrR_TrNId AND RELWZ.TrR_TrNTyp = 308 AND RELWZ.TrR_FATyp in (306,302,305)
    JOIN CDN.TraNag B ON RELWZ.TrR_FaId = B.TrN_TrNID
        left  JOIN CDN.TraNagRelacje RELFS ON RELWZ.TrR_FAID = RELFS.TrR_TrNId AND RELFS.TrR_TrNTyp in (306,302,305) AND (RELFS.TrR_FATyp = 302 or RELFS.TrR_FATyp = 305 or RELFS.TrR_FATyp = 306)
        left  JOIN CDN.TraNag c ON RELFS.TrR_FaId = c.TrN_TrNID
   WHERE A.TrN_GIDNumer > 0 AND A.TrN_eSklepID = @ESSID AND B.TrN_TS_Mod > @DateTSSynchr and ISNULL(A.TrN_NrListuPrzewozowego,'') = '' and ISNULL(B.TrN_NrListuPrzewozowego,'') != ''
   and not exists (select * from CDN.SenditZleceniePrzesylki where  SZL_FaId = A.TrN_TrNID and ISNULL(SZL_NrListuPrzewozowego,'') != '')
   and not exists (select * from CDN.SenditZleceniePrzesylki where  SZL_FaId = B.TrN_TrNID and ISNULL(SZL_NrListuPrzewozowego,'') != '')
   and not exists (select * from CDN.SenditZleceniePrzesylki where  SZL_FaId = C.TrN_TrNID and ISNULL(SZL_NrListuPrzewozowego,'') != '')
UNION
      SELECT DISTINCT @TypPtw_NrListuPrzew
             ,A.TrN_GidNumer
             ,32
             ,A.TrN_TrNID
             ,NULL
             ,datediff(second,convert(DATETIME,'1990-01-01',120), A.TrN_DaTaWys)
    ,NULL
             ,c.TrN_NrListuPrzewozowego
         FROM CDN.TraNag A
       JOIN CDN.TraNagRelacje RELWZ ON A.TrN_TrNID = RELWZ.TrR_TrNId AND RELWZ.TrR_TrNTyp = 308 AND RELWZ.TrR_FATyp in (306,302,305)
    JOIN CDN.TraNag B ON RELWZ.TrR_FaId = B.TrN_TrNID
         JOIN CDN.TraNagRelacje RELFS ON RELWZ.TrR_FAID = RELFS.TrR_TrNId AND RELFS.TrR_TrNTyp in (306,302,305) AND (RELFS.TrR_FATyp = 302 or RELFS.TrR_FATyp = 305 or RELFS.TrR_FATyp = 306)
         JOIN CDN.TraNag c ON RELFS.TrR_FaId = c.TrN_TrNID
      WHERE A.TrN_GIDNumer > 0 AND A.TrN_eSklepID = @ESSID AND B.TrN_TS_Mod > @DateTSSynchr and ISNULL(A.TrN_NrListuPrzewozowego,'') = '' and ISNULL(B.TrN_NrListuPrzewozowego,'') = ''
    and not exists (select * from CDN.SenditZleceniePrzesylki where  SZL_FaId = A.TrN_TrNID and ISNULL(SZL_NrListuPrzewozowego,'') != '')
     and not exists (select * from CDN.SenditZleceniePrzesylki where  SZL_FaId = B.TrN_TrNID and ISNULL(SZL_NrListuPrzewozowego,'') != '')
    and not exists (select * from CDN.SenditZleceniePrzesylki where  SZL_FaId = C.TrN_TrNID and ISNULL(SZL_NrListuPrzewozowego,'') != '')
UNION ALL
       SELECT DISTINCT @TypPtw_NrListuPrzewSendit
           ,A.TrN_GidNumer
             ,32
             ,A.TrN_TrNID
             ,NULL
             ,max(datediff(second,convert(DATETIME,'1990-01-01',120), A.TrN_DaTaWys))
             ,NULL
             ,min(SPA_url)
         FROM CDN.TraNag A
      join CDN.SenditZleceniePrzesylki on SZL_FaId = A.TrN_TrNID
      join cdn.SenditPaczki on SPA_SZLID = SZL_SZLID
      WHERE SZL_FaId > 0 and ISNULL(SPA_URL,'') != '' and A.TrN_GIDNumer > 0 AND A.TrN_eSklepID = @ESSID AND SZL_TS_Mod > @DateTSSynchr
   group by A.TrN_GidNumer,A.TrN_TrNID
UNION
       SELECT DISTINCT @TypPtw_NrListuPrzewSendit
            ,A.TrN_GidNumer
             ,32
             ,A.TrN_TrNID
             ,NULL
             ,max(datediff(second,convert(DATETIME,'1990-01-01',120), A.TrN_DaTaWys))
             ,NULL
             ,min(SPA_url)
         FROM CDN.TraNag A
      LEFT OUTER JOIN CDN.TraNagRelacje ON A.TrN_TrNID = TrR_TrNId AND TrR_TrNTyp = 308 AND (TrR_FATyp = 302 or TrR_FATyp = 305 or TrR_FATyp = 306)
      LEFT OUTER JOIN CDN.TraNag B ON TrR_FaId = B.TrN_TrNID
      join CDN.SenditZleceniePrzesylki on SZL_FaId = B.TrN_TrNID
      join cdn.SenditPaczki on SPA_SZLID = SZL_SZLID
      WHERE SZL_FaId > 0 and ISNULL(SPA_URL,'') != '' and A.TrN_GIDNumer > 0 AND A.TrN_eSklepID = @ESSID AND SZL_TS_Mod > @DateTSSynchr
   and not exists (select * from CDN.SenditZleceniePrzesylki where  SZL_FaId = A.TrN_TrNID and ISNULL(SZL_NrListuPrzewozowego,'') != '')
   group by A.TrN_GidNumer,A.TrN_TrNID
UNION
      SELECT DISTINCT @TypPtw_NrListuPrzewSendit
            ,A.TrN_GidNumer
             ,32
             ,A.TrN_TrNID
             ,NULL
             ,max(datediff(second,convert(DATETIME,'1990-01-01',120), A.TrN_DaTaWys))
             ,NULL
             ,min(SPA_url)
         FROM CDN.TraNag A
         JOIN CDN.TraNagRelacje RELWZ ON A.TrN_TrNID = RELWZ.TrR_TrNId AND RELWZ.TrR_TrNTyp = 308 AND RELWZ.TrR_FATyp in (306,302,305)
   JOIN CDN.TraNag B ON RELWZ.TrR_FaId = B.TrN_TrNID
         JOIN CDN.TraNagRelacje RELFS ON RELWZ.TrR_FAID = RELFS.TrR_TrNId AND RELFS.TrR_TrNTyp in (306,302,305) AND (RELFS.TrR_FATyp = 302 or RELFS.TrR_FATyp = 305 or RELFS.TrR_FATyp = 306)
         JOIN CDN.TraNag c ON RELFS.TrR_FaId = c.TrN_TrNID
         join CDN.SenditZleceniePrzesylki on SZL_FaId = c.TrN_TrNID
         join cdn.SenditPaczki on SPA_SZLID = SZL_SZLID
        WHERE SZL_FaId > 0 and ISNULL(SPA_URL,'') != '' and A.TrN_GIDNumer > 0 AND A.TrN_eSklepID = @ESSID AND SZL_TS_Mod > @DateTSSynchr
  and not exists (select * from CDN.SenditZleceniePrzesylki where  SZL_FaId = A.TrN_TrNID and ISNULL(SZL_NrListuPrzewozowego,'') != '')
     and not exists (select * from CDN.SenditZleceniePrzesylki where  SZL_FaId = B.TrN_TrNID and ISNULL(SZL_NrListuPrzewozowego,'') != '')
  group by A.TrN_GidNumer,A.TrN_TrNID
    UNION ALL
  SELECT DISTINCT
    @TypPtw_Twr
    ,Twr_TwrId
    ,16
    ,Twr_TwrId
    ,0
    ,''
    ,''
 ,NULL
  FROM CDN.TwrGrupy
  JOIN CDN.Towary On TwG_GIDNumer = Twr_TwrId AND TwG_GIDTyp = 16
  left join CDN.TwrTSModEsklep on TwTS_TwrId = Twr_TwrId
   LEFT OUTER JOIN cdn.TwrESklep on Twr_TwrId = Twes_TwrID and Twes_eSklepID = @ESSID
        WHERE TwG_GIDTyp = 16 AND Twr_GIDFirma = 1 AND TwG_GIDNumer > 0 AND (TwG_CzasModyfikacji > @TSSynchrGrupInt OR Twr_TS_Mod > @TSSynchrTwrDate OR ISNULL(TwTS_TS_ModESklep,0) > @TSSynchrTwrDate)
        AND (ISNULL(Twes_Udostepnij,0) = 0 OR Twr_NieAktywny = 1 OR NOT EXISTS(SELECT GrONumer FROM #TwrGrupyESklep WHERE GIDTyp = 16 AND GIDNumer = Twr_TwrId ))
        OR (1= @EsklepCena0Int AND EXISTS (SELECT TwC_TwrId FROM CDN.TwrCeny WHERE TwC_TwrId = Twr_TwrID AND Twes_Udostepnij=1 AND TwC_Wartosc = 0 AND TwC_TwCNumer = @NrCenyInt))
 union all
            SELECT  @TypPtw_CrosSeling  AS Typ
             ,ztw_ztwid    AS ID
             ,32           AS GIDTyp
             ,ztw_ztwid    AS GIDNumer
             ,0            AS Status
             ,''           AS Data
             ,''           AS Opis
    ,NULL     AS NrList
   from    cdn.ZestawyTwr where  ztw_eSklep = 0 and ztw_ts_mod > @DateTSSynchr
 ) PTW
 FOR XML EXPLICIT
