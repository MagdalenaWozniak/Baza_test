CREATE PROCEDURE [CDN].[Detal_AktualizujTraNag]
  @DSTrNID int ,
  @StanDetalID int ,
  @FAID int ,
  @ZwrID int ,
  @Korekta tinyint ,
  @PARodzajKor tinyint,
  @TypDokumentu int ,
  @NumerNr int ,
  @NumerString NVARCHAR(31) ,
  @NumerPelny  NVARCHAR(50) ,
  @DataDok datetime ,
  @Fiskalna tinyint ,
  @PodID int ,
  @OdbID int ,
  @RazemBrutto decimal(15, 2) ,
  @Rabat decimal(5, 2) ,
  @OsobaOdbierajaca nvarchar(40),
  @OpeID int ,
  @TS_Zal datetime ,
  @IloscElementow int,
  @IloscPlatnosci int,
  @Opis nvarchar(1024)
AS
SET NOCOUNT ON
DECLARE
    @DTrN_DTrNId INT
  SELECT  @DTrN_DTrNId = DTrN_DTrNId
    FROM CDN.DetalTraNag
    WHERE DTrN_DSTrNId = @DSTrNID and DTrN_StanDetalID= @StanDetalID
  IF @DTrN_DTrNId IS NULL
    BEGIN
       INSERT INTO CDN.DetalTraNag (
        DTrN_DSTrNID ,
        DTrN_StanDetalID ,
        DTrN_FAID ,
        DTrN_ZwrID ,
        DTrN_Korekta ,
  DTrN_PARodzajKor,
        DTrN_TypDokumentu ,
        DTrN_NumerNr ,
        DTrN_NumerString ,
        DTrN_NumerPelny  ,
        DTrN_DataDok ,
        DTrN_Fiskalna ,
        DTrN_PodID ,
        DTrN_OdbID ,
        DTrN_RazemBrutto ,
        DTrN_Rabat ,
        DTrN_StanSynchronizacji ,
        DTrN_OsobaOdbierajaca,
        DTrN_OpeID ,
        DTrN_TS_Zal ,
        DTrN_IloscElementow ,
        DTrN_IloscPlatnosci,
        DTrN_Waluta,
        DTrN_TypNB,
        DTrN_Opis )
  VALUES (
  @DSTrNID ,
  @StanDetalID ,
  @FAID ,
  @ZwrID ,
  @Korekta ,
  @PARodzajKor,
  @TypDokumentu ,
  @NumerNr ,
  @NumerString ,
  @NumerPelny  ,
  @DataDok ,
  @Fiskalna ,
  @PodID ,
  @OdbID ,
  @RazemBrutto ,
  @Rabat ,
  1,
  @OsobaOdbierajaca,
  @OpeID ,
  @TS_Zal,
  @IloscElementow,
  @IloscPlatnosci,
  '',
  2,
  @Opis
         )
    END
  SET NOCOUNT OFF
