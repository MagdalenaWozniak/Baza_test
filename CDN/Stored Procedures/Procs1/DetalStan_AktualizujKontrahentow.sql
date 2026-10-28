CREATE  PROCEDURE [CDN].[DetalStan_AktualizujKontrahentow]
  @OptimaId int,
  @Kod nvarchar(20),
  @EAN nvarchar(16),
  @Nazwa1 nvarchar(50),
  @Nazwa2 nvarchar(50),
  @Nazwa3 nvarchar(250),
  @Kraj nvarchar(40),
  @Wojewodztwo nvarchar(40),
  @Powiat nvarchar(40),
  @Gmina nvarchar(40),
  @Ulica nvarchar(40),
  @NrDomu nvarchar(10),
  @NrLokalu nvarchar(10),
  @Miasto nvarchar(40),
  @KodPocztowy nvarchar(10),
  @Poczta nvarchar(40),
  @Adres2 nvarchar(40),
  @NipKraj nvarchar(2),
  @NipE nvarchar(20),
  @Nip nvarchar(20),
  @Regon nvarchar(20),
  @Pesel nvarchar(11),
  @Telefon nvarchar(20),
  @Opis nvarchar(254),
  @OsobaOdbierajaca nvarchar(40),
  @Nieaktywny tinyint,
  @DateTSSynchr datetime,
  @DateTSSynchrNew datetime
AS
SET NOCOUNT ON
DECLARE
    @DSKnt_DSKntId INT
  SELECT @DSKnt_DSKntId = DSKnt_DSKntId
    FROM CDN.DetalStanKontrahenci
    WHERE DSKnt_OptimaId = @OptimaId
  IF @DSKnt_DSKntId IS NULL
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
  VALUES (
            @OptimaId,
            @Kod,
            @EAN,
            @Nazwa1,
            @Nazwa2,
            @Nazwa3,
            @Kraj,
            @Wojewodztwo,
            @Powiat,
            @Gmina,
            @Ulica,
            @NrDomu,
            @NrLokalu,
            @Miasto,
            @KodPocztowy,
            @Poczta,
            @Adres2,
            @NipKraj,
            @NipE,
            @Nip,
            @Regon,
            @Pesel,
            @Telefon,
            @Opis,
            @OsobaOdbierajaca,
            @Nieaktywny,
            @DateTSSynchr,
            0,
            0
         )
    END
  ELSE
 BEGIN
     UPDATE  CDN.DetalStanKontrahenci
   SET
            DSKnt_Kod = @Kod
           ,DSKnt_EAN = @EAN
           ,DSKnt_Nazwa1 = @Nazwa1
           ,DSKnt_Nazwa2 = @Nazwa2
           ,DSKnt_Nazwa3 = @Nazwa3
           ,DSKnt_Kraj = @Kraj
           ,DSKnt_Wojewodztwo = @Wojewodztwo
           ,DSKnt_Powiat = @Powiat
           ,DSKnt_Gmina = @Gmina
           ,DSKnt_Ulica = @Ulica
           ,DSKnt_NrDomu = @NrDomu
           ,DSKnt_NrLokalu = @NrLokalu
           ,DSKnt_Miasto = @Miasto
           ,DSKnt_KodPocztowy = @KodPocztowy
           ,DSKnt_Poczta = @Poczta
           ,DSKnt_Adres2 = @Adres2
           ,DSKnt_NipKraj = @NipKraj
           ,DSKnt_NipE = @NipE
           ,DSKnt_Nip = @Nip
           ,DSKnt_Regon = @Regon
           ,DSKnt_Pesel = @Pesel
           ,DSKnt_Telefon = @Telefon
           ,DSKnt_Opis = @Opis
           ,DSKnt_OsobaOdbierajaca = @OsobaOdbierajaca
           ,DSKnt_Nieaktywny = @Nieaktywny
           ,DSKnt_TS_Mod = @DateTSSynchr
           ,DSKnt_StanSynchronizacji = 0
           ,DSKnt_OpeID = 0
  WHERE (@DSKnt_DSKntId = DSKnt_DSKntId) and DSKnt_TS_Mod <= @DateTSSynchr
      END
  SET NOCOUNT OFF
