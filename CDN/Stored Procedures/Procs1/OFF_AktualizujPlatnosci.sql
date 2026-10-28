CREATE PROCEDURE CDN.OFF_AktualizujPlatnosci
  @Trn_GidNumerChr nvarchar(11),
  @Trn_GidTypChr   nvarchar(5),
  @Knt_GidNumerChr nvarchar(11),
  --@Knt_GidTypChr   nvarchar(5),
  @Trn_NumerPelny  nvarchar(30),
  @Bzd_KierunekChr nvarchar(5),
  @FormaXLPLChr    nvarchar(11),
  @DataChr         nvarchar(20),
  @TerminChr       nvarchar(20),
  @ZalegloscChr    nvarchar(20),
  @WartoscChr      nvarchar(20),      --nie wiem do czego
  @IDOperatorChr   nvarchar(11),
  @IDStanowiskoChr nvarchar(11)
/*
RETURNS @DANE Table( Bzd_BzdId       INT,
                     Bzd_Zaleglosc   DECIMAL(15,2),
                     Bzd_KwotaSys    DECIMAL(15,2),
                     Bzd_KwotarozSys DECIMAL(15,2),
                     Bzd_Idsynchro   INT)
*/
AS
  SET NOCOUNT ON
  DECLARE
   @Trn_TrnId       INT,
   @Knt_KntId       INT,
   @Bzd_DDfID       INT,
   @Fpl_FplId       INT,
   @IDSynchroXL     INT,
   @Trn_GidFirma    INT,
   @Trn_GidNumer    INT,
   @Trn_GidLp       SMALLINT,
   @Trn_GidTyp      SMALLINT,
   @Knt_GidFirma    INT,
   @Knt_GidNumer    INT,
   @Knt_GidLp       SMALLINT,
   @Knt_GidTyp      SMALLINT,
   @Bzd_Kierunek    SMALLINT,
   @FormaXLPL       INT,
   @Data            DATETIME,
   @Termin          DATETIME,
   @ZalegloscXL     DECIMAL(15,2),
   @IDOperator      INT,
   @IDStanowisko    INT,
   @Bzd_BzdId       INT,
   @Bzd_Zaleglosc   DECIMAL(15,2),
   @Bzd_KwotaSys    DECIMAL(15,2),
   @Bzd_KwotarozSys DECIMAL(15,2),
   @Bzd_Idsynchro   INT,
   @Komunikat       nvarchar(255),
   @ZalegloscO      DECIMAL(15,2),
   @Zmiany          DECIMAL(15,2)
 SELECT
   @Trn_GidFirma    = 0,
   @Trn_GidNumer    = CONVERT(INT,@Trn_GidNumerChr),
   @Trn_GidLp       = 0,
   @Trn_GidTyp      = CONVERT(SMALLINT, @Trn_GidTypChr),
   @Knt_GidFirma    = 0,
   @Knt_GidNumer    = CONVERT(INT, @Knt_GidNumerChr),
   @Knt_GidLp       = 0,
   @Knt_GidTyp      = 32,
   @Bzd_Kierunek    = CONVERT(SMALLINT,@Bzd_KierunekChr),
   @FormaXLPL       = CONVERT(INT,@FormaXLPLChr),
   @Data            = CONVERT(DATETIME,@DataChr,102),
   @Termin          = CONVERT(DATETIME,@TerminChr,102),
   @ZalegloscXL     = CONVERT(DECIMAL(15,2),@ZalegloscChr),
   @IDOperator      = CONVERT(INT,@IDOperatorChr),
   @IDStanowisko    = CONVERT(INT,@IDStanowiskoChr)
    declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @IDOperator, @OpeModKod OUT, @OpeModNazwisko OUT
   --KntGidNumer=0 to kontrahent jednorazowy
      if (@Knt_GidNumer='0')
            BEGIN
                        SET @Komunikat = '##OPT34490##'--' Płatność dla kontrahenta jednorazowego  '
                        RAISERROR( @Komunikat, 16, 1)
                        RETURN
            END
      SELECT @Trn_TrnId = Trn_TrnId FROM Cdn.TraNag WHERE  Trn_GidNumer = @Trn_GidNumer and Trn_GidTyp = @Trn_GidTyp
      SELECT @Fpl_FplId = Fpl_FplId FROM Cdn.FormyPlatnosci WHERE Fpl_XlId = @FormaXLPL
      IF  NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=1554)SELECT @IDSynchroXL=1 ELSE SELECT @IDSynchroXL=Fir_Wartosc+1 FROM Cdn.Firma WHERE Fir_Numer=1554
      IF @IDSynchroXL=0 SET @IDSynchroXL=1
      IF(@Trn_TrnId IS NULL)
            BEGIN
                  SELECT @Knt_KntId=Knt_KntId FROM Cdn.Kontrahenci WHERE Knt_GidNumer =@Knt_GidNumer AND Knt_GidTyp = @Knt_GidTyp
                  IF(@Knt_KntId IS NULL)
                        BEGIN
                                    SET @Komunikat = '##OPT34491##'--' Kontrahent nie istnieje  '
                                    RAISERROR( @Komunikat, 16, 1)
                                    RETURN
                        END
                  IF(@Bzd_Kierunek=1)  SELECT @Bzd_DDfID=4,@Bzd_Kierunek = -1
                  ELSE SELECT @Bzd_DDfID=5,@Bzd_Kierunek = 1
                  SELECT @Bzd_BzdId = Bzd_BzdId FROM Cdn.BnkZdarzenia WHERE Bzd_PodmiotID = @Knt_KntId AND Bzd_DDfID =@Bzd_DDfID AND Bzd_NumerPelny = '' AND Bzd_Opis = @Trn_NumerPelny
                  IF(@Bzd_BzdId IS NULL)
                        BEGIN
                              INSERT INTO Cdn.BnkZdarzenia(Bzd_Opis,Bzd_DDfID,Bzd_PodmiotID,Bzd_Kwota,Bzd_KwotaRozSys,Bzd_KwotaRoz,Bzd_KwotaSys,
                                          Bzd_Termin,Bzd_DataDok,Bzd_DataReal,Bzd_TS_Mod,Bzd_TS_Zal,Bzd_Stan,Bzd_Rozliczono,Bzd_Rozliczono2,
                                          Bzd_Priorytet,Bzd_Zwloka,Bzd_Kierunek,Bzd_KursL,Bzd_KursM,Bzd_KursNumer,Bzd_IBan,Bzd_PodmiotRachunekLp,
                                          Bzd_PodmiotTyp,Bzd_NumerPelny,Bzd_NumerObcy,Bzd_RachunekNr,Bzd_Waluta,Bzd_ElixirO1,Bzd_ElixirO2,Bzd_ElixirO3,
                                          Bzd_ElixirO4,Bzd_RelTyp,Bzd_RelId,Bzd_BraId,Bzd_DokumentTyp,Bzd_DokumentId,Bzd_FPlID,Bzd_ImportAppId,
                                          Bzd_KontoPrzeciwstawne,Bzd_IdSynchro,Bzd_OpeModId, Bzd_OpeModKod, Bzd_OpeModNazwisko,
            Bzd_OpeZalId, Bzd_OpeZalKod, Bzd_OpeZalNazwisko, Bzd_StaModId,Bzd_StaZalId, Bzd_DataKur, Bzd_WalutaDok)
                              VALUES (@Trn_NumerPelny,@Bzd_DDfID,@Knt_KntId,@ZalegloscXL,0,0,@ZalegloscXL,@Termin,@Data,@Termin,GETDATE(),GETDATE(),1,1,1,2,
                                    0,@Bzd_Kierunek,1,1,2,0,0,1,'','','','','','','','',0,0,2,0,0,@Fpl_FplId,'','',@IDSynchroXL,@IDOperator, @OpeModKod, @OpeModNazwisko,
                                    @IDOperator, @OpeModKod, @OpeModNazwisko, @IDStanowisko,@IDStanowisko,GETDATE(),'')
                        END
                  ELSE
                        BEGIN
                              UPDATE Cdn.BnkZdarzenia SET  Bzd_Kwota =@ZalegloscXL,
                                                Bzd_KwotaSys = @ZalegloscXL,
                                                Bzd_Termin = @Termin,
                                                Bzd_DataDok = @Data,
                                                Bzd_DataReal = @Termin,
                                                Bzd_FPlID = @Fpl_FplId,
                                                Bzd_IdSynchro =@IDSynchroXL,
                                                Bzd_Stan =1
                              WHERE Bzd_PodmiotID = @Knt_KntId AND Bzd_DDfID =@Bzd_DDfID AND Bzd_NumerPelny = '' AND Bzd_Opis = @Trn_NumerPelny
                        END
                  SELECT 0
                  RETURN
            END
      ELSE
            IF EXISTS (SELECT Bzd_DokumentId FROM cdn.BnkZdarzenia
                               LEFT OUTER JOIN cdn.BnkRozRelacje ON (Bzd_BzdId = BrR_ZDokId AND BrR_ZDokTyp = 1)
                               LEFT OUTER JOIN cdn.BnkZapisy ON (Bzp_Bzpid = BrR_DDokId AND BrR_DDokTyp = 2)
                               LEFT OUTER JOIN cdn.BnkRaporty ON (Bzp_BRpID=BRp_BRpId)
                               WHERE (Brp_GidNumer=0 OR Brp_GidNumer is NULL) AND Brp_BRaId<>2 AND Bzd_DokumentId=@TrN_TrNID )
        BEGIN
            UPDATE Cdn.BnkZdarzenia SET Bzd_IdSynchro =@IDSynchroXL
                                          WHERE Bzd_DokumentId=@TrN_TrNID
                  SELECT 0
                  RETURN
        END
            BEGIN
               SELECT @ZalegloscO = SUM(Bzd_KwotaSys-Bzd_KwotaRozSys)  FROM Cdn.BnkZdarzenia
                  JOIN Cdn.TraNag ON  Trn_trnId = BzD_DokumentId
                  WHERE  Bzd_KwotaSys >= Bzd_KwotarozSys and  (Trn_TrnId in  (SELECT TrR_FaId FROM Cdn.TraNag JOIN CDN.TraNagRelacje  ON TrN_TrNId = TrR_TrNId  WHERE Trn_GidNumer = @Trn_GidNumer and Trn_GidTyp = @Trn_GidTyp)
                  OR (Trn_GidNumer =@Trn_GidNumer and Trn_GidTyp = @Trn_GidTyp ))
            IF @ZalegloscO is NULL
            BEGIN
                  SELECT 0
                  RETURN
            END
            SET @Zmiany=0
               SELECT Bzd_BzdId, (Bzd_KwotaSys-Bzd_KwotaRozSys) as Bzd_Zaleglosc ,Bzd_KwotaSys,Bzd_KwotarozSys,Bzd_Idsynchro,@Zmiany as Rozlicz
                 INTO #TmpZdarzenia FROM Cdn.BnkZdarzenia
                      JOIN Cdn.TraNag ON  Trn_trnId = BzD_DokumentId
                      WHERE  Bzd_KwotaSys >= Bzd_KwotarozSys and  (Trn_TrnId in (SELECT TrR_FaId FROM Cdn.TraNag JOIN CDN.TraNagRelacje  ON TrN_TrNId = TrR_TrNId WHERE Trn_GidNumer = @Trn_GidNumer and Trn_GidTyp = @Trn_GidTyp)
                      OR (Trn_GidNumer =@Trn_GidNumer and Trn_GidTyp = @Trn_GidTyp))
               IF @ZalegloscO > @ZalegloscXL
                  BEGIN
                      DECLARE N CURSOR LOCAL FAST_FORWARD FOR
                       SELECT Bzd_BzdId,Bzd_Zaleglosc,Bzd_KwotaSys FROM #TmpZdarzenia order by Bzd_BzdId desc
                         OPEN N
                          WHILE 1=1
                           BEGIN
                            FETCH NEXT FROM N INTO @Bzd_BzdId,@Bzd_Zaleglosc,@Bzd_KwotaSys
                            IF @@FETCH_STATUS <> 0 BREAK
                              IF  @ZalegloscXL > 0
                      BEGIN
                                  IF @Bzd_Zaleglosc >= @ZalegloscXL
                                   BEGIN
                                      SET @Zmiany =@Bzd_KwotaSys- @ZalegloscXL
                                      SET @ZalegloscXL=0
                                   END
                                  ELSE
                                   BEGIN
                                      SET @ZalegloscXL=@ZalegloscXL - @Bzd_Zaleglosc
                                      SET @Zmiany =0
                                   END
                                 UPDATE #TmpZdarzenia SET Rozlicz  = @Zmiany  WHERE Bzd_BzdId = @Bzd_BzdId
                    END
                     ELSE
                                BEGIN
                      UPDATE #TmpZdarzenia SET Rozlicz  = @Bzd_KwotaSys  WHERE Bzd_BzdId = @Bzd_BzdId
                                END
                          END
                         CLOSE N
                         DEALLOCATE N
                 END
               ELSE
                 BEGIN
                      DECLARE N CURSOR LOCAL FAST_FORWARD FOR
                       SELECT Bzd_BzdId,Bzd_Zaleglosc,Bzd_KwotaSys,Bzd_KwotaRozSys FROM #TmpZdarzenia order by Bzd_BzdId desc
                         OPEN N
                          WHILE 1=1
                           BEGIN
                            FETCH NEXT FROM N INTO @Bzd_BzdId,@Bzd_Zaleglosc,@Bzd_KwotaSys,@Bzd_KwotaRozSys
                            IF @@FETCH_STATUS <> 0 BREAK
                              IF  @ZalegloscXL > 0
                      BEGIN
                                  IF @Bzd_KwotaSys <= @ZalegloscXL
                                   BEGIN
                                      SET @Zmiany =0
                                      SET @ZalegloscXL=@ZalegloscXL - @Bzd_KwotaSys
                                   END
                                  ELSE
                                   BEGIN
                                      SET @Zmiany = @Bzd_KwotaSys - @ZalegloscXL
                                      SET @ZalegloscXL=0
                                   END
                                 UPDATE #TmpZdarzenia SET Rozlicz  = @Zmiany  where Bzd_BzdId = @Bzd_BzdId
                              END
                             ELSE
                                BEGIN
                      UPDATE #TmpZdarzenia SET Rozlicz  = @Bzd_KwotaSys  where Bzd_BzdId = @Bzd_BzdId
                                END
                          END
                         CLOSE N
                         DEALLOCATE N
                 END
            END
  SET NOCOUNT OFF
  SELECT * FROM #TmpZdarzenia
  DROP TABLE #TmpZdarzenia
