CREATE PROCEDURE CDN.FaWalidacjaForXml
@TrnID            AS INT,
@eFa           AS INT
AS
BEGIN
 DECLARE @bufor INT, @rodzaj INT, @korekta INT
 DECLARE @waluta VARCHAR(3), @walSys VARCHAR(3)
 SELECT @bufor = TrN_Bufor, @rodzaj = TrN_Rodzaj, @korekta = TrN_Korekta, @waluta = TrN_Waluta
 FROM cdn.TraNag
 WHERE TrN_TrNID = @TrnID
 IF @bufor = -1
 BEGIN
        --RAISERROR( 'Dokument jest anulowany!' , 16, 1)
  EXEC cdn.RaiseOptimaException 34169
        RETURN
 END
 IF @bufor = 1
 BEGIN
        --RAISERROR( 'Dokument jest w buforze!' , 16, 1)
  EXEC cdn.RaiseOptimaException 34170
        RETURN
 END
 -- jest fakturą korektą zbiorczą / rabat
 IF @korekta = 6
 BEGIN
  --RAISERROR( 'Dokument jest korektą zbiorczą!' , 16, 1)
  EXEC cdn.RaiseOptimaException 34906
  RETURN
 END
 IF @eFa = 0 RETURN
-- Walidacja dla e-faktur
 -- jest fakturą zaliczkową lub korektą zaliczkowej
 IF @rodzaj = 302200 OR  @rodzaj = 302202
 BEGIN
        --RAISERROR( 'Dokument jest fakturą zaliczkową!' , 16, 1)
  EXEC cdn.RaiseOptimaException 34171
        RETURN
 END
 -- jest fakturą pierwotną
 IF @rodzaj = 302100
 BEGIN
        --RAISERROR( 'Dokument jest fakturą pierwotną!' , 16, 1)
  EXEC cdn.RaiseOptimaException 34172
        RETURN
 END
 -- jest fakturą VAT Marża
 IF @rodzaj = 302080
 BEGIN
        --RAISERROR( 'Dokument jest fakturą VAT marża!' , 16, 1)
  EXEC cdn.RaiseOptimaException 34173
        RETURN
 END
 -- jest dokumentem walutowym
 EXEC CDN.SymbolWalSys @walSys OUTPUT
 IF @waluta <> '' AND @waluta <> @WalSys
 BEGIN
        --RAISERROR( 'Dokument jest fakturą walutową!' , 16, 1)
  EXEC cdn.RaiseOptimaException 34174
        RETURN
 END
 -- ma kaucje
 DECLARE @kaucja INT
 SELECT @kaucja = count(*)
 FROM cdn.TraElem
 WHERE TrE_TrNID = @TrnID AND TrE_Kaucja=1
 IF @kaucja > 0
 BEGIN
        --RAISERROR( 'Na dokumencie znajdują się opakowania kaucjonowane!' , 16, 1)
  EXEC cdn.RaiseOptimaException 34175
        RETURN
 END
-- kontrahent, który jest odbiorcą faktury nie ma zaznaczonego checku ‘zgoda na wysyłanie..’
 DECLARE @zgoda INT
 SELECT @zgoda = Pod_PodId
 FROM cdn.TraNag
 JOIN cdn.PodmiotyView ON PoD_PodmiotTyp = TrN_PodmiotTyp AND PoD_PodId = TrN_PodId
 WHERE TrN_TrNID = @TrnID
 IF @zgoda = 0
 BEGIN
        --RAISERROR('Kontrahent, który jest odbiorcą faktury nie ma zaznaczonego parametru: Zgoda na wysyłanie e-faktur!' , 16, 1)
  EXEC cdn.RaiseOptimaException 34176
        RETURN
 END
-- jest fakturą korektą ilości na plus
 IF @korekta = 1
 BEGIN
  DECLARE @naplus INT
  SELECT @naplus = count(*)
  FROM cdn.TraElem
  WHERE TrE_Ilosc > 0
  IF @naplus > 0
  BEGIN
   --RAISERROR( 'Dokument posiada pozycje korekty ilości na plus!' , 16, 1)
   EXEC cdn.RaiseOptimaException 34177
   RETURN
  END
 END
-- jest fakturą korektą wartości do części ilości
-- E-Faktury. W przypadku eksportu dokumentu jeśli na nim jest przynajmniej 1 towar bez EAN-u dawać komunikat:
-- TRACK ID=149431
 IF EXISTS(SELECT * FROM cdn.TraElem WHERE TrE_TrNID = @TrnID AND LEN(TrE_TwREAN) = 0)
 BEGIN
  --RAISERROR( 'Nie wszystkie towary ujęte w eksportowanym dokumencie posiadają wypełniony kod EAN.' , 16, 1)
  EXEC cdn.RaiseOptimaException 34178
  RETURN
 END
KONIEC:
 RETURN
END
