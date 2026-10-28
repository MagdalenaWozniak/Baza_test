CREATE PROCEDURE CDN.DetalStan_WydrukiPozycjeDokumentuKorygujacego
@correctionId int
AS
BEGIN
SET NOCOUNT ON
SELECT DSTrE_TwrNazwa,
DSTrE_TwrKod, DSTrE_CenaPoRabacie, DSTrE_WartoscBrutto, DSTrE_Stawka, DSTrE_Flaga, DSTrE_Ilosc,
DSTrE_Jm, DSTrE_Kaucja, DSTrE_Lp
FROM CDN.DetalStanTraElem WHERE DSTrE_DSTrNId = @correctionId AND DSTrE_StornoId = 0
SET NOCOUNT OFF
END
