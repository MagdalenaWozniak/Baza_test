CREATE PROCEDURE [CDN].[DetalStan_PobierzElementyDokumentu]
@id int
AS
BEGIN
SET NOCOUNT ON
 SELECT a.DSTrE_DSTrEID,
 a.DSTrE_DSTrNId,
 a.DSTrE_StornoId,
 a.DSTrE_Lp,
 a.DSTrE_TwrId,
 a.DSTrE_TwrNazwa,
 a.DSTrE_TwrEAN,
 a.DSTrE_TwrKod,
 a.DSTrE_Stawka,
 a.DSTrE_Flaga,
 a.DSTrE_Cena,
 a.DSTrE_Rabat,
 a.DSTrE_CenaPoRabacie,
 a.DSTrE_Kaucja,
 a.DSTrE_Ilosc,
 a.DSTrE_Jm,
 a.DSTrE_JmCalkowite,
 a.DSTrE_JmPrzelicznikL,
 a.DSTrE_JmPrzelicznikM,
 a.DSTrE_Waluta,
 ISNULL(a.DSTrE_ZwrId, 0)
       FROM (CDN.DetalStanTraElem a
  left join CDN.DetalStanTraNag b ON b.DSTrN_DSTrNId = a.DSTrE_DSTrNId)
 WHERE b.DSTrN_DSTrNID = @id
SET NOCOUNT OFF
END
