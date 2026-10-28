CREATE PROCEDURE CDN.Med_EksportKntrahenci
  @ID INT      -- ID Stanowiska
AS
SET NOCOUNT ON
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
    Knt_TS_Mod
   from cdn.kontrahenci
   left join cdn.rabaty on rab_podmiotid = Knt_KntId and rab_typ =2
   left join cdn.kntosoby on KnO_KntId = Knt_KntId and KnO_Domyslny = 1
   where  Knt_ZakazDokumentowHaMag = 0
 SET NOCOUNT OFF
