CREATE VIEW CDN.TwrGrupyView (TwGId, Sciezka, Kod, Nazwa,Poziom, GIDNumer, GrONumer)
AS
SELECT TwGId, Sciezka, Kod, Nazwa,Poziom, GIDNumer, GrONumer FROM CDN.fnTwrGrupy ()
