CREATE PROCEDURE [CDN].[DetalStan_WydrukiPozycjeDokumentow]
@receiptId int
AS
BEGIN
SET NOCOUNT ON
SELECT DSTrE_TwrNazwa,
DSTrE_TwrKod,
DSTrE_CenaPoRabacie,
DSTrE_WartoscBrutto,
DSTrE_Stawka,
DSTrE_Flaga,
DSTrE_Ilosc,
DSTrE_Jm,
DSTrE_JmPrzelicznikL,
DSTrE_JmPrzelicznikM,
DSTrE_Kaucja,
DSTrE_Cena,
DSTrE_Rabat FROM CDN.DetalStanTraElem
WHERE DSTrE_DSTrNId = @receiptId AND DSTrE_StornoId = 0
SET NOCOUNT OFF
END
