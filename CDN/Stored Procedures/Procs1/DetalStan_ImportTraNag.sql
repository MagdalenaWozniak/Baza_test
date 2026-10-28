CREATE PROCEDURE [CDN].[DetalStan_ImportTraNag]
  @ID INT      -- ID Detalu
 ,@DateTSSynchr DATETIME  -- TimeStemp ostatniej synchronizacji
 ,@CzyTaSamaBaza tinyint
AS
SET NOCOUNT ON
declare
 @DSTrNID int ,
 @StanDetalID int ,
 @FAID int ,
 @ZwrID int ,
 @Korekta tinyint ,
 @PARodzajKor tinyint,
 @TypDokumentu int ,
 @NumerNr int ,
 @NumerString NVARCHAR(31) ,
 @NumerPelny NVARCHAR(50) ,
 @DataDok datetime ,
 @Fiskalna tinyint ,
 @PodID int ,
 @OdbID int ,
 @RazemBrutto decimal(15, 2) ,
 @Rabat decimal(5, 2) ,
 @OpeID int ,
 @OsobaOdbierajaca nvarchar(40),
 @Opis nvarchar(1024),
 @TS_Zal datetime ,
 @IloscElementow int ,
 @IloscPlatnosci int
if @CzyTaSamaBaza = 1
BEGIN
 update CDN.DetalStanTraNag SET DSTrN_StanSynchronizacji = 2 WHERE DSTrN_StanDetalID = @ID and DSTrN_DSTrNID in
 (select DTrN_DSTrNID from cdn.detaltranag where DTrN_StanSynchronizacji =2  and DTrN_StanDetalID = @ID)
 DECLARE Dodawane CURSOR LOCAL FAST_FORWARD FOR
 SELECT
 C.DSTrN_DSTrNID ,
 C.DSTrN_StanDetalID ,
 C.DSTrN_FAID ,
 C.DSTrN_ZwrID ,
 C.DSTrN_Korekta ,
 C.DSTrN_PARodzajKor ,
 C.DSTrN_TypDokumentu ,
 C.DSTrN_NumerNr ,
 C.DSTrN_NumerString ,
 C.DSTrN_NumerPelny ,
 C.DSTrN_DataDok ,
 C.DSTrN_Fiskalna ,
 A.DSKnt_OptimaId ,
 B.DSKnt_OptimaId ,
 C.DSTrN_RazemBrutto ,
 C.DSTrN_Rabat ,
 C.DSTrN_OsobaOdbierajaca,
 DSOpe_OptimaId ,
 C.DSTrN_TS_Zal ,
 (select count(*) from CDN.DetalStanTraElem  where DSTrE_DSTrNID = C.DSTrN_DSTrNID AND DSTrE_StornoID = 0 AND DSTrE_Ilosc <>0) as DSTrN_IloscElementow ,
 (select count(*) from CDN.DetalStanPlatnosciDokumentu WHERE DSPlD_DSTrNId = C.DSTrN_DSTrNID) as DSTrN_IloscPlatnosci,
 C.DSTrN_Opis
  from CDN.DetalStanTraNag C
  left join CDN.DetalStanTraNag D ON C.DSTrN_FAID = D.DSTrN_DSTrNID
  left join CDN.DetalStanOperatorzy ON C.DSTrN_OpeID = DSOpe_DSOpeID
  left join CDN.DetalStanKontrahenci A ON C.DSTrN_PodID = A.DSKnt_DSKntID
  left join CDN.DetalStanKontrahenci B ON C.DSTrN_OdbID = B.DSKnt_DSKntID
 where C.DSTrN_Bufor = 0 and ISNULL(D.DSTrN_Bufor,0) = 0 and ISNULL(C.DSTrN_StanSynchronizacji,0) < 2 and C.DSTrN_StanDetalID = @ID
 order by C.DSTrN_NumerNr
   OPEN Dodawane
       WHILE 1=1
        BEGIN
          FETCH NEXT FROM Dodawane INTO
 @DSTrNID ,
 @StanDetalID ,
 @FAID ,
 @ZwrID ,
 @Korekta ,
 @PARodzajKor,
 @TypDokumentu ,
 @NumerNr ,
 @NumerString ,
 @NumerPelny ,
 @DataDok ,
 @Fiskalna ,
 @PodID ,
 @OdbID ,
 @RazemBrutto ,
 @Rabat ,
 @OsobaOdbierajaca,
 @OpeID ,
 @TS_Zal ,
 @IloscElementow ,
 @IloscPlatnosci,
 @Opis
   IF @@FETCH_STATUS <> 0 BREAK
  EXEC CDN.Detal_AktualizujTraNag
 @DSTrNID ,
 @StanDetalID ,
 @FAID ,
 @ZwrID ,
 @Korekta ,
 @PARodzajKor ,
 @TypDokumentu ,
 @NumerNr ,
 @NumerString ,
 @NumerPelny ,
 @DataDok ,
 @Fiskalna ,
 @PodID ,
 @OdbID ,
 @RazemBrutto ,
 @Rabat ,
 @OsobaOdbierajaca,
 @OpeID ,
 @TS_Zal ,
 @IloscElementow ,
 @IloscPlatnosci,
 @Opis
    UPDATE CDN.DetalStanTraNag SET DSTrN_StanSynchronizacji = 1 WHERE DSTrN_DSTrNID = @DSTrNID and DSTrN_StanDetalID = @ID
END
   -- po udanym update towarow ustawiamy date
    CLOSE Dodawane
    DEALLOCATE Dodawane
END
ELSE
 SELECT
 C.DSTrN_DSTrNID ,
 C.DSTrN_StanDetalID ,
 C.DSTrN_FAID ,
 C.DSTrN_ZwrID ,
 C.DSTrN_Korekta ,
 C.DSTrN_TypDokumentu ,
 C.DSTrN_NumerNr ,
 C.DSTrN_NumerString ,
 C.DSTrN_NumerPelny ,
 C.DSTrN_DataDok ,
 C.DSTrN_Fiskalna ,
 A.DSKnt_OptimaId ,
 B.DSKnt_OptimaId ,
 C.DSTrN_RazemBrutto ,
 C.DSTrN_Rabat ,
 C.DSTrN_OsobaOdbierajaca,
 DSOpe_OptimaId ,
 C.DSTrN_TS_Zal ,
 (select count(*) from CDN.DetalStanTraElem  where DSTrE_DSTrNID = C.DSTrN_DSTrNID AND DSTrE_StornoID = 0 AND DSTrE_Ilosc <>0) as DSTrN_IloscElementow ,
 (select count(*) from CDN.DetalStanPlatnosciDokumentu WHERE DSPlD_DSTrNId = C.DSTrN_DSTrNID) as DSTrN_IloscPlatnosci,
 C.DSTrN_Opis
  from CDN.DetalStanTraNag C
  left join CDN.DetalStanTraNag D ON C.DSTrN_FAID = D.DSTrN_DSTrNID
  left join CDN.DetalStanOperatorzy ON C.DSTrN_OpeID = DSOpe_DSOpeID
  left join CDN.DetalStanKontrahenci A ON C.DSTrN_PodID = A.DSKnt_DSKntID
  left join CDN.DetalStanKontrahenci B ON C.DSTrN_OdbID = B.DSKnt_DSKntID
 where C.DSTrN_Bufor = 0 and ISNULL(D.DSTrN_Bufor,0) = 0 and ISNULL(C.DSTrN_StanSynchronizacji,0) < 2 and C.DSTrN_StanDetalID = @ID
 order by C.DSTrN_NumerNr
SET NOCOUNT OFF
