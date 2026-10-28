CREATE PROCEDURE [CDN].[OFF_Ex_HaMag]
  AS
  SET NOCOUNT ON
  DECLARE
    -- dla inserta
    @TrN_TrNId    INT,
    @TrN_FaId     INT,
    @TrN_RelTrNId INT,
    @TrN_ZwrId    INT,
    @TrN_DDfId    INT,
    @TrN_PodId    INT,
    @TrN_OdbId    INT,
    @TrN_TypDokumentu INT,
    @TrN_OdbDocID INT,
    @TrN_MagDocID INT,
    @Mag_GidNumer INT,
    @Zwr_GidTyp   INT,
    @Zwr_GidNumer INT,
    @Fa_GidTyp    INT,
    @Fa_GidNumer  INT,
    @Pod_GidTyp   INT,
    @Pod_GidNumer INT,
    @Odb_GidTyp   INT,
    @Odb_GidNumer INT,
    @IloscElementow INT,
    @TrN_NumerString nvarchar(31),
    @Fpl_XLID     INT,
    @TrN_FplId    INT,
    @JestemSpinaczem INT,
    @JestemSpinaczemPA INT,
    @Seria        nvarchar(5)
   CREATE TABLE  #TmpReszte(TrNId INT, Rok nvarchar(5), Seria nvarchar(10),Miesiac nvarchar(5), Zwr_GidTyp INT,
                             Zwr_GidNumer INT,Fa_GidTyp INT,Fa_GidNumer INT, Pod_GidTyp INT,
                             Pod_GidNumer INT,Odb_GidTyp INT, Odb_GidNumer INT, IloscElementow INT,Mag_GidNumer INT,Fpl_XLID    INT,JestemSpinaczem INT,JestemSpinaczemPA INT)
    CREATE TABLE #TmpHaMag (
         [TrN_ID] [int] IDENTITY (1, 1) NOT NULL ,
        [TrN_TrNID] [int] NOT NULL ,
        [TrN_TerminZwrotuKaucji] [datetime] NULL ,
        [TrN_RelTrNId] [int] NULL ,
        [TrN_DDfId] [int] NULL ,
        [TrN_TypDokumentu] [int] NOT NULL ,
        [TrN_ZwrId] [int] NULL ,
        [TrN_FaId] [int] NULL ,
        [TrN_NumerNr] [int] NOT NULL ,
        [TrN_NumerString] [nvarchar] (31)  NOT NULL ,
        [TrN_NumerPelny]  [nvarchar] (31)  NOT NULL,
        [TrN_DataDok] [datetime] NOT NULL ,
        [TrN_DataWys] [datetime] NOT NULL ,
        [TrN_DataOpe] [datetime] NOT NULL ,
        [TrN_NumerObcy] [nvarchar] (256)  ,
        [TrN_Fiskalna] [tinyint] NOT NULL ,
        [TrN_FiskalnaErr] [int] NULL ,
        [TrN_Rodzaj] [int] NOT NULL ,
        [TrN_PodID] [int] NULL ,
        [TrN_PodNazwa1] [nvarchar] (50) NOT NULL ,
        [TrN_PodNazwa2] [nvarchar] (50) NOT NULL ,
        [TrN_PodNazwa3] [nvarchar] (250) NOT NULL ,
        [TrN_PodWojewodztwo] [nvarchar] (40) NOT NULL ,
        [TrN_PodUlica] [nvarchar] (40) NOT NULL ,
        [TrN_PodMiasto] [nvarchar] (40) NOT NULL ,
        [TrN_PodKodPocztowy] [nvarchar] (10) NOT NULL ,
        [TrN_PodNipKraj] [nvarchar] (2) NOT NULL ,
        [TrN_PodNipE] [nvarchar] (20) NOT NULL ,
        [TrN_OdbID] [int] NULL ,
        [TrN_OdbNazwa1] [nvarchar] (50) NOT NULL ,
        [TrN_OdbNazwa2] [nvarchar] (50) NOT NULL ,
        [TrN_OdbNazwa3] [nvarchar] (250) NOT NULL ,
        [TrN_OdbWojewodztwo] [nvarchar] (40) NOT NULL ,
        [TrN_OdbUlica] [nvarchar] (40) NOT NULL ,
        [TrN_OdbMiasto] [nvarchar] (40) NOT NULL ,
        [TrN_OdbKodPocztowy] [nvarchar] (10) NOT NULL ,
        [TrN_OdbNipKraj] [nvarchar] (2) NOT NULL ,
        [TrN_OdbNipE] [nvarchar] (20) NOT NULL ,
        [TrN_OdbDocID] [int] NULL ,
        [TrN_FPlId] [int] NULL ,
        [TrN_Termin] [datetime] NOT NULL ,
        [TrN_RazemNetto] [decimal](15, 2) NOT NULL ,
        [TrN_RazemBrutto] [decimal](15, 2) NOT NULL ,
        [TrN_MagDocId] [int] NULL ,
        [TrN_TypNB] [tinyint] NOT NULL ,
        [TrN_Rabat] [decimal](5, 2) NOT NULL ,
        [TrN_Opis] [nvarchar] (1024) NOT NULL ,
        [TrN_OpeZalID] [int] NULL ,
  [TrN_OpeZalKod] [varchar](20) NULL ,
  [TrN_OpeZalNazwisko] [nvarchar](50) NULL ,
        [TrN_StaZalId] [int] NULL ,
        [TrN_OpeModID] [int] NULL ,
  [TrN_OpeModKod] [varchar](20) NULL ,
  [TrN_OpeModNazwisko] [nvarchar](50) NULL ,
        [TrN_StaModId] [int] NULL ,
        [TrN_GIDNumer] [int] NULL ,
        [TrN_OFFExportMag] [int] NULL
 CONSTRAINT [TrN_Primary] PRIMARY KEY  CLUSTERED
 (
  [TrN_ID]
 )  ON [PRIMARY] ,
) ON [PRIMARY]
    INSERT INTO #TmpHaMag select
        distinct
        [TrN_TrNID] ,
        [TrN_TerminZwrotuKaucji] ,
        case when TrN_TypDokumentu= 313 or  TrN_TypDokumentu= 314 then CDN.TraNagRelacjeFaId (TrN_TrNID,0,1 ) else CDN.TraNagRelacjeFaId (TrN_TrNID,0,0 ) end ,
        [TrN_DDfId] , [TrN_TypDokumentu] ,
        [TrN_ZwrId] ,
        case when TrN_TypDokumentu= 313 or  TrN_TypDokumentu= 314 then CDN.TraNagRelacjeFaId (TrN_TrNID,0,2 )else CDN.TraNagRelacjeFaId (TrN_TrNID,0,0 ) end ,
        [TrN_NumerNr] ,
        [TrN_NumerString] , [TrN_NumerPelny]  , [TrN_DataDok] ,
        [TrN_DataWys] , [TrN_DataOpe] , [TrN_NumerObcy] ,
        [TrN_Fiskalna] , [TrN_FiskalnaErr] , [TrN_Rodzaj] ,
        [TrN_PodID] , [TrN_PodNazwa1] , [TrN_PodNazwa2] ,
        [TrN_PodNazwa3] , [TrN_PodWojewodztwo] , [TrN_PodUlica] ,
        [TrN_PodMiasto] , [TrN_PodKodPocztowy] , [TrN_PodNipKraj] ,
        [TrN_PodNipE] , [TrN_OdbID] , [TrN_OdbNazwa1] ,
        [TrN_OdbNazwa2] , [TrN_OdbNazwa3] , [TrN_OdbWojewodztwo] ,
        [TrN_OdbUlica] , [TrN_OdbMiasto] , [TrN_OdbKodPocztowy] ,
        [TrN_OdbNipKraj] , [TrN_OdbNipE] , [TrN_OdbDocID] ,
        [TrN_FPlId] , [TrN_Termin] , [TrN_RazemNetto] ,
        [TrN_RazemBrutto] , [TrN_MagDocId] , [TrN_TypNB] ,
        [TrN_Rabat] , [TrN_Opis] , [TrN_OpeZalID] , [TrN_OpeZalKod], [TrN_OpeZalNazwisko],
        [TrN_StaZalId] , [TrN_OpeModID], [TrN_OpeModKod], [TrN_OpeModNazwisko] , [TrN_StaModId] ,
        [TrN_GIDNumer] , [TrN_OFFExportMag]
 from Cdn.TraNag
 WHERE (TrN_GidNumer IS NULL OR TrN_TS_Export IS NULL)
           AND TrN_Bufor = 0 AND (TrN_Rodzaj IN(312100,302002,302004,302005,302006,302007,302090,302091,302092,305004,305005,301004,301090,301091,301092,303000,303010,303002,304000,304010,311001,308000,308008,308009,308010,309000,301005,301006,303001,304001,313000,313001,313002,313004,314000,314001,314002,314004,314006)
           OR  TrN_TypDokumentu in (306,307) AND TrN_OFFExportMag=1)
  Update #TmpHaMag set TrN_FaId = NULL where TrN_FaId = 0
  -- detal nie wczytał jeszcze płatności to nie wysyłamy
  delete from  #TmpHaMag where trn_trnid in (select TrN_TrNID from #TmpHaMag
  left join cdn.DetalTraNag on dTrN_NumerPelny = TrN_NumerPelny
  where DTrN_StanSynchronizacji = 1)
-- po TrN_TrNId
   DECLARE N CURSOR LOCAL FAST_FORWARD FOR
   SELECT TrN_TrNId,TrN_FaId,TrN_RelTrNId,TrN_ZwrId,TrN_DDfId,TrN_NumerString,TrN_PodId,TrN_OdbId,TrN_TypDokumentu,TrN_OdbDocID,TrN_MagDocId,TrN_FplId FROM #TmpHaMag
             OPEN N
              WHILE 1=1
                BEGIN
                  FETCH NEXT FROM N INTO @TrN_TrNId,@TrN_FaId,@TrN_RelTrNId,@TrN_ZwrId,@TrN_DDfId,@TrN_NumerString,@TrN_PodId,@TrN_OdbId,@TrN_TypDokumentu,@TrN_OdbDocID,@TrN_MagDocId,@TrN_FplId
                    IF @@FETCH_STATUS <> 0 BREAK
                        IF EXISTS (SELECT TrN_TrNId FROM Cdn.TraNag WHERE @TrN_TypDokumentu<> 306 and @TrN_TypDokumentu<> 307 and TrN_Bufor = 1 AND (TrN_TrNId = @TrN_FaId OR TrN_TrNId = @TrN_ZwrId))
                           delete  #TmpHaMag WHERE TrN_TrNId=@TrN_TrNId
                        ELSE
                           IF EXISTS ( SELECT TrN_TrNId FROM Cdn.TraNag WHERE  (TrN_FaId = @TrN_FaId or TrN_FaId = @TrN_TrnId)  AND TrN_BufOR = 1  AND TrN_Rodzaj = 303010)
                              delete  #TmpHaMag WHERE TrN_TrNId=@TrN_TrNId
                           ELSE
                              BEGIN
                                SELECT @Zwr_GidTyp=null,@Zwr_GidNumer=null,@IloscElementow=null,@Fa_GidTyp=null,@Fa_GidNumer=null,@Pod_GidTyp=null,@Pod_GidNumer=null,@Odb_GidTyp=null,@Odb_GidNumer=null
                                SELECT @Zwr_GidTyp = TrN_GidTyp,@Zwr_GidNumer = TrN_GidNumer FROM cdn.tranag WHERE TrN_TrNid =@TrN_ZwrId
                                SELECT @IloscElementow = count(*) FROM cdn.traelem WHERE tre_TrNid=@TrN_TrNId
                                IF( @TrN_TypDokumentu= 313 or  @TrN_TypDokumentu= 314)
                                  SELECT @Fa_GidTyp = TrN_GidTyp,@Fa_GidNumer = TrN_GidNumer FROM cdn.tranag WHERE TrN_TrNid = @TrN_RelTrNId
                                ELSE
                                  SELECT @Fa_GidTyp = TrN_GidTyp,@Fa_GidNumer = TrN_GidNumer FROM cdn.tranag WHERE TrN_TrNid = @TrN_FaId
                                SELECT @Pod_GidTyp = Knt_GidTyp,@Pod_GidNumer =(CASE WHEN Knt_GidTyp < 1 OR Knt_GidTyp IS NULL THEN NULL ELSE Knt_GidNumer END) FROM cdn.kontrahenci WHERE Knt_KntId =@TrN_PodID
                                SELECT @Mag_GidNumer = Mag_GidNumer FROM Cdn.Magazyny WHERE Mag_MagId = @TrN_MagDocId
                                SELECT @Fpl_XLID = Fpl_XLID FROM  Cdn.FormyPlatnosci JOIN Cdn.TraNag ON Fpl_Fplid = @TrN_FplId
                                IF(@TrN_TypDokumentu = 309)
                                   SELECT @Odb_GidTyp = Knt_GidTyp,@Odb_GidNumer =(CASE WHEN Knt_GidTyp < 1 OR Knt_GidTyp IS NULL THEN NULL ELSE Knt_GidNumer END) FROM cdn.kontrahenci WHERE Knt_KntId =@TrN_OdbDocID
                                ELSE
                                   SELECT @Odb_GidTyp = Knt_GidTyp,@Odb_GidNumer =(CASE WHEN Knt_GidTyp < 1 OR Knt_GidTyp IS NULL THEN NULL ELSE Knt_GidNumer END) FROM cdn.kontrahenci WHERE Knt_KntId =@TrN_OdbID
                                IF(@TrN_TypDokumentu = 309)
                                  BEGIN
                                    SELECT @Odb_GidTyp = Knt_GidTyp,@Odb_GidNumer =(CASE WHEN Knt_GidTyp < 1 OR Knt_GidTyp IS NULL THEN NULL ELSE Knt_GidNumer END) FROM cdn.kontrahenci WHERE Knt_KntId =@TrN_OdbDocID
                                    UPDATE #TmpHaMag SET
                                       TrN_OdbID = @TrN_OdbDocID ,
                                       TrN_OdbNazwa1 = Knt_Nazwa1,
                                       TrN_OdbNazwa2 = Knt_Nazwa2,
                                       TrN_OdbNazwa3 = Knt_Nazwa3,
                                       TrN_OdbUlica  = Knt_Ulica,
                                       TrN_OdbMiasto = Knt_Miasto,
                                       TrN_OdbKodPocztowy = Knt_KodPocztowy,
                                       TrN_OdbNipE = Knt_NipE,
                                       TrN_OdbNipKraj = Knt_NIPKraj,
                                       TrN_OdbWojewodztwo = Knt_Wojewodztwo
                                    FROM CDN.Kontrahenci
                                    WHERE Knt_KntId=TrN_OdbDocID AND TrN_TrNId = @TrN_TrNId
                                  END
                                  SET @JestemSpinaczem=0
                                  SET @JestemSpinaczemPA=0
                                  --if exists ( select TrN_TrNId from cdn.tranag where (Trn_Rodzaj in (313000,313001,313002,313004,314000,314001,314002,314004,314006,303010,304010) and TrN_FaId =@TrN_TrNId))
                                  if exists ( select TrR_TrNId from cdn.tranagrelacje where TrR_TrNTyp in (313,314) and TrR_FaId = @TrN_TrNId and TrR_Flaga = 2)
                                     select @JestemSpinaczem=1
                                  if exists ( select TrR_TrNId from cdn.tranagrelacje where TrR_FaTyp =311 and TrR_TrNTyp in (303,304) and TrR_FaId = @TrN_TrNId )
                                     select @JestemSpinaczem=1
                                  --if exists ( select TrN_TrNId from cdn.tranag where (TrN_TypDokumentu in (306,307) and TrN_FaId =@TrN_TrNId and TrN_OFFExportMag=1))
                                  if exists ( select TrR_TrNId from cdn.tranagrelacje join cdn.tranag on TrN_TrNId = TrR_TrNId where TrR_FaTyp in (301,302) and TrR_TrNTyp in (306,307) and TrR_FaId = @TrN_TrNId and TrN_OFFExportMag=1)
                                     select @JestemSpinaczem=1
                                  --if exists ( select TrN_TrNId from cdn.tranag where (Trn_Rodzaj in(305000,305004) and TrN_FaId =@TrN_TrNId))
                                  if exists (select TrR_TrNId from cdn.tranagrelacje where TrR_FaTyp =302 and TrR_TrNTyp =305 and TrR_FaId =@TrN_TrNId )
                                     select @JestemSpinaczemPA=1
                                  INSERT INTO  #TmpReszte
                                       SELECT @TrN_TrNId,Rok,Seria,Miesiac,@Zwr_GidTyp,@Zwr_GidNumer ,@Fa_GidTyp,@Fa_GidNumer,@Pod_GidTyp,@Pod_GidNumer,@Odb_GidTyp,@Odb_GidNumer, @IloscElementow,@Mag_GidNumer,@Fpl_XLID,@JestemSpinaczem,@JestemSpinaczemPA
                                       FROM CDN.RozbijNumer (@TrN_DDfId,@TrN_NumerString)
                           END
                 END
              CLOSE N
            DEALLOCATE N
  SET NOCOUNT OFF
  SELECT * FROM #TmpHaMag
  LEFT JOIN  #TmpReszte on TrN_TrNId = TrNId order by JestemSpinaczem,TrN_TrNId
  DROP TABLE #TmpHaMag
  DROP TABLE  #TmpReszte
