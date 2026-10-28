CREATE PROCEDURE [CDN].[PobierzDostepneDostawy] @TwrId INT, @MagId INT, @Korekta INT, @CzyBuforBezDostaw INT, @KorektaPRodElem INT = 0, @KorektaTrNID INT = 0,  @RwsTrEId  TEXT = ''
AS
 SET NOCOUNT ON
declare
@TrS_Metoda int
 SELECT TOP 1 @TrS_Metoda = ISNULL( Fir_Wartosc,1 ) FROM cdn.Firma WHERE Fir_Numer = 1352
 DECLARE @RWS  TABLE (      TrEId INT)
  INSERT INTO @RWS    (       TrEId)
  SELECT NextIdInt
  FROM CDN.Text2TableInt ( @RwsTrEId )
if @TrS_Metoda = 2
begin
IF @Korekta = 0
   --poziom zeby bylo odpowienio posortowane
  select max(z.Tsd_TrsIdDost) as Tsd_TrsIdDost,
         max(z.Tsd_NumerPelny) as Tsd_NumerPelny,
         max(z.Tsd_NumerObcy) as Tsd_NumerObcy,
         max(z.Tsd_DataOpe) as Tsd_DataOpe,
         max(z.Tsd_Dostawca) as Tsd_Dostawca,
         sum(z.Tsd_IloscDostepna) as Tsd_IloscDostepna,
         ROUND(sum(z.Tsd_Wartosc)/sum(z.Tsd_IloscDostepna),4) as Tsd_Wartosc,
         max(z.Tsd_Cecha1_DeAId ) as Tsd_Cecha1_DeAId ,
         max(z.Tsd_Cecha1_Format) as Tsd_Cecha1_Format,
         max(z.Tsd_Cecha1_Kod) as Tsd_Cecha1_Kod,
         max(z.Tsd_Cecha1_Wartosc) as Tsd_Cecha1_Wartosc,
         max(z.Tsd_Cecha2_DeAId) as Tsd_Cecha2_DeAId,
         max(z.Tsd_Cecha2_Format) as Tsd_Cecha2_Format,
         max(z.Tsd_Cecha2_Kod) as Tsd_Cecha2_Kod,
         max(z.Tsd_Cecha2_Wartosc) as Tsd_Cecha2_Wartosc,
         max(z.Tsd_Cecha3_DeAId) as Tsd_Cecha3_DeAId,
         max(z.Tsd_Cecha3_Format) as Tsd_Cecha3_Format,
         max(z.Tsd_Cecha3_Kod) as Tsd_Cecha3_Kod,
         max(z.Tsd_Cecha3_Wartosc) as Tsd_Cecha3_Wartosc,
         max(z.Tsd_Cecha4_DeAId) as Tsd_Cecha4_DeAId,
         max(z.Tsd_Cecha4_Format) as Tsd_Cecha4_Format,
         max(z.Tsd_Cecha4_Kod) as Tsd_Cecha4_Kod,
         max(z.Tsd_Cecha4_Wartosc) as Tsd_Cecha4_Wartosc,
         max(z.Tsd_Cecha5_DeAId) as Tsd_Cecha5_DeAId,
         max(z.Tsd_Cecha5_Format) as Tsd_Cecha5_Format,
         max(z.Tsd_Cecha5_Kod) as Tsd_Cecha5_Kod,
         max(z.Tsd_Cecha5_Wartosc) as Tsd_Cecha5_Wartosc,
         max(z.Tsd_Cecha6_DeAId) as Tsd_Cecha6_DeAId,
         max(z.Tsd_Cecha6_Format) as Tsd_Cecha6_Format,
         max(z.Tsd_Cecha6_Kod) as Tsd_Cecha6_Kod,
         max(z.Tsd_Cecha6_Wartosc) as Tsd_Cecha6_Wartosc,
         max(z.Tsd_Cecha7_DeAId) as Tsd_Cecha7_DeAId,
         max(z.Tsd_Cecha7_Format) as Tsd_Cecha7_Format,
         max(z.Tsd_Cecha7_Kod) as Tsd_Cecha7_Kod,
         max(z.Tsd_Cecha7_Wartosc) as Tsd_Cecha7_Wartosc,
         max(z.Tsd_Cecha8_DeAId) as Tsd_Cecha8_DeAId,
         max(z.Tsd_Cecha8_Format) as Tsd_Cecha8_Format,
         max(z.Tsd_Cecha8_Kod) as Tsd_Cecha8_Kod,
         max(z.Tsd_Cecha8_Wartosc) as Tsd_Cecha8_Wartosc,
         max(z.Tsd_Cecha9_DeAId) as Tsd_Cecha9_DeAId,
         max(z.Tsd_Cecha9_Format) as Tsd_Cecha9_Format,
         max(z.Tsd_Cecha9_Kod) as Tsd_Cecha9_Kod,
         max(z.Tsd_Cecha9_Wartosc) as Tsd_Cecha9_Wartosc,
         max(z.Tsd_Cecha10_DeAId) as Tsd_Cecha10_DeAId,
         max(z.Tsd_Cecha10_Format) as Tsd_Cecha10_Format,
         max(z.Tsd_Cecha10_Kod) as Tsd_Cecha10_Kod,
         max(z.Tsd_Cecha10_Wartosc) as  Tsd_Cecha10_Wartosc
   from (SELECT  Twz_TrSIdDost AS Tsd_TrsIdDost,
          ISNULL(TrN_NumerPelny,'Dokument usunięty') AS Tsd_NumerPelny,
         ISNULL(TrN_NumerObcy,'') AS Tsd_NumerObcy,
         ISNULL(TrN_DataOpe,TwZ_Data) AS Tsd_DataOpe,
         ISNULL(TrN_PodNazwa1,'') AS Tsd_Dostawca,
         Twz_Ilosc AS  Tsd_IloscDostepna,
         Twz_Wartosc AS  Tsd_Wartosc,
         TsC_Cecha1_DeAId AS Tsd_Cecha1_DeAId ,
         TsC_Cecha1_Format AS Tsd_Cecha1_Format,
         TsC_Cecha1_Kod AS Tsd_Cecha1_Kod,
         TsC_Cecha1_Wartosc AS Tsd_Cecha1_Wartosc,
         TsC_Cecha2_DeAId AS Tsd_Cecha2_DeAId,
         TsC_Cecha2_Format AS Tsd_Cecha2_Format,
         TsC_Cecha2_Kod AS Tsd_Cecha2_Kod,
         TsC_Cecha2_Wartosc AS Tsd_Cecha2_Wartosc,
         TsC_Cecha3_DeAId AS Tsd_Cecha3_DeAId,
         TsC_Cecha3_Format AS Tsd_Cecha3_Format,
         TsC_Cecha3_Kod AS Tsd_Cecha3_Kod,
         TsC_Cecha3_Wartosc AS Tsd_Cecha3_Wartosc,
         TsC_Cecha4_DeAId AS Tsd_Cecha4_DeAId,
         TsC_Cecha4_Format AS Tsd_Cecha4_Format,
         TsC_Cecha4_Kod AS Tsd_Cecha4_Kod,
         TsC_Cecha4_Wartosc AS Tsd_Cecha4_Wartosc,
         TsC_Cecha5_DeAId AS Tsd_Cecha5_DeAId,
         TsC_Cecha5_Format AS Tsd_Cecha5_Format,
         TsC_Cecha5_Kod AS Tsd_Cecha5_Kod,
         TsC_Cecha5_Wartosc AS Tsd_Cecha5_Wartosc,
         TsC_Cecha6_DeAId AS Tsd_Cecha6_DeAId,
         TsC_Cecha6_Format AS Tsd_Cecha6_Format,
         TsC_Cecha6_Kod AS Tsd_Cecha6_Kod,
         TsC_Cecha6_Wartosc AS Tsd_Cecha6_Wartosc,
         TsC_Cecha7_DeAId AS Tsd_Cecha7_DeAId,
         TsC_Cecha7_Format AS Tsd_Cecha7_Format,
         TsC_Cecha7_Kod AS Tsd_Cecha7_Kod,
         TsC_Cecha7_Wartosc AS Tsd_Cecha7_Wartosc,
         TsC_Cecha8_DeAId AS Tsd_Cecha8_DeAId,
         TsC_Cecha8_Format AS Tsd_Cecha8_Format,
         TsC_Cecha8_Kod AS Tsd_Cecha8_Kod,
         TsC_Cecha8_Wartosc AS Tsd_Cecha8_Wartosc,
         TsC_Cecha9_DeAId AS Tsd_Cecha9_DeAId,
         TsC_Cecha9_Format AS Tsd_Cecha9_Format,
         TsC_Cecha9_Kod AS Tsd_Cecha9_Kod,
         TsC_Cecha9_Wartosc AS Tsd_Cecha9_Wartosc,
         TsC_Cecha10_DeAId AS Tsd_Cecha10_DeAId,
         TsC_Cecha10_Format AS Tsd_Cecha10_Format,
         TsC_Cecha10_Kod AS Tsd_Cecha10_Kod,
         TsC_Cecha10_Wartosc AS Tsd_Cecha10_Wartosc
 FROM CDN.TwrZasoby
 LEFT JOIN CDN.TraSElem TraSElem ON Twz_TrSIdDost = TrS_TrSId
 LEFT JOIN CDN.TraSElemCechy TraSElemCechy ON TrS_TrSId = TsC_TrSId
 LEFT JOIN CDN.TraElem TraElemDos ON TrS_TrEId = TraElemDos.TrE_TrEId
 LEFT JOIN CDN.TraNag  ON TrN_TrNId = TraElemDos.TrE_TrNId
 WHERE Twz_TwrId = @TwrId and Twz_MagId = @MagId
UNION ALL
   SELECT A.TrS_TrSIdDost AS Tsd_TrsIdDost,
         ISNULL(TrN_NumerPelny,'Dokument usunięty') AS Tsd_NumerPelny,
         ISNULL(TrN_NumerObcy,'') AS Tsd_NumerObcy,
         ISNULL(TrN_DataOpe,A.TrS_DataOpe) AS Tsd_DataOpe,
         ISNULL(TrN_PodNazwa1,'') AS Tsd_Dostawca,
         A.TrS_Ilosc AS Tsd_IloscDostepna,
         A.TrS_Wartosc AS  Tsd_Wartosc,
         TsC_Cecha1_DeAId AS Tsd_Cecha1_DeAId ,
         TsC_Cecha1_Format AS Tsd_Cecha1_Format,
         TsC_Cecha1_Kod AS Tsd_Cecha1_Kod,
         TsC_Cecha1_Wartosc AS Tsd_Cecha1_Wartosc,
         TsC_Cecha2_DeAId AS Tsd_Cecha2_DeAId,
         TsC_Cecha2_Format AS Tsd_Cecha2_Format,
         TsC_Cecha2_Kod AS Tsd_Cecha2_Kod,
         TsC_Cecha2_Wartosc AS Tsd_Cecha2_Wartosc,
         TsC_Cecha3_DeAId AS Tsd_Cecha3_DeAId,
         TsC_Cecha3_Format AS Tsd_Cecha3_Format,
         TsC_Cecha3_Kod AS Tsd_Cecha3_Kod,
         TsC_Cecha3_Wartosc AS Tsd_Cecha3_Wartosc,
         TsC_Cecha4_DeAId AS Tsd_Cecha4_DeAId,
         TsC_Cecha4_Format AS Tsd_Cecha4_Format,
         TsC_Cecha4_Kod AS Tsd_Cecha4_Kod,
         TsC_Cecha4_Wartosc AS Tsd_Cecha4_Wartosc,
         TsC_Cecha5_DeAId AS Tsd_Cecha5_DeAId,
         TsC_Cecha5_Format AS Tsd_Cecha5_Format,
         TsC_Cecha5_Kod AS Tsd_Cecha5_Kod,
         TsC_Cecha5_Wartosc AS Tsd_Cecha5_Wartosc,
         TsC_Cecha6_DeAId AS Tsd_Cecha6_DeAId,
         TsC_Cecha6_Format AS Tsd_Cecha6_Format,
         TsC_Cecha6_Kod AS Tsd_Cecha6_Kod,
         TsC_Cecha6_Wartosc AS Tsd_Cecha6_Wartosc,
         TsC_Cecha7_DeAId AS Tsd_Cecha7_DeAId,
         TsC_Cecha7_Format AS Tsd_Cecha7_Format,
         TsC_Cecha7_Kod AS Tsd_Cecha7_Kod,
         TsC_Cecha7_Wartosc AS Tsd_Cecha7_Wartosc,
         TsC_Cecha8_DeAId AS Tsd_Cecha8_DeAId,
         TsC_Cecha8_Format AS Tsd_Cecha8_Format,
         TsC_Cecha8_Kod AS Tsd_Cecha8_Kod,
         TsC_Cecha8_Wartosc AS Tsd_Cecha8_Wartosc,
         TsC_Cecha9_DeAId AS Tsd_Cecha9_DeAId,
         TsC_Cecha9_Format AS Tsd_Cecha9_Format,
         TsC_Cecha9_Kod AS Tsd_Cecha9_Kod,
         TsC_Cecha9_Wartosc AS Tsd_Cecha9_Wartosc,
         TsC_Cecha10_DeAId AS Tsd_Cecha10_DeAId,
         TsC_Cecha10_Format AS Tsd_Cecha10_Format,
         TsC_Cecha10_Kod AS Tsd_Cecha10_Kod,
         TsC_Cecha10_Wartosc AS Tsd_Cecha10_Wartosc
  FROM CDN.TraSElem A
  LEFT JOIN CDN.TraSElemCechy TraSElemCechy ON A.TrS_TrSIdDost = TsC_TrSId
  LEFT JOIN CDN.TraSElem B ON A.TrS_TrSIdDost = B.TrS_TrSId
  LEFT JOIN CDN.TraElem  ON B.TrS_TrEId = TrE_TrEId
  LEFT JOIN CDN.TraNag  ON TrN_TrNId = TrE_TrNId
  LEFT JOIN CDN.TrasElemDost ON A.TrS_TrSId = case  when A.TrS_Rodzaj in (312000,312008) then (TsD_TrSId-1) else TsD_TrSId end
  WHERE A.TrS_TrEId = @CzyBuforBezDostaw AND TsD_TsDId IS NULL AND A.TrS_TrSIdDost IS NOT NULL AND A.Trs_MagId = @MagId AND A.TrS_TwrId = @TwrId
  union all
   SELECT A.TrS_TrSIdDost AS Tsd_TrsIdDost,
         ISNULL(TrN_NumerPelny,'Dokument usunięty') AS Tsd_NumerPelny,
         ISNULL(TrN_NumerObcy,'') AS Tsd_NumerObcy,
         ISNULL(TrN_DataOpe,A.TrS_DataOpe) AS Tsd_DataOpe,
         ISNULL(TrN_PodNazwa1,'') AS Tsd_Dostawca,
         A.TrS_Ilosc AS Tsd_IloscDostepna,
         A.TrS_Wartosc AS  Tsd_Wartosc,
         TsC_Cecha1_DeAId AS Tsd_Cecha1_DeAId ,
         TsC_Cecha1_Format AS Tsd_Cecha1_Format,
         TsC_Cecha1_Kod AS Tsd_Cecha1_Kod,
         TsC_Cecha1_Wartosc AS Tsd_Cecha1_Wartosc,
         TsC_Cecha2_DeAId AS Tsd_Cecha2_DeAId,
         TsC_Cecha2_Format AS Tsd_Cecha2_Format,
         TsC_Cecha2_Kod AS Tsd_Cecha2_Kod,
         TsC_Cecha2_Wartosc AS Tsd_Cecha2_Wartosc,
         TsC_Cecha3_DeAId AS Tsd_Cecha3_DeAId,
         TsC_Cecha3_Format AS Tsd_Cecha3_Format,
         TsC_Cecha3_Kod AS Tsd_Cecha3_Kod,
         TsC_Cecha3_Wartosc AS Tsd_Cecha3_Wartosc,
         TsC_Cecha4_DeAId AS Tsd_Cecha4_DeAId,
         TsC_Cecha4_Format AS Tsd_Cecha4_Format,
         TsC_Cecha4_Kod AS Tsd_Cecha4_Kod,
         TsC_Cecha4_Wartosc AS Tsd_Cecha4_Wartosc,
         TsC_Cecha5_DeAId AS Tsd_Cecha5_DeAId,
         TsC_Cecha5_Format AS Tsd_Cecha5_Format,
         TsC_Cecha5_Kod AS Tsd_Cecha5_Kod,
         TsC_Cecha5_Wartosc AS Tsd_Cecha5_Wartosc,
         TsC_Cecha6_DeAId AS Tsd_Cecha6_DeAId,
         TsC_Cecha6_Format AS Tsd_Cecha6_Format,
         TsC_Cecha6_Kod AS Tsd_Cecha6_Kod,
         TsC_Cecha6_Wartosc AS Tsd_Cecha6_Wartosc,
         TsC_Cecha7_DeAId AS Tsd_Cecha7_DeAId,
         TsC_Cecha7_Format AS Tsd_Cecha7_Format,
         TsC_Cecha7_Kod AS Tsd_Cecha7_Kod,
         TsC_Cecha7_Wartosc AS Tsd_Cecha7_Wartosc,
         TsC_Cecha8_DeAId AS Tsd_Cecha8_DeAId,
         TsC_Cecha8_Format AS Tsd_Cecha8_Format,
         TsC_Cecha8_Kod AS Tsd_Cecha8_Kod,
         TsC_Cecha8_Wartosc AS Tsd_Cecha8_Wartosc,
         TsC_Cecha9_DeAId AS Tsd_Cecha9_DeAId,
         TsC_Cecha9_Format AS Tsd_Cecha9_Format,
         TsC_Cecha9_Kod AS Tsd_Cecha9_Kod,
         TsC_Cecha9_Wartosc AS Tsd_Cecha9_Wartosc,
         TsC_Cecha10_DeAId AS Tsd_Cecha10_DeAId,
         TsC_Cecha10_Format AS Tsd_Cecha10_Format,
         TsC_Cecha10_Kod AS Tsd_Cecha10_Kod,
         TsC_Cecha10_Wartosc AS Tsd_Cecha10_Wartosc
  FROM CDN.TraSElem A
  LEFT JOIN CDN.TraSElemCechy TraSElemCechy ON A.TrS_TrSIdDost = TsC_TrSId
  LEFT JOIN CDN.TraSElem B ON A.TrS_TrSIdDost = B.TrS_TrSId
  LEFT JOIN CDN.TraElem  ON B.TrS_TrEId = TrE_TrEId
  LEFT JOIN CDN.TraNag  ON TrN_TrNId = TrE_TrNId
  LEFT JOIN CDN.TrasElemDost ON A.TrS_TrSId = case  when A.TrS_Rodzaj in (312000,312008) then (TsD_TrSId-1) else TsD_TrSId end
  WHERE A.TrS_TrEId = @CzyBuforBezDostaw AND TsD_TsDId IS NOT NULL AND A.TrS_TrSIdDost IS NOT NULL AND A.Trs_MagId = @MagId AND A.TrS_TwrId = @TwrId
   UNION ALL
   SELECT A.TrS_TrSIdDost AS Tsd_TrsIdDost,
         ISNULL(TrN_NumerPelny,'Dokument usunięty') AS Tsd_NumerPelny,
         ISNULL(TrN_NumerObcy,'') AS Tsd_NumerObcy,
         ISNULL(TrN_DataOpe,A.TrS_DataOpe) AS Tsd_DataOpe,
         ISNULL(TrN_PodNazwa1,'') AS Tsd_Dostawca,
         A.TrS_Ilosc AS Tsd_IloscDostepna,
         A.TrS_Wartosc AS  Tsd_Wartosc,
         TsC_Cecha1_DeAId AS Tsd_Cecha1_DeAId ,
         TsC_Cecha1_Format AS Tsd_Cecha1_Format,
         TsC_Cecha1_Kod AS Tsd_Cecha1_Kod,
         TsC_Cecha1_Wartosc AS Tsd_Cecha1_Wartosc,
         TsC_Cecha2_DeAId AS Tsd_Cecha2_DeAId,
         TsC_Cecha2_Format AS Tsd_Cecha2_Format,
         TsC_Cecha2_Kod AS Tsd_Cecha2_Kod,
         TsC_Cecha2_Wartosc AS Tsd_Cecha2_Wartosc,
         TsC_Cecha3_DeAId AS Tsd_Cecha3_DeAId,
         TsC_Cecha3_Format AS Tsd_Cecha3_Format,
         TsC_Cecha3_Kod AS Tsd_Cecha3_Kod,
         TsC_Cecha3_Wartosc AS Tsd_Cecha3_Wartosc,
         TsC_Cecha4_DeAId AS Tsd_Cecha4_DeAId,
         TsC_Cecha4_Format AS Tsd_Cecha4_Format,
         TsC_Cecha4_Kod AS Tsd_Cecha4_Kod,
         TsC_Cecha4_Wartosc AS Tsd_Cecha4_Wartosc,
         TsC_Cecha5_DeAId AS Tsd_Cecha5_DeAId,
         TsC_Cecha5_Format AS Tsd_Cecha5_Format,
         TsC_Cecha5_Kod AS Tsd_Cecha5_Kod,
         TsC_Cecha5_Wartosc AS Tsd_Cecha5_Wartosc,
         TsC_Cecha6_DeAId AS Tsd_Cecha6_DeAId,
         TsC_Cecha6_Format AS Tsd_Cecha6_Format,
         TsC_Cecha6_Kod AS Tsd_Cecha6_Kod,
         TsC_Cecha6_Wartosc AS Tsd_Cecha6_Wartosc,
         TsC_Cecha7_DeAId AS Tsd_Cecha7_DeAId,
         TsC_Cecha7_Format AS Tsd_Cecha7_Format,
         TsC_Cecha7_Kod AS Tsd_Cecha7_Kod,
         TsC_Cecha7_Wartosc AS Tsd_Cecha7_Wartosc,
         TsC_Cecha8_DeAId AS Tsd_Cecha8_DeAId,
         TsC_Cecha8_Format AS Tsd_Cecha8_Format,
         TsC_Cecha8_Kod AS Tsd_Cecha8_Kod,
         TsC_Cecha8_Wartosc AS Tsd_Cecha8_Wartosc,
         TsC_Cecha9_DeAId AS Tsd_Cecha9_DeAId,
         TsC_Cecha9_Format AS Tsd_Cecha9_Format,
         TsC_Cecha9_Kod AS Tsd_Cecha9_Kod,
         TsC_Cecha9_Wartosc AS Tsd_Cecha9_Wartosc,
         TsC_Cecha10_DeAId AS Tsd_Cecha10_DeAId,
         TsC_Cecha10_Format AS Tsd_Cecha10_Format,
         TsC_Cecha10_Kod AS Tsd_Cecha10_Kod,
         TsC_Cecha10_Wartosc AS Tsd_Cecha10_Wartosc
  FROM CDN.TraSElem A
  LEFT JOIN CDN.TraSElemCechy TraSElemCechy ON A.TrS_TrSIdDost = TsC_TrSId
  LEFT JOIN CDN.TraSElem B ON A.TrS_TrSIdDost = B.TrS_TrSId
  LEFT JOIN CDN.TraElem  ON B.TrS_TrEId = TrE_TrEId
  LEFT JOIN CDN.TraNag  ON TrN_TrNId = TrE_TrNId
  LEFT JOIN CDN.TrasElemDost ON A.TrS_TrSId = case  when A.TrS_Rodzaj in (312000,312008) then (TsD_TrSId-1) else TsD_TrSId end
  WHERE A.TrS_TrEId in (select TrEId from @RWS) AND TsD_TsDId IS NULL AND A.TrS_TrSIdDost IS NOT NULL AND A.Trs_MagId = @MagId AND A.TrS_TwrId = @TwrId
  union all
   SELECT A.TrS_TrSIdDost AS Tsd_TrsIdDost,
         ISNULL(TrN_NumerPelny,'Dokument usunięty') AS Tsd_NumerPelny,
         ISNULL(TrN_NumerObcy,'') AS Tsd_NumerObcy,
         ISNULL(TrN_DataOpe,A.TrS_DataOpe) AS Tsd_DataOpe,
         ISNULL(TrN_PodNazwa1,'') AS Tsd_Dostawca,
         A.TrS_Ilosc AS Tsd_IloscDostepna,
         A.TrS_Wartosc AS  Tsd_Wartosc,
         TsC_Cecha1_DeAId AS Tsd_Cecha1_DeAId ,
         TsC_Cecha1_Format AS Tsd_Cecha1_Format,
         TsC_Cecha1_Kod AS Tsd_Cecha1_Kod,
         TsC_Cecha1_Wartosc AS Tsd_Cecha1_Wartosc,
         TsC_Cecha2_DeAId AS Tsd_Cecha2_DeAId,
         TsC_Cecha2_Format AS Tsd_Cecha2_Format,
         TsC_Cecha2_Kod AS Tsd_Cecha2_Kod,
         TsC_Cecha2_Wartosc AS Tsd_Cecha2_Wartosc,
         TsC_Cecha3_DeAId AS Tsd_Cecha3_DeAId,
         TsC_Cecha3_Format AS Tsd_Cecha3_Format,
         TsC_Cecha3_Kod AS Tsd_Cecha3_Kod,
         TsC_Cecha3_Wartosc AS Tsd_Cecha3_Wartosc,
         TsC_Cecha4_DeAId AS Tsd_Cecha4_DeAId,
         TsC_Cecha4_Format AS Tsd_Cecha4_Format,
         TsC_Cecha4_Kod AS Tsd_Cecha4_Kod,
         TsC_Cecha4_Wartosc AS Tsd_Cecha4_Wartosc,
         TsC_Cecha5_DeAId AS Tsd_Cecha5_DeAId,
         TsC_Cecha5_Format AS Tsd_Cecha5_Format,
         TsC_Cecha5_Kod AS Tsd_Cecha5_Kod,
         TsC_Cecha5_Wartosc AS Tsd_Cecha5_Wartosc,
         TsC_Cecha6_DeAId AS Tsd_Cecha6_DeAId,
         TsC_Cecha6_Format AS Tsd_Cecha6_Format,
         TsC_Cecha6_Kod AS Tsd_Cecha6_Kod,
         TsC_Cecha6_Wartosc AS Tsd_Cecha6_Wartosc,
         TsC_Cecha7_DeAId AS Tsd_Cecha7_DeAId,
         TsC_Cecha7_Format AS Tsd_Cecha7_Format,
         TsC_Cecha7_Kod AS Tsd_Cecha7_Kod,
         TsC_Cecha7_Wartosc AS Tsd_Cecha7_Wartosc,
         TsC_Cecha8_DeAId AS Tsd_Cecha8_DeAId,
         TsC_Cecha8_Format AS Tsd_Cecha8_Format,
         TsC_Cecha8_Kod AS Tsd_Cecha8_Kod,
         TsC_Cecha8_Wartosc AS Tsd_Cecha8_Wartosc,
         TsC_Cecha9_DeAId AS Tsd_Cecha9_DeAId,
         TsC_Cecha9_Format AS Tsd_Cecha9_Format,
         TsC_Cecha9_Kod AS Tsd_Cecha9_Kod,
         TsC_Cecha9_Wartosc AS Tsd_Cecha9_Wartosc,
         TsC_Cecha10_DeAId AS Tsd_Cecha10_DeAId,
         TsC_Cecha10_Format AS Tsd_Cecha10_Format,
         TsC_Cecha10_Kod AS Tsd_Cecha10_Kod,
         TsC_Cecha10_Wartosc AS Tsd_Cecha10_Wartosc
  FROM CDN.TraSElem A
  LEFT JOIN CDN.TraSElemCechy TraSElemCechy ON A.TrS_TrSIdDost = TsC_TrSId
  LEFT JOIN CDN.TraSElem B ON A.TrS_TrSIdDost = B.TrS_TrSId
  LEFT JOIN CDN.TraElem  ON B.TrS_TrEId = TrE_TrEId
  LEFT JOIN CDN.TraNag  ON TrN_TrNId = TrE_TrNId
  LEFT JOIN CDN.TrasElemDost ON A.TrS_TrSId = case  when A.TrS_Rodzaj in (312000,312008) then (TsD_TrSId-1) else TsD_TrSId end
  WHERE A.TrS_TrEId in (select TrEId from @RWS) AND TsD_TsDId IS NOT NULL AND A.TrS_TrSIdDost IS NOT NULL AND A.Trs_MagId = @MagId AND A.TrS_TwrId = @TwrId
) as z group by Tsd_TrsIdDost order by  TsD_DataOpe desc,Tsd_TrsIdDost desc
ELSE
IF @KorektaPRodElem != 0
 begin
 SELECT MAX(Tsd_TsDID) as Tsd_TsDID,
           MAX(Tsd_TrSID) as Tsd_TrSID,
           MAX(Tsd_TrEId) as Tsd_TrEId,
           MAX(Tsd_ZwrId) as Tsd_ZwrId,
           MAX(a.Tsd_TrsIdDost) as Tsd_TrsIdDost,
           MAX(Tsd_NumerPelny) as Tsd_NumerPelny,
           MAX(Tsd_NumerObcy) as Tsd_NumerObcy,
           MAX(Tsd_DataOpe) as Tsd_DataOpe,
           MAX(Tsd_Dostawca) as Tsd_Dostawca,
           MAX(z.ilosc) AS Tsd_Ilosc,
           MAX(Tsd_IloscDostepna) as Tsd_IloscDostepna,
           MAX(Tsd_Wartosc) as Tsd_Wartosc,
           MAX(Tsd_Cecha1_DeAId ) as Tsd_Cecha1_DeAId,MAX(Tsd_Cecha1_Format ) as Tsd_Cecha1_Format,MAX(Tsd_Cecha1_Kod ) as Tsd_Cecha1_Kod,MAX(Tsd_Cecha1_Wartosc) as Tsd_Cecha1_Wartosc,
           MAX(Tsd_Cecha2_DeAId ) as Tsd_Cecha2_DeAId,MAX(Tsd_Cecha2_Format ) as Tsd_Cecha2_Format,MAX(Tsd_Cecha2_Kod ) as Tsd_Cecha2_Kod,MAX(Tsd_Cecha2_Wartosc) as Tsd_Cecha2_Wartosc,
           MAX(Tsd_Cecha3_DeAId ) as Tsd_Cecha3_DeAId,MAX(Tsd_Cecha3_Format ) as Tsd_Cecha3_Format,MAX(Tsd_Cecha3_Kod ) as Tsd_Cecha3_Kod,MAX(Tsd_Cecha3_Wartosc) as Tsd_Cecha3_Wartosc,
           MAX(Tsd_Cecha4_DeAId ) as Tsd_Cecha4_DeAId,MAX(Tsd_Cecha4_Format ) as Tsd_Cecha4_Format,MAX(Tsd_Cecha4_Kod ) as Tsd_Cecha4_Kod,MAX(Tsd_Cecha4_Wartosc) as Tsd_Cecha4_Wartosc,
           MAX(Tsd_Cecha5_DeAId ) as Tsd_Cecha5_DeAId,MAX(Tsd_Cecha5_Format ) as Tsd_Cecha5_Format,MAX(Tsd_Cecha5_Kod ) as Tsd_Cecha5_Kod,MAX(Tsd_Cecha5_Wartosc) as Tsd_Cecha5_Wartosc,
           MAX(Tsd_Cecha6_DeAId ) as Tsd_Cecha6_DeAId,MAX(Tsd_Cecha6_Format ) as Tsd_Cecha6_Format,MAX(Tsd_Cecha6_Kod ) as Tsd_Cecha6_Kod,MAX(Tsd_Cecha6_Wartosc) as Tsd_Cecha6_Wartosc,
           MAX(Tsd_Cecha7_DeAId ) as Tsd_Cecha7_DeAId,MAX(Tsd_Cecha7_Format ) as Tsd_Cecha7_Format,MAX(Tsd_Cecha7_Kod ) as Tsd_Cecha7_Kod,MAX(Tsd_Cecha7_Wartosc) as Tsd_Cecha7_Wartosc,
           MAX(Tsd_Cecha8_DeAId ) as Tsd_Cecha8_DeAId,MAX(Tsd_Cecha8_Format ) as Tsd_Cecha8_Format,MAX(Tsd_Cecha8_Kod ) as Tsd_Cecha8_Kod,MAX(Tsd_Cecha8_Wartosc) as Tsd_Cecha8_Wartosc,
           MAX(Tsd_Cecha9_DeAId ) as Tsd_Cecha9_DeAId,MAX(Tsd_Cecha9_Format ) as Tsd_Cecha9_Format,MAX(Tsd_Cecha9_Kod ) as Tsd_Cecha9_Kod,MAX(Tsd_Cecha9_Wartosc) as Tsd_Cecha9_Wartosc,
           MAX(Tsd_Cecha10_DeAId ) as Tsd_Cecha10_DeAId,MAX(Tsd_Cecha10_Format ) as Tsd_Cecha10_Format,MAX(Tsd_Cecha10_Kod ) as Tsd_Cecha10_Kod,MAX(Tsd_Cecha10_Wartosc) as Tsd_Cecha10_Wartosc
    FROM CDN.TraSElemDost AS a
    JOIN (SELECT Tsd_TrsIdDost,SUM(Tsd_Ilosc) AS ilosc
            FROM CDN.TraSElemDost
           WHERE TsD_PdEId IN (SELECT PdE_PdEId FROM CDN.ProdElem join cdn.traelem on tre_treid = pde_treid WHERE (PdE_PdEId=@KorektaPRodElem OR PdE_ZwrID = @KorektaPRodElem) and tre_trnid != @KorektaTrNID)
           GROUP BY Tsd_TrsIdDost) AS z ON z.Tsd_TrsIdDost = a.Tsd_TrsIdDost
    WHERE TsD_PdEId = @KorektaPRodElem
    GROUP BY a.Tsd_TrsIdDost, TsD_DataOpe
    order by TsD_DataOpe ,a.Tsd_TrsIdDost
 end
 else
 IF EXISTS(SELECT * FROM CDN.TraSElemDost WHERE Tsd_TrEID=@Korekta  and TsD_PdEId = 0)
    SELECT MAX(Tsd_TsDID) as Tsd_TsDID,
           MAX(Tsd_TrSID) as Tsd_TrSID,
           MAX(Tsd_TrEId) as Tsd_TrEId,
           MAX(Tsd_ZwrId) as Tsd_ZwrId,
           MAX(a.Tsd_TrsIdDost) as Tsd_TrsIdDost,
           MAX(Tsd_NumerPelny) as Tsd_NumerPelny,
           MAX(Tsd_NumerObcy) as Tsd_NumerObcy,
           MAX(Tsd_DataOpe) as Tsd_DataOpe,
           MAX(Tsd_Dostawca) as Tsd_Dostawca,
           MAX(z.ilosc) AS Tsd_Ilosc,
           MAX(Tsd_IloscDostepna) as Tsd_IloscDostepna,
           MAX(Tsd_Wartosc) as Tsd_Wartosc,
           MAX(Tsd_Cecha1_DeAId ) as Tsd_Cecha1_DeAId,MAX(Tsd_Cecha1_Format ) as Tsd_Cecha1_Format,MAX(Tsd_Cecha1_Kod ) as Tsd_Cecha1_Kod,MAX(Tsd_Cecha1_Wartosc) as Tsd_Cecha1_Wartosc,
           MAX(Tsd_Cecha2_DeAId ) as Tsd_Cecha2_DeAId,MAX(Tsd_Cecha2_Format ) as Tsd_Cecha2_Format,MAX(Tsd_Cecha2_Kod ) as Tsd_Cecha2_Kod,MAX(Tsd_Cecha2_Wartosc) as Tsd_Cecha2_Wartosc,
           MAX(Tsd_Cecha3_DeAId ) as Tsd_Cecha3_DeAId,MAX(Tsd_Cecha3_Format ) as Tsd_Cecha3_Format,MAX(Tsd_Cecha3_Kod ) as Tsd_Cecha3_Kod,MAX(Tsd_Cecha3_Wartosc) as Tsd_Cecha3_Wartosc,
           MAX(Tsd_Cecha4_DeAId ) as Tsd_Cecha4_DeAId,MAX(Tsd_Cecha4_Format ) as Tsd_Cecha4_Format,MAX(Tsd_Cecha4_Kod ) as Tsd_Cecha4_Kod,MAX(Tsd_Cecha4_Wartosc) as Tsd_Cecha4_Wartosc,
           MAX(Tsd_Cecha5_DeAId ) as Tsd_Cecha5_DeAId,MAX(Tsd_Cecha5_Format ) as Tsd_Cecha5_Format,MAX(Tsd_Cecha5_Kod ) as Tsd_Cecha5_Kod,MAX(Tsd_Cecha5_Wartosc) as Tsd_Cecha5_Wartosc,
           MAX(Tsd_Cecha6_DeAId ) as Tsd_Cecha6_DeAId,MAX(Tsd_Cecha6_Format ) as Tsd_Cecha6_Format,MAX(Tsd_Cecha6_Kod ) as Tsd_Cecha6_Kod,MAX(Tsd_Cecha6_Wartosc) as Tsd_Cecha6_Wartosc,
           MAX(Tsd_Cecha7_DeAId ) as Tsd_Cecha7_DeAId,MAX(Tsd_Cecha7_Format ) as Tsd_Cecha7_Format,MAX(Tsd_Cecha7_Kod ) as Tsd_Cecha7_Kod,MAX(Tsd_Cecha7_Wartosc) as Tsd_Cecha7_Wartosc,
           MAX(Tsd_Cecha8_DeAId ) as Tsd_Cecha8_DeAId,MAX(Tsd_Cecha8_Format ) as Tsd_Cecha8_Format,MAX(Tsd_Cecha8_Kod ) as Tsd_Cecha8_Kod,MAX(Tsd_Cecha8_Wartosc) as Tsd_Cecha8_Wartosc,
           MAX(Tsd_Cecha9_DeAId ) as Tsd_Cecha9_DeAId,MAX(Tsd_Cecha9_Format ) as Tsd_Cecha9_Format,MAX(Tsd_Cecha9_Kod ) as Tsd_Cecha9_Kod,MAX(Tsd_Cecha9_Wartosc) as Tsd_Cecha9_Wartosc,
           MAX(Tsd_Cecha10_DeAId ) as Tsd_Cecha10_DeAId,MAX(Tsd_Cecha10_Format ) as Tsd_Cecha10_Format,MAX(Tsd_Cecha10_Kod ) as Tsd_Cecha10_Kod,MAX(Tsd_Cecha10_Wartosc) as Tsd_Cecha10_Wartosc
    FROM CDN.TraSElemDost AS a
    JOIN (SELECT Tsd_TrsIdDost,SUM(Tsd_Ilosc) AS ilosc
            FROM CDN.TraSElemDost
           WHERE Tsd_TrEID IN (SELECT TrE_TrEId FROM CDN.TraElem WHERE TrE_TrEId=@Korekta OR TrE_ZwrID = @Korekta)
           GROUP BY Tsd_TrsIdDost) AS z ON z.Tsd_TrsIdDost = a.Tsd_TrsIdDost
    WHERE Tsd_TrEID=@Korekta  and TsD_PdEId = 0
    GROUP BY a.Tsd_TrsIdDost, TsD_DataOpe
    order by TsD_DataOpe ,a.Tsd_TrsIdDost
 ELSE
    SELECT MAX(Tsd_TsDID) as Tsd_TsDID,
           MAX(Tsd_TrSID) as Tsd_TrSID,
           z.ID as Tsd_TrEId,
           MAX(Tsd_ZwrId) as Tsd_ZwrId,
           MAX(TraSElemDost.Tsd_TrsIdDost) as Tsd_TrsIdDost,
           MAX(Tsd_NumerPelny) as Tsd_NumerPelny,
           MAX(Tsd_NumerObcy) as Tsd_NumerObcy,
           MAX(Tsd_DataOpe) as Tsd_DataOpe,
           MAX(Tsd_Dostawca) as Tsd_Dostawca,
           MAX(z.ilosc) AS Tsd_Ilosc,
           MAX(Tsd_IloscDostepna) as Tsd_IloscDostepna,
           MAX(Tsd_Wartosc) as Tsd_Wartosc,
           MAX(Tsd_Cecha1_DeAId ) as Tsd_Cecha1_DeAId,MAX(Tsd_Cecha1_Format ) as Tsd_Cecha1_Format,MAX(Tsd_Cecha1_Kod ) as Tsd_Cecha1_Kod,MAX(Tsd_Cecha1_Wartosc) as Tsd_Cecha1_Wartosc,
           MAX(Tsd_Cecha2_DeAId ) as Tsd_Cecha2_DeAId,MAX(Tsd_Cecha2_Format ) as Tsd_Cecha2_Format,MAX(Tsd_Cecha2_Kod ) as Tsd_Cecha2_Kod,MAX(Tsd_Cecha2_Wartosc) as Tsd_Cecha2_Wartosc,
           MAX(Tsd_Cecha3_DeAId ) as Tsd_Cecha3_DeAId,MAX(Tsd_Cecha3_Format ) as Tsd_Cecha3_Format,MAX(Tsd_Cecha3_Kod ) as Tsd_Cecha3_Kod,MAX(Tsd_Cecha3_Wartosc) as Tsd_Cecha3_Wartosc,
           MAX(Tsd_Cecha4_DeAId ) as Tsd_Cecha4_DeAId,MAX(Tsd_Cecha4_Format ) as Tsd_Cecha4_Format,MAX(Tsd_Cecha4_Kod ) as Tsd_Cecha4_Kod,MAX(Tsd_Cecha4_Wartosc) as Tsd_Cecha4_Wartosc,
           MAX(Tsd_Cecha5_DeAId ) as Tsd_Cecha5_DeAId,MAX(Tsd_Cecha5_Format ) as Tsd_Cecha5_Format,MAX(Tsd_Cecha5_Kod ) as Tsd_Cecha5_Kod,MAX(Tsd_Cecha5_Wartosc) as Tsd_Cecha5_Wartosc,
           MAX(Tsd_Cecha6_DeAId ) as Tsd_Cecha6_DeAId,MAX(Tsd_Cecha6_Format ) as Tsd_Cecha6_Format,MAX(Tsd_Cecha6_Kod ) as Tsd_Cecha6_Kod,MAX(Tsd_Cecha6_Wartosc) as Tsd_Cecha6_Wartosc,
           MAX(Tsd_Cecha7_DeAId ) as Tsd_Cecha7_DeAId,MAX(Tsd_Cecha7_Format ) as Tsd_Cecha7_Format,MAX(Tsd_Cecha7_Kod ) as Tsd_Cecha7_Kod,MAX(Tsd_Cecha7_Wartosc) as Tsd_Cecha7_Wartosc,
           MAX(Tsd_Cecha8_DeAId ) as Tsd_Cecha8_DeAId,MAX(Tsd_Cecha8_Format ) as Tsd_Cecha8_Format,MAX(Tsd_Cecha8_Kod ) as Tsd_Cecha8_Kod,MAX(Tsd_Cecha8_Wartosc) as Tsd_Cecha8_Wartosc,
           MAX(Tsd_Cecha9_DeAId ) as Tsd_Cecha9_DeAId,MAX(Tsd_Cecha9_Format ) as Tsd_Cecha9_Format,MAX(Tsd_Cecha9_Kod ) as Tsd_Cecha9_Kod,MAX(Tsd_Cecha9_Wartosc) as Tsd_Cecha9_Wartosc,
           MAX(Tsd_Cecha10_DeAId ) as Tsd_Cecha10_DeAId,MAX(Tsd_Cecha10_Format ) as Tsd_Cecha10_Format,MAX(Tsd_Cecha10_Kod ) as Tsd_Cecha10_Kod,MAX(Tsd_Cecha10_Wartosc) as Tsd_Cecha10_Wartosc
   FROM CDN.TraElem a
   JOIN CDN.tranagrelacje ON TrR_TrNID = a.TrE_TrNID
   JOIN CDN.TraElem b ON TrR_FaId = b.TrE_TrNID AND a.TrE_Lppow = b.TrE_LpPow
   JOIN CDN.TraSElemDost  TraSElemDost ON b.TrE_TrEId = TraSElemDost.Tsd_TrEID
   JOIN (SELECT Tsd_TrsIdDost,SUM(Tsd_ilosc) AS ilosc, ID from
(SELECT TsD_TrsIdDost, tsd_ilosc, tsd_treid as ID
         FROM CDN.TraSElemDost
      WHERE Tsd_TrEID IN (
               SELECT b.TrE_TrEId
                 FROM CDN.TraElem a
                 JOIN CDN.tranagrelacje ON TrR_TrNID = a.TrE_TrNID
                 JOIN CDN.TraElem b ON TrR_FaId = b.TrE_TrNID AND a.TrE_Lppow = b.TrE_LpPow WHERE a.TrE_TrEId = @Korekta
               UNION ALL
               SELECT TrE_TrEId FROM CDN.TraElem WHERE TrE_ZwrID in ( SELECT b.TrE_TrEId
                 FROM CDN.TraElem a
                 JOIN CDN.tranagrelacje ON TrR_TrNID = a.TrE_TrNID
                 JOIN CDN.TraElem b ON TrR_FaId = b.TrE_TrNID AND a.TrE_Lppow = b.TrE_LpPow WHERE a.TrE_TrEId =@Korekta
)) and tsd_zwrid is null  and TsD_PdEId = 0
union all
SELECT TsD_TrsIdDost, tsd_ilosc, tsd_zwrid as ID
         FROM CDN.TraSElemDost
      WHERE Tsd_TrEID IN (
               SELECT b.TrE_TrEId
                 FROM CDN.TraElem a
                 JOIN CDN.tranagrelacje ON TrR_TrNID = a.TrE_TrNID
                 JOIN CDN.TraElem b ON TrR_FaId = b.TrE_TrNID AND a.TrE_Lppow = b.TrE_LpPow WHERE a.TrE_TrEId = @Korekta
               UNION ALL
               SELECT TrE_TrEId FROM CDN.TraElem WHERE TrE_ZwrID in ( SELECT b.TrE_TrEId
                 FROM CDN.TraElem a
                 JOIN CDN.tranagrelacje ON TrR_TrNID = a.TrE_TrNID
                 JOIN CDN.TraElem b ON TrR_FaId = b.TrE_TrNID AND a.TrE_Lppow = b.TrE_LpPow WHERE a.TrE_TrEId =@Korekta
)) and tsd_zwrid is not null  and TsD_PdEId = 0) as y
GROUP BY y.ID,y.Tsd_TrsIdDost) AS z ON z.Tsd_TrsIdDost = TraSElemDost.Tsd_TrsIdDost
   WHERE a.TrE_TrEId = @Korekta and TraSElemDost.Tsd_Ilosc > 0
   GROUP BY z.ID ,TraSElemDost.Tsd_TrsIdDost, TsD_DataOpe
   ORDER BY TsD_DataOpe ,TraSElemDost.Tsd_TrsIdDost
End
else
begin
IF @Korekta = 0
   --poziom zeby bylo odpowienio posortowane
  select max(z.Tsd_TrsIdDost) as Tsd_TrsIdDost,
         max(z.Tsd_NumerPelny) as Tsd_NumerPelny,
         max(z.Tsd_NumerObcy) as Tsd_NumerObcy,
         max(z.Tsd_DataOpe) as Tsd_DataOpe,
         max(z.Tsd_Dostawca) as Tsd_Dostawca,
         sum(z.Tsd_IloscDostepna) as Tsd_IloscDostepna,
         ROUND(sum(z.Tsd_Wartosc)/sum(z.Tsd_IloscDostepna),4) as Tsd_Wartosc,
         max(z.Tsd_Cecha1_DeAId ) as Tsd_Cecha1_DeAId ,
         max(z.Tsd_Cecha1_Format) as Tsd_Cecha1_Format,
         max(z.Tsd_Cecha1_Kod) as Tsd_Cecha1_Kod,
         max(z.Tsd_Cecha1_Wartosc) as Tsd_Cecha1_Wartosc,
         max(z.Tsd_Cecha2_DeAId) as Tsd_Cecha2_DeAId,
         max(z.Tsd_Cecha2_Format) as Tsd_Cecha2_Format,
         max(z.Tsd_Cecha2_Kod) as Tsd_Cecha2_Kod,
         max(z.Tsd_Cecha2_Wartosc) as Tsd_Cecha2_Wartosc,
         max(z.Tsd_Cecha3_DeAId) as Tsd_Cecha3_DeAId,
         max(z.Tsd_Cecha3_Format) as Tsd_Cecha3_Format,
         max(z.Tsd_Cecha3_Kod) as Tsd_Cecha3_Kod,
         max(z.Tsd_Cecha3_Wartosc) as Tsd_Cecha3_Wartosc,
         max(z.Tsd_Cecha4_DeAId) as Tsd_Cecha4_DeAId,
         max(z.Tsd_Cecha4_Format) as Tsd_Cecha4_Format,
         max(z.Tsd_Cecha4_Kod) as Tsd_Cecha4_Kod,
         max(z.Tsd_Cecha4_Wartosc) as Tsd_Cecha4_Wartosc,
         max(z.Tsd_Cecha5_DeAId) as Tsd_Cecha5_DeAId,
         max(z.Tsd_Cecha5_Format) as Tsd_Cecha5_Format,
         max(z.Tsd_Cecha5_Kod) as Tsd_Cecha5_Kod,
         max(z.Tsd_Cecha5_Wartosc) as Tsd_Cecha5_Wartosc,
         max(z.Tsd_Cecha6_DeAId) as Tsd_Cecha6_DeAId,
         max(z.Tsd_Cecha6_Format) as Tsd_Cecha6_Format,
         max(z.Tsd_Cecha6_Kod) as Tsd_Cecha6_Kod,
         max(z.Tsd_Cecha6_Wartosc) as Tsd_Cecha6_Wartosc,
         max(z.Tsd_Cecha7_DeAId) as Tsd_Cecha7_DeAId,
         max(z.Tsd_Cecha7_Format) as Tsd_Cecha7_Format,
         max(z.Tsd_Cecha7_Kod) as Tsd_Cecha7_Kod,
         max(z.Tsd_Cecha7_Wartosc) as Tsd_Cecha7_Wartosc,
         max(z.Tsd_Cecha8_DeAId) as Tsd_Cecha8_DeAId,
         max(z.Tsd_Cecha8_Format) as Tsd_Cecha8_Format,
         max(z.Tsd_Cecha8_Kod) as Tsd_Cecha8_Kod,
         max(z.Tsd_Cecha8_Wartosc) as Tsd_Cecha8_Wartosc,
         max(z.Tsd_Cecha9_DeAId) as Tsd_Cecha9_DeAId,
         max(z.Tsd_Cecha9_Format) as Tsd_Cecha9_Format,
         max(z.Tsd_Cecha9_Kod) as Tsd_Cecha9_Kod,
         max(z.Tsd_Cecha9_Wartosc) as Tsd_Cecha9_Wartosc,
         max(z.Tsd_Cecha10_DeAId) as Tsd_Cecha10_DeAId,
         max(z.Tsd_Cecha10_Format) as Tsd_Cecha10_Format,
         max(z.Tsd_Cecha10_Kod) as Tsd_Cecha10_Kod,
         max(z.Tsd_Cecha10_Wartosc) as  Tsd_Cecha10_Wartosc
   from (SELECT  Twz_TrSIdDost AS Tsd_TrsIdDost,
          ISNULL(TrN_NumerPelny,'Dokument usunięty') AS Tsd_NumerPelny,
         ISNULL(TrN_NumerObcy,'') AS Tsd_NumerObcy,
         ISNULL(TrN_DataOpe,TwZ_Data) AS Tsd_DataOpe,
         ISNULL(TrN_PodNazwa1,'') AS Tsd_Dostawca,
         Twz_Ilosc AS  Tsd_IloscDostepna,
         Twz_Wartosc AS  Tsd_Wartosc,
         TsC_Cecha1_DeAId AS Tsd_Cecha1_DeAId ,
         TsC_Cecha1_Format AS Tsd_Cecha1_Format,
         TsC_Cecha1_Kod AS Tsd_Cecha1_Kod,
         TsC_Cecha1_Wartosc AS Tsd_Cecha1_Wartosc,
         TsC_Cecha2_DeAId AS Tsd_Cecha2_DeAId,
         TsC_Cecha2_Format AS Tsd_Cecha2_Format,
         TsC_Cecha2_Kod AS Tsd_Cecha2_Kod,
         TsC_Cecha2_Wartosc AS Tsd_Cecha2_Wartosc,
         TsC_Cecha3_DeAId AS Tsd_Cecha3_DeAId,
         TsC_Cecha3_Format AS Tsd_Cecha3_Format,
         TsC_Cecha3_Kod AS Tsd_Cecha3_Kod,
         TsC_Cecha3_Wartosc AS Tsd_Cecha3_Wartosc,
         TsC_Cecha4_DeAId AS Tsd_Cecha4_DeAId,
         TsC_Cecha4_Format AS Tsd_Cecha4_Format,
         TsC_Cecha4_Kod AS Tsd_Cecha4_Kod,
         TsC_Cecha4_Wartosc AS Tsd_Cecha4_Wartosc,
         TsC_Cecha5_DeAId AS Tsd_Cecha5_DeAId,
         TsC_Cecha5_Format AS Tsd_Cecha5_Format,
         TsC_Cecha5_Kod AS Tsd_Cecha5_Kod,
         TsC_Cecha5_Wartosc AS Tsd_Cecha5_Wartosc,
         TsC_Cecha6_DeAId AS Tsd_Cecha6_DeAId,
         TsC_Cecha6_Format AS Tsd_Cecha6_Format,
         TsC_Cecha6_Kod AS Tsd_Cecha6_Kod,
         TsC_Cecha6_Wartosc AS Tsd_Cecha6_Wartosc,
         TsC_Cecha7_DeAId AS Tsd_Cecha7_DeAId,
         TsC_Cecha7_Format AS Tsd_Cecha7_Format,
         TsC_Cecha7_Kod AS Tsd_Cecha7_Kod,
         TsC_Cecha7_Wartosc AS Tsd_Cecha7_Wartosc,
         TsC_Cecha8_DeAId AS Tsd_Cecha8_DeAId,
         TsC_Cecha8_Format AS Tsd_Cecha8_Format,
         TsC_Cecha8_Kod AS Tsd_Cecha8_Kod,
         TsC_Cecha8_Wartosc AS Tsd_Cecha8_Wartosc,
         TsC_Cecha9_DeAId AS Tsd_Cecha9_DeAId,
         TsC_Cecha9_Format AS Tsd_Cecha9_Format,
         TsC_Cecha9_Kod AS Tsd_Cecha9_Kod,
         TsC_Cecha9_Wartosc AS Tsd_Cecha9_Wartosc,
         TsC_Cecha10_DeAId AS Tsd_Cecha10_DeAId,
         TsC_Cecha10_Format AS Tsd_Cecha10_Format,
         TsC_Cecha10_Kod AS Tsd_Cecha10_Kod,
         TsC_Cecha10_Wartosc AS Tsd_Cecha10_Wartosc
 FROM CDN.TwrZasoby
 LEFT JOIN CDN.TraSElem TraSElem ON Twz_TrSIdDost = TrS_TrSId
 LEFT JOIN CDN.TraSElemCechy TraSElemCechy ON TrS_TrSId = TsC_TrSId
 LEFT JOIN CDN.TraElem TraElemDos ON TrS_TrEId = TraElemDos.TrE_TrEId
 LEFT JOIN CDN.TraNag  ON TrN_TrNId = TraElemDos.TrE_TrNId
 WHERE Twz_TwrId = @TwrId and Twz_MagId = @MagId
UNION ALL
   SELECT A.TrS_TrSIdDost AS Tsd_TrsIdDost,
         ISNULL(TrN_NumerPelny,'Dokument usunięty') AS Tsd_NumerPelny,
         ISNULL(TrN_NumerObcy,'') AS Tsd_NumerObcy,
         ISNULL(TrN_DataOpe,A.TrS_DataOpe) AS Tsd_DataOpe,
         ISNULL(TrN_PodNazwa1,'') AS Tsd_Dostawca,
         A.TrS_Ilosc AS Tsd_IloscDostepna,
         A.TrS_Wartosc AS  Tsd_Wartosc,
         TsC_Cecha1_DeAId AS Tsd_Cecha1_DeAId ,
         TsC_Cecha1_Format AS Tsd_Cecha1_Format,
         TsC_Cecha1_Kod AS Tsd_Cecha1_Kod,
         TsC_Cecha1_Wartosc AS Tsd_Cecha1_Wartosc,
         TsC_Cecha2_DeAId AS Tsd_Cecha2_DeAId,
         TsC_Cecha2_Format AS Tsd_Cecha2_Format,
         TsC_Cecha2_Kod AS Tsd_Cecha2_Kod,
         TsC_Cecha2_Wartosc AS Tsd_Cecha2_Wartosc,
         TsC_Cecha3_DeAId AS Tsd_Cecha3_DeAId,
         TsC_Cecha3_Format AS Tsd_Cecha3_Format,
         TsC_Cecha3_Kod AS Tsd_Cecha3_Kod,
         TsC_Cecha3_Wartosc AS Tsd_Cecha3_Wartosc,
         TsC_Cecha4_DeAId AS Tsd_Cecha4_DeAId,
         TsC_Cecha4_Format AS Tsd_Cecha4_Format,
         TsC_Cecha4_Kod AS Tsd_Cecha4_Kod,
         TsC_Cecha4_Wartosc AS Tsd_Cecha4_Wartosc,
         TsC_Cecha5_DeAId AS Tsd_Cecha5_DeAId,
         TsC_Cecha5_Format AS Tsd_Cecha5_Format,
         TsC_Cecha5_Kod AS Tsd_Cecha5_Kod,
         TsC_Cecha5_Wartosc AS Tsd_Cecha5_Wartosc,
         TsC_Cecha6_DeAId AS Tsd_Cecha6_DeAId,
         TsC_Cecha6_Format AS Tsd_Cecha6_Format,
         TsC_Cecha6_Kod AS Tsd_Cecha6_Kod,
         TsC_Cecha6_Wartosc AS Tsd_Cecha6_Wartosc,
         TsC_Cecha7_DeAId AS Tsd_Cecha7_DeAId,
         TsC_Cecha7_Format AS Tsd_Cecha7_Format,
         TsC_Cecha7_Kod AS Tsd_Cecha7_Kod,
         TsC_Cecha7_Wartosc AS Tsd_Cecha7_Wartosc,
         TsC_Cecha8_DeAId AS Tsd_Cecha8_DeAId,
         TsC_Cecha8_Format AS Tsd_Cecha8_Format,
         TsC_Cecha8_Kod AS Tsd_Cecha8_Kod,
         TsC_Cecha8_Wartosc AS Tsd_Cecha8_Wartosc,
         TsC_Cecha9_DeAId AS Tsd_Cecha9_DeAId,
         TsC_Cecha9_Format AS Tsd_Cecha9_Format,
         TsC_Cecha9_Kod AS Tsd_Cecha9_Kod,
         TsC_Cecha9_Wartosc AS Tsd_Cecha9_Wartosc,
         TsC_Cecha10_DeAId AS Tsd_Cecha10_DeAId,
         TsC_Cecha10_Format AS Tsd_Cecha10_Format,
         TsC_Cecha10_Kod AS Tsd_Cecha10_Kod,
         TsC_Cecha10_Wartosc AS Tsd_Cecha10_Wartosc
  FROM CDN.TraSElem A
  LEFT JOIN CDN.TraSElemCechy TraSElemCechy ON A.TrS_TrSIdDost = TsC_TrSId
  LEFT JOIN CDN.TraSElem B ON A.TrS_TrSIdDost = B.TrS_TrSId
  LEFT JOIN CDN.TraElem  ON B.TrS_TrEId = TrE_TrEId
  LEFT JOIN CDN.TraNag  ON TrN_TrNId = TrE_TrNId
  LEFT JOIN CDN.TrasElemDost ON A.TrS_TrSId = case  when A.TrS_Rodzaj in (312000,312008) then (TsD_TrSId-1) else TsD_TrSId end
  WHERE A.TrS_TrEId = @CzyBuforBezDostaw AND TsD_TsDId IS NULL AND A.TrS_TrSIdDost IS NOT NULL AND A.Trs_MagId = @MagId AND A.TrS_TwrId = @TwrId
  union all
   SELECT A.TrS_TrSIdDost AS Tsd_TrsIdDost,
         ISNULL(TrN_NumerPelny,'Dokument usunięty') AS Tsd_NumerPelny,
         ISNULL(TrN_NumerObcy,'') AS Tsd_NumerObcy,
         ISNULL(TrN_DataOpe,A.TrS_DataOpe) AS Tsd_DataOpe,
         ISNULL(TrN_PodNazwa1,'') AS Tsd_Dostawca,
         A.TrS_Ilosc AS Tsd_IloscDostepna,
         A.TrS_Wartosc AS  Tsd_Wartosc,
         TsC_Cecha1_DeAId AS Tsd_Cecha1_DeAId ,
         TsC_Cecha1_Format AS Tsd_Cecha1_Format,
         TsC_Cecha1_Kod AS Tsd_Cecha1_Kod,
         TsC_Cecha1_Wartosc AS Tsd_Cecha1_Wartosc,
         TsC_Cecha2_DeAId AS Tsd_Cecha2_DeAId,
         TsC_Cecha2_Format AS Tsd_Cecha2_Format,
         TsC_Cecha2_Kod AS Tsd_Cecha2_Kod,
         TsC_Cecha2_Wartosc AS Tsd_Cecha2_Wartosc,
         TsC_Cecha3_DeAId AS Tsd_Cecha3_DeAId,
         TsC_Cecha3_Format AS Tsd_Cecha3_Format,
         TsC_Cecha3_Kod AS Tsd_Cecha3_Kod,
         TsC_Cecha3_Wartosc AS Tsd_Cecha3_Wartosc,
         TsC_Cecha4_DeAId AS Tsd_Cecha4_DeAId,
         TsC_Cecha4_Format AS Tsd_Cecha4_Format,
         TsC_Cecha4_Kod AS Tsd_Cecha4_Kod,
         TsC_Cecha4_Wartosc AS Tsd_Cecha4_Wartosc,
         TsC_Cecha5_DeAId AS Tsd_Cecha5_DeAId,
         TsC_Cecha5_Format AS Tsd_Cecha5_Format,
         TsC_Cecha5_Kod AS Tsd_Cecha5_Kod,
         TsC_Cecha5_Wartosc AS Tsd_Cecha5_Wartosc,
         TsC_Cecha6_DeAId AS Tsd_Cecha6_DeAId,
         TsC_Cecha6_Format AS Tsd_Cecha6_Format,
         TsC_Cecha6_Kod AS Tsd_Cecha6_Kod,
         TsC_Cecha6_Wartosc AS Tsd_Cecha6_Wartosc,
         TsC_Cecha7_DeAId AS Tsd_Cecha7_DeAId,
         TsC_Cecha7_Format AS Tsd_Cecha7_Format,
         TsC_Cecha7_Kod AS Tsd_Cecha7_Kod,
         TsC_Cecha7_Wartosc AS Tsd_Cecha7_Wartosc,
         TsC_Cecha8_DeAId AS Tsd_Cecha8_DeAId,
         TsC_Cecha8_Format AS Tsd_Cecha8_Format,
         TsC_Cecha8_Kod AS Tsd_Cecha8_Kod,
         TsC_Cecha8_Wartosc AS Tsd_Cecha8_Wartosc,
         TsC_Cecha9_DeAId AS Tsd_Cecha9_DeAId,
         TsC_Cecha9_Format AS Tsd_Cecha9_Format,
         TsC_Cecha9_Kod AS Tsd_Cecha9_Kod,
         TsC_Cecha9_Wartosc AS Tsd_Cecha9_Wartosc,
         TsC_Cecha10_DeAId AS Tsd_Cecha10_DeAId,
         TsC_Cecha10_Format AS Tsd_Cecha10_Format,
         TsC_Cecha10_Kod AS Tsd_Cecha10_Kod,
         TsC_Cecha10_Wartosc AS Tsd_Cecha10_Wartosc
  FROM CDN.TraSElem A
  LEFT JOIN CDN.TraSElemCechy TraSElemCechy ON A.TrS_TrSIdDost = TsC_TrSId
  LEFT JOIN CDN.TraSElem B ON A.TrS_TrSIdDost = B.TrS_TrSId
  LEFT JOIN CDN.TraElem  ON B.TrS_TrEId = TrE_TrEId
  LEFT JOIN CDN.TraNag  ON TrN_TrNId = TrE_TrNId
  LEFT JOIN CDN.TrasElemDost ON A.TrS_TrSId = case  when A.TrS_Rodzaj in (312000,312008) then (TsD_TrSId-1) else TsD_TrSId end
  WHERE A.TrS_TrEId = @CzyBuforBezDostaw AND TsD_TsDId IS NOT NULL AND A.TrS_TrSIdDost IS NOT NULL AND A.Trs_MagId = @MagId AND A.TrS_TwrId = @TwrId
   UNION ALL
   SELECT A.TrS_TrSIdDost AS Tsd_TrsIdDost,
         ISNULL(TrN_NumerPelny,'Dokument usunięty') AS Tsd_NumerPelny,
         ISNULL(TrN_NumerObcy,'') AS Tsd_NumerObcy,
         ISNULL(TrN_DataOpe,A.TrS_DataOpe) AS Tsd_DataOpe,
         ISNULL(TrN_PodNazwa1,'') AS Tsd_Dostawca,
         A.TrS_Ilosc AS Tsd_IloscDostepna,
         A.TrS_Wartosc AS  Tsd_Wartosc,
         TsC_Cecha1_DeAId AS Tsd_Cecha1_DeAId ,
         TsC_Cecha1_Format AS Tsd_Cecha1_Format,
         TsC_Cecha1_Kod AS Tsd_Cecha1_Kod,
         TsC_Cecha1_Wartosc AS Tsd_Cecha1_Wartosc,
         TsC_Cecha2_DeAId AS Tsd_Cecha2_DeAId,
         TsC_Cecha2_Format AS Tsd_Cecha2_Format,
         TsC_Cecha2_Kod AS Tsd_Cecha2_Kod,
         TsC_Cecha2_Wartosc AS Tsd_Cecha2_Wartosc,
         TsC_Cecha3_DeAId AS Tsd_Cecha3_DeAId,
         TsC_Cecha3_Format AS Tsd_Cecha3_Format,
         TsC_Cecha3_Kod AS Tsd_Cecha3_Kod,
         TsC_Cecha3_Wartosc AS Tsd_Cecha3_Wartosc,
         TsC_Cecha4_DeAId AS Tsd_Cecha4_DeAId,
         TsC_Cecha4_Format AS Tsd_Cecha4_Format,
         TsC_Cecha4_Kod AS Tsd_Cecha4_Kod,
         TsC_Cecha4_Wartosc AS Tsd_Cecha4_Wartosc,
         TsC_Cecha5_DeAId AS Tsd_Cecha5_DeAId,
         TsC_Cecha5_Format AS Tsd_Cecha5_Format,
         TsC_Cecha5_Kod AS Tsd_Cecha5_Kod,
         TsC_Cecha5_Wartosc AS Tsd_Cecha5_Wartosc,
         TsC_Cecha6_DeAId AS Tsd_Cecha6_DeAId,
         TsC_Cecha6_Format AS Tsd_Cecha6_Format,
         TsC_Cecha6_Kod AS Tsd_Cecha6_Kod,
         TsC_Cecha6_Wartosc AS Tsd_Cecha6_Wartosc,
         TsC_Cecha7_DeAId AS Tsd_Cecha7_DeAId,
         TsC_Cecha7_Format AS Tsd_Cecha7_Format,
         TsC_Cecha7_Kod AS Tsd_Cecha7_Kod,
         TsC_Cecha7_Wartosc AS Tsd_Cecha7_Wartosc,
         TsC_Cecha8_DeAId AS Tsd_Cecha8_DeAId,
         TsC_Cecha8_Format AS Tsd_Cecha8_Format,
         TsC_Cecha8_Kod AS Tsd_Cecha8_Kod,
         TsC_Cecha8_Wartosc AS Tsd_Cecha8_Wartosc,
         TsC_Cecha9_DeAId AS Tsd_Cecha9_DeAId,
         TsC_Cecha9_Format AS Tsd_Cecha9_Format,
         TsC_Cecha9_Kod AS Tsd_Cecha9_Kod,
         TsC_Cecha9_Wartosc AS Tsd_Cecha9_Wartosc,
         TsC_Cecha10_DeAId AS Tsd_Cecha10_DeAId,
         TsC_Cecha10_Format AS Tsd_Cecha10_Format,
         TsC_Cecha10_Kod AS Tsd_Cecha10_Kod,
         TsC_Cecha10_Wartosc AS Tsd_Cecha10_Wartosc
  FROM CDN.TraSElem A
  LEFT JOIN CDN.TraSElemCechy TraSElemCechy ON A.TrS_TrSIdDost = TsC_TrSId
  LEFT JOIN CDN.TraSElem B ON A.TrS_TrSIdDost = B.TrS_TrSId
  LEFT JOIN CDN.TraElem  ON B.TrS_TrEId = TrE_TrEId
  LEFT JOIN CDN.TraNag  ON TrN_TrNId = TrE_TrNId
  LEFT JOIN CDN.TrasElemDost ON A.TrS_TrSId = case  when A.TrS_Rodzaj in (312000,312008) then (TsD_TrSId-1) else TsD_TrSId end
  WHERE A.TrS_TrEId in (select TrEId from @RWS) AND TsD_TsDId IS NULL AND A.TrS_TrSIdDost IS NOT NULL AND A.Trs_MagId = @MagId AND A.TrS_TwrId = @TwrId
  union all
   SELECT A.TrS_TrSIdDost AS Tsd_TrsIdDost,
         ISNULL(TrN_NumerPelny,'Dokument usunięty') AS Tsd_NumerPelny,
         ISNULL(TrN_NumerObcy,'') AS Tsd_NumerObcy,
         ISNULL(TrN_DataOpe,A.TrS_DataOpe) AS Tsd_DataOpe,
         ISNULL(TrN_PodNazwa1,'') AS Tsd_Dostawca,
         A.TrS_Ilosc AS Tsd_IloscDostepna,
         A.TrS_Wartosc AS  Tsd_Wartosc,
         TsC_Cecha1_DeAId AS Tsd_Cecha1_DeAId ,
         TsC_Cecha1_Format AS Tsd_Cecha1_Format,
         TsC_Cecha1_Kod AS Tsd_Cecha1_Kod,
         TsC_Cecha1_Wartosc AS Tsd_Cecha1_Wartosc,
         TsC_Cecha2_DeAId AS Tsd_Cecha2_DeAId,
         TsC_Cecha2_Format AS Tsd_Cecha2_Format,
         TsC_Cecha2_Kod AS Tsd_Cecha2_Kod,
         TsC_Cecha2_Wartosc AS Tsd_Cecha2_Wartosc,
         TsC_Cecha3_DeAId AS Tsd_Cecha3_DeAId,
         TsC_Cecha3_Format AS Tsd_Cecha3_Format,
         TsC_Cecha3_Kod AS Tsd_Cecha3_Kod,
         TsC_Cecha3_Wartosc AS Tsd_Cecha3_Wartosc,
         TsC_Cecha4_DeAId AS Tsd_Cecha4_DeAId,
         TsC_Cecha4_Format AS Tsd_Cecha4_Format,
         TsC_Cecha4_Kod AS Tsd_Cecha4_Kod,
         TsC_Cecha4_Wartosc AS Tsd_Cecha4_Wartosc,
         TsC_Cecha5_DeAId AS Tsd_Cecha5_DeAId,
         TsC_Cecha5_Format AS Tsd_Cecha5_Format,
         TsC_Cecha5_Kod AS Tsd_Cecha5_Kod,
         TsC_Cecha5_Wartosc AS Tsd_Cecha5_Wartosc,
         TsC_Cecha6_DeAId AS Tsd_Cecha6_DeAId,
         TsC_Cecha6_Format AS Tsd_Cecha6_Format,
         TsC_Cecha6_Kod AS Tsd_Cecha6_Kod,
         TsC_Cecha6_Wartosc AS Tsd_Cecha6_Wartosc,
         TsC_Cecha7_DeAId AS Tsd_Cecha7_DeAId,
         TsC_Cecha7_Format AS Tsd_Cecha7_Format,
         TsC_Cecha7_Kod AS Tsd_Cecha7_Kod,
         TsC_Cecha7_Wartosc AS Tsd_Cecha7_Wartosc,
         TsC_Cecha8_DeAId AS Tsd_Cecha8_DeAId,
         TsC_Cecha8_Format AS Tsd_Cecha8_Format,
         TsC_Cecha8_Kod AS Tsd_Cecha8_Kod,
         TsC_Cecha8_Wartosc AS Tsd_Cecha8_Wartosc,
         TsC_Cecha9_DeAId AS Tsd_Cecha9_DeAId,
         TsC_Cecha9_Format AS Tsd_Cecha9_Format,
         TsC_Cecha9_Kod AS Tsd_Cecha9_Kod,
         TsC_Cecha9_Wartosc AS Tsd_Cecha9_Wartosc,
         TsC_Cecha10_DeAId AS Tsd_Cecha10_DeAId,
         TsC_Cecha10_Format AS Tsd_Cecha10_Format,
         TsC_Cecha10_Kod AS Tsd_Cecha10_Kod,
         TsC_Cecha10_Wartosc AS Tsd_Cecha10_Wartosc
  FROM CDN.TraSElem A
  LEFT JOIN CDN.TraSElemCechy TraSElemCechy ON A.TrS_TrSIdDost = TsC_TrSId
  LEFT JOIN CDN.TraSElem B ON A.TrS_TrSIdDost = B.TrS_TrSId
  LEFT JOIN CDN.TraElem  ON B.TrS_TrEId = TrE_TrEId
  LEFT JOIN CDN.TraNag  ON TrN_TrNId = TrE_TrNId
  LEFT JOIN CDN.TrasElemDost ON A.TrS_TrSId = case  when A.TrS_Rodzaj in (312000,312008) then (TsD_TrSId-1) else TsD_TrSId end
  WHERE A.TrS_TrEId in (select TrEId from @RWS) AND TsD_TsDId IS NOT NULL AND A.TrS_TrSIdDost IS NOT NULL AND A.Trs_MagId = @MagId AND A.TrS_TwrId = @TwrId
) as z group by Tsd_TrsIdDost order by TsD_DataOpe,Tsd_TrsIdDost
ELSE
IF @KorektaPRodElem != 0
 begin
 SELECT MAX(Tsd_TsDID) as Tsd_TsDID,
           MAX(Tsd_TrSID) as Tsd_TrSID,
           MAX(Tsd_TrEId) as Tsd_TrEId,
           MAX(Tsd_ZwrId) as Tsd_ZwrId,
           MAX(a.Tsd_TrsIdDost) as Tsd_TrsIdDost,
           MAX(Tsd_NumerPelny) as Tsd_NumerPelny,
           MAX(Tsd_NumerObcy) as Tsd_NumerObcy,
           MAX(Tsd_DataOpe) as Tsd_DataOpe,
           MAX(Tsd_Dostawca) as Tsd_Dostawca,
           MAX(z.ilosc) AS Tsd_Ilosc,
           MAX(Tsd_IloscDostepna) as Tsd_IloscDostepna,
           MAX(Tsd_Wartosc) as Tsd_Wartosc,
           MAX(Tsd_Cecha1_DeAId ) as Tsd_Cecha1_DeAId,MAX(Tsd_Cecha1_Format ) as Tsd_Cecha1_Format,MAX(Tsd_Cecha1_Kod ) as Tsd_Cecha1_Kod,MAX(Tsd_Cecha1_Wartosc) as Tsd_Cecha1_Wartosc,
           MAX(Tsd_Cecha2_DeAId ) as Tsd_Cecha2_DeAId,MAX(Tsd_Cecha2_Format ) as Tsd_Cecha2_Format,MAX(Tsd_Cecha2_Kod ) as Tsd_Cecha2_Kod,MAX(Tsd_Cecha2_Wartosc) as Tsd_Cecha2_Wartosc,
           MAX(Tsd_Cecha3_DeAId ) as Tsd_Cecha3_DeAId,MAX(Tsd_Cecha3_Format ) as Tsd_Cecha3_Format,MAX(Tsd_Cecha3_Kod ) as Tsd_Cecha3_Kod,MAX(Tsd_Cecha3_Wartosc) as Tsd_Cecha3_Wartosc,
           MAX(Tsd_Cecha4_DeAId ) as Tsd_Cecha4_DeAId,MAX(Tsd_Cecha4_Format ) as Tsd_Cecha4_Format,MAX(Tsd_Cecha4_Kod ) as Tsd_Cecha4_Kod,MAX(Tsd_Cecha4_Wartosc) as Tsd_Cecha4_Wartosc,
           MAX(Tsd_Cecha5_DeAId ) as Tsd_Cecha5_DeAId,MAX(Tsd_Cecha5_Format ) as Tsd_Cecha5_Format,MAX(Tsd_Cecha5_Kod ) as Tsd_Cecha5_Kod,MAX(Tsd_Cecha5_Wartosc) as Tsd_Cecha5_Wartosc,
           MAX(Tsd_Cecha6_DeAId ) as Tsd_Cecha6_DeAId,MAX(Tsd_Cecha6_Format ) as Tsd_Cecha6_Format,MAX(Tsd_Cecha6_Kod ) as Tsd_Cecha6_Kod,MAX(Tsd_Cecha6_Wartosc) as Tsd_Cecha6_Wartosc,
           MAX(Tsd_Cecha7_DeAId ) as Tsd_Cecha7_DeAId,MAX(Tsd_Cecha7_Format ) as Tsd_Cecha7_Format,MAX(Tsd_Cecha7_Kod ) as Tsd_Cecha7_Kod,MAX(Tsd_Cecha7_Wartosc) as Tsd_Cecha7_Wartosc,
           MAX(Tsd_Cecha8_DeAId ) as Tsd_Cecha8_DeAId,MAX(Tsd_Cecha8_Format ) as Tsd_Cecha8_Format,MAX(Tsd_Cecha8_Kod ) as Tsd_Cecha8_Kod,MAX(Tsd_Cecha8_Wartosc) as Tsd_Cecha8_Wartosc,
           MAX(Tsd_Cecha9_DeAId ) as Tsd_Cecha9_DeAId,MAX(Tsd_Cecha9_Format ) as Tsd_Cecha9_Format,MAX(Tsd_Cecha9_Kod ) as Tsd_Cecha9_Kod,MAX(Tsd_Cecha9_Wartosc) as Tsd_Cecha9_Wartosc,
           MAX(Tsd_Cecha10_DeAId ) as Tsd_Cecha10_DeAId,MAX(Tsd_Cecha10_Format ) as Tsd_Cecha10_Format,MAX(Tsd_Cecha10_Kod ) as Tsd_Cecha10_Kod,MAX(Tsd_Cecha10_Wartosc) as Tsd_Cecha10_Wartosc
    FROM CDN.TraSElemDost AS a
    JOIN (SELECT Tsd_TrsIdDost,SUM(Tsd_Ilosc) AS ilosc
            FROM CDN.TraSElemDost
           WHERE TsD_PdEId IN (SELECT PdE_PdEId FROM CDN.ProdElem join cdn.traelem on tre_treid = pde_treid WHERE (PdE_PdEId=@KorektaPRodElem OR PdE_ZwrID = @KorektaPRodElem) and tre_trnid != @KorektaTrNID)
           GROUP BY Tsd_TrsIdDost) AS z ON z.Tsd_TrsIdDost = a.Tsd_TrsIdDost
    WHERE TsD_PdEId = @KorektaPRodElem
    GROUP BY a.Tsd_TrsIdDost, TsD_DataOpe
    order by TsD_DataOpe desc,a.Tsd_TrsIdDost desc
 end
 else
 IF EXISTS(SELECT * FROM CDN.TraSElemDost WHERE Tsd_TrEID=@Korekta  and TsD_PdEId = 0)
    SELECT MAX(Tsd_TsDID) as Tsd_TsDID,
           MAX(Tsd_TrSID) as Tsd_TrSID,
           MAX(Tsd_TrEId) as Tsd_TrEId,
           MAX(Tsd_ZwrId) as Tsd_ZwrId,
           MAX(a.Tsd_TrsIdDost) as Tsd_TrsIdDost,
           MAX(Tsd_NumerPelny) as Tsd_NumerPelny,
           MAX(Tsd_NumerObcy) as Tsd_NumerObcy,
           MAX(Tsd_DataOpe) as Tsd_DataOpe,
           MAX(Tsd_Dostawca) as Tsd_Dostawca,
           MAX(z.ilosc) AS Tsd_Ilosc,
           MAX(Tsd_IloscDostepna) as Tsd_IloscDostepna,
           MAX(Tsd_Wartosc) as Tsd_Wartosc,
           MAX(Tsd_Cecha1_DeAId ) as Tsd_Cecha1_DeAId,MAX(Tsd_Cecha1_Format ) as Tsd_Cecha1_Format,MAX(Tsd_Cecha1_Kod ) as Tsd_Cecha1_Kod,MAX(Tsd_Cecha1_Wartosc) as Tsd_Cecha1_Wartosc,
           MAX(Tsd_Cecha2_DeAId ) as Tsd_Cecha2_DeAId,MAX(Tsd_Cecha2_Format ) as Tsd_Cecha2_Format,MAX(Tsd_Cecha2_Kod ) as Tsd_Cecha2_Kod,MAX(Tsd_Cecha2_Wartosc) as Tsd_Cecha2_Wartosc,
           MAX(Tsd_Cecha3_DeAId ) as Tsd_Cecha3_DeAId,MAX(Tsd_Cecha3_Format ) as Tsd_Cecha3_Format,MAX(Tsd_Cecha3_Kod ) as Tsd_Cecha3_Kod,MAX(Tsd_Cecha3_Wartosc) as Tsd_Cecha3_Wartosc,
           MAX(Tsd_Cecha4_DeAId ) as Tsd_Cecha4_DeAId,MAX(Tsd_Cecha4_Format ) as Tsd_Cecha4_Format,MAX(Tsd_Cecha4_Kod ) as Tsd_Cecha4_Kod,MAX(Tsd_Cecha4_Wartosc) as Tsd_Cecha4_Wartosc,
           MAX(Tsd_Cecha5_DeAId ) as Tsd_Cecha5_DeAId,MAX(Tsd_Cecha5_Format ) as Tsd_Cecha5_Format,MAX(Tsd_Cecha5_Kod ) as Tsd_Cecha5_Kod,MAX(Tsd_Cecha5_Wartosc) as Tsd_Cecha5_Wartosc,
           MAX(Tsd_Cecha6_DeAId ) as Tsd_Cecha6_DeAId,MAX(Tsd_Cecha6_Format ) as Tsd_Cecha6_Format,MAX(Tsd_Cecha6_Kod ) as Tsd_Cecha6_Kod,MAX(Tsd_Cecha6_Wartosc) as Tsd_Cecha6_Wartosc,
           MAX(Tsd_Cecha7_DeAId ) as Tsd_Cecha7_DeAId,MAX(Tsd_Cecha7_Format ) as Tsd_Cecha7_Format,MAX(Tsd_Cecha7_Kod ) as Tsd_Cecha7_Kod,MAX(Tsd_Cecha7_Wartosc) as Tsd_Cecha7_Wartosc,
           MAX(Tsd_Cecha8_DeAId ) as Tsd_Cecha8_DeAId,MAX(Tsd_Cecha8_Format ) as Tsd_Cecha8_Format,MAX(Tsd_Cecha8_Kod ) as Tsd_Cecha8_Kod,MAX(Tsd_Cecha8_Wartosc) as Tsd_Cecha8_Wartosc,
           MAX(Tsd_Cecha9_DeAId ) as Tsd_Cecha9_DeAId,MAX(Tsd_Cecha9_Format ) as Tsd_Cecha9_Format,MAX(Tsd_Cecha9_Kod ) as Tsd_Cecha9_Kod,MAX(Tsd_Cecha9_Wartosc) as Tsd_Cecha9_Wartosc,
           MAX(Tsd_Cecha10_DeAId ) as Tsd_Cecha10_DeAId,MAX(Tsd_Cecha10_Format ) as Tsd_Cecha10_Format,MAX(Tsd_Cecha10_Kod ) as Tsd_Cecha10_Kod,MAX(Tsd_Cecha10_Wartosc) as Tsd_Cecha10_Wartosc
    FROM CDN.TraSElemDost AS a
    JOIN (SELECT Tsd_TrsIdDost,SUM(Tsd_Ilosc) AS ilosc
            FROM CDN.TraSElemDost
           WHERE Tsd_TrEID IN (SELECT TrE_TrEId FROM CDN.TraElem WHERE TrE_TrEId=@Korekta OR TrE_ZwrID = @Korekta)
           GROUP BY Tsd_TrsIdDost) AS z ON z.Tsd_TrsIdDost = a.Tsd_TrsIdDost
    WHERE Tsd_TrEID=@Korekta  and TsD_PdEId = 0
    GROUP BY a.Tsd_TrsIdDost, TsD_DataOpe
    order by TsD_DataOpe desc,a.Tsd_TrsIdDost desc
 ELSE
    SELECT MAX(Tsd_TsDID) as Tsd_TsDID,
           MAX(Tsd_TrSID) as Tsd_TrSID,
           z.ID as Tsd_TrEId,
           MAX(Tsd_ZwrId) as Tsd_ZwrId,
           MAX(TraSElemDost.Tsd_TrsIdDost) as Tsd_TrsIdDost,
           MAX(Tsd_NumerPelny) as Tsd_NumerPelny,
           MAX(Tsd_NumerObcy) as Tsd_NumerObcy,
           MAX(Tsd_DataOpe) as Tsd_DataOpe,
           MAX(Tsd_Dostawca) as Tsd_Dostawca,
           MAX(z.ilosc) AS Tsd_Ilosc,
           MAX(Tsd_IloscDostepna) as Tsd_IloscDostepna,
           MAX(Tsd_Wartosc) as Tsd_Wartosc,
           MAX(Tsd_Cecha1_DeAId ) as Tsd_Cecha1_DeAId,MAX(Tsd_Cecha1_Format ) as Tsd_Cecha1_Format,MAX(Tsd_Cecha1_Kod ) as Tsd_Cecha1_Kod,MAX(Tsd_Cecha1_Wartosc) as Tsd_Cecha1_Wartosc,
           MAX(Tsd_Cecha2_DeAId ) as Tsd_Cecha2_DeAId,MAX(Tsd_Cecha2_Format ) as Tsd_Cecha2_Format,MAX(Tsd_Cecha2_Kod ) as Tsd_Cecha2_Kod,MAX(Tsd_Cecha2_Wartosc) as Tsd_Cecha2_Wartosc,
           MAX(Tsd_Cecha3_DeAId ) as Tsd_Cecha3_DeAId,MAX(Tsd_Cecha3_Format ) as Tsd_Cecha3_Format,MAX(Tsd_Cecha3_Kod ) as Tsd_Cecha3_Kod,MAX(Tsd_Cecha3_Wartosc) as Tsd_Cecha3_Wartosc,
           MAX(Tsd_Cecha4_DeAId ) as Tsd_Cecha4_DeAId,MAX(Tsd_Cecha4_Format ) as Tsd_Cecha4_Format,MAX(Tsd_Cecha4_Kod ) as Tsd_Cecha4_Kod,MAX(Tsd_Cecha4_Wartosc) as Tsd_Cecha4_Wartosc,
           MAX(Tsd_Cecha5_DeAId ) as Tsd_Cecha5_DeAId,MAX(Tsd_Cecha5_Format ) as Tsd_Cecha5_Format,MAX(Tsd_Cecha5_Kod ) as Tsd_Cecha5_Kod,MAX(Tsd_Cecha5_Wartosc) as Tsd_Cecha5_Wartosc,
           MAX(Tsd_Cecha6_DeAId ) as Tsd_Cecha6_DeAId,MAX(Tsd_Cecha6_Format ) as Tsd_Cecha6_Format,MAX(Tsd_Cecha6_Kod ) as Tsd_Cecha6_Kod,MAX(Tsd_Cecha6_Wartosc) as Tsd_Cecha6_Wartosc,
           MAX(Tsd_Cecha7_DeAId ) as Tsd_Cecha7_DeAId,MAX(Tsd_Cecha7_Format ) as Tsd_Cecha7_Format,MAX(Tsd_Cecha7_Kod ) as Tsd_Cecha7_Kod,MAX(Tsd_Cecha7_Wartosc) as Tsd_Cecha7_Wartosc,
           MAX(Tsd_Cecha8_DeAId ) as Tsd_Cecha8_DeAId,MAX(Tsd_Cecha8_Format ) as Tsd_Cecha8_Format,MAX(Tsd_Cecha8_Kod ) as Tsd_Cecha8_Kod,MAX(Tsd_Cecha8_Wartosc) as Tsd_Cecha8_Wartosc,
           MAX(Tsd_Cecha9_DeAId ) as Tsd_Cecha9_DeAId,MAX(Tsd_Cecha9_Format ) as Tsd_Cecha9_Format,MAX(Tsd_Cecha9_Kod ) as Tsd_Cecha9_Kod,MAX(Tsd_Cecha9_Wartosc) as Tsd_Cecha9_Wartosc,
           MAX(Tsd_Cecha10_DeAId ) as Tsd_Cecha10_DeAId,MAX(Tsd_Cecha10_Format ) as Tsd_Cecha10_Format,MAX(Tsd_Cecha10_Kod ) as Tsd_Cecha10_Kod,MAX(Tsd_Cecha10_Wartosc) as Tsd_Cecha10_Wartosc
   FROM CDN.TraElem a
   JOIN CDN.tranagrelacje ON TrR_TrNID = a.TrE_TrNID
   JOIN CDN.TraElem b ON TrR_FaId = b.TrE_TrNID AND a.TrE_Lppow = b.TrE_LpPow
   JOIN CDN.TraSElemDost  TraSElemDost ON b.TrE_TrEId = TraSElemDost.Tsd_TrEID
   JOIN (SELECT Tsd_TrsIdDost,SUM(Tsd_ilosc) AS ilosc, ID from
(SELECT TsD_TrsIdDost, tsd_ilosc, tsd_treid as ID
         FROM CDN.TraSElemDost
      WHERE Tsd_TrEID IN (
               SELECT b.TrE_TrEId
                 FROM CDN.TraElem a
                 JOIN CDN.tranagrelacje ON TrR_TrNID = a.TrE_TrNID
                 JOIN CDN.TraElem b ON TrR_FaId = b.TrE_TrNID AND a.TrE_Lppow = b.TrE_LpPow WHERE a.TrE_TrEId = @Korekta
               UNION ALL
               SELECT TrE_TrEId FROM CDN.TraElem WHERE TrE_ZwrID in ( SELECT b.TrE_TrEId
                 FROM CDN.TraElem a
                 JOIN CDN.tranagrelacje ON TrR_TrNID = a.TrE_TrNID
                 JOIN CDN.TraElem b ON TrR_FaId = b.TrE_TrNID AND a.TrE_Lppow = b.TrE_LpPow WHERE a.TrE_TrEId =@Korekta
)) and tsd_zwrid is null  and TsD_PdEId = 0
union all
SELECT TsD_TrsIdDost, tsd_ilosc, tsd_zwrid as ID
         FROM CDN.TraSElemDost
      WHERE Tsd_TrEID IN (
               SELECT b.TrE_TrEId
                 FROM CDN.TraElem a
                 JOIN CDN.tranagrelacje ON TrR_TrNID = a.TrE_TrNID
                 JOIN CDN.TraElem b ON TrR_FaId = b.TrE_TrNID AND a.TrE_Lppow = b.TrE_LpPow WHERE a.TrE_TrEId = @Korekta
               UNION ALL
               SELECT TrE_TrEId FROM CDN.TraElem WHERE TrE_ZwrID in ( SELECT b.TrE_TrEId
                 FROM CDN.TraElem a
                 JOIN CDN.tranagrelacje ON TrR_TrNID = a.TrE_TrNID
                 JOIN CDN.TraElem b ON TrR_FaId = b.TrE_TrNID AND a.TrE_Lppow = b.TrE_LpPow WHERE a.TrE_TrEId =@Korekta
)) and tsd_zwrid is not null  and TsD_PdEId = 0) as y
GROUP BY y.ID,y.Tsd_TrsIdDost) AS z ON z.Tsd_TrsIdDost = TraSElemDost.Tsd_TrsIdDost
   WHERE a.TrE_TrEId = @Korekta and TraSElemDost.Tsd_Ilosc > 0
   GROUP BY z.ID ,TraSElemDost.Tsd_TrsIdDost, TsD_DataOpe
   ORDER BY TsD_DataOpe desc,TraSElemDost.Tsd_TrsIdDost desc
end
SET NOCOUNT OFF
