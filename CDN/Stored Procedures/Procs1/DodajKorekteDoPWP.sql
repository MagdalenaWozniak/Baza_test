CREATE PROCEDURE [CDN].[DodajKorekteDoPWP]
  @TrN_TrNId_Zrd      INT,
  @ServerCfgString    NVARCHAR(250),  -- nazwa serwera z bazą konfiguracyjną
  @BazaCfgString      NVARCHAR(250),  -- nazwa bazy konfiguracyjnej
  @Seria              NVARCHAR(20)=''
AS
SET NOCOUNT ON
 DECLARE
  @TrEIdRwsOrg   INT,
  @WartoscZakupu   decimal(15, 2),
  @WartoscZakupuReszta decimal(15, 2),
  @PdeId     INT,
  @TrNIdPWP    INT,
  @TrN_DDFId_Doc   INT,
  @TrN_OpeZalId_Doc  INT,           -- Opertor zalogowany do programu, który wykonuje operację przekształcenia
  @TrN_OpeZalKod  VARCHAR(20),
  @TrN_OpeZalNazwisko  NVARCHAR(50),
  @TrN_StaZalId_Doc  INT,           -- Sanowisko, z którego jest wykonywana operacja przekształcenia
  @TrN_MagZrdId_Doc  INT,
  @TrN_DataDok_Doc  DATETIME,
  @SeriaOperatora   NVARCHAR(5),
  @RejestrOperatora  NVARCHAR(20),
  @TrN_NumerString_Doc NVARCHAR(31),
  @TrN_NumerNr_Doc  INT,
  @TrN_TrNId_Doc   INT,
  @TrN_DataDok  DATETIME,
  @Komunikat    NVARCHAR(255),
  @NumerPelny  NVarchar(30) ,
  @TypDokumentu int
 if exists(select WZKK.TrN_ZwrIdWZKK,WZKK.trn_zwrid,RWS.TrN_TrNID  ,* from  cdn.tranag WZKK
 join cdn.tranag RWS on WZKK.trn_zwrid = RWS.TrN_TrNID
  where WZKK.TrN_ZwrIdWZKK = @TrN_TrNId_Zrd and RWS.trn_typdokumentu = 318)
  begin
   DECLARE @Roznice TABLE
   (
   TrEID int ,
   WartoscZakupu decimal(15, 2)
   )
    DECLARE @ProdElem TABLE(
   TRnIdPwPOrg int,
   TrEIdPWPOrg int,
   TrEIdRwsOrg int,
   ZwrId int,
   Lp smallint,
   DataWys datetime,
   DataOpe datetime,
   TwrId int,
   MagId int,
   TrEIdRWS int,
   Ilosc decimal(15, 4),
   JmCalkowite smallint,
   JMPrzelicznikL decimal(15, 2),
   JMPrzelicznikM decimal(7, 0),
   IloscJM decimal(15, 4),
   WartoscZakupu decimal(15, 2),
   Jm nvarchar(20),
   TwrTyp smallint )
   DECLARE @WZKKSklad TABLE
  (
   TrEId int,
   zwridWZKK int,
   elemidWZKK int,
   zwridRWS int ,
   WartoscZakupu decimal(15, 2),
   poziom int
   )
   insert into @WZKKSklad
   select  WZKKSklad.tre_TrEId,WZKKSklad.tre_zwrid,WZKKSklad.tre_zwrid,0, WZKKSklad.TrE_WartoscZakupu,0 from cdn.tranag WZKK
   join cdn.traelem WZKKSklad on WZKKSklad.tre_trnid = WZKK.trn_trnid
   where WZKK.TrN_ZwrIdWZKK = @TrN_TrNId_Zrd  and WZKK.TrN_TypDokumentu   = 306
   declare @a int
   select @a = 0
   WHILE 1=1
   BEGIN
   set @a=@a+1
   update @WZKKSklad set zwridRWS = tre_treid from @WZKKSklad
   join cdn.traelem on elemidWZKK =  tre_treid
   join cdn.tranag on tre_trnid = trn_trnid
   where TrE_TypDokumentu = 318 and trn_bufor != -1
   if not exists ( select * from  @WZKKSklad where zwridRWS = 0)
   Break
   update @WZKKSklad set elemidWZKK = tre_zwrid,poziom =@a from @WZKKSklad
   join cdn.traelem on tre_treid =  elemidWZKK
   join cdn.tranag on tre_trnid = trn_trnid
   where trn_bufor != -1
   if not exists ( select * from  @WZKKSklad where poziom = @a)
   Break
   END
   delete from @WZKKSklad where WartoscZakupu = 0
   if (select count(*) from @WZKKSklad) = 0
   return
   --select * from @WZKKSklad
  INSERT INTO @ProdElem
  select
   PWPElem.TrE_TrnId,
   ProdElem.PdE_TrEId,
   RWSSklad.TrE_TrEID,
   ProdElem.PdE_PdeId,
   ProdElem.PdE_Lp,
   getdate(),
   getdate(),
   ProdElem.PdE_TwrId,
   ProdElem.PdE_MagId,
   WZKKSklad.TrEId,
   ProdElem.PdE_Ilosc,
   ProdElem.PdE_JmCalkowite,
   ProdElem.PdE_JMPrzelicznikL,
   ProdElem.PdE_JMPrzelicznikM,
   0,
   WZKKSklad.WartoscZakupu/RWSSklad.tre_ilosc * ProdElem.pde_ilosc,
   ProdElem.PdE_Jm,
   ProdElem.PdE_TwrTyp
  from  cdn.ProdElem
  left join cdn.traelem PWPElem on PdE_TrEId = PWPElem.TrE_TrEId
  left join cdn.traelem  RWSSklad on PdE_TrEIdRWS = RWSSklad.TrE_TrEID
  left join cdn.tranag WZKK on WZKK.trn_zwrid = RWSSklad.tre_trnid
  join @WZKKSklad WZKKSklad on RWSSklad.TrE_TrEID =  WZKKSklad.zwridRWS
  where WZKK.TrN_ZwrIdWZKK = @TrN_TrNId_Zrd and RWSSklad.Tre_TypDokumentu = 318
  INSERT INTO @Roznice
  select RWSSklad.TrE_TrEID,WZKKSklad.WartoscZakupu from cdn.traelem  RWSSklad
  left join cdn.tranag WZKK on WZKK.trn_zwrid = RWSSklad.tre_trnid
  join @WZKKSklad WZKKSklad on RWSSklad.TrE_TrEID =  WZKKSklad.zwridRWS
  where WZKK.TrN_ZwrIdWZKK = @TrN_TrNId_Zrd and RWSSklad.Tre_TypDokumentu = 318
  DECLARE T CURSOR LOCAL FAST_FORWARD FOR
   SELECT TrEIdRwsOrg,WartoscZakupu,ZwrId FROM @ProdElem ORDER BY ZwrId
   OPEN T
     WHILE 1=1
     BEGIN
    FETCH NEXT FROM T INTO @TrEIdRwsOrg,@WartoscZakupu,@PdeId
    IF @@FETCH_STATUS <> 0 BREAK
     IF EXISTS (SELECT TrEIdRwsOrg FROM @ProdElem WHERE TrEIdRwsOrg = @TrEIdRwsOrg AND ZwrId > @PdeId )
     BEGIN
      UPDATE @Roznice SET
       WartoscZakupu = WartoscZakupu - @WartoscZakupu
      WHERE  TrEID = @TrEIdRwsOrg
     END
     ELSE
     BEGIN
      SELECT @WartoscZakupuReszta =  WartoscZakupu
      FROM @Roznice
      WHERE TrEID = @TrEIdRwsOrg
      UPDATE @ProdElem SET
       WartoscZakupu = @WartoscZakupuReszta
      WHERE  ZwrId = @PdeId
     UPDATE @Roznice SET
       WartoscZakupu = WartoscZakupu - @WartoscZakupu
      WHERE  TrEID = 0
     END
     END
   CLOSE T
    DEALLOCATE T
  SELECT @TrN_OpeZalId_Doc = TrN_OpeZalId,
   @TrN_OpeZalKod = TrN_OpeZalKod,
   @TrN_OpeZalNazwisko = TrN_OpeZalNazwisko,
      @TrN_StaZalId_Doc = TrN_StaZalId,
      @TrN_DataDok_Doc = TrN_DataOpe,
      @TrN_MagZrdId_Doc = TrN_MagZrdId
      FROM CDN.TraNag WHERE TrN_TrNId = @TrN_TrNId_Zrd
  SET @TrN_DDFId_Doc = CDN.DomyslnaDefinicja(317001)
    IF ( SELECT TOP 1 DDf_SeriaOperatora FROM cdn.DokDefinicje WHERE DDF_DDFId = @TrN_DDFId_Doc ) = 1
   EXEC CDN.SeriaOperatora @ServerCfgString, @BazaCfgString, @TrN_OpeZalId_Doc, @SeriaOperatora OUTPUT, @RejestrOperatora OUTPUT
    SET @SeriaOperatora = ISNULL(@SeriaOperatora, '')
    if @Seria <> '' and @SeriaOperatora = ''
    SET @SeriaOperatora = @Seria
   DECLARE T CURSOR LOCAL FAST_FORWARD FOR
   SELECT TRnIdPwPOrg FROM @ProdElem
   group by  TRnIdPwPOrg
   OPEN T
     WHILE 1=1
     BEGIN
    FETCH NEXT FROM T INTO @TrNIdPWP
    IF @@FETCH_STATUS <> 0 BREAK
    IF EXISTS (SELECT TRnIdPwPOrg FROM @ProdElem WHERE TRnIdPwPOrg = @TrNIdPWP )
    BEGIN
    set @TrN_DataDok = @TrN_DataDok_Doc
    select   @TrN_DataDok = case when @TrN_DataDok_Doc > A.TrN_DataOpe then @TrN_DataDok_Doc else A.TrN_DataOpe END
    FROM CDN.TraNag A
    WHERE A.TrN_TrNId = @TrNIdPWP
    SET @TrN_NumerString_Doc = CDN.NumerString
    (
       317001,
       @TrN_OpeZalId_Doc,
       @TrN_StaZalId_Doc,
       @TrN_MagZrdId_Doc,
       @TrN_DataDok,
       @SeriaOperatora,
       default,
       default,
       default
    )
    SET @Komunikat = CDN.SprawdzNumerString ( @TrN_DDFId_Doc, @TrN_NumerString_Doc )
    IF @Komunikat <> '' GOTO KOMUNIKAT
    SELECT @TrN_NumerNr_Doc = ISNULL(MAX(TrN_NumerNr),0) + 1 FROM cdn.TraNag WHERE TrN_NumerString = @TrN_NumerString_Doc
    INSERT INTO CDN.TraNag
       (TrN_RelTrNId
       ,TrN_FVMarza
       ,TrN_DDfId
       ,TrN_TypDokumentu
       ,TrN_ZwrId
       ,TrN_FaId
       ,TrN_NumerNr
       ,TrN_NumerString
       ,TrN_Bufor
       ,TrN_Anulowany
       ,TrN_VaNId
       ,TrN_DataDok
       ,TrN_DataWys
       ,TrN_DataOpe
       ,TrN_NumerObcy
       ,TrN_DataKur
       ,TrN_NumerPelnyPrw
       ,TrN_TaxFreePotwierdzony
       ,TrN_Korekta
       ,TrN_Fiskalna
       ,TrN_FiskalnaErr
       ,TrN_StatusInt
       ,TrN_RabatPromocyjny
       ,TrN_RabatKorekta
       ,TrN_Detal
       ,TrN_Rodzaj
       ,TrN_PodmiotTyp
       ,TrN_PodID
       ,TrN_PodNazwa1
       ,TrN_PodNazwa2
       ,TrN_PodNazwa3
       ,TrN_PodKraj
       ,TrN_PodWojewodztwo
       ,TrN_PodPowiat
       ,TrN_PodGmina
       ,TrN_PodUlica
       ,TrN_PodNrDomu
       ,TrN_PodNrLokalu
       ,TrN_PodMiasto
       ,TrN_PodKodPocztowy
       ,TrN_PodPoczta
       ,TrN_PodAdres2
       ,TrN_PodNipKraj
       ,TrN_PodNipE
       ,TrN_PodmiotGLN
       ,TrN_Finalny
       ,TrN_Export
       ,TrN_OdbiorcaTyp
       ,TrN_OdbID
       ,TrN_OdbNazwa1
       ,TrN_OdbNazwa2
       ,TrN_OdbNazwa3
       ,TrN_OdbKraj
       ,TrN_OdbWojewodztwo
       ,TrN_OdbPowiat
       ,TrN_OdbGmina
       ,TrN_OdbUlica
       ,TrN_OdbNrDomu
       ,TrN_OdbNrLokalu
       ,TrN_OdbMiasto
       ,TrN_OdbKodPocztowy
       ,TrN_OdbPoczta
       ,TrN_OdbAdres2
       ,TrN_OdbNipKraj
       ,TrN_OdbNipE
       ,TrN_OdbiorcaGLN
       ,TrN_OdbiorcaDocTyp
       ,TrN_OdbDocID
       ,TrN_OdbTelefon
       ,TrN_OdbEmail
       ,TrN_KatID
       ,TrN_Kategoria
       ,TrN_FPlId
       ,TrN_Termin
       ,TrN_TerminZwrotuKaucji
       ,TrN_RazemNetto
       ,TrN_RazemVAT
       ,TrN_RazemBrutto
       ,TrN_RazemNettoWal
       ,TrN_RazemVATWal
       ,TrN_RazemBruttoWal
       ,TrN_Waluta
       ,TrN_KursNumer
       ,TrN_KursL
       ,TrN_KursM
       ,TrN_PlatElemWalSys
       ,TrN_VatDlaDokWal
       ,TrN_PlatKaucje
       ,TrN_PodmiotZalTyp
       ,TrN_PodZalId
       ,TrN_BlokadaPlatnosci
       ,TrN_MagZrdId
       ,TrN_MagDocId
       ,TrN_TypNB
       ,TrN_Rabat
       ,TrN_Odebral
       ,TrN_Opis
       ,TrN_ZwroconoCalaIlosc
       ,TrN_NotaKorPrzed
       ,TrN_NotaKorPo
       ,TrN_TrSTyp
       ,TrN_DekId
       ,TrN_TS_Export
       ,TrN_OpeZalID
       ,TrN_OpeZalKod
       ,TrN_OpeZalNazwisko
       ,TrN_StaZalId
       ,TrN_TS_Zal
       ,TrN_OpeModID
       ,TrN_OpeModKod
       ,TrN_OpeModNazwisko
       ,TrN_StaModId
       ,TrN_TS_Mod
       ,TrN_GIDTyp
       ,TrN_GIDFirma
       ,TrN_GIDNumer
       ,TrN_GIDLp
       ,TrN_OFFPrawoDoFAPA
       ,TrN_OFFPrawoDoAnulowania
       ,TrN_OFFExportMag
       ,TrN_Centrala
       ,TrN_KodTransakcji
       ,TrN_IsNId
       ,TrN_DataTransportu
       ,TrN_KodKraju
       ,TrN_DabId
       ,TrN_DataEFaktura
       ,TrN_OpeWysylajacy
       ,TrN_EFakturaGUID
       ,TrN_DataPtwTaxFree
       ,TrN_PreDekID
       ,TrN_TrybNettoVAT
       ,TrN_NieOkreslonaWartoscKor
       ,TrN_PodatekVat
       ,TrN_ZwrIdWZKK
       ,TrN_OpeZatwID
       ,TrN_OpeZatwKod
       ,TrN_OpeZatwNazwisko
       ,TrN_TS_Zatw
       ,TrN_PCId
       ,TrN_PCJSID)
    SELECT
       A.TrN_RelTrNId
       ,A.TrN_FVMarza
       ,@TrN_DDFId_Doc
       ,317
       ,case when ISNULL(A.TrN_ZwrID,0) > 0 then  A.TrN_ZwrID else  A.TrN_TrNId end
       ,NULL
       ,@TrN_NumerNr_Doc
       ,@TrN_NumerString_Doc
       ,A.TrN_Bufor
       ,A.TrN_Anulowany
       ,A.TrN_VaNId
       ,@TrN_DataDok
       ,@TrN_DataDok
       ,@TrN_DataDok
       ,A.TrN_NumerObcy
       ,A.TrN_DataKur
       ,A.TrN_NumerPelnyPrw
       ,A.TrN_TaxFreePotwierdzony
       ,2
       ,A.TrN_Fiskalna
       ,A.TrN_FiskalnaErr
       ,A.TrN_StatusInt
       ,A.TrN_RabatPromocyjny
       ,A.TrN_RabatKorekta
       ,A.TrN_Detal
       ,317001
       ,A.TrN_PodmiotTyp
       ,A.TrN_PodID
       ,A.TrN_PodNazwa1
       ,A.TrN_PodNazwa2
       ,A.TrN_PodNazwa3
       ,A.TrN_PodKraj
       ,A.TrN_PodWojewodztwo
       ,A.TrN_PodPowiat
       ,A.TrN_PodGmina
       ,A.TrN_PodUlica
       ,A.TrN_PodNrDomu
       ,A.TrN_PodNrLokalu
       ,A.TrN_PodMiasto
       ,A.TrN_PodKodPocztowy
       ,A.TrN_PodPoczta
       ,A.TrN_PodAdres2
       ,A.TrN_PodNipKraj
       ,A.TrN_PodNipE
       ,A.TrN_PodmiotGLN
       ,A.TrN_Finalny
       ,A.TrN_Export
       ,A.TrN_OdbiorcaTyp
       ,A.TrN_OdbID
       ,A.TrN_OdbNazwa1
       ,A.TrN_OdbNazwa2
       ,A.TrN_OdbNazwa3
       ,A.TrN_OdbKraj
       ,A.TrN_OdbWojewodztwo
       ,A.TrN_OdbPowiat
       ,A.TrN_OdbGmina
       ,A.TrN_OdbUlica
       ,A.TrN_OdbNrDomu
       ,A.TrN_OdbNrLokalu
       ,A.TrN_OdbMiasto
       ,A.TrN_OdbKodPocztowy
       ,A.TrN_OdbPoczta
       ,A.TrN_OdbAdres2
       ,A.TrN_OdbNipKraj
       ,A.TrN_OdbNipE
       ,A.TrN_OdbiorcaGLN
       ,A.TrN_OdbiorcaDocTyp
       ,A.TrN_OdbDocID
       ,A.TrN_OdbTelefon
       ,A.TrN_OdbEmail
       ,A.TrN_KatID
       ,A.TrN_Kategoria
       ,A.TrN_FPlId
       ,A.TrN_Termin
       ,A.TrN_TerminZwrotuKaucji
       ,0
       ,0
       ,0
       ,0
       ,0
       ,0
       ,A.TrN_Waluta
       ,A.TrN_KursNumer
       ,A.TrN_KursL
       ,A.TrN_KursM
       ,A.TrN_PlatElemWalSys
       ,A.TrN_VatDlaDokWal
       ,A.TrN_PlatKaucje
       ,A.TrN_PodmiotZalTyp
       ,A.TrN_PodZalId
       ,A.TrN_BlokadaPlatnosci
       ,A.TrN_MagZrdId
       ,A.TrN_MagDocId
       ,A.TrN_TypNB
       ,0
       ,A.TrN_Odebral
       ,'Korekta wartości na podstawie WZKK do RWS'
       ,A.TrN_ZwroconoCalaIlosc
       ,A.TrN_NotaKorPrzed
       ,A.TrN_NotaKorPo
       ,A.TrN_TrSTyp
       ,NULL
       ,NULL
       ,@TrN_OpeZalId_Doc
       ,@TrN_OpeZalKod
       ,@TrN_OpeZalNazwisko
       ,@TrN_StaZalId_Doc
       ,GETDATE()
       ,@TrN_OpeZalId_Doc
       ,@TrN_OpeZalKod
       ,@TrN_OpeZalNazwisko
       ,@TrN_StaZalId_Doc
       ,GETDATE()
       ,NULL
       ,NULL
       ,NULL
       ,NULL
       ,A.TrN_OFFPrawoDoFAPA
       ,A.TrN_OFFPrawoDoAnulowania
       ,A.TrN_OFFExportMag
       ,A.TrN_Centrala
       ,A.TrN_KodTransakcji
       ,A.TrN_IsNId
       ,A.TrN_DataTransportu
       ,A.TrN_KodKraju
       ,A.TrN_DabId
       ,A.TrN_DataEFaktura
       ,A.TrN_OpeWysylajacy
       ,A.TrN_EFakturaGUID
       ,A.TrN_DataPtwTaxFree
       ,A.TrN_PreDekID
       ,A.TrN_TrybNettoVAT
       ,A.TrN_NieOkreslonaWartoscKor
       ,A.TrN_PodatekVat
       ,@TrN_TrNId_Zrd
       ,@TrN_OpeZalId_Doc
       ,@TrN_OpeZalKod
       ,case when @TrN_OpeZalNazwisko= '' then @TrN_OpeZalKod else @TrN_OpeZalNazwisko end
       ,GETDATE()
       ,A.TrN_PCId
       ,A.TrN_PCJSID
      FROM CDN.TraNag A
      WHERE A.TrN_TrNId = @TrNIdPWP
      SET @TrN_TrNId_Doc = SCOPE_IDENTITY()
      --logi
      select @NumerPelny = TrN_numerPelny,@TypDokumentu = trn_typdokumentu from cdn.tranag where trn_trnid = @TrN_TrNId_Doc
      exec [CDN].[RejestrOperacjiDodaj] @TypDokumentu,0, @TrN_TrNId_Doc, @NumerPelny, 1, ''
   /*
      --   dodajemy atrybuty
     IF EXISTS(SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=1823 and Fir_Wartosc = '1' and CONVERT(INT, @TrN_Rodzaj_Doc/1000) IN (306, 307))
   BEGIN
     INSERT INTO CDN.DokAtrybuty
    (
    DAt_DeAId,
    DAt_Kod,
    DAt_WartoscTxt,
    DAt_TrNId
     )
     SELECT
     DAt_DeAId,
     DAt_Kod,
     DAt_WartoscTxt,
     @TrN_TrNId_Doc
     FROM CDN.DokAtrybuty
     WHERE DaT_TrNId = @TrN_TrNId_Zrd
   END
   */
   INSERT INTO CDN.TraElem
       (TrE_TrNId
       ,TrE_ZwrId
       ,TrE_TrEIdProd
       ,TrE_PdRId
       ,TrE_Lp
       ,TrE_LpPow
       ,TrE_LpPowRel
       ,TrE_TypDokumentu
       ,TrE_Aktywny
       ,TrE_DataDok
       ,TrE_RabatPromocyjny
       ,TrE_RabatKorekta
       ,TrE_Promocje
       ,TrE_DataOpe
       ,TrE_PodmiotTyp
       ,TrE_PodID
       ,TrE_KatID
       ,TrE_TwrId
       ,TrE_MagId
       ,TrE_TwrNazwa
       ,TrE_TwrEAN
       ,TrE_TwrTyp
       ,TrE_TwrKodDostawcy
       ,TrE_TwrNumerKat
       ,TrE_TwrKod
       ,TrE_TwrOpis
       ,TrE_TwrSWW
       ,TrE_Stawka
       ,TrE_Flaga
       ,TrE_Zrodlowa
       ,TrE_TwCNumer
       ,TrE_TypNB
       ,TrE_Cena0
       ,TrE_Rabat
       ,TrE_CenaW
       ,TrE_Waluta
       ,TrE_Kaucja
       ,TrE_WyborDostaw
       ,TrE_KursNumer
       ,TrE_KursL
       ,TrE_KursM
       ,TrE_CenaT
       ,TrE_Ilosc
       ,TrE_IloscKW
       ,TrE_Jm
       ,TrE_JmZ
       ,TrE_JmCalkowite
       ,TrE_JMPrzelicznikL
       ,TrE_JMPrzelicznikM
       ,TrE_IloscJM
       ,TrE_IloscJMKW
       ,TrE_WartoscNetto
       ,TrE_WartoscBrutto
       ,TrE_KosztUslugi
       ,TrE_KosztKGO
       ,TrE_WartoscZakupuWylicz
       ,TrE_Cena0WD
       ,TrE_CenaWWD
       ,TrE_WartoscNettoWal
       ,TrE_WartoscBruttoWal
       ,TrE_WartoscTymczasowa
       ,TrE_Atr1_DeAId
       ,TrE_Atr1_Kod
       ,TrE_Atr1_Wartosc
       ,TrE_Atr2_DeAId
       ,TrE_Atr2_Kod
       ,TrE_Atr2_Wartosc
       ,TrE_Atr3_DeAId
       ,TrE_Atr3_Kod
       ,TrE_Atr3_Wartosc
       ,TrE_Atr4_DeAId
       ,TrE_Atr4_Kod
       ,TrE_Atr4_Wartosc
       ,TrE_Atr5_DeAId
       ,TrE_Atr5_Kod
       ,TrE_Atr5_Wartosc
       ,TrE_Prog
       ,TrE_UpustTyp
       ,TrE_Upust
       ,TrE_UpustKnt
       ,TrE_UpustKntTyp)
     select
    @TrN_TrNId_Doc
    ,TrE_trEId
    ,TrE_TrEIdProd
    ,TrE_PdRId
    ,TrE_Lp
    ,TrE_LpPow
    ,TrE_LpPowRel
    ,TrE_TypDokumentu
    ,TrE_Aktywny
    ,@TrN_DataDok
    ,TrE_RabatPromocyjny
    ,TrE_RabatKorekta
    ,TrE_Promocje
    ,@TrN_DataDok
    ,TrE_PodmiotTyp
    ,TrE_PodID
    ,TrE_KatID
    ,TrE_TwrId
    ,TrE_MagId
    ,TrE_TwrNazwa
    ,TrE_TwrEAN
    ,TrE_TwrTyp
    ,TrE_TwrKodDostawcy
    ,TrE_TwrNumerKat
    ,TrE_TwrKod
    ,TrE_TwrOpis
    ,TrE_TwrSWW
    ,TrE_Stawka
    ,TrE_Flaga
    ,TrE_Zrodlowa
    ,TrE_TwCNumer
    ,TrE_TypNB
    ,0
    ,0
    ,0
    ,TrE_Waluta
    ,TrE_Kaucja
    ,0
    ,TrE_KursNumer
    ,TrE_KursL
    ,TrE_KursM
    ,0
    ,0
    ,0
    ,TrE_Jm
    ,TrE_JmZ
    ,TrE_JmCalkowite
    ,TrE_JMPrzelicznikL
    ,TrE_JMPrzelicznikM
    ,0
    ,0
    ,0
    ,0
    ,0--TrE_KosztUslugi
    ,TrE_KosztKGO
    ,0
    ,0
    ,0
    --,TrE_WartoscNettoWal
    ,0
    --,TrE_WartoscBruttoWal
    ,0
    ,0
    ,TrE_Atr1_DeAId
    ,TrE_Atr1_Kod
    ,TrE_Atr1_Wartosc
    ,TrE_Atr2_DeAId
    ,TrE_Atr2_Kod
    ,TrE_Atr2_Wartosc
    ,TrE_Atr3_DeAId
    ,TrE_Atr3_Kod
    ,TrE_Atr3_Wartosc
    ,TrE_Atr4_DeAId
    ,TrE_Atr4_Kod
    ,TrE_Atr4_Wartosc
    ,TrE_Atr5_DeAId
    ,TrE_Atr5_Kod
    ,TrE_Atr5_Wartosc
    ,TrE_Prog
    ,TrE_UpustTyp
    ,TrE_Upust
    ,TrE_UpustKnt
    ,TrE_UpustKntTyp
   FROM cdn.traelem TrE_trEId
   where  TrE_trEId in (
   select TrEIdPWPOrg from @ProdElem
   where  TRnIdPwPOrg = @TrNIdPWP
   group by TrEIdPWPOrg
   )
   INSERT INTO [CDN].[ProdElem]
       ([PdE_TrEId]
       ,[PdE_ZwrId]
       ,[PdE_Lp]
       ,[PdE_DataWys]
       ,[PdE_DataOpe]
       ,[PdE_TwrId]
       ,[PdE_MagId]
       ,[PdE_TrEIdRWS]
       ,[PdE_Ilosc]
       ,[PdE_JmCalkowite]
       ,[PdE_JMPrzelicznikL]
       ,[PdE_JMPrzelicznikM]
       ,[PdE_IloscJM]
       ,[PdE_WartoscZakupu]
       ,[PdE_Jm]
       ,[Pde_TwrTyp])
   select
    tre_treid,
    ZwrId ,
    Lp ,
    @TrN_DataDok ,
    @TrN_DataDok ,
    TwrId ,
    MagId ,
    TrEIdRWS ,
    Ilosc ,
    JmCalkowite ,
    JMPrzelicznikL ,
    JMPrzelicznikM ,
    IloscJM ,
    WartoscZakupu ,
    Jm,
    TwrTyp
    FROM @ProdElem
    left join cdn.traelem on TrE_ZwrId = TrEIdPWPOrg
    where  TRnIdPwPOrg = @TrNIdPWP and Tre_trnid = @TrN_TrNId_Doc
    INSERT INTO [CDN].[TraElemAtr]
           ([TrA_TrEId]
           ,[TrA_Lp]
           ,[TrA_DeAId]
           ,[TrA_Kod]
           ,[TrA_Wartosc]
           ,[TrA_ESklep])
    select
     tre_treid,
           TrA_Lp,
           TrA_DeAId,
           TrA_Kod,
           TrA_Wartosc,
           TrA_ESklep
    FROM cdn.TraElemAtr
    left join @ProdElem on TrA_TrEId = TrEIdPWPOrg
    left join cdn.traelem on TrE_ZwrId = TrEIdPWPOrg
    where  TRnIdPwPOrg = @TrNIdPWP and Tre_trnid = @TrN_TrNId_Doc
   update cdn.traelem set TrE_Aktywny = 2
   FROM cdn.traelem
    where Tre_trnid = @TrN_TrNId_Doc
   DELETE FROM CDN.TraVat WHERE TrV_TrNId = @TrN_TrNId_Doc
   EXEC CDN.AktualizujTraVATTraNag @TrN_TrNId_Doc
  /*
   INSERT INTO [CDN].[TraNagRelacje]
         ([TrR_TrNTyp]
         ,[TrR_TrNId]
         ,[TrR_FaTyp]
         ,[TrR_FaId]
         ,[TrR_Flaga])
       VALUES
         (317
         ,@TrN_TrNId_Doc
         ,307
         ,@TrN_TrNId_Zrd
         ,0)
   */
   --jesli towar złozony jest na innym pwp to dla pewności
   exec cdn.DodajKorekteDoPWP @TrN_TrNId_Doc, @ServerCfgString,@BazaCfgString
    END
     END
   CLOSE T
    DEALLOCATE T
  KOMUNIKAT:
    IF @Komunikat <> ''
   BEGIN
     RAISERROR( @Komunikat, 16, 1)
     ROLLBACK TRAN
     SET NOCOUNT OFF
     RETURN
   END
 end
SET NOCOUNT OFF
