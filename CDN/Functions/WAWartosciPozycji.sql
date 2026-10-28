CREATE FUNCTION CDN.WAWartosciPozycji(@DokumentTyp int)
RETURNS @Result TABLE( Id int identity(1,1), Makro varchar(128), Definicja varchar(128), Format varchar(128) default(''), Zrodlo varchar(128) default('this'), SrcDokIdFieldName  varchar(128) default(''), LpPozycjiFieldName varchar(128) default(''), SrcDokTyp int default(0), auto int default(1), sourceType int default(0))
AS
BEGIN
 if @DokumentTyp= 1      --   Faktury zakupu
 begin
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, sourceType) values('L.p. [netto pozycji]','TrE_Lp,TrE_TwrKod,TrE_WartoscNetto', 'Elementy', 'Pozycja/{0}/{1}/[{2}]', 'TrE_TwrId','TrE_Lp', 33,1);
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, auto, sourceType) values('netto dokumentu','TrN_RazemNetto', 'this', 'Pozycja/Dokument/[{0}]', '', '', 1, 0,2);
 end
 else if @DokumentTyp= 2           --   Faktury sprzedaży
 begin
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, sourceType) values('L.p. [netto pozycji]','TrE_Lp,TrE_TwrKod,TrE_WartoscNetto', 'Elementy', 'Pozycja/{0}/{1}/[{2}]', 'TrE_TwrId','TrE_Lp', 33,1);
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, auto, sourceType) values('netto dokumentu','TrN_RazemNetto', 'this', 'Pozycja/Dokument/[{0}]', '', '', 2, 0,2);
 end
 else if @DokumentTyp= 3           --   Dokument wewnętrzny zakupu
 begin
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, sourceType) values('L.p. [netto pozycji]','TrE_Lp,TrE_TwrKod,TrE_WartoscNetto', 'Elementy', 'Pozycja/{0}/{1}/[{2}]', 'TrE_TwrId','TrE_Lp', 33,1);
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, auto, sourceType) values('netto dokumentu','TrN_RazemNetto', 'this', 'Pozycja/Dokument/[{0}]', '', '', 3, 0,2);
 end
 else if @DokumentTyp= 4           --   Dokument wewnętrzny sprzedaży
 begin
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, sourceType) values('L.p. [netto pozycji]','TrE_Lp,TrE_TwrKod,TrE_WartoscNetto', 'Elementy', 'Pozycja/{0}/{1}/[{2}]', 'TrE_TwrId','TrE_Lp', 33,1);
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, auto, sourceType) values('netto dokumentu','TrN_RazemNetto', 'this', 'Pozycja/Dokument/[{0}]', '', '', 4, 0,2);
 end
 else if @DokumentTyp= 5           --   Dokument TaxFree
 begin
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, sourceType) values('L.p. [netto pozycji]','TrE_Lp,TrE_TwrKod,TrE_WartoscNetto', 'Elementy', 'Pozycja/{0}/{1}/[{2}]', 'TrE_TwrId','TrE_Lp', 33,1);
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, auto, sourceType) values('netto dokumentu','TrN_RazemNetto', 'this', 'Pozycja/Dokument/[{0}]', '', '', 5, 0,2);
 end
 else if @DokumentTyp= 6           --   Paragony
 begin
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, sourceType) values('L.p. [netto pozycji]','TrE_Lp,TrE_TwrKod,TrE_WartoscNetto', 'Elementy', 'Pozycja/{0}/{1}/[{2}]', 'TrE_TwrId','TrE_Lp', 33,1);
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, auto, sourceType) values('netto dokumentu','TrN_RazemNetto', 'this', 'Pozycja/Dokument/[{0}]', '', '', 6, 0,2);
 end
 else if @DokumentTyp= 7           --   Kompletacja przyjecie produktów
 begin
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, sourceType) values('L.p. [netto pozycji]','TrE_Lp,TrE_TwrKod,TrE_WartoscNetto', 'Elementy', 'Pozycja/{0}/{1}/[{2}]', 'TrE_TwrId','TrE_Lp', 33,1);
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, auto, sourceType) values('netto dokumentu','TrN_RazemNetto', 'this', 'Pozycja/Dokument/[{0}]', '', '', 7, 0,2);
 end
 else if @DokumentTyp= 8           --   Kompletacja rozchód składników
 begin
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, sourceType) values('L.p. [netto pozycji]','TrE_Lp,TrE_TwrKod,TrE_WartoscNetto', 'Elementy', 'Pozycja/{0}/{1}/[{2}]', 'TrE_TwrId','TrE_Lp', 33,1);
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, auto, sourceType) values('netto dokumentu','TrN_RazemNetto', 'this', 'Pozycja/Dokument/[{0}]', '', '', 8, 0,2);
 end
 else if @DokumentTyp= 9           --   Przesuniecia MM
 begin
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, sourceType) values('L.p. [netto pozycji]','TrE_Lp,TrE_TwrKod,TrE_WartoscNetto', 'Elementy', 'Pozycja/{0}/{1}/[{2}]', 'TrE_TwrId','TrE_Lp', 33,1);
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, auto, sourceType) values('netto dokumentu','TrN_RazemNetto', 'this', 'Pozycja/Dokument/[{0}]', '', '', 9, 0,2);
 end
 else if @DokumentTyp= 10          --   Przyjęcie kaucji
 begin
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, sourceType) values('L.p. [netto pozycji]','TrE_Lp,TrE_TwrKod,TrE_WartoscNetto', 'Elementy', 'Pozycja/{0}/{1}/[{2}]', 'TrE_TwrId','TrE_Lp', 33,1);
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, auto, sourceType) values('netto dokumentu','TrN_RazemNetto', 'this', 'Pozycja/Dokument/[{0}]', '', '', 10, 0,2);
 end
 else if @DokumentTyp= 11          --   Przyjęcie wewnętrzne
 begin
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, sourceType) values('L.p. [netto pozycji]','TrE_Lp,TrE_TwrKod,TrE_WartoscNetto', 'Elementy', 'Pozycja/{0}/{1}/[{2}]', 'TrE_TwrId','TrE_Lp', 33,1);
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, auto, sourceType) values('netto dokumentu','TrN_RazemNetto', 'this', 'Pozycja/Dokument/[{0}]', '','', 11, 0,2);
 end
 else if @DokumentTyp= 12          --   Przyjęcie zewnętrzne
 begin
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, sourceType) values('L.p. [netto pozycji]','TrE_Lp,TrE_TwrKod,TrE_WartoscNetto', 'Elementy', 'Pozycja/{0}/{1}/[{2}]', 'TrE_TwrId','TrE_Lp', 33,1);
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, auto, sourceType) values('netto dokumentu','TrN_RazemNetto', 'this', 'Pozycja/Dokument/[{0}]', '', '', 12, 0,2);
 end
 else if @DokumentTyp= 13          --   Rozchód wewnętrzny
 begin
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, sourceType) values('L.p. [netto pozycji]','TrE_Lp,TrE_TwrKod,TrE_WartoscNetto', 'Elementy', 'Pozycja/{0}/{1}/[{2}]', 'TrE_TwrId','TrE_Lp', 33,1);
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, auto, sourceType) values('netto dokumentu','TrN_RazemNetto', 'this', 'Pozycja/Dokument/[{0}]', '', '', 13, 0,2);
 end
 else if @DokumentTyp= 14          --   Wydanie kaucji
 begin
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, sourceType) values('L.p. [netto pozycji]','TrE_Lp,TrE_TwrKod,TrE_WartoscNetto', 'Elementy', 'Pozycja/{0}/{1}/[{2}]', 'TrE_TwrId','TrE_Lp', 33,1);
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, auto, sourceType) values('netto dokumentu','TrN_RazemNetto', 'this', 'Pozycja/Dokument/[{0}]', '', '', 14, 0,2);
 end
 else if @DokumentTyp= 15          --   Wydanie zewnętrzne
 begin
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, sourceType) values('L.p. [netto pozycji]','TrE_Lp,TrE_TwrKod,TrE_WartoscNetto', 'Elementy', 'Pozycja/{0}/{1}/[{2}]', 'TrE_TwrId','TrE_Lp', 33,1);
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, auto, sourceType) values('netto dokumentu','TrN_RazemNetto', 'this', 'Pozycja/Dokument/[{0}]', '', '', 15, 0,2);
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, sourceType) values('L.p. [Koszt_zakupu]','TrE_Lp,TrE_TwrKod,TrE_WartoscZakupu', 'Elementy', 'Pozycja/Koszt_zakupu/{0}/{1}/[{2}]', 'TrE_TwrId','TrE_Lp', 33,1);
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, auto, sourceType) values('Koszt_zakupu','TrN_WartoscZakupu', 'this', 'Pozycja/Koszt_zakupu/Dokument/[{0}]', '', '', 15, 0,2);
 end
 else if @DokumentTyp= 16          --   Ewidencja Przychodów
 begin
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, auto, sourceType) values('L.p. [netto pozycji]','Kdd_Lp,Kdd_Kwota', 'KwotyDodatkowe', 'Pozycja/{0}/Kwota dodatkowa/[{1}]', 'Kdd_DokumentID', 'Kdd_Lp', 16, 0,1);
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, auto, sourceType) values('[netto pozycji]','EDN_KwotaRazemSys', 'this', 'Pozycja/Dokument/[{0}]', '', '', 16, 0,2);
 end
 else if @DokumentTyp= 17          --   Ewidencja kosztów
 begin
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, auto, sourceType) values('L.p. [netto pozycji]','Kdd_Lp,Kdd_Kwota', 'KwotyDodatkowe', 'Pozycja/{0}/Kwota dodatkowa/[{1}]', 'Kdd_DokumentID', 'Kdd_Lp', 17, 0,1);
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, auto, sourceType) values('[netto pozycji]','EDN_KwotaRazemSys', 'this', 'Pozycja/Dokument/[{0}]', '', '', 17, 0,2);
 end
 else if @DokumentTyp= 18          --   Bilans otwarcia
  insert into @Result(Makro, Definicja, sourceType) values('L.p. [netto pozycji]','',1);
 else if @DokumentTyp= 19          --   Polecenie Księgowania
 begin
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, sourceType) values('L.p. [netto pozycji]','DeE_Lp,DeE_KontoWn,DeE_Kwota', 'Elementy', 'Pozycja/{0}/{1}/[{2}] Strona Wn', 'DeE_AccWnId', 'DeE_Lp', 37,1);
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, sourceType) values('L.p. [brutto pozycji]','DeE_Lp,DeE_KontoMa,DeE_Kwota', 'Elementy', 'Pozycja/{0}/{1}/[{2}] Strona Ma', 'DeE_AccMaId', 'DeE_Lp', 37,2);
 end
 else if @DokumentTyp= 20          --   Rejestr zakupu
 begin
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, auto, sourceType) values('L.p. [netto pozycji]','Kdd_Lp,Kdd_Kwota', 'KwotyDodatkowe', 'Pozycja/{0}/Kwota dodatkowa/[{1}]', 'Kdd_DokumentID', 'Kdd_Lp', 20, 0,1);
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, auto, sourceType) values('L.p. [Stawka VAT][netto pozycji]','VaT_Lp,VaT_StawkaSymbol,VaT_Netto', 'Elementy', 'Pozycja/{0}/Netto, {1}/[{2}]', '', 'VaT_Lp', 20, 0,2);
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, auto, sourceType) values('VAT na NIE NETTO+VAT na NIE łącznie','VaT_Lp,VaT_StawkaSymbol,VaT_KwotaNKUP', 'Elementy', 'Pozycja/{0}/Koszt, {1}/[{2}]', '', 'VaT_Lp', 20, 0,3);
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, auto, sourceType) values('VAT','VaT_Lp,VaT_StawkaSymbol,VaT_VATNKUP', 'Elementy', 'Pozycja/{0}/VAT_KOSZT, {1}/[{2}]', '', 'VaT_Lp', 20, 0,4);
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, auto, sourceType) values('[netto dokumentu]','VaN_RazemNetto', 'this', 'Pozycja/Dokument/Netto/[{0}]', '', '', 20, 0,5);
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, auto, sourceType) values('[netto dokumentu]','VaN_KwotaNKUP', 'this', 'Pozycja/Dokument/Koszt/[{0}]', '', '', 20, 0,6);
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, auto, sourceType) values('[netto dokumentu]','VaN_VATNKUP', 'this', 'Pozycja/Dokument/VAT_KOSZT/[{0}]', '', '', 20, 0,7);
 end
 else if @DokumentTyp= 21          --   Rejestr sprzedaży
 begin
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, auto, sourceType) values('L.p. [netto pozycji]','Kdd_Lp,Kdd_Kwota', 'KwotyDodatkowe', 'Pozycja/{0}/Kwota dodatkowa/[{1}]', 'Kdd_DokumentID', 'Kdd_Lp', 21, 0,1);
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, auto, sourceType) values('L.p. [Stawka VAT][netto pozycji]','VaT_Lp,VaT_StawkaSymbol,VaT_Netto', 'Elementy', 'Pozycja/{0}/Netto, {1}/[{2}]', '', 'VaT_Lp', 21, 0,2);
  --insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, auto) values('VAT na NIE NETTO+VAT na NIE łącznie','VaT_Lp,VaT_Stawka,VaT_KwotaNKUP', 'Elementy', 'Pozycja/{0}/Koszt, {1}%/[{2}]', '', 'VaT_Lp', 21, 0);
  --insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, auto) values('VAT','VaT_Lp,VaT_Stawka,VaT_VATNKUP', 'Elementy', 'Pozycja/{0}/VAT, {1}%/[{2}]', '', 'VaT_Lp', 21, 0);
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, auto, sourceType) values('[netto dokumentu]','VaN_RazemNetto', 'this', 'Pozycja/Dokument/Netto/[{0}]', '', '', 21, 0,5);
  --insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, auto) values('[netto dokumentu]','VaN_KwotaNKUP', 'this', 'Pozycja/Dokument/Koszt[{0}]', '', '', 21, 0);
  --insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, auto) values('[netto dokumentu]','VaN_VATNKUP', 'this', 'Pozycja/Dokument/VAT[{0}]', '', '', 21, 0);
 end
 else if @DokumentTyp= 22          --   Wpłata
 begin
    insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, sourceType) values('L.p. [netto pozycji]','BZp_Kwota', 'this', 'Pozycja/Netto/{0}', '', '',22,1);
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, sourceType) values('L.p. [netto pozycji]','Kdd_Lp,Kdd_Kwota', 'KwotyDodatkowe', 'Pozycja/{0}/Kwota dodatkowa/[{1}]', 'Kdd_DokumentID', 'Kdd_Lp',22,2);
 end
 else if @DokumentTyp= 23          --   Wypłata
 begin
    insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, sourceType) values('L.p. [netto pozycji]','BZp_Kwota', 'this', 'Pozycja/Netto/{0}', '', '', 23,1);
  insert into @Result(Makro, Definicja, Zrodlo, Format, SrcDokIdFieldName,  LpPozycjiFieldName,SrcDokTyp, sourceType) values('L.p. [netto pozycji]','Kdd_Lp,Kdd_Kwota', 'KwotyDodatkowe', 'Pozycja/{0}/Kwota dodatkowa/[{1}]', 'Kdd_DokumentID', 'Kdd_Lp',23,2);
 end
 else if @DokumentTyp= 24          --   Różnice kursowe
  insert into @Result(Makro, Definicja, sourceType) values('L.p. [netto pozycji]','',1);
 else if @DokumentTyp= 25          --   Różnice kursowe magazynu walut
  insert into @Result(Makro, Definicja, sourceType) values('L.p. [netto pozycji]','',1);
 else if @DokumentTyp= 26          --   Amortyzacja
  insert into @Result(Makro, Definicja, sourceType) values('L.p. [netto pozycji]','',1);
 else if @DokumentTyp= 27          --   Likwidacja
  insert into @Result(Makro, Definicja, sourceType) values('L.p. [netto pozycji]','',1);
 else if @DokumentTyp= 28          --   Otrzymanie
  insert into @Result(Makro, Definicja, sourceType) values('L.p. [netto pozycji]','',1);
 else if @DokumentTyp= 29          --   Ulepszenie
  insert into @Result(Makro, Definicja, sourceType) values('L.p. [netto pozycji]','',1);
 else if @DokumentTyp= 30          --   Przeszacowanie
  insert into @Result(Makro, Definicja, sourceType) values('L.p. [netto pozycji]','',1);
 else if @DokumentTyp= 31          --   Lista płac
  insert into @Result(Makro, Definicja, sourceType) values('L.p. [netto pozycji]','',1);
 else if @DokumentTyp= 32          --   Grupy towarowe
  insert into @Result(Makro, Definicja, sourceType) values('L.p. [netto pozycji]','',1);
 else if @DokumentTyp= 33          --   Towary
  insert into @Result(Makro, Definicja,sourceType) values('L.p. [netto pozycji]','',1);
 else if @DokumentTyp= 34          --   Środki trwałe
  insert into @Result(Makro, Definicja, sourceType) values('L.p. [netto pozycji]','',1);
 else if @DokumentTyp= 35          --   Pracownicy
  insert into @Result(Makro, Definicja, sourceType) values('L.p. [netto pozycji]','',1);
 else if @DokumentTyp= 36          --   Wspólnicy
  insert into @Result(Makro, Definicja, sourceType) values('L.p. [netto pozycji]','',1);
 else if @DokumentTyp= 37          --   Konto księgowe
  insert into @Result(Makro, Definicja, sourceType) values('L.p. [netto pozycji]','',1);
 return
END
