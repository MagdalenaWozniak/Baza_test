CREATE PROCEDURE CDN.AktualizujDaneKnt
@TrNIDStr TEXT,
@ZmianaExport int,
@Offline int,
@OpeId int = 0,
@sData nvarchar(30) = ''
AS
BEGIN
DECLARE
 @PodmiotID int,
 @PodmiotTyp int,
 @OdbiorcaID int,
 @OdbiorcaTyp int,
 @Count int,
 @Data DATETIME,
 @TrNId int,
 @Typ  int,
 @NumerPelny nvarchar(30),
 @Komunikat                 NVARCHAR(255)
 declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @OpeId, @OpeModKod OUT, @OpeModNazwisko OUT
 select @Data = CONVERT(DATETIME, @sData,    120 )
 IF @sData = ''
  select @Data = GETDATE()
 SELECT @Count= count(*) from ( SELECT TrN_PodId FROM CDN.TraNag WHERE TrN_TrNID IN (SELECT NextIdInt FROM CDN.Text2TableInt(@TrNIDStr)) GROUP BY TrN_PodmiotTyp, TrN_PodID) as a
 IF @Count <> 1
            BEGIN
              SET @Komunikat = '##OPT34458##'--' Nie można poprawić danych podmiotu. Zaznaczone dokumenty wystawione są dla różnych podmiotów!'
              RAISERROR( @Komunikat, 16, 1)
              SET NOCOUNT OFF
              RETURN
            END
 SELECT @Count= count(*) from ( SELECT TrN_OdbId FROM CDN.TraNag WHERE TrN_TrNID IN (SELECT NextIdInt FROM CDN.Text2TableInt(@TrNIDStr)) GROUP BY TrN_OdbiorcaTyp, TrN_OdbID) as a
 IF @Count <> 1
            BEGIN
              SET @Komunikat = '##OPT34458##'--' Nie można poprawić danych podmiotu. Zaznaczone dokumenty wystawione są dla różnych podmiotów!'
              RAISERROR( @Komunikat, 16, 1)
              SET NOCOUNT OFF
              RETURN
            END
 SELECT @Count = COUNT(*) FROM CDN.TraNag WHERE TrN_TrNID IN (SELECT NextIdInt FROM CDN.Text2TableInt(@TrNIDStr)) AND (TrN_DeKID IS NOT NULL OR TrN_VaNID IS NOT NULL)
 IF @Count > 0
            BEGIN
              SET @Komunikat = '##OPT34459##'--' Nie można poprawić danych podmiotu. Niektóre z zaznaczonych dokumentów są już zaksięgowane!'
              RAISERROR( @Komunikat, 16, 1)
              SET NOCOUNT OFF
              RETURN
            END
    SELECT @Count = COUNT(*) FROM CDN.TraNag WHERE TrN_TrNID IN (SELECT NextIdInt FROM CDN.Text2TableInt(@TrNIDStr)) AND TrN_TS_Export IS NOT NULL
 IF (@Count > 0 and @Offline = 1) or (@Count > 0 and @ZmianaExport = 0)
            BEGIN
              SET @Komunikat = '##OPT34460##'--' Nie można poprawić danych podmiotu. Niektóre z zaznaczonych dokumentów zostały wyeksportowane do centrali!'
              RAISERROR( @Komunikat, 16, 1)
              SET NOCOUNT OFF
              RETURN
            END
 SELECT @Count = COUNT(*) FROM CDN.TraNag WHERE TrN_TrNID IN (SELECT NextIdInt FROM CDN.Text2TableInt(@TrNIDStr)) AND TrN_Bufor = -1
 IF @Count > 0
            BEGIN
              SET @Komunikat = '##OPT34461##'--' Nie można poprawić danych podmiotu. Niektóre z zaznaczonych dokumentów zostały anulowane!'
              RAISERROR( @Komunikat, 16, 1)
              SET NOCOUNT OFF
              RETURN
            END
 SELECT DISTINCT @PodmiotTyp=Trn_PodmiotTyp, @PodmiotID=TrN_PodID, @OdbiorcaID=TrN_OdbID, @OdbiorcaTyp=TrN_OdbiorcaTyp FROM CDN.TraNag WHERE TrN_TrNID IN (SELECT NextIdInt FROM CDN.Text2TableInt(@TrNIDStr))
-- Poprawiamy dane podmiotu
-- Kontrahent
 IF @PodmiotTyp = 1
 BEGIN
   UPDATE CDN.TraNag SET
  [TrN_PodNazwa1] = case when isnull(k.Knt_CJBId,0) = 0 then k.Knt_Nazwa1 else  cjb.Knt_Nazwa1 end,
  [TrN_PodNazwa2] = case when isnull(k.Knt_CJBId,0) = 0 then k.Knt_Nazwa2 else  cjb.Knt_Nazwa2 end ,
  [TrN_PodNazwa3] = case when isnull(k.Knt_CJBId,0) = 0 then k.Knt_Nazwa3 else  cjb.Knt_Nazwa3 end,
  [TrN_PodKraj] = case when isnull(k.Knt_CJBId,0) = 0 then k.Knt_Kraj else  cjb.Knt_Kraj end,
  [TrN_PodWojewodztwo] = case when isnull(k.Knt_CJBId,0) = 0 then k.Knt_Wojewodztwo else  cjb.Knt_Wojewodztwo end,
  [TrN_PodPowiat] = case when isnull(k.Knt_CJBId,0) = 0 then k.Knt_Powiat else  cjb.Knt_Powiat end,
  [TrN_PodGmina] = case when isnull(k.Knt_CJBId,0) = 0 then k.Knt_Gmina else  cjb.Knt_Gmina end,
  [TrN_PodUlica] = case when isnull(k.Knt_CJBId,0) = 0 then k.Knt_Ulica else  cjb.Knt_Ulica end,
  [TrN_PodNrDomu] = case when isnull(k.Knt_CJBId,0) = 0 then k.Knt_NrDomu else  cjb.Knt_NrDomu end,
  [TrN_PodNrLokalu] = case when isnull(k.Knt_CJBId,0) = 0 then k.Knt_NrLokalu else  cjb.Knt_NrLokalu end,
  [TrN_PodMiasto] = case when isnull(k.Knt_CJBId,0) = 0 then k.Knt_Miasto else  cjb.Knt_Miasto end,
  [TrN_PodKodPocztowy] = case when isnull(k.Knt_CJBId,0) = 0 then k.Knt_KodPocztowy else  cjb.Knt_KodPocztowy end,
  [TrN_PodPoczta] = case when isnull(k.Knt_CJBId,0) = 0 then k.Knt_Poczta else  cjb.Knt_Poczta end,
  [TrN_PodAdres2] = case when isnull(k.Knt_CJBId,0) = 0 then k.Knt_Adres2 else  cjb.Knt_Adres2 end,
  [TrN_PodNipKraj] = case when isnull(k.Knt_CJBId,0) = 0 then k.Knt_NipKraj else  cjb.Knt_NipKraj end,
  [TrN_ZwolnionyZAkcyzy] = case when isnull(k.Knt_CJBId,0) = 0 then k.Knt_ZwolnionyZAkcyzy else  cjb.Knt_ZwolnionyZAkcyzy end,
  [TrN_Pesel] = case when isnull(k.Knt_CJBId,0) = 0 then k.Knt_Pesel else  cjb.Knt_Pesel end,
  [TrN_PodNipE]   = case when isnull(k.Knt_CJBId,0) = 0 then  Case When TrN_TypDokumentu=350 AND k.Knt_NipE='' THEN k.Knt_Pesel ELSE k.Knt_NipE END else  Case When TrN_TypDokumentu=350 AND cjb.Knt_NipE='' THEN cjb.Knt_Pesel ELSE cjb.Knt_NipE END end,
  [TrN_OpeModID] = case when @OpeId > 0 then @OpeId else TrN_OpeModID end,
  [TrN_OpeModKod] = case when @OpeId > 0 then @OpeModKod else TrN_OpeModKod end,
  [TrN_OpeModNazwisko] = case when @OpeId > 0 then @OpeModNazwisko else TrN_OpeModNazwisko end,
  [TrN_TS_Mod] = GETDATE(),
  [TrN_PodatekVat] = case when isnull(k.Knt_CJBId,0) = 0 then k.Knt_PodatekVat else  cjb.Knt_PodatekVat end,
  [TrN_DokumentTozsamosci] = case when isnull(k.Knt_CJBId,0) = 0 then k.Knt_DokumentTozsamosci else cjb.Knt_DokumentTozsamosci end
   FROM CDN.Kontrahenci k
   left join cdn.Kontrahenci cjb on k.Knt_CJBId = cjb.knt_kntid
   WHERE k.Knt_KntID = @PodmiotID AND TrN_TrNID IN (SELECT NextIdInt FROM CDN.Text2TableInt(@TrNIDStr))
 END
-- Bank
 IF @PodmiotTyp = 2
 BEGIN
   UPDATE CDN.TraNag SET
  [TrN_PodNazwa1] = b.BNa_Nazwa1,
  [TrN_PodNazwa2] = b.BNa_Nazwa2,
--  [TrN_PodNazwa3] = b.BNa_Nazwa3,
  [TrN_PodKraj] = b.BNa_Kraj,
  [TrN_PodWojewodztwo] = b.BNa_Wojewodztwo,
  [TrN_PodPowiat] = b.BNa_Powiat,
  [TrN_PodGmina] = b.BNa_Gmina,
  [TrN_PodUlica] = b.BNa_Ulica,
  [TrN_PodNrDomu] = b.BNa_NrDomu,
  [TrN_PodNrLokalu] = b.BNa_NrLokalu,
  [TrN_PodMiasto] = b.BNa_Miasto,
  [TrN_PodKodPocztowy] = b.BNa_KodPocztowy,
  [TrN_PodPoczta] = b.BNa_Poczta,
  [TrN_PodAdres2] = b.BNa_Adres2,
  [TrN_OpeModID] = case when @OpeId > 0 then @OpeId else TrN_OpeModID end,
  [TrN_OpeModKod] = case when @OpeId > 0 then @OpeModKod else TrN_OpeModKod end,
  [TrN_OpeModNazwisko] = case when @OpeId > 0 then @OpeModNazwisko else TrN_OpeModNazwisko end,
  [TrN_TS_Mod] = GETDATE()
--  [TrN_PodNipE] = b.BNa_NipE
   FROM CDN.BnkNazwy b WHERE b.BNa_BNaID = @PodmiotID AND TrN_TrNID IN (SELECT NextIdInt FROM CDN.Text2TableInt(@TrNIDStr))
 END
-- Pracownik i wspólnik
 IF @PodmiotTyp = 3 OR @PodmiotTyp = 4
 BEGIN
   UPDATE CDN.TraNag SET
  [TrN_PodNazwa1] = p.PRE_Nazwisko,
  [TrN_PodNazwa2] = p.PRE_Imie1,
--  [TrN_PodNazwa3] = p.BNa_Nazwa3,
  [TrN_PodKraj] = p.PRE_MLDKraj,
  [TrN_PodWojewodztwo] = p.PRE_MLDWojewodztwo,
  [TrN_PodPowiat] = p.PRE_MLDPowiat,
  [TrN_PodGmina] = p.PRE_MLDGmina,
  [TrN_PodUlica] = p.PRE_MLDUlica,
  [TrN_PodNrDomu] = p.PRE_MLDNrDomu,
  [TrN_PodNrLokalu] = p.PRE_MLDNrLokalu,
  [TrN_PodMiasto] = p.PRE_MLDMiasto,
  [TrN_PodKodPocztowy] = p.PRE_MLDKodPocztowy,
  [TrN_PodPoczta] = p.PRE_MLDPoczta,
  [TrN_PodAdres2] = p.PRE_MLDAdres2,
  [TrN_Pesel] = p.PRE_Pesel,
  [TrN_OpeModID] = case when @OpeId > 0 then @OpeId else TrN_OpeModID end,
  [TrN_OpeModKod] = case when @OpeId > 0 then @OpeModKod else TrN_OpeModKod end,
  [TrN_OpeModNazwisko] = case when @OpeId > 0 then @OpeModNazwisko else TrN_OpeModNazwisko end,
  [TrN_TS_Mod] = GETDATE()
   FROM CDN.PracEtaty p WHERE p.PRE_PreID = @PodmiotID AND TrN_TrNID IN (SELECT NextIdInt FROM CDN.Text2TableInt(@TrNIDStr))
 END
-- Urzad
 IF @PodmiotTyp = 5
 BEGIN
   UPDATE CDN.TraNag SET
  [TrN_PodNazwa1] = u.Urz_Nazwa1,
  [TrN_PodNazwa2] = u.Urz_Nazwa2,
--  [TrN_PodNazwa3] = u.Urz_Nazwa3,
  [TrN_PodKraj] = u.Urz_Kraj,
  [TrN_PodWojewodztwo] = u.Urz_Wojewodztwo,
  [TrN_PodPowiat] = u.Urz_Powiat,
  [TrN_PodGmina] = u.Urz_Gmina,
  [TrN_PodUlica] = u.Urz_Ulica,
  [TrN_PodNrDomu] = u.Urz_NrDomu,
  [TrN_PodNrLokalu] = u.Urz_NrLokalu,
  [TrN_PodMiasto] = u.Urz_Miasto,
  [TrN_PodKodPocztowy] = u.Urz_KodPocztowy,
  [TrN_PodPoczta] = u.Urz_Poczta,
  [TrN_PodAdres2] = u.Urz_Adres2,
  [TrN_OpeModID] = case when @OpeId > 0 then @OpeId else TrN_OpeModID end,
  [TrN_OpeModKod] = case when @OpeId > 0 then @OpeModKod else TrN_OpeModKod end,
  [TrN_OpeModNazwisko] = case when @OpeId > 0 then @OpeModNazwisko else TrN_OpeModNazwisko end,
  [TrN_TS_Mod] = GETDATE()
--  [TrN_PodNipE] = u.Urz_NipE
   FROM CDN.Urzedy u WHERE u.Urz_UrzID = @PodmiotID AND TrN_TrNID IN (SELECT NextIdInt FROM CDN.Text2TableInt(@TrNIDStr))
 END
-- Poprawiamy dane odbiorcy
-- Kontrahent
 IF @OdbiorcaTyp = 1
 BEGIN
   UPDATE CDN.TraNag SET
  [TrN_OdbNazwa1] = k.Knt_Nazwa1,
  [TrN_OdbNazwa2] = k.Knt_Nazwa2,
  [TrN_OdbNazwa3] = k.Knt_Nazwa3,
  [TrN_OdbKraj] = k.Knt_Kraj,
  [TrN_OdbWojewodztwo] = k.Knt_Wojewodztwo,
  [TrN_OdbPowiat] = k.Knt_Powiat,
  [TrN_OdbGmina] = k.Knt_Gmina,
  [TrN_OdbUlica] = k.Knt_Ulica,
  [TrN_OdbNrDomu] = k.Knt_NrDomu,
  [TrN_OdbNrLokalu] = k.Knt_NrLokalu,
  [TrN_OdbMiasto] = k.Knt_Miasto,
  [TrN_OdbKodPocztowy] = k.Knt_KodPocztowy,
  [TrN_OdbPoczta] = k.Knt_Poczta,
  [TrN_OdbAdres2] = k.Knt_Adres2,
  [TrN_OdbNipKraj] = k.Knt_NipKraj,
  [TrN_OdbNipE] = k.Knt_NipE
   FROM CDN.Kontrahenci k WHERE k.Knt_KntID = @OdbiorcaID AND TrN_TrNID IN (SELECT NextIdInt FROM CDN.Text2TableInt(@TrNIDStr))
 END
-- Bank
 IF @OdbiorcaTyp = 2
 BEGIN
   UPDATE CDN.TraNag SET
  [TrN_OdbNazwa1] = b.BNa_Nazwa1,
  [TrN_OdbNazwa2] = b.BNa_Nazwa2,
  [TrN_OdbKraj] = b.BNa_Kraj,
  [TrN_OdbWojewodztwo] = b.BNa_Wojewodztwo,
  [TrN_OdbPowiat] = b.BNa_Powiat,
  [TrN_OdbGmina] = b.BNa_Gmina,
  [TrN_OdbUlica] = b.BNa_Ulica,
  [TrN_OdbNrDomu] = b.BNa_NrDomu,
  [TrN_OdbNrLokalu] = b.BNa_NrLokalu,
  [TrN_OdbMiasto] = b.BNa_Miasto,
  [TrN_OdbKodPocztowy] = b.BNa_KodPocztowy,
  [TrN_OdbPoczta] = b.BNa_Poczta,
  [TrN_OdbAdres2] = b.BNa_Adres2
--  [TrN_OdbNipE] = b.BNa_NipE
   FROM CDN.BnkNazwy b WHERE b.BNa_BNaID = @OdbiorcaID AND TrN_TrNID IN (SELECT NextIdInt FROM CDN.Text2TableInt(@TrNIDStr))
 END
-- Pracownik i wspólnik
 IF @OdbiorcaTyp = 3 OR @OdbiorcaTyp = 4
 BEGIN
   UPDATE CDN.TraNag SET
  [TrN_OdbNazwa1] = p.PRE_Nazwisko,
  [TrN_OdbNazwa2] = p.PRE_Imie1,
--  [TrN_OdbNazwa3] = p.BNa_Nazwa3,
  [TrN_OdbKraj] = p.PRE_MLDKraj,
  [TrN_OdbWojewodztwo] = p.PRE_MLDWojewodztwo,
  [TrN_OdbPowiat] = p.PRE_MLDPowiat,
  [TrN_OdbGmina] = p.PRE_MLDGmina,
  [TrN_OdbUlica] = p.PRE_MLDUlica,
  [TrN_OdbNrDomu] = p.PRE_MLDNrDomu,
  [TrN_OdbNrLokalu] = p.PRE_MLDNrLokalu,
  [TrN_OdbMiasto] = p.PRE_MLDMiasto,
  [TrN_OdbKodPocztowy] = p.PRE_MLDKodPocztowy,
  [TrN_OdbPoczta] = p.PRE_MLDPoczta,
  [TrN_OdbAdres2] = p.PRE_MLDAdres2
   FROM CDN.PracEtaty p WHERE p.PRE_PreID = @OdbiorcaID AND TrN_TrNID IN (SELECT NextIdInt FROM CDN.Text2TableInt(@TrNIDStr))
 END
-- Urzad
 IF @OdbiorcaTyp = 5
 BEGIN
   UPDATE CDN.TraNag SET
  [TrN_OdbNazwa1] = u.Urz_Nazwa1,
  [TrN_OdbNazwa2] = u.Urz_Nazwa2,
--  [TrN_OdbNazwa3] = u.Urz_Nazwa3,
  [TrN_OdbKraj] = u.Urz_Kraj,
  [TrN_OdbWojewodztwo] = u.Urz_Wojewodztwo,
  [TrN_OdbPowiat] = u.Urz_Powiat,
  [TrN_OdbGmina] = u.Urz_Gmina,
  [TrN_OdbUlica] = u.Urz_Ulica,
  [TrN_OdbNrDomu] = u.Urz_NrDomu,
  [TrN_OdbNrLokalu] = u.Urz_NrLokalu,
  [TrN_OdbMiasto] = u.Urz_Miasto,
  [TrN_OdbKodPocztowy] = u.Urz_KodPocztowy,
  [TrN_OdbPoczta] = u.Urz_Poczta,
  [TrN_OdbAdres2] = u.Urz_Adres2
--  [TrN_OdbNipE] = u.Urz_NipE
   FROM CDN.Urzedy u WHERE u.Urz_UrzID = @OdbiorcaID AND TrN_TrNID IN (SELECT NextIdInt FROM CDN.Text2TableInt(@TrNIDStr))
 END
 --logi
 Declare Dodane Cursor Local Fast_Forward For
 select TrN_TrNID,TrN_TypDokumentu,TrN_NumerPelny FROM cdn.tranag WHERE  TrN_TrNID IN (SELECT NextIdInt FROM  CDN.Text2TableInt(@TrNIDStr))
 Open Dodane
 While 1=1
  Begin
   Fetch Next From Dodane InTo
   @TrNId,
   @Typ,
   @NumerPelny
   If @@Fetch_Status <> 0 Break
   exec [CDN].[RejestrOperacjiDodaj] @Typ,0, @TrNId, @NumerPelny, 2, 'Aktualizacja kontrahenta'
  end
 Close Dodane
 Deallocate Dodane
END
