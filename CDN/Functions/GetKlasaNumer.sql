CREATE FUNCTION CDN.GetKlasaNumer(@Klasa nvarchar(50))
RETURNS int
AS
BEGIN
 DECLARE @result int
 SELECT @result =
 case @Klasa
 when 'Ewidencja dodatkowa przychodów' then   101
 when 'Ewidencja dodatkowa przychodow' then   101
 when 'Ewidencja dodatkowa kosztów'  then   102
 when 'Ewidencja dodatkowa kosztow'  then   102
 when 'Potwierdzenie salda KH'   then   111
 when 'Ponaglenie zapłaty KH'   then   112
 when 'Ponaglenie zaplaty KH'   then   112
 when 'Nota odsetkowa KH'    then   113
 when 'Delegacja'      then    114
 when 'PK kompensaty'    then   115
 when 'Różnica kursowa KH'  then   116
 when 'Bilans otwarcia'     then   500
 when 'Wypłata'       then   201
 when 'Wyplata'       then   201
 when 'Wpłata'       then   202
 when 'Wplata'       then   202
 when 'Raport kasa/bank'     then   211
 when 'Nota odsetkowa'     then   221
 when 'Ponaglenie zapłaty'    then   222
 when 'Ponaglenie zaplaty'    then   222
 when 'Potwierdzenie salda'    then   223
    when 'Różnica kursowa'     then        224
 when 'Roznica kursowa'     then        224
    when 'Różnica kursowa MW'    then   225
 when 'Roznica kursowa MW'    then   225
 when 'Kompensata'      then   226
 when 'Faktura zakupu'     then   301
 when 'Faktura sprzedaży'    then   302
 when 'Faktura sprzedazy'    then   302
 when 'Przyjęcie wewnętrzne'    then   303
 when 'Przyjecie wewnetrzne'    then   303
 when 'Rozchód wewnętrzny'    then   304
 when 'Rozchod wewnetrzny'    then   304
 when 'Paragon'       then   305
 when 'Wydanie zewnętrzne'    then   306
 when 'Wydanie zewnetrzne'    then   306
 when 'Przyjęcie zewnętrzne'    then   307
 when 'Przyjecie zewnetrzne'    then   307
 when 'Rezerwacja odbiorcy'    then   308
 when 'Zamówienie u dostawcy'   then   309
 when 'Zamowienie u dostawcy'   then   309
 when 'Bilans otwarcia magazynu'   then   310
 when 'Arkusz inwentaryzacyjny'   then   311
 when 'Przesunięcie międzymagazynowe' then   312
 when 'Przesuniecie miedzymagazynowe' then   312
 when 'Faktura zaliczkowa'    then   313
 when 'Wydanie kaucji'     then   314
 when 'Przyjęcie wewnętrzne produktów' then   317
 when 'Przyjecie wewnetrzne produktow' then   317
 when 'Rozchód wewnętrzny składników' then   318
 when 'Rozchod wewnetrzny skladnikow' then   318
    when 'Faktura proforma'     then       320
    when 'Faktura wewnętrzna zakupu'  then       321
 when 'Faktura wewnetrzna zakupu'  then       321
    when 'Faktura wewnętrzna sprzedaży'  then       322
 when 'Faktura wewnetrzna sprzedazy'  then       322
    when 'Faktura dla rolnika ryczałtowego' then      350
 when 'Faktura dla rolnika ryczaltowego' then      350
    when 'Zlecenie nadania paczki' then 370
 when 'Umowa'       then   400
 when 'Lista płac'      then   600
 when 'Lista plac'      then   600
    when 'Kontakt'       then    700
    when 'Oferta MS Word'     then     800
 when 'Etat korygująca'     then    650
 when 'Etat korygujaca'     then    650
 when 'Zlecenie serwisowe'    then    900
 when 'Dokument TaxFree'     then   345
 when 'Obieg dokumentów'     then   750
 when 'Obieg dokumentow'     then   750
 when 'Wiadomość przychodząca'   then   1010
 when 'Wiadomosc przychodzaca'   then   1010
 when 'Wiadomość wychodząca'    then   1011
 when 'Wiadomosc wychodzaca'    then   1011
 when 'Identyfikator księgowy'   then   1012
 when 'Identyfikator ksiegowy'   then   1012
 when 'Wiadomość SMS'     then   1020
 when 'Wiadomosc SMS'     then   1020
  when 'Arkusz inwent. ST' then 1111
  when 'Arkusz inwent. WYP' then 1112
-- when 'Faktury sprzedaży - zlecenie serwisowe'  then 900302
-- when 'Rozchody wewnętrzne - zlecenie serwisowe' then  900304
-- when 'Paragony - zlecenie serwisowe'   then 900305
-- when 'Wydania zewnętrzne - zlecenie serwisowe'  then 900306
-- when 'Zamówienia ZD - zlecenie serwisowe'   then 900309
-- when 'Przesunięcia MM - zlecenie serwisowe'  then 900312
 else 0
 end
 RETURN @result
END
