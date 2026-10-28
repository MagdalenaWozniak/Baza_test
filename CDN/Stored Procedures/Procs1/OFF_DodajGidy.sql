CREATE  PROCEDURE CDN.OFF_DodajGidy
@GidTypChr   nvarchar(5),
@GidNumerChr nvarchar(11),
@IDChr       nvarchar(11),
@TypChr      nvarchar(5),
@StatusChr   nvarchar(5)
AS
  SET NOCOUNT ON
  DECLARE
  @GidFirma   INT,
  @GidTyp     SMALLINT,
  @GidNumer   INT,
  @GidLp      SMALLINT,
  @ID         INT,
  @Typ        SMALLINT,
  @Status     SMALLINT,
  @Knt_Ts_Export DATETIME,
  @Komunikat  nvarchar(255)
 SELECT
  @GidFirma   = 0,
  @GidNumer   = CONVERT(INT,@GidNumerChr),
  @GidTyp     = CONVERT(SMALLINT,@GidTypChr),
  @GidLp      = 0,
  @ID         = CONVERT(INT,@IDChr),
  @Typ        = CONVERT(SMALLINT,@TypChr),
  @Status     = CONVERT(SMALLINT,@StatusChr)
      IF (@GidTyp IS NULL OR @GidFirma IS NULL OR @GidNumer IS NULL OR @GidLp IS NULL OR @ID IS NULL)
            BEGIN
                  SET @Komunikat = '##OPT34492##'--' Błąd potwierdzenia - brak danych '
                        RAISERROR( @Komunikat, 16, 1)
                        RETURN
            END
      ELSE
            BEGIN
                  IF @Typ = 1 --kontrahenci
                        BEGIN
                              SELECT @Knt_Ts_Export = Knt_Ts_Export FROM Cdn.Kontrahenci WHERE Knt_KntID = @ID
                              UPDATE Cdn.Kontrahenci SET Knt_GidNumer = @GidNumer,
                                                         Knt_GidTyp   = @GidTyp,
                                                         Knt_GidFirma = @GidFirma,
                                                         Knt_GidLp    = @GidLp,
                                                         Knt_Ts_Export= @Knt_Ts_Export
                               WHERE Knt_KntID = @ID
                        UPDATE Cdn.KntPromocje SET KPR_KNTNumer = @GidNumer,
                                                         KPR_KNTTyp   = @GidTyp,
                                                         KPR_KNTFirma = @GidFirma,
                                                         KPR_KNTLp    = @GidLp
                               WHERE KPR_KNTNumer = @ID and KPR_KNTTyp = 0
                        END
                  IF @Typ = 2
                        BEGIN
                              SET @Komunikat = '##OPT34493##'--' Zły typ potwierdzenia '
                                    RAISERROR( @Komunikat, 16, 1)
                                    RETURN
                        END
                  IF @Typ = 3 -- dokumenty
                        BEGIN
                              UPDATE Cdn.TraNag SET Trn_GidNumer = @GidNumer,
                                                              Trn_GidTyp   = @GidTyp,
                                                              --Trn_GidFirma = @GidFirma,
                                                              Trn_GidLp    = @GidLp,
                                                              Trn_ts_export= GETDATE()
                              WHERE Trn_TrnId = @ID
                              --JESLI DOKUMENT POTWIERDZONY DODAJEMY IDSYNCHRO DLA NIEGO ABY POTEM ZIDENTYFIKOWAC GO CZY JEST DO ROZLICZENIA
                              UPDATE Cdn.BnkZdarzenia SET Bzd_IdSynchro =(SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=1554) WHERE Bzd_DokumentId =@ID
                        END
                  IF @Typ = 4 --raporty kasowo bankowe
                        BEGIN
                              UPDATE Cdn.BnkRaporty SET Brp_GidNumer = @GidNumer,
                                                                  Brp_GidTyp   = @GidTyp,
                                                                  Brp_GidFirma = @GidFirma,
                                                                  Brp_GidLp    = @GidLp
                              WHERE Brp_BrpId = @ID
                        END
                  IF @Typ = 5 --RO ZD
                        BEGIN
                              IF @Status>31 UPDATE Cdn.TraNag SET Trn_Bufor =-1,TrN_OFFPrawoDoAnulowania = 2 WHERE Trn_TrnId = @ID
                              IF @Status>15 AND @Status<22  UPDATE Cdn.TraNag SET Trn_Rodzaj = Trn_Rodzaj+100 WHERE Trn_TrnId = @ID AND TrN_Rodzaj in(309000,308000)
                        END
                  IF @Typ = 6 -- anulowanie dokumentu
                        BEGIN
                              UPDATE Cdn.TraNag SET TrN_OFFPrawoDoAnulowania = 2,
                                                    Trn_ts_export= GETDATE()
                      WHERE Trn_TrnId = @ID
                        END
                  IF @Typ = 7 -- zakaz dla pa->fa
                        BEGIN
                              UPDATE Cdn.TraNag SET TrN_OFFPrawoDoFAPA = 2,
                                                    Trn_ts_export= GETDATE()
                              WHERE Trn_TrnId = @ID
                         END
            END
  SET NOCOUNT OFF
