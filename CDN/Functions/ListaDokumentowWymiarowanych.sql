CREATE FUNCTION CDN.ListaDokumentowWymiarowanych()
RETURNS @Result TABLE(  id int identity(1,1), grupa int, kod int, nazwa nvarchar(100), kolumna varchar(4), konfiguracja nvarchar(100), aktywny tinyint default(0))
AS
BEGIN
 --insert into @result (grupa, kod, nazwa, kolumna, konfiguracja) values(NULL,NULL,NULL,NULL, '-wszystkie-');
 insert into @result (grupa, kod, nazwa, kolumna, konfiguracja, aktywny) values(1,301,'Faktury zakupu',             'D001', 'Faktury', 1);
 insert into @result (grupa, kod, nazwa, kolumna, konfiguracja, aktywny) values(1,302,'Faktury sprzedaży',         'D002', 'Faktury', 1);
 insert into @result (grupa, kod, nazwa, kolumna, konfiguracja, aktywny) values(1,321,'Dokument wewnętrzny zakupu',      'D003', 'Faktury', 1);
 insert into @result (grupa, kod, nazwa, kolumna, konfiguracja, aktywny) values(1,322,'Dokument wewnętrzny sprzedaży',     'D004', 'Faktury', 1);
 insert into @result (grupa, kod, nazwa, kolumna, konfiguracja, aktywny) values(1,345,'Dokument TaxFree',          'D005', 'Faktury', 1);
 insert into @result (grupa, kod, nazwa, kolumna, konfiguracja, aktywny) values(1,305,'Paragony',                  'D006', 'Faktury', 1);
 insert into @result (grupa, kod, nazwa, kolumna, konfiguracja, aktywny) values(1,317,'Kompletacja przyjęcie produktów',     'D007', 'Handel', 1);
 insert into @result (grupa, kod, nazwa, kolumna, konfiguracja, aktywny) values(1,318,'Kompletacja rozchód składników',     'D008', 'Handel', 1);
 insert into @result (grupa, kod, nazwa, kolumna, konfiguracja, aktywny) values(1,312,'Przesunięcia międzymagazynowe',               'D009', 'Handel', 1);
 insert into @result (grupa, kod, nazwa, kolumna, konfiguracja, aktywny) values(1,313,'Przyjęcie kaucji',             'D010', 'Handel', 1);
 insert into @result (grupa, kod, nazwa, kolumna, konfiguracja, aktywny) values(1,303,'Przyjęcie wewnętrzne',         'D011', 'Handel', 1);
 insert into @result (grupa, kod, nazwa, kolumna, konfiguracja, aktywny) values(1,307,'Przyjęcie zewnętrzne',         'D012', 'Handel', 1);
 insert into @result (grupa, kod, nazwa, kolumna, konfiguracja, aktywny) values(1,304,'Rozchód wewnętrzny',           'D013', 'Handel', 1);
 insert into @result (grupa, kod, nazwa, kolumna, konfiguracja, aktywny) values(1,314,'Wydanie kaucji',               'D014', 'Handel', 1);
 insert into @result (grupa, kod, nazwa, kolumna, konfiguracja, aktywny) values(1,306,'Wydanie zewnętrzne',           'D015', 'Handel', 1);
  insert into @result (grupa, kod, nazwa, kolumna, konfiguracja, aktywny) values(12,101,'Ewidencja przychodów',      'D016', 'Księga Handlowa', 1);
 insert into @result (grupa, kod, nazwa, kolumna, konfiguracja, aktywny) values(12,102,'Ewidencja kosztów',         'D017', 'Księga Handlowa', 1);
 insert into @result (grupa, kod, nazwa, kolumna, konfiguracja) values(50,1, 'Bilans otwarcia',            'D018', 'Księga Handlowa');
 insert into @result (grupa, kod, nazwa, kolumna, konfiguracja, aktywny) values(49,1, 'Polecenie księgowania',     'D019', 'Księga Handlowa', 1);
 insert into @result (grupa, kod, nazwa, kolumna, konfiguracja, aktywny) values(2,1,  'Rejestr zakupu',              'D020', 'Księga Handlowa', 1);
 insert into @result (grupa, kod, nazwa, kolumna, konfiguracja, aktywny) values(2,2,  'Rejestr sprzedaży',          'D021', 'Księga Handlowa', 1);
 insert into @result (grupa, kod, nazwa, kolumna, konfiguracja) values(9,1,'Wpłata',                    'D022', 'Kasa/Bank');
 insert into @result (grupa, kod, nazwa, kolumna, konfiguracja) values(9,2,'Wypłata',                  'D023', 'Kasa/Bank');
 insert into @result (grupa, kod, nazwa, kolumna, konfiguracja) values(13,1,'Różnice kursowe',             'D024', 'Kasa/Bank');
 insert into @result (grupa, kod, nazwa, kolumna, konfiguracja) values(43,1,'Różnice kursowe magazynu walut', 'D025', 'Kasa/Bank');
  insert into @result (grupa, kod, nazwa, kolumna, konfiguracja) values(7,3,'Amortyzacja',                'D026', 'Środki trwałe');
  insert into @result (grupa, kod, nazwa, kolumna, konfiguracja) values(7,5,'Likwidacja',                  'D027', 'Środki trwałe');
  insert into @result (grupa, kod, nazwa, kolumna, konfiguracja) values(7,4,'Otrzymanie',                  'D028', 'Środki trwałe');
 insert into @result (grupa, kod, nazwa, kolumna, konfiguracja) values(7,1,'Ulepszenie',                  'D029', 'Środki trwałe');
 insert into @result (grupa, kod, nazwa, kolumna, konfiguracja) values(7,2,'Przeszacowanie',               'D030', 'Środki trwałe');
 insert into @result (grupa, kod, nazwa, kolumna, konfiguracja) values(10,1,'Lista płac',               'D031', 'Płace i Kadry');
  insert into @result (grupa, kod, nazwa, kolumna, konfiguracja, aktywny) values(300,1,'Grupy towarowe',           'D032', 'Słowniki', 1);
 insert into @result (grupa, kod, nazwa, kolumna, konfiguracja, aktywny) values(300,2,'Towary',                   'D033', 'Słowniki', 1);
 insert into @result (grupa, kod, nazwa, kolumna, konfiguracja) values(300,3,'Środki trwałe',            'D034', 'Słowniki');
  insert into @result (grupa, kod, nazwa, kolumna, konfiguracja) values(300,4,'Pracownicy',                 'D035', 'Słowniki');
  insert into @result (grupa, kod, nazwa, kolumna, konfiguracja) values(300,5,'Wspólnicy',                 'D036', 'Słowniki');
  insert into @result (grupa, kod, nazwa, kolumna, konfiguracja, aktywny) values(300,6,'Konto księgowe',             'D037', 'Słowniki', 1);
 delete from @result where aktywny <> 1;
 return
END
