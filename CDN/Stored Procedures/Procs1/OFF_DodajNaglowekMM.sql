CREATE PROCEDURE CDN.OFF_DodajNaglowekMM
  @TrN_GIDTypChr      nvarchar(5),
  @TrN_GIDNumerChr    nvarchar(11),
  @TrN_Id             nvarchar(11),       --NIE POTRZEBNE
  @TrN_GIDTypZ        nvarchar(5),       --NIE POTRZEBNE
  @TrN_GIDNumerZ      nvarchar(11),       --NIE POTRZEBNE
  --@TrN_TypDokumentuChr nvarchar(11),
  @TrN_NumerNrChr     nvarchar(11),
  @ROK                nvarchar(4),            --NIE POTRZEBNE
  --@TrN_GIDTypK        nvarchar(5),       --NIE POTRZEBNE
  @TrN_GIDNumerK      nvarchar(11),       --NIE POTRZEBNE
  @TrN_PodNazwa1      nvarchar(50),       --NIE POTRZEBNE
  @TrN_PodNazwa2      nvarchar(50),      --NIE POTRZEBNE
  @TrN_PodNazwa3      nvarchar(250),      --NIE POTRZEBNE
  @TrN_IdoOdbiorcy    nvarchar(11),       --NIE POTRZEBNE
  --@TrN_GIDTypO        nvarchar(5),       --NIE POTRZEBNE
  @TrN_GIDNumerO      nvarchar(11),       --NIE POTRZEBNE
  @TrN_OdbNazwa1      nvarchar(50),      --NIE POTRZEBNE
  @TrN_OdbNazwa2      nvarchar(50),      --NIE POTRZEBNE
  @TrN_OdbNazwa3      nvarchar(250),      --NIE POTRZEBNE
  @TrN_OdbUlica       nvarchar(40),      --NIE POTRZEBNE
  @TrN_OdbMiasto      nvarchar(40),      --NIE POTRZEBNE
  @TrN_PodUlica       nvarchar(40),       --NIE POTRZEBNE
  @TrN_PodMiasto      nvarchar(40),       --NIE POTRZEBNE
  @TrN_OdbKodPocztowy nvarchar(10),--NIE POTRZEBNE
  @TrN_OdbNipE        nvarchar(20),       --NIE POTRZEBNE
  @TrN_PodKodPocztowy nvarchar(10),--NIE POTRZEBNE
  @Trn_NumerPelny     nvarchar(30),      --NIE POTRZEBNE
  @TrN_NumerObcy      nvarchar(256),
  @Seria              nvarchar(10),
  @TrN_PodId          nvarchar(11),            --NIE POTRZEBNE
  @TrN_TypNBChr       nvarchar(1),
  @TrN_PodNipE        nvarchar(20),       --NIE POTRZEBNE
--  @Trn_RodzajN        nvarchar(11),            --NIE POTRZEBNE
  @Termin             nvarchar(12),       --NIE POTRZEBNE
  @Trn_RazemBruttoChr nvarchar(19),
  @TrN_RazemNettoChr  nvarchar(19),
 -- @TrN_RazemVATChr    nvarchar(19),
  @TrN_DataWysChr     nvarchar(20),
  @TrN_DataDokChr     nvarchar(20),
  @TrN_DataOpeChr     nvarchar(20),
--  @Trn_Korekta        nvarchar(2),       --NIE POTRZEBNE
  @Trn_RabatChr       nvarchar(11),
--  @TrN_GIDTypOP       nvarchar(5),       --NIE POTRZEBNE
  @TrN_GIDNumerOP     nvarchar(11),       --NIE POTRZEBNE
  @FormaPIXLIDChr     nvarchar(5),
  @Trn_Opis           nvarchar(254),
  @BuforChr           nvarchar(11),
  @GidNumerMagZChr    nvarchar(11),
  @Miesiac            nvarchar(11),
  @IdOperatorChr      nvarchar(11),
  @IdStanowiskoChr    nvarchar(11)
AS
  SET NOCOUNT ON
  DECLARE
  @TrN_GIDFirma         INT,
  @TrN_GIDTyp           SMALLINT,
  @TrN_GIDNumer         INT,
  @TrN_GIDLp            SMALLINT,
  @TrN_TypDokumentu     INT,
  @TrN_NumerNr          INT,
  @Trn_RazemBrutto      DECIMAL(15,2),
  @TrN_RazemNetto       DECIMAL(15,2),
  @TrN_RazemVAT         DECIMAL(15,2),
  @TrN_DataWys          DATETIME,
  @TrN_DataDok          DATETIME,
  @TrN_DataOpe          DATETIME,
  @Trn_Rabat            DECIMAL(5,2),
  @TrN_TypNB            TINYINT,
  @FormaPIXLID          SMALLINT,
  @fplid                INT,
  @MagZrdId             INT,
  @DdfId                INT,
  @Trn_TrnId            INT,
  @TrN_Rodzaj           INT,
  @TrN_NumerString      nvarchar(50),
  @IdOperator           INT,
  @IdStanowisko         INT,
  @GidNumerMagZ         INT,
  @Bufor                SMALLINT,
  @Komunikat            nvarchar(255)
    IF (@TrN_TypNBChr='N') SET @TrN_TypNBChr='1'
    ELSE SET @TrN_TypNBChr ='2'
SELECT
  @TrN_GIDFirma       =0,
  @TrN_GIDTyp         =CONVERT(SMALLINT,@TrN_GIDTypChr),
  @TrN_GIDNumer       =CONVERT(INT, @TrN_GIDNumerChr),
  @TrN_GIDLp          =0,
  --@TrN_TypDokumentu   =CONVERT(INT, @TrN_TypDokumentuChr),
  @TrN_NumerNr        =CONVERT(INT, @TrN_NumerNrChr),
  @Trn_RazemBrutto    =CONVERT(DECIMAL(15,2),@Trn_RazemBruttoChr),
  @TrN_RazemNetto     =CONVERT(DECIMAL(15,2),@TrN_RazemNettoChr),
  @TrN_RazemVAT       =0,
  @TrN_DataWys        =CONVERT(DATETIME,@TrN_DataWysChr,120),
  @TrN_DataDok        =CONVERT(DATETIME,@TrN_DataDokChr,120),
  @TrN_DataOpe        =CONVERT(DATETIME, @TrN_DataOpeChr,120),
  @Trn_Rabat          =CONVERT(DECIMAL(5,2),@Trn_RabatChr),
  @TrN_TypNB          =CONVERT(TINYINT,@TrN_TypNBChr),
  @FormaPIXLID        =CONVERT(SMALLINT,@FormaPIXLIDChr),
  @IdOperator         =CONVERT(INT, @IdOperatorChr),
  @IdStanowisko       =CONVERT(INT, @IdStanowiskoChr),
  @GidNumerMagZ       =CONVERT(INT, @GidNumerMagZChr),
  @Bufor              =CONVERT(SMALLINT, @BuforChr)
   declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @IdOperator, @OpeModKod OUT, @OpeModNazwisko OUT
  IF exists(SELECT Trn_TrnId From Cdn.TraNag Where Trn_GidNumer =@Trn_GidNumer and Trn_GidTyp= @Trn_GidTyp)
      BEGIN
            Update Cdn.TraNag Set Trn_Ts_Export= null Where Trn_GidNumer =@Trn_GidNumer and Trn_GidTyp= @Trn_GidTyp
            SET @Komunikat = '##OPT34486##'--'MM już istnieje'
                  RAISERROR( @Komunikat, 16, 1)
                  RETURN
      END
  IF exists(SELECT Trn_TrnId From Cdn.TraNag Where TrN_Bufor = 0 AND Trn_Rodzaj = 311000)
      BEGIN
            SET @Komunikat = '##OPT34487##'--'Nie jest możliwe wystawienie dokumentu ponieważ istnieje zatwierdzony ale nie potwierdzony arkusz inwentaryzacyjny!'
                  RAISERROR( @Komunikat, 16, 1)
                  RETURN
      END
  IF exists(SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=1562 AND Fir_Wartosc=1)
      BEGIN
            SET @Komunikat = '##OPT34488##'--'Wykonano zwrot całkowity'
                  RAISERROR( @Komunikat, 16, 1)
                  RETURN
      END
 IF (@TrN_GIDTyp = 1600)
      BEGIN
            select
                  @TrN_TypDokumentu = 312,
                  @DDfId              = 26,
                  @TrN_Rodzaj =312010
      SELECT top 1 @TrN_NumerString=DDf_Numeracja FROM Cdn.DokDefinicje WHERE Ddf_Klasa =312 order by ddf_ddfid desc
                  --@TrN_NumerString = 'MM/@numer/'+@Rok+'/'+@Seria
                   SET @TrN_NumerString    = REPLACE ( @TrN_NumerString, '/@brak'  , ''       )
                   SET @TrN_NumerString    = REPLACE ( @TrN_NumerString, '@brak/'  , ''       )
                   SET @TrN_NumerString    = REPLACE ( @TrN_NumerString, '@rejestr', @Seria )
                   SET @TrN_NumerString    = REPLACE ( @TrN_NumerString, '@rok_kal', @Rok )
                   if @Miesiac <>  '0' and @Miesiac <> ''
                        if @Miesiac in ('10','11','12')
       SET @TrN_NumerString    = REPLACE ( @TrN_NumerString, '@miesiac', @Miesiac )
                        else
       SET @TrN_NumerString    = REPLACE ( @TrN_NumerString, '@miesiac', '0'+@Miesiac )
      END
      SELECT top 1 @DDfId=DDf_DDfId FROM Cdn.DokDefinicje WHERE Ddf_Klasa =312 order by ddf_ddfid desc
      if @Seria=''
      begin
        SELECT top 1 @DDfId=DDf_DDfId FROM Cdn.DokDefinicje WHERE Ddf_Klasa = 999
        if @Miesiac <>  '0' and @Miesiac <> ''
                        if @Miesiac in ('10','11','12')
       set @TrN_NumerString = 'MM/@numer/'+@Rok+'/'+@miesiac+'/'+@Seria
                        else
                            set @TrN_NumerString = 'MM/@numer/'+@Rok+'/'+'0'+@Miesiac+'/'+@Seria
  else
   set @TrN_NumerString = 'MM/@numer/'+@Rok+'/'+@Seria
      end
      SELECT top 1 @fplid=fpl_fplid FROM Cdn.FormyPlatnosci WHERE Fpl_Nieaktywny=0
      IF @fplid is NULL
      BEGIN
            SET @Komunikat = '##OPT34489##'--'Brak form płatności!'
                  RAISERROR( @Komunikat, 16, 1)
                  RETURN
      END
      SET @MagZrdId = 0
      SELECT @MagZrdId=Mag_MagId FROM Cdn.Magazyny WHERE Mag_GidNumer = @GidNumerMagZ
      if @MagZrdId = 0
        SELECT top 1 @MagZrdId=Mag_MagId FROM Cdn.Magazyny WHERE Mag_Typ = 2
      INSERT INTO Cdn.TraNag(TrN_DDfId,TrN_TypDokumentu,TrN_NumerNr,TrN_NumerString,
                         TrN_Bufor,TrN_DataDok,TrN_DataWys,TrN_DataOpe,TrN_NumerObcy,TrN_NumerPelnyPrw,
                        TrN_Korekta,TrN_Fiskalna,TrN_Detal,TrN_Rodzaj,TrN_PodmiotTyp,TrN_PodID,
                        TrN_PodNazwa1,TrN_PodNazwa2,TrN_PodNazwa3,TrN_PodKraj,TrN_PodWojewodztwo,
                         TrN_PodPowiat,TrN_PodGmina,TrN_PodUlica,TrN_PodNrDomu,TrN_PodNrLokalu,
                        TrN_PodMiasto,TrN_PodKodPocztowy,TrN_PodPoczta,TrN_PodAdres2,TrN_PodNipKraj,
                        TrN_PodNipE,TrN_PodmiotGLN,TrN_Finalny,TrN_Export,TrN_OdbiorcaTyp,TrN_OdbID,
                        TrN_OdbNazwa1,TrN_OdbNazwa2,TrN_OdbNazwa3,TrN_OdbKraj,TrN_OdbWojewodztwo,
                        TrN_OdbPowiat,TrN_OdbGmina,TrN_OdbUlica,TrN_OdbNrDomu,TrN_OdbNrLokalu,
                        TrN_OdbMiasto,TrN_OdbKodPocztowy,TrN_OdbPoczta,TrN_OdbAdres2,TrN_OdbNipKraj,
                        TrN_OdbNipE,TrN_OdbiorcaGLN,TrN_Kategoria,TrN_FPlId,TrN_Termin,TrN_RazemNetto,
                        TrN_RazemVAT,TrN_RazemBrutto,TrN_RazemNettoWal,TrN_RazemVATWal,TrN_RazemBruttoWal,
                        TrN_Waluta,TrN_KursNumer,TrN_KursL,TrN_KursM,TrN_PlatElemWalSys,TrN_BlokadaPlatnosci,
                        TrN_MagZrdId,TrN_MagDocId,TrN_TypNB,TrN_Rabat,TrN_Odebral,TrN_Opis,TrN_NotaKorPrzed,
                        TrN_NotaKorPo,TrN_TrSTyp,TrN_OpeZalID,TrN_OpeZalKod, TrN_OpeZalNazwisko, TrN_StaZalId, TrN_TS_Zal,TrN_OpeModID, TrN_OpeModKod, TrN_OpeModNazwisko,TrN_StaModId,
                        TrN_TS_Mod,TrN_GIDTyp,TrN_GIDFirma,TrN_GIDNumer,TrN_GIDLp,TrN_Centrala,TrN_KodTransakcji,TrN_KodKraju,TrN_Anulowany,
                        TrN_PlatKaucje,TrN_TaxFreePotwierdzony,TrN_VatDlaDokWal, TrN_DataKur,trn_platnikid, trn_platniktyp)
             VALUES(@DDfId,@TrN_TypDokumentu,@TrN_NumerNr,@TrN_NumerString,@Bufor,@TrN_DataDok,@TrN_DataWys,@TrN_DataOpe,@TrN_NumerObcy,'',0,0,0,@TrN_Rodzaj,1,1,'','',
                        '','','','','','','','','','','','','','','',1,0,1,1,'','','','','','','','','','','','','','','','','',
                        '',@fplid,GetDate(),@TrN_RazemNetto,@TrN_RazemVAT,@TrN_RazemNetto,@TrN_RazemNetto,@TrN_RazemVAT,
                        @TrN_RazemNetto,'',2,1,1,0,1,@MagZrdId,1,
      @TrN_TypNB,@TrN_Rabat,'',@TrN_Opis,'','',0,@IdOperator, @OpeModKod, @OpeModNazwisko,@IdStanowisko, GetDate(),@IdOperator, @OpeModKod, @OpeModNazwisko ,@IdStanowisko,
      GetDate(),@TrN_GIDTyp,@TrN_GIDFirma,@TrN_GIDNumer,@TrN_GIDLp,0,'','','',
      0,0,0,@TrN_DataDok,1,1)
 --      SELECT top 1 @Trn_TrnId=Trn_TrnId From Cdn.TraNag Where Trn_GidNumer = @TrN_GIDNumer and Trn_GidTyp= @TrN_GIDTyp
 --      INSERT INTO cdn.TraVat (TrV_TrNId, TrV_Stawka, TrV_Flaga, TrV_Zrodlowa, TrV_Netto,TrV_NettoWal, TrV_VAT,TrV_VATWal,TrV_Typ)
 --      SELECT TrE_TrNId,TrE_Stawka, TrE_Flaga, TrE_Zrodlowa, SUM(TrE_WartoscNetto),SUM(TrE_WartoscNetto),   ROUND(SUM(TrE_WartoscNetto) * TrE_Stawka / 100,2),ROUND(SUM(TrE_WartoscNetto) * TrE_Stawka / 100,2),0
 --                  FROM cdn.TraElem  JOIN cdn.TraNag ON TrN_TrNId = TrE_TrNId
 --                  WHERE TrE_TrNId = @Trn_TrnId  GROUP BY TrE_Stawka, TrE_Flaga, TrE_Zrodlowa,TrE_TrNId
  SET NOCOUNT OFF
