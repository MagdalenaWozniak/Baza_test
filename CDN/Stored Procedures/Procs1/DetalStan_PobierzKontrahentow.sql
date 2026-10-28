CREATE PROCEDURE [CDN].[DetalStan_PobierzKontrahentow]
@OnlyActive tinyint
AS
BEGIN
SET NOCOUNT ON
IF @OnlyActive = 1
BEGIN
 SELECT DSKnt_DSKntId
      ,DSKnt_OptimaId
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
      ,DSKnt_NieAktywny
      ,DSKnt_StanSynchronizacji
      ,DSKnt_Telefon
      ,DSKnt_Opis
      ,DSKnt_OsobaOdbierajaca
      ,DSKnt_TS_Mod
      ,DSKnt_OpeID FROM CDN.DetalStanKontrahenci WHERE DSKnt_Nieaktywny = 0
END
ELSE
BEGIN
 SELECT DSKnt_DSKntId
      ,DSKnt_OptimaId
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
      ,DSKnt_NieAktywny
      ,DSKnt_StanSynchronizacji
      ,DSKnt_Telefon
      ,DSKnt_Opis
      ,DSKnt_OsobaOdbierajaca
      ,DSKnt_TS_Mod
      ,DSKnt_OpeID FROM CDN.DetalStanKontrahenci
END
SET NOCOUNT OFF
END
