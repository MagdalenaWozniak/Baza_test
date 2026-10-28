CREATE PROCEDURE [CDN].[DetalStan_PobierzZamknieteFaktury]
@DocType int,
@PosId int,
@OpeId int,
@KntKod varchar(200),
@OpeKod varchar(200),
@DateFrom datetime,
@DateTo datetime
AS
BEGIN
SET NOCOUNT ON
 SELECT b.DSTrN_DSTrNID,
   b.DSTrN_NumerPelny,
   b.DSTrN_DataDok,
   b.DSTrN_RazemBrutto,
   b.DSTrN_FaId,
   a.DSKnt_Kod,
   a.DSKnt_NipE,
   c.DSOpe_Kod,
   b.DSTrN_NumerString,
   b.DSTrN_NumerNr,
   b.DSTrN_StanSynchronizacji,
   case when ISNULL(b.DSTrN_Korekta, 0) = 0 then SUM(case when d.DSTrE_Kaucja = 1 then d.DSTrE_WartoscBrutto else convert(decimal(15,2), 0) end) else convert(decimal(15,2), 0) end,
   e.DSTrN_DataDok,
   ISNULL(b.DSTrN_Korekta, 0),
   b.DSTrN_Opis,
   b.DSTrN_OsobaOdbierajaca
 FROM (((CDN.DetalStanKontrahenci a right join CDN.DetalStanTraNag b
 ON b.DSTrN_PodID = a.DSKnt_DSKntId) left join CDN.DetalStanOperatorzy c
 ON b.DSTrN_OpeID = c.DSOpe_DSOpeID) left join CDN.DetalStanTraElem d
 ON b.DSTrN_FaId = d.DSTrE_DSTrNId) left join CDN.DetalStanTraNag e
 ON b.DSTrN_FaId = e.DSTrN_DSTrNID
 WHERE b.DSTrN_TypDokumentu = @DocType AND
   b.DSTrN_Bufor = 0 AND
   b.DSTrN_StanDetalID = @PosId AND
   (@OpeId = 0 OR b.DSTrN_OpeID = @OpeId) AND
   (@OpeKod IS NULL OR c.DSOpe_Kod = @OpeKod) AND
   (@KntKod IS NULL OR a.DSKnt_Kod = @KntKod) AND
   (@DateFrom IS NULL OR b.DSTrN_DataDok >= @DateFrom) AND
   (@DateTo IS NULL OR b.DSTrN_DataDok <= @DateTo)
 GROUP BY b.DSTrN_DSTrNID,
   b.DSTrN_NumerPelny,
   b.DSTrN_DataDok,
   b.DSTrN_RazemBrutto,
   b.DSTrN_FaId,
   a.DSKnt_Kod,
   a.DSKnt_NipE,
   c.DSOpe_Kod,
   b.DSTrN_NumerString,
   b.DSTrN_NumerNr,
   b.DSTrN_StanSynchronizacji,
   e.DSTrN_DataDok,
   b.DSTrN_Korekta,
   b.DSTrN_Opis,
   b.DSTrN_OsobaOdbierajaca
SET NOCOUNT OFF
END
