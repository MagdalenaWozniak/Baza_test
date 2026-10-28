CREATE PROCEDURE [CDN].[DetalStan_PobierzParagonyDoKorekty]
@PosId int,
@OpeId int
AS
BEGIN
SET NOCOUNT ON
IF @OpeId > 0
BEGIN
 SELECT b.DSTrN_DSTrNID
      ,b.DSTrN_StanDetalID
      ,b.DSTrN_FaId
      ,b.DSTrN_TypDokumentu
      ,b.DSTrN_NumerNr
      ,b.DSTrN_NumerString
      ,b.DSTrN_NumerPelny
      ,b.DSTrN_Bufor
      ,b.DSTrN_Anulowany
      ,b.DSTrN_DataDok
      ,b.DSTrN_Fiskalna
      ,b.DSTrN_FiskalnaErr
      ,b.DSTrN_PodID
      ,b.DSTrN_OdbID
      ,b.DSTrN_RazemBrutto
      ,b.DSTrN_Rabat
      ,b.DSTrN_Waluta
      ,b.DSTrN_OsobaOdbierajaca
      ,b.DSTrN_StanSynchronizacji
      ,b.DSTrN_OpeID
      ,b.DSTrN_ZmianaId
      ,b.DSTrN_TS_Zal
      ,a.DSKnt_Kod
      ,a.DSKnt_NipE
      ,c.DSOpe_Kod
      ,a.DSKnt_Nazwa1
      ,b.DSTrN_Opis
 FROM ((CDN.DetalStanKontrahenci a
  right join CDN.DetalStanTraNag b ON b.DSTrN_PodID = a.DSKnt_DSKntId)
  left join CDN.DetalStanOperatorzy c ON b.DSTrN_OpeID = c.DSOpe_DSOpeID)
 WHERE b.DSTrN_TypDokumentu = 305 AND
   b.DSTrN_Korekta IS NULL AND
   b.DSTrN_Bufor = 0 AND
   b.DSTrN_StanDetalID = @PosId AND
   b.DSTrN_OpeID = @OpeId
END
ELSE
BEGIN
 SELECT b.DSTrN_DSTrNID
      ,b.DSTrN_StanDetalID
      ,b.DSTrN_FaId
      ,b.DSTrN_TypDokumentu
      ,b.DSTrN_NumerNr
      ,b.DSTrN_NumerString
      ,b.DSTrN_NumerPelny
      ,b.DSTrN_Bufor
      ,b.DSTrN_Anulowany
      ,b.DSTrN_DataDok
      ,b.DSTrN_Fiskalna
      ,b.DSTrN_FiskalnaErr
      ,b.DSTrN_PodID
      ,b.DSTrN_OdbID
      ,b.DSTrN_RazemBrutto
      ,b.DSTrN_Rabat
      ,b.DSTrN_Waluta
      ,b.DSTrN_OsobaOdbierajaca
      ,b.DSTrN_StanSynchronizacji
      ,b.DSTrN_OpeID
      ,b.DSTrN_ZmianaId
      ,b.DSTrN_TS_Zal
      ,a.DSKnt_Kod
      ,a.DSKnt_NipE
      ,c.DSOpe_Kod
      ,a.DSKnt_Nazwa1
      ,b.DSTrN_Opis
 FROM ((CDN.DetalStanKontrahenci a
  right join CDN.DetalStanTraNag b ON b.DSTrN_PodID = a.DSKnt_DSKntId)
        left join CDN.DetalStanOperatorzy c ON b.DSTrN_OpeID = c.DSOpe_DSOpeID)
 WHERE b.DSTrN_TypDokumentu = 305 AND
   b.DSTrN_Korekta IS NULL AND
   b.DSTrN_Bufor = 0 AND
   b.DSTrN_StanDetalID = @PosId
END
SET NOCOUNT OFF
END
