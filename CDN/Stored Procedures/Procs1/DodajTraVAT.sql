-- uzupełnianie tabelki VAT dla dokumentów magazynowych WZ/PZ i WKA/PKA
CREATE PROCEDURE CDN.DodajTraVAT
  @TrN_TrNId_Zrd_List TEXT,         -- TrN_TrNId nagłówka do dodania lub do skopiowania
  @TrN_TrNId_Doc      INT           -- TrN_TrNId nagłówka do dodania lub do skopiowania
AS
SET NOCOUNT ON
  DECLARE
    @TrN_TrNId_Zrd INT
  -- wyliczenie nowej tabelki VAT jeśli jest więcej agregowanych dokumentów
  IF ( SELECT COUNT(NextIdINT) FROM CDN.Text2TableINT ( @TrN_TrNId_Zrd_List ) ) > 1
    BEGIN
      EXEC CDN.AktualizujTraVATTraNag @TrN_TrNId_Doc
      RETURN
    END
  ELSE
    SELECT TOP 1 @TrN_TrNId_Zrd = NextIdINT FROM CDN.Text2TableINT ( @TrN_TrNId_Zrd_List )
  -- tabelkę VAT przepisujemy 1:1,  jeśli źródłowy dokument handlowy jest taki sam jak docelowy   dokument  magazynowy
  -- Taabelkę VAT budujemy na nowo, jeśli źródłowy dokument handlowy jest     różny od docelowego dokumentu magazynowgo
  IF NOT EXISTS ( SELECT COUNT(TrE_Lp)
                    FROM
                     ( SELECT * FROM cdn.TraElem a WHERE TRE_TRNID = @TrN_TrNId_Zrd
                       UNION ALL
                       SELECT * FROM cdn.TraElem b WHERE TRE_TRNID = @TrN_TrNId_Doc
                     ) AS E
                     GROUP BY TrE_Lp,
                              TrE_TwrId,
                              TrE_Ilosc,
                              TrE_IloscJM,
                              TrE_JM, TrE_JMZ,
                              TrE_JMPrzelicznikL,
                              TrE_JMPrzelicznikM,
                              TrE_Waluta,
                              TrE_KursNumer,
                              TrE_KursL,
                              TrE_KursM,
                              TrE_Cena0,
                              TrE_CenaW,
                              TrE_CenaT,
                              TrE_Cena0WD,
                              TrE_CenaWWD,
                              TrE_WartoscNetto,
                              TrE_WartoscBrutto,
                              TrE_WartoscNettoWal,
                              TrE_WartoscBruttoWal,
                              TrE_Stawka,
                              TrE_Flaga,
                              TrE_Zrodlowa
                     HAVING COUNT(TrE_Lp) <> 2
                  ) AND  NOT EXISTS (SELECT * FROM cdn.TraVAT WHERE TrV_TrNId = @TrN_TrNId_Zrd AND TrV_Typ = 1 )
    INSERT INTO cdn.TraVAT
      (
  --       TrV_TrVID,
         TrV_TrNID,
  --       TrV_TrNidFinalna,
         TrV_Stawka,
         TrV_Flaga,
         TrV_Zrodlowa,
         TrV_Netto,
         TrV_VAT,
         TrV_NettoWal,
         TrV_VATWal,
         TrV_Typ
      )
    SELECT
  --       TrV_TrVID,
         @TrN_TrNID_Doc,
  --       TrV_TrNidFinalna,
         TrV_Stawka,
         TrV_Flaga,
         TrV_Zrodlowa,
         TrV_Netto,
         TrV_VAT,
         TrV_NettoWal,
         TrV_VATWal,
         TrV_Typ
     FROM cdn.TraVAT WHERE TrV_TrNID = @TrN_TrNId_Zrd AND TrV_TYP = 0
   -- dokumenty źródłowy i docelowy nie są jednakowe - liczymy tabelkę od nowa
   ELSE
     EXEC CDN.AktualizujTraVATTraNag @TrN_TrNId_Doc
