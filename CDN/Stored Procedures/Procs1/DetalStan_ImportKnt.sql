CREATE PROCEDURE [CDN].[DetalStan_ImportKnt]
  @ID INT      -- ID Detalu
 ,@DateTSSynchr DATETIME  -- TimeStemp ostatniej synchronizacji
 ,@CzyTaSamaBaza tinyint
AS
SET NOCOUNT ON
SET ARITHABORT ON
declare
 @DSKntId int ,
 @OptimaId int ,
 @Kod nvarchar(20) ,
 @EAN nvarchar(16) ,
 @Nazwa1 nvarchar(50) ,
 @Nazwa2 nvarchar(50) ,
 @Nazwa3 nvarchar(250) ,
 @Kraj nvarchar(40) ,
 @Wojewodztwo nvarchar(40) ,
 @Powiat nvarchar(40) ,
 @Gmina nvarchar(40) ,
 @Ulica nvarchar(40) ,
 @NrDomu nvarchar(10) ,
 @NrLokalu nvarchar(10) ,
 @Miasto nvarchar(40) ,
 @KodPocztowy nvarchar(10) ,
 @Poczta nvarchar(40) ,
 @Adres2 nvarchar(40) ,
 @NipKraj nvarchar(2) ,
 @NipE nvarchar(20) ,
 @Nip nvarchar(20) ,
 @Regon nvarchar(20) ,
 @Pesel nvarchar(11) ,
 @Telefon nvarchar(20),
 @Opis nvarchar(254),
 @OsobaOdbierajaca nvarchar(40),
 @OpeID int,
 @TS_Mod datetime,
 @OptimaIdnew int ,
 @DateTSSynchrNew DATETIME,
 @Kodnew nvarchar(20)
if @CzyTaSamaBaza = 1
BEGIN
  select @DateTSSynchrNew = max(DSKnt_TS_Mod) from cdn.DetalStanKontrahenci
 DECLARE Dodawane CURSOR LOCAL FAST_FORWARD FOR
  SELECT
 DSKnt_DSKntId,
 DSKnt_OptimaId,
 DSKnt_Kod,
 DSKnt_EAN,
 DSKnt_Nazwa1,
 DSKnt_Nazwa2,
 DSKnt_Nazwa3,
 DSKnt_Kraj,
 DSKnt_Wojewodztwo,
 DSKnt_Powiat,
 DSKnt_Gmina,
 DSKnt_Ulica,
 DSKnt_NrDomu,
 DSKnt_NrLokalu,
 DSKnt_Miasto,
 DSKnt_KodPocztowy,
 DSKnt_Poczta,
 DSKnt_Adres2,
 DSKnt_NipKraj,
 DSKnt_NipE,
 DSKnt_Nip,
 DSKnt_Regon,
 DSKnt_Pesel,
 DSKnt_Telefon,
 DSKnt_Opis,
 DSKnt_OsobaOdbierajaca,
 DSOpe_OptimaID,
 DSKnt_TS_Mod
   FROM CDN.DetalStanKontrahenci
   join CDN.DetalStanOperatorzy ON DSKnt_OpeID = DSOpe_DSOpeID
   WHERE DSKnt_TS_Mod > @DateTSSynchr
   OPEN Dodawane
       WHILE 1=1
        BEGIN
          FETCH NEXT FROM Dodawane INTO
 @DSKntId,
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
 @Opis ,
 @OsobaOdbierajaca,
 @OpeID,
 @TS_Mod
   IF @@FETCH_STATUS <> 0 BREAK
  EXEC CDN.Detal_AktualizujKontrahentow
 @DSKntId,
 @OptimaId,
 @ID,
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
 @Opis ,
 @OsobaOdbierajaca,
 @OpeID,
 @TS_Mod,
 @OptimaIdnew out,
 @Kodnew out
 if @Kodnew is not null and @OptimaIdnew is not null
 Update cdn.DetalStanKontrahenci set DSKnt_Kod = @Kodnew, DSKnt_OptimaId = @OptimaIdnew where DSKnt_DSKntId = @DSKntId
 Delete from cdn.DetalKontrahenci where DKnt_DSKntId = @DSKntId and DKnt_StanDetalID = @ID
    UPDATE CDN.DetalStanKonfiguracja SET DSKnf_TS_SynchroImportKnt = @DateTSSynchrNew WHERE DSKnf_StanDetalID = @ID
    UPDATE CDN.DetalStanowiska SET DSta_TS_SynchroImportKnt = @DateTSSynchrNew WHERE DSta_DStaId = @ID
END
    CLOSE Dodawane
    DEALLOCATE Dodawane
END
ELSE
  SELECT
 DSKnt_DSKntId,
 DSKnt_OptimaId,
 @ID,
 DSKnt_Kod,
 DSKnt_EAN,
 DSKnt_Nazwa1,
 DSKnt_Nazwa2,
 DSKnt_Nazwa3,
 DSKnt_Kraj,
 DSKnt_Wojewodztwo,
 DSKnt_Powiat,
 DSKnt_Gmina,
 DSKnt_Ulica,
 DSKnt_NrDomu,
 DSKnt_NrLokalu,
 DSKnt_Miasto,
 DSKnt_KodPocztowy,
 DSKnt_Poczta,
 DSKnt_Adres2,
 DSKnt_NipKraj,
 DSKnt_NipE,
 DSKnt_Nip,
 DSKnt_Regon,
 DSKnt_Pesel,
 DSKnt_Telefon,
 DSKnt_Opis,
 DSKnt_OsobaOdbierajaca,
 DSOpe_OptimaID,
 DSKnt_TS_Mod
   FROM CDN.DetalStanKontrahenci
   join CDN.DetalStanOperatorzy ON DSKnt_OpeID = DSOpe_DSOpeID
   WHERE DSKnt_TS_Mod > @DateTSSynchr
SET NOCOUNT OFF
SET ARITHABORT OFF
