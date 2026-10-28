CREATE PROCEDURE CDN.KntScal_eSklepy
 @KntNadID AS INT, -- ID kontrahenta nadrzędnego (głównego)
 @KntPodID AS INT  -- ID kontrahenta podrzędnego (duplikata)
AS
 SET NOCOUNT ON
 EXEC cdn.KntScal_SprawdzPodmioty @KntNadID, @KntPodID, 0
 IF @@ERROR <> 0 RETURN
 -- najpierw dodajemy przedstawicieli dla tych linków e-sklepów, które za chwilę dodamy;
 -- po dodaniu najpierw linków nie wiedzielibyśmy dla których linków dodać przedstawicieli (odróznienie nowych od starych)
 ALTER TABLE cdn.KntOsoby DISABLE TRIGGER ALL
 INSERT INTO cdn.KntOsoby (KnO_KntId, KnO_Nazwisko, KnO_Plec, KnO_Tytul, KnO_Domyslny, KnO_Nieaktywny,
  KnO_Kraj, KnO_Powiat, KnO_Wojewodztwo, KnO_Gmina, KnO_Miasto, KnO_Ulica, KnO_NrDomu, KnO_NrLokalu, KnO_KodPocztowy, KnO_Poczta, KnO_Adres2,
  KnO_Telefon, KnO_GSM, KnO_TelefonSMS, KnO_Email, KnO_Mailing,
  KnO_Informacje)
  SELECT @KntNadID, K.Knt_Kod, 1, '', 0, 0,
   K.Knt_Kraj, K.Knt_Powiat, K.Knt_Wojewodztwo, K.Knt_Gmina, K.Knt_Miasto, K.Knt_Ulica, K.Knt_NrDomu, K.Knt_NrLokalu, K.Knt_KodPocztowy, K.Knt_Poczta, K.Knt_Adres2,
   K.Knt_Telefon1, K.Knt_Telefon2, K.Knt_TelefonSMS, K.Knt_Email, 0,
   0
  FROM cdn.KntESklepy A INNER JOIN cdn.Kontrahenci K ON K.Knt_KntID = A.KES_KntID
   WHERE A.KES_KntID = @KntPodID
    AND NOT EXISTS (SELECT * FROM cdn.KntESklepy B WHERE B.KES_KntID = @KntNadID AND B.KES_eSklepID = A.KES_eSklepID)
 ALTER TABLE cdn.KntOsoby ENABLE TRIGGER ALL
 DECLARE @KntNadKod NVARCHAR(20)
 DECLARE @KntPodKod NVARCHAR(20)
 SELECT @KntNadKod = Knt_Kod FROM cdn.Kontrahenci WHERE Knt_KntID = @KntNadID
 SELECT @KntPodKod = Knt_Kod FROM cdn.Kontrahenci WHERE Knt_KntID = @KntPodID
 INSERT INTO cdn.KntScalHist (KSH_NazwaTabeli, KSH_IDWiersza, KSH_NumerDok, KSH_OldKntID, KSH_OldKntKod, KSH_NewKntID, KSH_NewKntKod)
      SELECT 'cdn.KntESklepy', A.KES_KESID, (SELECT ESS_Nazwa FROM cdn.eSklepStanowiska WHERE ESS_ESSId = A.KES_eSklepID), @KntPodID, @KntPodKod, @KntNadID, @KntNadKod
  FROM cdn.KntESklepy A
   WHERE A.KES_KntID = @KntPodID
    AND NOT EXISTS (SELECT * FROM cdn.KntESklepy B WHERE B.KES_KntID = @KntNadID AND B.KES_eSklepID = A.KES_eSklepID)
 ALTER TABLE cdn.KntESklepy DISABLE TRIGGER ALL
 INSERT INTO cdn.KntESklepy (KES_KntID, KES_eSklepID, KES_TypCenyDomyslnej)
  SELECT @KntNadID, A.KES_eSklepID, A.KES_TypCenyDomyslnej
  FROM cdn.KntESklepy A
   WHERE A.KES_KntID = @KntPodID
    AND NOT EXISTS (SELECT * FROM cdn.KntESklepy B WHERE B.KES_KntID = @KntNadID AND B.KES_eSklepID = A.KES_eSklepID)
 ALTER TABLE cdn.KntESklepy ENABLE TRIGGER ALL
 SET NOCOUNT OFF
