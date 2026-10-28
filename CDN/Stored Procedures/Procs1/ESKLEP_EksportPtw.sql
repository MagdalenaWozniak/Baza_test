CREATE PROCEDURE [CDN].[ESKLEP_EksportPtw]
  @ID INT      -- ID e-sklepu
AS
DECLARE  @TypPtw_Knt SMALLINT
  ,@TypPtw_Zam SMALLINT
  ,@TypPtw_ZamStan SMALLINT
  ,@TypPtw_Twr SMALLINT
  ,@TypPtw_NrListuPrzew SMALLINT
  ,@TypPtw_KntExport SMALLINT
  ,@TypPtw_CrosSeling SMALLINT
  ,@TypPtw_KntDeact SMALLINT
  ,@TypPtw_NrListuPrzewSendit SMALLINT
  ,@TypPtw_Przepiecie SMALLINT
  ,@undef UNIQUEIDENTIFIER
SELECT @TypPtw_Knt  = 1
      ,@TypPtw_Zam  = 2
      ,@TypPtw_ZamStan = 3
      ,@TypPtw_Twr  = 4
      ,@TypPtw_NrListuPrzew  = 6
      ,@TypPtw_KntExport  = 7
   ,@TypPtw_CrosSeling = 8
   ,@TypPtw_KntDeact   = 9
   ,@TypPtw_NrListuPrzewSendit  = 61 -- sendit url
   ,@TypPtw_Przepiecie = 10
DECLARE
     @TSSynchr         nvarchar(254),
     @TSSynchrGrup     nvarchar(254),
     @TSSynchrGrupInt  INT,
     @TSSynchrTwr      nvarchar(254),
     @TSSynchrTwrDate  DATETIME,
     @TwGNumer         nvarchar(254),
     @TwGNumerInt      INT,
     @DateTSSynchr     DATETIME,
     @NrCeny           nvarchar(20),
     @NrCenyInt        INT,
     @EsklepCena0      nvarchar(254),
     @EsklepCena0Int   INT,
     @ESSID            INT
 CREATE TABLE #TwrGrupyESklep (TwGID INT, Kod nvarchar(50), Nazwa nvarchar(255), Poziom INT, GIDNumer INT, GrONumer INT, GIDTyp SMALLINT,GrOTyp SMALLINT, CzasModyfikacji INT, eSklepLp INT, PRIMARY KEY(Poziom, GrONumer, GIDNumer, GIDTyp))
 SELECT  @ESSID = ESS_ESSID, @TSSynchr = ESS_TS_SynchroPotw, @TSSynchrGrup = ESS_TS_SynchroGrupPotw,@TSSynchrTwr = ESS_TS_SynchroTwrPotw,
         @TwGNumerInt = ESS_TwGNumer,@NrCenyInt = ESS_NrCeny, @EsklepCena0Int = ESS_EsklepCena0
 FROM cdn.eSklepStanowiska WHERE ESS_IdISklep = @ID
 --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1828) SELECT @TSSynchr = 0 ELSE SELECT @TSSynchr = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1828
 SELECT @DateTSSynchr = dateadd( second, CONVERT(INT,@TSSynchr),CONVERT(DATETIME,'1990-01-01',120))
 --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1841) SELECT @TSSynchrGrup = 0 ELSE SELECT @TSSynchrGrup = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1841
 SELECT @TSSynchrGrupInt = CONVERT(INT,@TSSynchrGrup)
 --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1836) SELECT @TSSynchrTwr = 0 ELSE SELECT @TSSynchrTwr = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1836
 SELECT @TSSynchrTwrDate = dateadd( second, CONVERT(INT,@TSSynchrTwr),CONVERT(DATETIME,'1990-01-01',120))
 --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1837) SELECT @TwGNumer = 0 ELSE SELECT @TwGNumer = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1837
 --SELECT @TwGNumerInt = CONVERT(INT,@TwGNumer)
 --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1833) SELECT @NrCeny = 0 ELSE SELECT @NrCeny = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1833
 --SELECT @NrCenyInt = CONVERT(INT,@NrCeny)
 --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1889) SELECT @EsklepCena0= 0 ELSE SELECT @EsklepCena0 = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1889
 --SELECT @EsklepCena0Int = CONVERT(INT,@EsklepCena0)
 INSERT INTO  #TwrGrupyESklep
     SELECT * FROM CDN.TwrGrupyESklep (@TwGNumerInt)
  delete from #TwrGrupyESklep where GrONumer = @TwGNumerInt and GIDTyp = 16
  -- kasujemy przepietych kontrahentów którzy juz zostali wysłani
delete from cdn.eSklepKntRelacje
where ESK_ESKId in (select ESK_ESKId from cdn.eSklepKntRelacje
left join cdn.kontrahenci on ESK_KntOptimaID = knt_kntid
where ESK_eSklepID = @ESSID and ESK_KnteSklepID < 0 and KnT_TS_MOD < @DateTSSynchr)
-- Potwierdzenia kontrahentów
SELECT  1 AS Tag, NULL AS Parent,
   PTW.Typ  AS [PTW!1!Typ]
  ,PTW.ID   AS [PTW!1!ID]
  ,PTW.GIDTyp  AS [PTW!1!GIDTyp]
  ,PTW.GIDNumer AS [PTW!1!GIDNumer]
  ,PTW.GIDNumer2 AS [PTW!1!GIDNumer2]
  ,PTW.GUID AS [PTW!1!GUID]
  ,PTW.Status  AS [PTW!1!Status]
  ,PTW.Data  AS [PTW!1!Data]
  ,PTW.Opis  AS [PTW!1!Opis]
  ,PTW.Opis2  AS [PTW!1!Opis2]
FROM
 (
      SELECT  @TypPtw_Knt  AS Typ
             ,esk_kntesklepid AS ID
             ,32           AS GIDTyp
             ,Knt_KntId    AS GIDNumer
    ,0            AS GIDNumer2
    ,@undef       AS GUID
             ,0            AS Status
             ,''           AS Data
             ,''           AS Opis
    ,null         AS Opis2
      FROM CDN.Kontrahenci  WITH(NOLOCK)
      Join Cdn.eSklepKntRelacje on Knt_KntId = ESK_KntOptimaID
      WHERE Knt_GIDFirma = 1 AND Knt_GIDNumer>0 AND ESK_eSklepID = @ESSID AND KnT_TS_MOD > @DateTSSynchr
UNION ALL
      SELECT  @TypPtw_Zam
             ,TrN_GidNumer
             ,32
             ,TrN_TrNID
    ,0            AS GIDNumer2
    ,@undef       AS GUID
             ,0
             ,datediff(second,convert(DATETIME,'1990-01-01',120), TrN_DaTaWys)
             ,TrN_NumerPelny
    ,null         AS Opis2
      FROM CDN.TraNag
      WHERE TrN_GIDNumer > 0 AND TrN_eSklepID = @ESSID AND TrN_TS_MOD > @DateTSSynchr
UNION ALL
      SELECT  DISTINCT @TypPtw_ZamStan
             ,TrN_GidNumer
             ,32
             ,TrN_TrNID
    ,0            AS GIDNumer2
    ,@undef       AS GUID
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
    ,null         AS Opis2
      FROM CDN.TraNag
      LEFT OUTER JOIN CDN.TraNagRelacje ON TrN_TrNId = TrR_TrNId AND TrR_FaTyp <> 309
      WHERE TrN_GIDNumer > 0 AND TrN_eSklepID = @ESSID AND TrN_TS_Mod > @DateTSSynchr
UNION ALL
      SELECT DISTINCT @TypPtw_NrListuPrzew
             ,A.TrN_GidNumer
             ,32
             ,A.TrN_TrNID
             ,0            AS GIDNumer2
             ,@undef       AS GUID
             ,A.TrN_NrListuPrzewozowegoTypKuriera
             ,datediff(second,convert(DATETIME,'1990-01-01',120), A.TrN_DaTaWys)
             ,A.TrN_NrListuPrzewozowego
             ,null         AS Opis2
      FROM CDN.TraNag A
      WHERE A.TrN_GIDNumer > 0 AND A.TrN_eSklepID = @ESSID AND A.TrN_TS_Mod > @DateTSSynchr
      and not exists (select * from CDN.SenditZleceniePrzesylki join CDN.DokRelacje ON DoR_DokumentTyp=370 AND DoR_DokumentId=SZL_SZLID where  DoR_ParentTyp= A.TrN_TypDokumentu and   DoR_ParentId = A.TrN_TrNID and ISNULL(SZL_NrListuPrzewozowego,'') != '')
UNION
      SELECT DISTINCT @TypPtw_NrListuPrzew
             ,A.TrN_GidNumer
             ,32
             ,A.TrN_TrNID
             ,0            AS GIDNumer2
             ,@undef       AS GUID
             ,B.TrN_NrListuPrzewozowegoTypKuriera
             ,datediff(second,convert(DATETIME,'1990-01-01',120), A.TrN_DaTaWys)
             ,B.TrN_NrListuPrzewozowego
             ,null         AS Opis2
         FROM CDN.TraNag A
         LEFT OUTER JOIN CDN.TraNagRelacje ON A.TrN_TrNID = TrR_TrNId AND TrR_TrNTyp = 308 AND (TrR_FATyp = 302 or TrR_FATyp = 305 or TrR_FATyp = 306)
         LEFT OUTER JOIN CDN.TraNag B ON TrR_FaId = B.TrN_TrNID
         WHERE A.TrN_GIDNumer > 0 AND A.TrN_eSklepID = @ESSID AND B.TrN_TS_Mod > @DateTSSynchr and ISNULL(A.TrN_NrListuPrzewozowego,'') = ''
         and not exists (select * from CDN.SenditZleceniePrzesylki join CDN.DokRelacje ON DoR_DokumentTyp=370 AND DoR_DokumentId=SZL_SZLID where  DoR_ParentTyp= A.TrN_TypDokumentu and   DoR_ParentId = A.TrN_TrNID and ISNULL(SZL_NrListuPrzewozowego,'') != '')
         and not exists (select * from CDN.SenditZleceniePrzesylki join CDN.DokRelacje ON DoR_DokumentTyp=370 AND DoR_DokumentId=SZL_SZLID where  DoR_ParentTyp= B.TrN_TypDokumentu and   DoR_ParentId = B.TrN_TrNID and ISNULL(SZL_NrListuPrzewozowego,'') != '')
UNION
      SELECT DISTINCT @TypPtw_NrListuPrzew
             ,A.TrN_GidNumer
             ,32
             ,A.TrN_TrNID
             ,0            AS GIDNumer2
             ,@undef       AS GUID
             ,c.TrN_NrListuPrzewozowegoTypKuriera
             ,datediff(second,convert(DATETIME,'1990-01-01',120), A.TrN_DaTaWys)
             ,c.TrN_NrListuPrzewozowego
             ,null         AS Opis2
         FROM CDN.TraNag A
         JOIN CDN.TraNagRelacje RELWZ ON A.TrN_TrNID = RELWZ.TrR_TrNId AND RELWZ.TrR_TrNTyp = 308 AND RELWZ.TrR_FATyp in (306,302,305)
         JOIN CDN.TraNag B ON RELWZ.TrR_FaId = B.TrN_TrNID
         JOIN CDN.TraNagRelacje RELFS ON RELWZ.TrR_FAID = RELFS.TrR_TrNId AND RELFS.TrR_TrNTyp in (306,302,305) AND (RELFS.TrR_FATyp = 302 or RELFS.TrR_FATyp = 305 or RELFS.TrR_FATyp = 306)
         JOIN CDN.TraNag c ON RELFS.TrR_FaId = c.TrN_TrNID
         WHERE A.TrN_GIDNumer > 0 AND A.TrN_eSklepID = @ESSID AND B.TrN_TS_Mod > @DateTSSynchr and ISNULL(A.TrN_NrListuPrzewozowego,'') = '' and ISNULL(B.TrN_NrListuPrzewozowego,'') = ''
         and not exists (select * from CDN.SenditZleceniePrzesylki join CDN.DokRelacje ON DoR_DokumentTyp=370 AND DoR_DokumentId=SZL_SZLID where  DoR_ParentTyp= A.TrN_TypDokumentu and   DoR_ParentId = A.TrN_TrNID and ISNULL(SZL_NrListuPrzewozowego,'') != '')
         and not exists (select * from CDN.SenditZleceniePrzesylki join CDN.DokRelacje ON DoR_DokumentTyp=370 AND DoR_DokumentId=SZL_SZLID where  DoR_ParentTyp= B.TrN_TypDokumentu and   DoR_ParentId = B.TrN_TrNID and ISNULL(SZL_NrListuPrzewozowego,'') != '')
         and not exists (select * from CDN.SenditZleceniePrzesylki join CDN.DokRelacje ON DoR_DokumentTyp=370 AND DoR_DokumentId=SZL_SZLID where  DoR_ParentTyp= C.TrN_TypDokumentu and   DoR_ParentId = C.TrN_TrNID and ISNULL(SZL_NrListuPrzewozowego,'') != '')
UNION ALL
       SELECT DISTINCT @TypPtw_NrListuPrzewSendit
             ,A.TrN_GidNumer
             ,32
             ,A.TrN_TrNID
             ,0            AS GIDNumer2
             ,@undef       AS GUID
             ,case when SZL_TypKuriera = 1 then  7
             when SZL_TypKuriera = 2 then 7
             when SZL_TypKuriera = 3 then 4
             when SZL_TypKuriera = 4 and SZL_TypPaczkiDPD NOT IN(0,1)  then 6
             when SZL_TypKuriera = 4 and SZL_TypPaczkiDPD IN(0,1)  then 15
             else 0
             end
             ,datediff(second,convert(DATETIME,'1990-01-01',120), A.TrN_DaTaWys)
             ,SPA_NumerListu
             ,SPA_url
         FROM CDN.TraNag A
         join CDN.DokRelacje ON DoR_DokumentTyp=370 and DoR_ParentTyp= A.TrN_TypDokumentu and   DoR_ParentId = A.TrN_TrNID
         join CDN.SenditZleceniePrzesylki on SZL_SZLID = DoR_DokumentId
         join cdn.SenditPaczki on SPA_SZLID = SZL_SZLID
         WHERE DoR_ParentId > 0 and ISNULL(SPA_URL,'') != '' and A.TrN_GIDNumer > 0 AND A.TrN_eSklepID = @ESSID AND SZL_TS_Mod > @DateTSSynchr
UNION
       SELECT DISTINCT @TypPtw_NrListuPrzewSendit
             ,A.TrN_GidNumer
             ,32
             ,A.TrN_TrNID
             ,0            AS GIDNumer2
             ,@undef       AS GUID
             ,case when SZL_TypKuriera = 1 then  7
             when SZL_TypKuriera = 2 then 7
             when SZL_TypKuriera = 3 then 4
             when SZL_TypKuriera = 4 and SZL_TypPaczkiDPD NOT IN(0,1)  then 6
             when SZL_TypKuriera = 4 and SZL_TypPaczkiDPD IN(0,1)  then 15
             else 0
             end
             ,datediff(second,convert(DATETIME,'1990-01-01',120), A.TrN_DaTaWys)
             ,SPA_NumerListu
             ,SPA_url
         FROM CDN.TraNag A
         LEFT OUTER JOIN CDN.TraNagRelacje ON A.TrN_TrNID = TrR_TrNId AND TrR_TrNTyp = 308 AND (TrR_FATyp = 302 or TrR_FATyp = 305 or TrR_FATyp = 306  or TrR_FATyp = 320)
         LEFT OUTER JOIN CDN.TraNag B ON TrR_FaId = B.TrN_TrNID
         join CDN.DokRelacje ON DoR_DokumentTyp=370 and DoR_ParentTyp= B.TrN_TypDokumentu and   DoR_ParentId = B.TrN_TrNID
         join CDN.SenditZleceniePrzesylki on SZL_SZLID = DoR_DokumentId
         join cdn.SenditPaczki on SPA_SZLID = SZL_SZLID
         WHERE DoR_ParentId > 0 and ISNULL(SPA_URL,'') != '' and A.TrN_GIDNumer > 0 AND A.TrN_eSklepID = @ESSID AND SZL_TS_Mod > @DateTSSynchr
         and not exists (select * from CDN.SenditZleceniePrzesylki join CDN.DokRelacje ON DoR_DokumentTyp=370 AND DoR_DokumentId=SZL_SZLID where  DoR_ParentTyp= A.TrN_TypDokumentu and   DoR_ParentId = A.TrN_TrNID and ISNULL(SZL_NrListuPrzewozowego,'') != '')
UNION
      SELECT DISTINCT @TypPtw_NrListuPrzewSendit
             ,A.TrN_GidNumer
             ,32
             ,A.TrN_TrNID
             ,0            AS GIDNumer2
             ,@undef       AS GUID
             ,case when SZL_TypKuriera = 1 then  7
             when SZL_TypKuriera = 2 then 7
             when SZL_TypKuriera = 3 then 4
             when SZL_TypKuriera = 4 and SZL_TypPaczkiDPD NOT IN(0,1)  then 6
             when SZL_TypKuriera = 4 and SZL_TypPaczkiDPD IN(0,1)  then 15
             else 0
             end
             ,datediff(second,convert(DATETIME,'1990-01-01',120), A.TrN_DaTaWys)
             ,SPA_NumerListu
             ,SPA_url
         FROM CDN.TraNag A
         JOIN CDN.TraNagRelacje RELWZ ON A.TrN_TrNID = RELWZ.TrR_TrNId AND RELWZ.TrR_TrNTyp = 308 AND RELWZ.TrR_FATyp in (306,302,305)
         JOIN CDN.TraNag B ON RELWZ.TrR_FaId = B.TrN_TrNID
         JOIN CDN.TraNagRelacje RELFS ON RELWZ.TrR_FAID = RELFS.TrR_TrNId AND RELFS.TrR_TrNTyp in (306,302,305) AND (RELFS.TrR_FATyp = 302 or RELFS.TrR_FATyp = 305 or RELFS.TrR_FATyp = 306)
         JOIN CDN.TraNag c ON RELFS.TrR_FaId = c.TrN_TrNID
         join CDN.DokRelacje ON DoR_DokumentTyp=370 and DoR_ParentTyp= C.TrN_TypDokumentu and   DoR_ParentId = C.TrN_TrNID
   join CDN.SenditZleceniePrzesylki on SZL_SZLID = DoR_DokumentId
         join cdn.SenditPaczki on SPA_SZLID = SZL_SZLID
         WHERE DoR_ParentId > 0 and ISNULL(SPA_URL,'') != '' and A.TrN_GIDNumer > 0 AND A.TrN_eSklepID = @ESSID AND SZL_TS_Mod > @DateTSSynchr
         and not exists (select * from CDN.SenditZleceniePrzesylki join CDN.DokRelacje ON DoR_DokumentTyp=370 AND DoR_DokumentId=SZL_SZLID where  DoR_ParentTyp= A.TrN_TypDokumentu and   DoR_ParentId = A.TrN_TrNID and ISNULL(SZL_NrListuPrzewozowego,'') != '')
         and not exists (select * from CDN.SenditZleceniePrzesylki join CDN.DokRelacje ON DoR_DokumentTyp=370 AND DoR_DokumentId=SZL_SZLID where  DoR_ParentTyp= B.TrN_TypDokumentu and   DoR_ParentId = B.TrN_TrNID and ISNULL(SZL_NrListuPrzewozowego,'') != '')
UNION ALL
  SELECT DISTINCT
     @TypPtw_Twr
    ,Twr_TwrId
    ,16
    ,Twr_TwrId
 ,0            AS GIDNumer2
 ,@undef       AS GUID
    ,0
    ,''
    ,''
 ,null         AS Opis2
  FROM CDN.TwrGrupy
  JOIN CDN.Towary On TwG_GIDNumer = Twr_TwrId AND TwG_GIDTyp = 16
  LEFT OUTER JOIN cdn.TwrESklep on Twr_TwrId = Twes_TwrID and Twes_eSklepID = @ESSID
  left join cdn.TwrTSModEsklep on TwTS_TwrId = Twr_TwrId
        WHERE TwG_GIDTyp = 16 AND Twr_GIDFirma = 1 AND TwG_GIDNumer > 0
        AND (TwG_CzasModyfikacji > @TSSynchrGrupInt OR case when TwTS_TS_ModESklep is not null and  TwTS_TS_ModESklep > Twr_TS_Mod then TwTS_TS_ModESklep else Twr_TS_Mod end > @TSSynchrTwrDate)
        AND (ISNULL(Twes_Udostepnij,0) = 0 OR Twr_NieAktywny = 1 OR
        NOT EXISTS(SELECT GrONumer FROM #TwrGrupyESklep WHERE GIDTyp = 16 AND GIDNumer = Twr_TwrId ))
        OR
        (1= @EsklepCena0Int AND EXISTS
        (SELECT TwC_TwrId FROM CDN.TwrCeny WHERE TwC_TwrId = Twr_TwrID
        AND Twes_Udostepnij=1 AND TwC_Wartosc = 0 AND TwC_TwCNumer = @NrCenyInt))
union all
            SELECT  @TypPtw_KntDeact  AS Typ
             ,esk_kntesklepid AS ID
             ,32           AS GIDTyp
             ,Knt_KntId    AS GIDNumer
    ,0            AS GIDNumer2
    ,@undef       AS GUID
             ,case when ISNULL(Knt_NadId,0) != 0 then 5 else  4    end       AS Status
             ,''           AS Data
             ,''           AS Opis
             ,null         AS Opis2
              FROM CDN.Kontrahenci  WITH(NOLOCK)
    Join Cdn.eSklepKntRelacje on Knt_KntId = ESK_KntOptimaID
    left join cdn.KntESklepy on Knt_KntID = KES_KntID AND KES_eSklepID = @ESSID
     WHERE Knt_GIDFirma = 1 AND Knt_GIDNumer>0 AND ESK_eSklepID = @ESSID   and esk_kntesklepid > 0
      AND KnT_TS_MOD > @DateTSSynchr
      and ( ISNULL(KES_KntID,0)  = 0 or knt_nieaktywny=1 )
union all
            SELECT  @TypPtw_CrosSeling  AS Typ
             ,ztw_ztwid    AS ID
             ,32           AS GIDTyp
             ,ztw_ztwid    AS GIDNumer
    ,0            AS GIDNumer2
    ,@undef       AS GUID
             ,0            AS Status
             ,''           AS Data
             ,''           AS Opis
    ,null         AS Opis2
   from    cdn.ZestawyTwr where  ztw_eSklep = 0 and ztw_ts_mod > @DateTSSynchr
   or cdn.ESKLEP_EksportCrosSelingZestawNieEksportowalny( ztw_ZTwId , 1 ,  @TSSynchrTwrDate , @NrCenyInt , @EsklepCena0Int )>0
 union all
SELECT  @TypPtw_Przepiecie  AS Typ
             ,new.ESK_KnteSklepID    AS ID
             ,32           AS GIDTyp
             ,old.ESK_KntOptimaID    AS GIDNumer
    ,0            AS GIDNumer2
    ,@undef       AS GUID
             ,new.ESK_KntOptimaID             AS Status
             ,''           AS Data
             ,''           AS Opis
    ,null         AS Opis2
from
cdn.eSklepKntRelacje old
left join cdn.eSklepKntRelacje new on abs(old.ESK_KnteSklepID) = new.ESK_KnteSklepID and old.ESK_eSklepID = new.ESK_eSklepID
where old.ESK_KnteSklepID < 0 and old.ESK_eSklepID = @ESSID
UNION ALL
      SELECT  14
             ,TrN_GidNumer
             ,32
             ,TrN_TrNID
    ,0            AS GIDNumer2
    ,@undef       AS GUID
             ,TrN_eSklepStatusPlatnosci
             ,''
             ,''
    ,null         AS Opis2
      FROM CDN.TraNag
      WHERE TrN_GIDNumer > 0 AND TrN_eSklepID = @ESSID AND TrN_TS_MOD > @DateTSSynchr and TrN_eSklepStatusPlatnosci is not null
UNION ALL
      SELECT  15
             ,TrN_GidNumer
             ,32
             ,TrN_TrNID
    ,0            AS GIDNumer2
    ,@undef       AS GUID
             ,TrN_eSklepStatusDostawy
             ,''
             ,''
    ,null         AS Opis2
      FROM CDN.TraNag
      WHERE TrN_GIDNumer > 0 AND TrN_eSklepID = @ESSID AND TrN_TS_MOD > @DateTSSynchr and TrN_eSklepStatusDostawy != -1
UNION ALL
 SELECT  17
             ,ESAN_SANeSklepID
             ,0
             ,ESAN_SANOptimaID
    ,0            AS GIDNumer2
    ,@undef       AS GUID
             ,''
             ,''
             ,''
    ,null         AS Opis2
      FROM CDN.eSklepAdresyNadawczeRelacje
      WHERE ESan_eSklepID = @ESSID AND ESan_TS > @DateTSSynchr
UNION ALL
    SELECT  91  AS Typ
             ,KESP_PrzedstawicieleSklepID AS ID
             ,32           AS GIDTyp
             ,KESP_KESPId  AS GIDNumer
    ,esk_kntesklepid    AS GIDNumer2
    ,@undef       AS GUID
             ,0            AS Status
             ,''           AS Data
             ,''           AS Opis
    ,null         AS Opis2
      FROM CDN.KntESklepyPrzedstawiciele WITH(NOLOCK)
   join CDN.Kontrahenci   on Knt_KntId = KESP_KntID
      Join Cdn.eSklepKntRelacje on Knt_KntId = ESK_KntOptimaID
      WHERE Knt_GIDFirma = 1 AND Knt_GIDNumer>0 AND ESK_eSklepID = @ESSID and KESP_eSklepID = @ESSID AND KESP_nieaktywny = 0  AND KnT_TS_MOD >@DateTSSynchr
   UNION ALL
    SELECT  92  AS Typ
             ,KESP_PrzedstawicieleSklepID AS ID
             ,32           AS GIDTyp
             ,KESP_KESPId  AS GIDNumer
    ,esk_kntesklepid    AS GIDNumer2
    ,@undef       AS GUID
             ,0            AS Status
             ,''           AS Data
             ,''           AS Opis
    ,null         AS Opis2
      FROM CDN.KntESklepyPrzedstawiciele WITH(NOLOCK)
   join CDN.Kontrahenci   on Knt_KntId = KESP_KntID
   join CDN.KntOsoby   on KnO_KnOId = KESP_PrzedstawicielID
      Join Cdn.eSklepKntRelacje on Knt_KntId = ESK_KntOptimaID
      WHERE Knt_GIDFirma = 1 AND Knt_GIDNumer>0 AND ESK_eSklepID = @ESSID and KESP_eSklepID = @ESSID AND KESP_nieaktywny = 1
   AND (Knt_TS_Mod >@DateTSSynchr or KnO_DataAnonimizacji >@DateTSSynchr)
union all
            SELECT  20  AS Typ
             ,0 AS ID
             ,0           AS GIDTyp
             ,0    AS GIDNumer
    ,0            AS GIDNumer2
    ,RZT_GuidGlowny       AS GUID
             ,case when ISNULL(RZT_Nieaktywny,0) = 1  or ISNULL(RZTES_RZTID,0)  = 0 then 0 else  1    end       AS Status
             ,''           AS Data
             ,''           AS Opis
    ,null         AS Opis2
              FROM CDN.RejestracjaZgodTresc  WITH(NOLOCK)
     join (select max (RZT_RZTId) as id ,RZT_GuidGlowny as guidgl from CDN.RejestracjaZgodTresc
     join CDN.RejestracjaZgodTrescESklepy on RZT_RZTId = RZTES_RZTID and RZTES_eSklepID = @ESSID
     group by RZT_GuidGlowny
     ) as najnowsza on id = RZT_RZTId
     left join CDN.RejestracjaZgodTrescESklepy on RZT_RZTId = RZTES_RZTID and RZTES_eSklepID = @ESSID
     WHERE  ( ISNULL(RZTES_RZTID,0)  = 0 or RZT_Nieaktywny=1 or ISNULL(RZTES_RZTID,0)  > 0 )
     AND RZT_TS_MOD >@DateTSSynchr and RZTES_eSklepWyslana = 1
     union all
     SELECT  19  AS Typ
             ,esk_kntesklepid AS ID
             ,32           AS GIDTyp
             ,Knt_KntId    AS GIDNumer
    ,0            AS GIDNumer2
    ,@undef       AS GUID
             ,0      AS Status
             ,''           AS Data
             ,''           AS Opis
    ,null         AS Opis2
              FROM CDN.Kontrahenci  WITH(NOLOCK)
    Join Cdn.eSklepKntRelacje on Knt_KntId = ESK_KntOptimaID
    left join cdn.KntESklepy on Knt_KntID = KES_KntID AND KES_eSklepID = @ESSID
     WHERE Knt_GIDFirma = 1 AND Knt_GIDNumer>0 AND ESK_eSklepID = @ESSID   and esk_kntesklepid > 0
      AND Knt_DataAnonimizacji > @DateTSSynchr
      and ISNULL(Knt_LpAnonimizacji, 0) != 0
   UNION ALL
    SELECT  18  AS Typ
             ,KESP_PrzedstawicieleSklepID AS ID
             ,32           AS GIDTyp
             ,KESP_KESPId  AS GIDNumer
    ,esk_kntesklepid    AS GIDNumer2
    ,@undef       AS GUID
             ,0            AS Status
             ,''           AS Data
             ,''           AS Opis
    ,null         AS Opis2
      FROM CDN.KntESklepyPrzedstawiciele WITH(NOLOCK)
   join CDN.Kontrahenci   on Knt_KntId = KESP_KntID
   join CDN.KntOsoby   on KnO_KnOId = KESP_PrzedstawicielID
      Join Cdn.eSklepKntRelacje on Knt_KntId = ESK_KntOptimaID
      WHERE Knt_GIDFirma = 1 AND Knt_GIDNumer>0 AND ESK_eSklepID = @ESSID and KESP_eSklepID = @ESSID AND ISNULL(KnO_LpAnonimizacji, 0) != 0  AND KnO_DataAnonimizacji >@DateTSSynchr
   UNION ALL
    SELECT  22
             ,TrN_GidNumer
             ,32
             ,TrN_TrNID
    ,0            AS GIDNumer2
    ,@undef       AS GUID
             ,0
             ,datediff(day,convert(DATETIME,'2000-01-01 ',120), TrN_eSklepDataDost)
             ,TrN_NumerPelny
    ,null         AS Opis2
      FROM CDN.TraNag
      WHERE TrN_GIDNumer > 0 AND TrN_eSklepID = @ESSID AND TrN_TS_MOD > @DateTSSynchr
 ) PTW
 FOR XML EXPLICIT
