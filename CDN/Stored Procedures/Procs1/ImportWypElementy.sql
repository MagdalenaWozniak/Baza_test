create procedure cdn.ImportWypElementy
@Wpe_WplId int  ,
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@Pra_ImportRowID nvarchar(36),
@Pra_Kod varchar(20),
@TWp_ImportRowID nvarchar(36),
@TWp_Nazwa varchar(40),
@Wpe_Nazwa nvarchar(128)  ,
@Wpe_Wartosc decimal(15, 2)  ,
@Wpe_WartoscWal decimal(15, 2)  ,
@Wpe_Netto decimal(15, 2)  ,
@Wpe_NettoWal decimal(15, 2)  ,
@Wpe_Brutto50 decimal(15, 2) ,
@Wpe_Koszty decimal(15, 2)  ,
@Wpe_Koszty50 decimal(15, 2) ,
@Wpe_Przychod50 decimal(15, 2)  ,
@Wpe_Waluta varchar(3)  ,
@Wpe_Ulga decimal(15, 2)  ,
@Wpe_ZalFis decimal(15, 2)  ,
@Wpe_NalFis decimal(15, 2)  ,
@Wpe_TyUb int  ,
@Wpe_NrZUS int ,
@Wpe_PodstEmer decimal(15, 2)  ,
@Wpe_PodstRent decimal(15, 2)  ,
@Wpe_PodstChor decimal(15, 2)  ,
@Wpe_PodstWypad decimal(15, 2) ,
@Wpe_PodstZdrow decimal(15, 2) ,
@Wpe_PodstFP decimal(15, 2)  ,
@Wpe_PodstFGSP decimal(15, 2) ,
@Wpe_PodstFEP decimal(15, 2)  ,
@Wpe_PodstPPK decimal(15, 2)  ,
@Wpe_SklEmerPrac decimal(15, 2)  ,
@Wpe_SklEmerFirma decimal(15, 2)  ,
@Wpe_SklRentPrac decimal(15, 2)  ,
@Wpe_SklRentFirma decimal(15, 2)  ,
@Wpe_SklChorPrac decimal(15, 2)  ,
@Wpe_SklChorFirma decimal(15, 2) ,
@Wpe_SklWypadPrac decimal(15, 2)  ,
@Wpe_SklWypadFirma decimal(15, 2) ,
@Wpe_SklZdrowPrac decimal(15, 2)  ,
@Wpe_SklZdrowFirma decimal(15, 2)  ,
@Wpe_SklZdrowSuma decimal(15, 2)  ,
@Wpe_SklFP decimal(15, 2)  ,
@Wpe_SklFGSP decimal(15, 2)  ,
@Wpe_SklFEP decimal(15, 2)  ,
@Wpe_SklPPKPrac1 decimal(15, 2)  ,
@Wpe_SklPPKPrac2 decimal(15, 2)  ,
@Wpe_SklPPKFirma1 decimal(15, 2)  ,
@Wpe_SklPPKFirma2 decimal(15, 2)  ,
@Kat_KodSzczegol nvarchar(20),
@Kat_ImportRowId nvarchar(36),
@Wpe_KategoriaOpis varchar(50)  ,
@Wpe_Korekta tinyint ,
@Wpe_Archiwalny tinyint  ,
@Wpe_Temp int  ,
@WPE_ZalFisZwol tinyint,
@WPE_PodstPITZwol decimal(15, 2),
@ZrdId nvarchar(5),
@OpeId int,
@IdParam int output,
@Warnings nvarchar(1000) output
as
 begin
declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
exec CDN.OpeKodNazwisko @OpeId, @OpeModKod OUT, @OpeModNazwisko OUT
  DECLARE @PraID INT
  SET @PraID = NULL
  IF @Pra_ImportRowID Is NOT Null
   SELECT @PraID = Pra_PraID FROM CDN.PracKod WHERE Pra_ImportRowId = @Pra_ImportRowID
  IF @PraID is Null
   SELECT @PraID = Pra_PraID FROM CDN.PracKod WHERE Pra_Kod = @Pra_Kod
  IF @PraID is Null
  BEGIN
   RAISERROR('##OPT33103##', 16, 1) --RAISERROR('Brak zadanego pracownika w bazie dla elementu wypłaty.', 16, 1)
   RETURN
  END
  DECLARE @TWpID INT
  SET @TWpID = NULL
  IF @TWp_ImportRowID Is NOT Null
   SELECT @TWpID = TWp_TWpID FROM CDN.TypWyplata WHERE TWp_ImportRowId = @TWp_ImportRowID
  IF @TWpID is Null
   SELECT @TWpID = TWp_TWpID FROM CDN.TypWyplata WHERE TWp_Nazwa = @TWp_Nazwa
  IF @TWpID is Null
  BEGIN
   RAISERROR('##OPT33104##', 16, 1) --RAISERROR('Brak zadanego typu wypłaty w bazie dla elementu wypłaty.', 16, 1)
   RETURN
  END
  DECLARE @KatID INT
  SET @KatID = NULL
  IF(@Kat_ImportRowId is not NULL OR @Kat_KodSzczegol is not NULL)
  BEGIN
   SELECT @KatId = Kat_KatId FROM CDN.Kategorie WHERE Kat_ImportRowId = @Kat_ImportRowId
   IF(@KatId is NULL)
   BEGIN
    SELECT @KatId = Kat_KatId FROM CDN.Kategorie WHERE Kat_KodSzczegol = @Kat_KodSzczegol
    IF @KatId is NULL
     --SET @Warnings = 'Brak kategorii ' + IsNull(@Kat_KodSzczegol, '') + ' w bazie docelowej. Kategoria na elemencie wypłaty nie została zaimportowana.\'
     SET @Warnings = '##OPT33207##%%kategoria%%=' + IsNull(@Kat_KodSzczegol, '') + '##\'
   END
  END
  SELECT @Wpe_PodstPPK = IsNull(@Wpe_PodstPPK, 0)
  SELECT @Wpe_SklPPKPrac1 = IsNull(@Wpe_SklPPKPrac1, 0)
  SELECT @Wpe_SklPPKPrac2 = IsNull(@Wpe_SklPPKPrac2, 0)
  SELECT @Wpe_SklPPKFirma1 = IsNull(@Wpe_SklPPKFirma1, 0)
  SELECT @Wpe_SklPPKFirma2 = IsNull(@Wpe_SklPPKFirma2, 0)
  insert into cdn.WypElementy
  (
   WPE_WplId   ,
   WPE_PraId  ,
   WPE_TwpId  ,
   WPE_Nazwa  ,
   WPE_Wartosc   ,
   WPE_WartoscWal   ,
   WPE_Netto   ,
   WPE_NettoWal   ,
   WPE_Brutto50  ,
   WPE_Koszty   ,
   WPE_Koszty50  ,
   WPE_Przychod50   ,
   WPE_Waluta ,
   WPE_Ulga   ,
   WPE_ZalFis   ,
   WPE_NalFis   ,
   WPE_TyUb   ,
   WPE_NrZUS  ,
   WPE_PodstEmer   ,
   WPE_PodstRent   ,
   WPE_PodstChor   ,
   WPE_PodstWypad  ,
   WPE_PodstZdrow  ,
   WPE_PodstFP   ,
   WPE_PodstFGSP  ,
   WPE_PodstFEP   ,
   WPE_PodstPPK   ,
   WPE_SklEmerPrac   ,
   WPE_SklEmerFirma   ,
   WPE_SklRentPrac   ,
   WPE_SklRentFirma   ,
   WPE_SklChorPrac   ,
   WPE_SklChorFirma  ,
   WPE_SklWypadPrac   ,
   WPE_SklWypadFirma  ,
   WPE_SklZdrowPrac   ,
   WPE_SklZdrowFirma   ,
   WPE_SklZdrowSuma   ,
   WPE_SklFP   ,
   WPE_SklFGSP   ,
   WPE_SklFEP   ,
   WPE_SklPPKPrac1 ,
   WPE_SklPPKPrac2 ,
   WPE_SklPPKFirma1 ,
   WPE_SklPPKFirma2 ,
   WPE_KatID  ,
   WPE_KategoriaOpis  ,
   WPE_Korekta  ,
   WPE_Archiwalny   ,
   WPE_Temp   ,
   WPE_ZalFisZwol,
   WPE_PodstPITZwol,
   WPE_OpeZalId  ,
   WPE_OpeZalKod,
   WPE_OpeZalNazwisko,
   WPE_TS_Zal   ,
   WPE_OpeModId  ,
   WPE_OpeModKod  ,
   WPE_OpeModNazwisko  ,
   WPE_TS_Mod
  )
  values
  (
   @Wpe_WplId   ,
   @PraID  ,
   @TwpID  ,
   @Wpe_Nazwa  ,
   @Wpe_Wartosc   ,
   @Wpe_WartoscWal   ,
   @Wpe_Netto   ,
   @Wpe_NettoWal   ,
   @Wpe_Brutto50  ,
   @Wpe_Koszty   ,
   @Wpe_Koszty50  ,
   @Wpe_Przychod50   ,
   @Wpe_Waluta ,
   @Wpe_Ulga   ,
   @Wpe_ZalFis   ,
   @Wpe_NalFis   ,
   @Wpe_TyUb   ,
   @Wpe_NrZUS  ,
   @Wpe_PodstEmer   ,
   @Wpe_PodstRent   ,
   @Wpe_PodstChor   ,
   @Wpe_PodstWypad  ,
   @Wpe_PodstZdrow  ,
   @Wpe_PodstFP   ,
   @Wpe_PodstFGSP  ,
   @Wpe_PodstFEP   ,
   @Wpe_PodstPPK   ,
   @Wpe_SklEmerPrac   ,
   @Wpe_SklEmerFirma   ,
   @Wpe_SklRentPrac   ,
   @Wpe_SklRentFirma   ,
   @Wpe_SklChorPrac   ,
   @Wpe_SklChorFirma  ,
   @Wpe_SklWypadPrac   ,
   @Wpe_SklWypadFirma  ,
   @Wpe_SklZdrowPrac   ,
   @Wpe_SklZdrowFirma   ,
   @Wpe_SklZdrowSuma   ,
   @Wpe_SklFP   ,
   @Wpe_SklFGSP   ,
   @Wpe_SklFEP   ,
   @Wpe_SklPPKPrac1 ,
   @Wpe_SklPPKPrac2 ,
   @Wpe_SklPPKFirma1 ,
   @Wpe_SklPPKFirma2 ,
   @KatID  ,
   @Wpe_KategoriaOpis  ,
   @Wpe_Korekta  ,
   @Wpe_Archiwalny   ,
   @Wpe_Temp   ,
   IsNull(@WPE_ZalFisZwol, 0),
   IsNull(@WPE_PodstPITZwol, 0),
   @OpeId  ,
   @OpeModKod,
   @OpeModNazwisko,
   getdate()   ,
   @OpeId  ,
   @OpeModKod,
   @OpeModNazwisko,
   getdate()
  )
  select @IdParam = SCOPE_IDENTITY()
 end
