CREATE PROCEDURE [CDN].[Detal_EksportKnt]
  @ID INT      -- ID Detalu
 ,@DateTSSynchr DATETIME  -- TimeStemp ostatniej synchronizacji
 ,@CzyTaSamaBaza tinyint
AS
SET NOCOUNT ON
declare
  @DateTSSynchrNew DATETIME
  select @DateTSSynchrNew = GetDate()
if @CzyTaSamaBaza = 1
BEGIN
    INSERT INTO CDN.DetalStanKontrahenci (
            DSKnt_OptimaId
           ,DSKnt_Kod
           ,DSKnt_EAN
           ,DSKnt_Nazwa1
           ,DSKnt_Nazwa2
           ,DSKnt_Nazwa3
           ,DSKnt_Kraj
           ,DSKnt_Wojewodztwo
           ,DSKnt_Powiat
           ,DSKnt_Gmina
           ,DSKnt_Ulica
           ,DSKnt_NrDomu
           ,DSKnt_NrLokalu
           ,DSKnt_Miasto
           ,DSKnt_KodPocztowy
           ,DSKnt_Poczta
           ,DSKnt_Adres2
           ,DSKnt_NipKraj
           ,DSKnt_NipE
           ,DSKnt_Nip
           ,DSKnt_Regon
           ,DSKnt_Pesel
           ,DSKnt_Telefon
           ,DSKnt_Opis
           ,DSKnt_OsobaOdbierajaca
           ,DSKnt_Nieaktywny
           ,DSKnt_TS_Mod
           ,DSKnt_StanSynchronizacji
           ,DSKnt_OpeID)
  SELECT
    Knt_KntId as Knt_OptimaId ,
    Knt_Kod,
    Knt_EAN,
    Knt_Nazwa1,
    Knt_Nazwa2,
    Knt_Nazwa3,
    Knt_Kraj,
    Knt_Wojewodztwo,
    Knt_Powiat,
    Knt_Gmina,
    Knt_Ulica,
    Knt_NrDomu,
    Knt_NrLokalu,
    Knt_Miasto,
    Knt_KodPocztowy,
    Knt_Poczta,
    Knt_Adres2,
    Knt_NipKraj,
    Knt_NipE,
    Knt_Nip,
    Knt_Regon,
    Knt_Pesel,
    Knt_Telefon1,
    LEFT(Knt_Opis, 254),
    ISNULL(KnO_Nazwisko,''),
    Knt_Nieaktywny,
    Knt_TS_Mod,
 0,
 0
   from cdn.kontrahenci
   left join cdn.rabaty on rab_podmiotid = Knt_KntId and rab_typ =2
   left join cdn.kntosoby on KnO_KntId = Knt_KntId and KnO_Domyslny = 1
   left join CDN.DetalStanKontrahenci on DSKnt_OptimaId = Knt_KntId
   where Knt_TS_Mod > @DateTSSynchr and Knt_ZakazDokumentowHaMag = 0 AND DSKnt_DSKntId IS NULL
   CREATE TABLE #TmpDetalStanKontrahenci(
 [TmpDSKnt_DSKntId] [int] NOT NULL,
 [TmpDSKnt_OptimaId] [int] NOT NULL,
 [TmpDSKnt_Kod] [varchar](20) NOT NULL,
 [TmpDSKnt_EAN] [varchar](16) NOT NULL,
 [TmpDSKnt_Nazwa1] [nvarchar](50) NOT NULL,
 [TmpDSKnt_Nazwa2] [nvarchar](50) NOT NULL,
 [TmpDSKnt_Nazwa3] [nvarchar](250) NOT NULL,
 [TmpDSKnt_Kraj] [nvarchar](40) NOT NULL,
 [TmpDSKnt_Wojewodztwo] [nvarchar](40) NOT NULL,
 [TmpDSKnt_Powiat] [nvarchar](40) NOT NULL,
 [TmpDSKnt_Gmina] [nvarchar](40) NOT NULL,
 [TmpDSKnt_Ulica] [nvarchar](40) NOT NULL,
 [TmpDSKnt_NrDomu] [nvarchar](10) NOT NULL,
 [TmpDSKnt_NrLokalu] [nvarchar](10) NOT NULL,
 [TmpDSKnt_Miasto] [nvarchar](40) NOT NULL,
 [TmpDSKnt_KodPocztowy] [varchar](10) NOT NULL,
 [TmpDSKnt_Poczta] [nvarchar](40) NOT NULL,
 [TmpDSKnt_Adres2] [nvarchar](40) NOT NULL,
 [TmpDSKnt_NipKraj] [varchar](2) NOT NULL,
 [TmpDSKnt_NipE] [varchar](20) NOT NULL,
 [TmpDSKnt_Nip] [varchar](20) NOT NULL,
 [TmpDSKnt_Regon] [varchar](20) NOT NULL,
 [TmpDSKnt_Pesel] [nvarchar](11) NOT NULL,
 [TmpDSKnt_Telefon] [varchar](20) NOT NULL,
 [TmpDSKnt_Opis] [nvarchar](254) NOT NULL,
 [TmpDSKnt_OsobaOdbierajaca] [nvarchar](40) NOT NULL,
 [TmpDSKnt_NieAktywny] [tinyint] NOT NULL,
 [TmpDSKnt_TS_Mod] [datetime] NOT NULL,
 [TmpDSKnt_StanSynchronizacji] [int] NOT NULL,
 [TmpDSKnt_OpeID] [int] NOT NULL
)
  INSERT INTO #TmpDetalStanKontrahenci (
   TmpDSKnt_DSKntId
           ,TmpDSKnt_OptimaId
           ,TmpDSKnt_Kod
           ,TmpDSKnt_EAN
           ,TmpDSKnt_Nazwa1
           ,TmpDSKnt_Nazwa2
           ,TmpDSKnt_Nazwa3
           ,TmpDSKnt_Kraj
           ,TmpDSKnt_Wojewodztwo
           ,TmpDSKnt_Powiat
           ,TmpDSKnt_Gmina
           ,TmpDSKnt_Ulica
           ,TmpDSKnt_NrDomu
           ,TmpDSKnt_NrLokalu
           ,TmpDSKnt_Miasto
           ,TmpDSKnt_KodPocztowy
           ,TmpDSKnt_Poczta
           ,TmpDSKnt_Adres2
           ,TmpDSKnt_NipKraj
           ,TmpDSKnt_NipE
           ,TmpDSKnt_Nip
           ,TmpDSKnt_Regon
           ,TmpDSKnt_Pesel
           ,TmpDSKnt_Telefon
           ,TmpDSKnt_Opis
           ,TmpDSKnt_OsobaOdbierajaca
           ,TmpDSKnt_Nieaktywny
           ,TmpDSKnt_TS_Mod
           ,TmpDSKnt_StanSynchronizacji
           ,TmpDSKnt_OpeID)
  SELECT
 DSKnt_DSKntId,
    Knt_KntId as Knt_OptimaId ,
    Knt_Kod,
    Knt_EAN,
    Knt_Nazwa1,
    Knt_Nazwa2,
    Knt_Nazwa3,
    Knt_Kraj,
    Knt_Wojewodztwo,
    Knt_Powiat,
    Knt_Gmina,
    Knt_Ulica,
    Knt_NrDomu,
    Knt_NrLokalu,
    Knt_Miasto,
    Knt_KodPocztowy,
    Knt_Poczta,
    Knt_Adres2,
    Knt_NipKraj,
    Knt_NipE,
    Knt_Nip,
    Knt_Regon,
    Knt_Pesel,
    Knt_Telefon1,
    LEFT(Knt_Opis, 254),
    ISNULL(KnO_Nazwisko,''),
    Knt_Nieaktywny,
    Knt_TS_Mod,
 0,
 0
   from cdn.kontrahenci
   inner join CDN.DetalStanKontrahenci on DSKnt_OptimaId = Knt_KntId
   left join cdn.rabaty on rab_podmiotid = Knt_KntId and rab_typ =2
   left join cdn.kntosoby on KnO_KntId = Knt_KntId and KnO_Domyslny = 1
   where Knt_TS_Mod > @DateTSSynchr and Knt_ZakazDokumentowHaMag = 0
   UPDATE  TableA
   SET
            TableA.DSKnt_Kod = TableB.TmpDSKnt_Kod
           ,TableA.DSKnt_EAN = TableB.TmpDSKnt_EAN
           ,TableA.DSKnt_Nazwa1 = TableB.TmpDSKnt_Nazwa1
           ,TableA.DSKnt_Nazwa2 = TableB.TmpDSKnt_Nazwa2
           ,TableA.DSKnt_Nazwa3 = TableB.TmpDSKnt_Nazwa3
           ,TableA.DSKnt_Kraj = TableB.TmpDSKnt_Kraj
           ,TableA.DSKnt_Wojewodztwo = TableB.TmpDSKnt_Wojewodztwo
           ,TableA.DSKnt_Powiat = TableB.TmpDSKnt_Powiat
           ,TableA.DSKnt_Gmina = TableB.TmpDSKnt_Gmina
           ,TableA.DSKnt_Ulica = TableB.TmpDSKnt_Ulica
           ,TableA.DSKnt_NrDomu = TableB.TmpDSKnt_NrDomu
           ,TableA.DSKnt_NrLokalu = TableB.TmpDSKnt_NrLokalu
           ,TableA.DSKnt_Miasto = TableB.TmpDSKnt_Miasto
           ,TableA.DSKnt_KodPocztowy = TableB.TmpDSKnt_KodPocztowy
           ,TableA.DSKnt_Poczta = TableB.TmpDSKnt_Poczta
           ,TableA.DSKnt_Adres2 = TableB.TmpDSKnt_Adres2
           ,TableA.DSKnt_NipKraj = TableB.TmpDSKnt_NipKraj
           ,TableA.DSKnt_NipE = TableB.TmpDSKnt_NipE
           ,TableA.DSKnt_Nip = TableB.TmpDSKnt_Nip
           ,TableA.DSKnt_Regon = TableB.TmpDSKnt_Regon
           ,TableA.DSKnt_Pesel = TableB.TmpDSKnt_Pesel
           ,TableA.DSKnt_Telefon = TableB.TmpDSKnt_Telefon
           ,TableA.DSKnt_Opis = TableB.TmpDSKnt_Opis
           ,TableA.DSKnt_OsobaOdbierajaca = TableB.TmpDSKnt_OsobaOdbierajaca
           ,TableA.DSKnt_Nieaktywny = TableB.TmpDSKnt_Nieaktywny
           ,TableA.DSKnt_TS_Mod = TableB.TmpDSKnt_TS_Mod
           ,TableA.DSKnt_StanSynchronizacji = 0
           ,TableA.DSKnt_OpeID = 0
 FROM
 CDN.DetalStanKontrahenci AS TableA
 INNER JOIN #TmpDetalStanKontrahenci AS TableB
 ON TableA.DSKnt_DSKntId = TableB.TmpDSKnt_DSKntId
 drop TABLE #TmpDetalStanKontrahenci
 UPDATE CDN.DetalStanKonfiguracja SET DSKnf_TS_SynchroKnt = @DateTSSynchrNew WHERE DSKnf_StanDetalID = @ID
 UPDATE CDN.DetalStanowiska SET DSta_TS_SynchroKnt = @DateTSSynchrNew WHERE DSta_DStaId = @ID
END
ELSE
  SELECT
    Knt_KntId as Knt_OptimaId ,
 Knt_Kod,
 Knt_EAN,
 Knt_Nazwa1,
 Knt_Nazwa2,
 Knt_Nazwa3,
 Knt_Kraj,
 Knt_Wojewodztwo,
 Knt_Powiat,
 Knt_Gmina,
 Knt_Ulica,
 Knt_NrDomu,
 Knt_NrLokalu,
 Knt_Miasto,
 Knt_KodPocztowy,
 Knt_Poczta,
 Knt_Adres2,
 Knt_NipKraj,
 Knt_NipE,
 Knt_Nip,
 Knt_Regon,
 Knt_Pesel,
 Knt_Telefon1,
 Knt_Opis,
 ISNULL(KnO_Nazwisko,''),
 Knt_Nieaktywny,
 Knt_TS_Mod,
 @DateTSSynchrNew
   from cdn.kontrahenci
   left join cdn.rabaty on rab_podmiotid = Knt_KntId and rab_typ =2
   left join cdn.kntosoby on KnO_KntId = Knt_KntId and KnO_Domyslny = 1
   where Knt_TS_Mod > @DateTSSynchr and Knt_ZakazDokumentowHaMag = 0
 SET NOCOUNT OFF
